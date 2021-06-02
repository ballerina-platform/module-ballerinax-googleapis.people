// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

# Google Contacts configuration.
#
# + oauth2Config - OAuth client configuration
# + secureSocketConfig - HTTP client configuration
public type GoogleContactsConfiguration record {
    http:BearerTokenConfig | http:OAuth2RefreshTokenGrantConfig oauth2Config;
    http:ClientSecureSocket secureSocketConfig?;
};

# Google Contacts Client.
#
# + googleContactClient - Connector http endpoint
@display {label: "Google People API", iconPath: "GooglePeopleLogo.png"}
public client class Client {
    public http:Client googleContactClient;

    public isolated function init(GoogleContactsConfiguration googleContactConfig) returns error? {
        http:ClientSecureSocket? socketConfig = googleContactConfig?.secureSocketConfig;
        self.googleContactClient = check new (BASE_URL, {
            auth: googleContactConfig.oauth2Config,
            secureSocket: socketConfig
        });
    }

    # Fetch all from Other Contacts.
    # 
    # + readMasks - Restrict which fields on the person are returned
    # + options - Record that contains options
    # + return - Stream of `PersonResponse` on success else an `error`
    @display {label: "List OtherContacts"}
    isolated remote function listOtherContacts(@display {label: "Read Masks"} OtherContactFieldMask[] readMasks, 
                                      @display {label: "List options (Page token and sync token)"} ContactListOptions? options = ()) 
                                      returns @tainted @display {label: "PersonResponses list"} stream<PersonResponse>|error {
        string path = LIST_OTHERCONTACT_PATH;
        http:Request request = new;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        PersonResponse[] persons = [];
        return getOtherContactsStream(self.googleContactClient, persons, pathWithReadMasks, options);
    }

    # Create a contact.
    # 
    # + person - Record of type of `CreatePerson`
    # + personFields - Restrict which fields on the person are returned
    # + return - `PersonResponse` on success else an `error`
    @display {label: "Create Contact"}
    isolated remote function createContact(@display {label: "Contact details"} Person person, 
                                  @display {label: "Person Fields"} FieldMask[] personFields) returns 
                                  @tainted @display {label: "PersonResponse"} PersonResponse|error {
        string path = CREATE_CONTACT_PATH + QUESTION_MARK;
        json payload = check person.cloneWithType(json);
        http:Request request = new;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        request.setJsonPayload(payload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(pathWithPersonFields, request);
        var response = check handleResponse(httpResponse);
        return check response.cloneWithType(PersonResponse);
    }

    # Fetch a contact.
    # 
    # + resourceName - Contact resource name
    # + personFields - Restrict which fields on the person are returned
    # + return - `PersonResponse` on success else an `error`
    @display {label: "Get a Contact"}
    isolated remote function getContact(@display {label: "Contact Resource Name"} string resourceName, 
                               @display {label: "Person Fields"} FieldMask[] personFields) returns 
                               @tainted @display {label: "PersonResponse"} PersonResponse|error {
        string path = SLASH + resourceName + QUESTION_MARK;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields);
        var response = check handleResponse(httpResponse);
        return check response.cloneWithType(PersonResponse);
    }

    # Search a contacts.
    # 
    # + query - String to be searched
    # + readMasks - Restrict which fields on the person are returned
    # + return - `PersonResponse[]` on success else an `error`
    @display {label: "Search a Contact"}
    isolated remote function searchContacts(@display {label: "Searchable substring"} string query,
                                 @display {label: "Read Masks"} FieldMask[] readMasks) returns 
                                 @tainted @display {label: "PersonResponse Array"} PersonResponse[]|error {
        string path = SLASH + SEARCH_CONTACT_PATH + QUESTION_MARK;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        string pathWithQuery = pathWithReadMasks + QUERY_PATH + query;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithQuery);
        var response = check handleResponseWithNull(httpResponse);
        var searchResponse = check response.cloneWithType(SearchResponse);
        PersonResponse[] persons = [];
        int i = persons.length();
        foreach var result in searchResponse.results {
            var personResult = result.person;
            if(personResult is json) {
                persons[i] = check personResult.cloneWithType(PersonResponse);
                i = i + 1;
            }
        }
        return persons;
    }

    # Update contact photo for a contact.
    # 
    # + resourceName - Contact resource name
    # + imagePath - Path to image from root directory
    # + return - () on success, else an 'error'
    @display {label: "Update a Contact Photo"}
    isolated remote function updateContactPhoto(@display {label: "Contact Resource Name"} string resourceName,
                                       @display {label: "Image Path"} string imagePath) returns 
                                       @tainted error? {
        string path = SLASH + resourceName + COLON + UPDATE_PHOTO_PATH;
        http:Request request = new;
        string encodedString = check convertImageToBase64String(imagePath);
        json updatePayload = {"photoBytes": encodedString};
        request.setJsonPayload(<@untainted>updatePayload);
        http:Response uploadResponse = <http:Response>check self.googleContactClient->patch(path, request);
        return handleUploadPhotoResponse(uploadResponse);
    }

    # Delete a contact photo.
    # 
    # + resourceName - Contact resource name
    # + return - () on success, else an 'error'
    @display {label: "Delete a Contact Photo"}
    isolated remote function deleteContactPhoto(@display {label: "Contact Resource Name"} string resourceName) returns 
                                       @tainted error? {
        string path = SLASH + resourceName + COLON + DELETE_PHOTO_PATH;
        http:Response deleteResponse = <http:Response>check self.googleContactClient->delete(path);
        return handleDeleteResponse(deleteResponse);
    }

    # Get Batch contacts.
    # 
    # + resourceNames - String array of contact resource names
    # + personFields - Restrict which fields on the person are returned
    # + return - `PersonResponse[]` on success, else an `error`
    @display {label: "Get Batch Contacts"}   
    isolated remote function getBatchContacts(@display {label: "Contact Resource Names"} string[] resourceNames, 
                                     @display {label: "Person Fields"} FieldMask[] personFields) returns 
                                     @tainted @display {label: "PersonResponse Array"} PersonResponse[]|error {
        string path = SLASH + BATCH_CONTACT_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        string pathWithPersonFields = prepareUrlWithPersonFields(pathWithResources + AMBERSAND, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields);
        var response = check handleResponse(httpResponse);
        var batchResponse = check response.cloneWithType(BatchGetResponse);
        PersonResponse[] persons = [];
        int i = persons.length();
        foreach var result in batchResponse.responses {
            var personResult = result.person;
            if(personResult is json) {
                persons[i] = check personResult.cloneWithType(PersonResponse);
                i = i + 1;
            }
        }
        return persons;
    }

    # Update a contact.
    # 
    # + resourceName - Contact resource name
    # + person - Person record
    # + updatePersonFields - Restrict which fields on the person are returned
    # + personFields - Restrict which fields on the person are returned
    # + return - `Person` on success else an `error`
    @display {label: "Update a Contact"}  
    isolated remote function updateContact(@display {label: "Contact Resource Name"} string resourceName, 
                                  @display {label: "Contact details"} Person person, 
                                  @display {label: "Person Fields to be updated"} FieldMask[] updatePersonFields,
                                  @display {label: "Person Fields to be returned"} FieldMask[]? personFields = ()) returns 
                                  @tainted @display {label: "PersonResponse"} PersonResponse|error {
        string getPath = SLASH + resourceName + QUESTION_MARK;
        string getPathWithPersonFields = prepareUrlWithPersonFields(getPath, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(getPathWithPersonFields);
        var getResponse = check handleResponse(httpResponse);
        var getContact = getResponse.cloneWithType(PersonResponse);
        if (getContact is PersonResponse) {
            string path = SLASH + resourceName + ":updateContact" + QUESTION_MARK;
            string pathWithUpdatePersonFields = prepareUrlWithUpdatePersonFields(path, updatePersonFields);
            string pathWithFields = pathWithUpdatePersonFields + AMBERSAND;
            http:Request request = new;
            string pathWithPersonFields = prepareUrlWithPersonFields(pathWithFields, personFields);
            Person updatedContact = prepareUpdate(person, getContact);
            json payload = check getContact.cloneWithType(json);
            request.setJsonPayload(<@untainted>payload);
            http:Response updateResponse = <http:Response>check self.googleContactClient->patch(pathWithPersonFields, request);
            var response = check handleResponse(updateResponse);
            return check response.cloneWithType(PersonResponse);
        } else {
            return error(getContact.toString());
        }
    }

    # Delete a Contact.
    # 
    # + resourceName - Contact resource name
    # + return - () on success, else an `error`
    @display {label: "Delete a Contact"}
    isolated remote function deleteContact(@display {label: "Person Resource Name"} string resourceName) returns 
                                  @tainted error? {
        string path = SLASH + resourceName + COLON + DELETE_CONTACT_PATH;
        http:Response deleteResponse = <http:Response>check self.googleContactClient->delete(path);
        return handleDeleteResponse(deleteResponse);
    }

    // Only Authenticated user's contacts can be obtained
    # Get Peoples
    # 
    # + personFields - Restrict which fields on the person are returned
    # + options - Record that contains options
    # + return - `stream<PersonResponse>` on success or else an `error`
    @display {label: "List Contacts"}
    isolated remote function listContacts(@display {label: "Person Fields"} FieldMask[] personFields, 
                                @display {label: "List options (Page token and sync token)"} ContactListOptions? options = ()) returns
                                @tainted @display {label: "Stream of PersonResponses"} stream<PersonResponse>|error {
        string path = SLASH + LIST_PEOPLE_PATH;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        PersonResponse[] persons = [];
        return getContactsStream(self.googleContactClient, persons, pathWithPersonFields, options);
    }

    # Create a `ContactGroup`.
    # 
    # + contactGroupName - Name of the `ContactGroup` to be created
    # + return - `ContactGroup` on success else an `error`
    @display {label: "Create a Contact Group"}
    isolated remote function createContactGroup(@display {label: "Contact Group Resource Name"} string contactGroupName) returns 
                                       @tainted @display {label: "Contact Group"} ContactGroup|error {
        string path = SLASH + CONTACT_GROUP_PATH;
        http:Request request = new;
        json createContactJsonPayload = {
            "contactGroup": {"name": contactGroupName},
            "readGroupFields": ""
        };
        request.setJsonPayload(createContactJsonPayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(path, request);
        var response = check handleResponse(httpResponse);
        return check response.cloneWithType(ContactGroup);
    }

    # Get Batch contact groups.
    # 
    # + resourceNames - Name of the `ContactGroup` to be fetched
    # + return - `ContactGroup[]` on success else an `error`
    @display {label: "Get Batch Contact Groups"}   
    isolated remote function getBatchContactGroup(@display {label: "Resource Names"} string[] resourceNames) returns 
                                         @tainted @display {label: "Contact Group Array"} ContactGroup[]|error {
        string path = SLASH + CONTACT_GROUP_PATH + BATCH_CONTACT_GROUP_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithResources);
        var response = check handleResponse(httpResponse);
        var batchResponse = check response.cloneWithType(ContactGroupBatch);
        ContactGroup[] contactGroups = [];
        int i = contactGroups.length();
        foreach var result in batchResponse.responses {
            var contactGroupResult = result.contactGroup;
            if(contactGroupResult is json) {
                contactGroups[i] = check contactGroupResult.cloneWithType(ContactGroup);
                i = i + 1;
            }
        }
        return contactGroups;
    }

    # Fetch `Contact Groups` of authenticated user.
    # 
    # + return - `ContactGroup[]` on success else an `error`
    @display {label: "List Contact Groups"}
    isolated remote function listContactGroup() returns @tainted @display {label: "Contact Group Array"} ContactGroup[]|error {
        string path = SLASH + CONTACT_GROUP_PATH;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path);
        var response = check handleResponse(httpResponse);
        ContactGroupList contactGroupList = check response.cloneWithType(ContactGroupList);
        ContactGroup[] contactGroupArray = contactGroupList.contactGroups;
        return contactGroupArray;
    }

    # Fetch a `Contact Group`.
    # 
    # + resourceName - Name of the `ContactGroup` to be created
    # + maxMembers - maximum number of members returned in contact group
    # + return - `ContactGroup` on success else an `error`
    @display {label: "Get a Contact Group"}
    isolated remote function getContactGroup(@display {label: "Contact Group Resource Name"} string resourceName,
                                    @display {label: "Maximum members"} int maxMembers) returns 
                                    @tainted @display {label: "Contact Group"} ContactGroup|error {
        string path = SLASH + resourceName;
        string pathWithParameter = prepareUrlWithStringParameter(path, maxMembers.toString());
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path);
        var response = check handleResponse(httpResponse);
        return response.cloneWithType(ContactGroup);
    }

    # Update a `Contact Group`.
    # 
    # + resourceName - Name of the `ContactGroup` to be created
    # + updateName - Name to be updated
    # + return - `ContactGroup` on success else an `error`
    @display {label: "Update a Contact Group"}
    isolated remote function updateContactGroup(@display {label: "Contact Group Resource Name"} string resourceName,
                                       @display {label: "Name to be Updated"} string updateName) returns                          
                                       @tainted @display {label: "Contact Group"} ContactGroup|error {
        string path = SLASH + resourceName;
        http:Request request = new;
        string getpath = SLASH + resourceName;
        http:Response gethttpResponse = <http:Response>check self.googleContactClient->get(getpath);
        var getResponse = check handleResponse(gethttpResponse);
        var getContactGroup = getResponse.cloneWithType(ContactGroup);
        if (getContactGroup is ContactGroup) {
            getContactGroup.name = updateName;
            json payload = check getContactGroup.cloneWithType(json);
            json newpayload = {"contactGroup": payload};
            request.setJsonPayload(<@untainted>newpayload);
            http:Response httpResponse = <http:Response>check self.googleContactClient->put(path, request);
            var response = check handleResponse(httpResponse);
            return check response.cloneWithType(ContactGroup);
        } else {
            return error(getContactGroup.toString());
        }
    }

    # Delete a 'Contact Group'.
    # 
    # + resourceName - Contact Group resource name
    # + return - () on success, else an `error`
    @display {label: "Delete a Contact Group"}
    isolated remote function deleteContactGroup(@display {label: "Contact Group Resource Name"} string resourceName) returns 
                                       @tainted error? {
        string path = SLASH + resourceName;
        http:Response deleteResponse = <http:Response>check self.googleContactClient->delete(path);
        return handleDeleteResponse(deleteResponse);
    }

    # Modify a contacts in Contact Group.
    # 
    # + contactGroupResourceName - Contact Group resource name
    # + resourceNameToAdd - Contact resource name to add
    # + resourceNameToRemove - Contact resource name to remove
    # + return - () on success, else an `error`
    @display {label: "Modify contacts in Contact Group"}
    isolated remote function modifyContactGroup(string contactGroupResourceName, string[]? resourceNameToAdd = (), string[]? resourceNameToRemove = ()) returns 
                                       @tainted error? {
        string path = SLASH + contactGroupResourceName + "/members:modify";
        http:Request request = new;
        json payload =  {
                            "resourceNamesToAdd": resourceNameToAdd,
                            "resourceNamesToRemove": resourceNameToRemove
                        };
        request.setJsonPayload(payload);
        http:Response response = <http:Response>check self.googleContactClient->post(path, request);
        return handleModifyResponse(response);
    }    
}
