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

# Object for Google Contacts configuration.
#
# + oauth2Config - OAuth client configuration
# + secureSocketConfig - HTTP client configuration
public type GoogleContactsConfiguration record {
    http:OAuth2RefreshTokenGrantConfig oauth2Config;
    http:ClientSecureSocket secureSocketConfig?;
};

# Google Contacts Client.
#
# + googleContactClient - The HTTP Client
@display {label: "Google People API Client", iconPath: "GooglePeopleLogo.png"}
public client class Client {
    public http:Client googleContactClient;

    public isolated function init(GoogleContactsConfiguration googleContactConfig) returns error? {
        http:ClientSecureSocket? socketConfig = googleContactConfig?.secureSocketConfig;
        self.googleContactClient = check new (BASE_URL, {
            auth: googleContactConfig.oauth2Config,
            secureSocket: socketConfig
        });
    }

    # Fetch all from "Other Contacts".
    # 
    # + readMasks - Restrict which fields on the person are returned
    # + return - Stream of `Person` on success else an `error`
    @display {label: "List OtherContacts"}
    isolated remote function listOtherContacts(@display {label: "Read Masks"} OtherContactMasks[] readMasks, 
                                      @display {label: "Optional query parameters"} ContactListOptions? options = ()) 
                                      returns @tainted @display {label: "Stream of Persons"} stream<Person>|error {
        string path = LIST_OTHERCONTACT_PATH;
        http:Request request = new;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        Person[] persons = [];
        return getOtherContactsStream(self.googleContactClient, persons, pathWithReadMasks, options);
    }

    # Copies "Other contact" to a new contact in the user's "myContacts".
    # 
    # + copyMasks - Restrict which fields on the person are to be copied
    # + readMasks - Restrict which fields on the person are returned
    # + resourceName - OtherContacts resource name
    # + return - `Person` on success else an `error`
    @display {label: "Copy a OtherContact to MyContact"}
    isolated remote function copyOtherContactToMyContact(@display {label: "OtherContact Resource Name"} string resourceName,
                                                @display {label: "Copy Masks"} OtherContactMasks[] copyMasks, 
                                                @display {label: "Read Masks"} ContactMasks[]? readMasks = ()) 
                                                returns @tainted @display {label: "Person"} Person|error {
        string path = SLASH + resourceName + COPY_CONTACT_PATH;
        http:Request request = new;
        string copyMask = prepareCopyMaskString(copyMasks);
        string readMask = prepareReadMaskString(readMasks);
        json copyPayload = {
            "copyMask": copyMask,
            "readMask": readMask
        };
        request.setJsonPayload(copyPayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(path, request);
        var response = check handleResponse(httpResponse);
        return check response.cloneWithType(Person);
    }

    # Search a "Other contacts"(contacts created automatically by emails and google+).
    # 
    # + query - String to be searched
    # + return - `Person[]` on success else an `error`
    @display {label: "Search in OtherContacts"}
    isolated remote function searchOtherContacts(@display {label: "Searchable substring"} string query,
                                        @display {label: "Read Masks"} OtherContactMasks[] readMasks) returns 
                                        @tainted @display {label: "Array of Person"} Person[]|error {
        string path = SEARCH_OTHERCONTACT_PATH + QUESTION_MARK;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        string pathWithQuery = pathWithReadMasks + QUERY_PATH + query;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithQuery);
        var response = check handleResponseWithNull(httpResponse);
        var searchResponse = check response.cloneWithType(SearchResponse);
        Person[] persons = [];
        int i = persons.length();
        foreach var result in searchResponse.results {
            var personResult = result.person;
            if(personResult is json) {
                persons[i] = check personResult.cloneWithType(Person);
                i = i + 1;
            }
        }
        return persons;
    }

    # Create a contact.
    # 
    # + createContact - Record of type of `CreatePerson`
    # + personFields - Restrict which fields on the person are returned
    # + return - `Person` on success else an `error`
    @display {label: "Create Contact"}
    isolated remote function createContact(@display {label: "Contact details"} CreatePerson createContact, 
                                  @display {label: "Person Fields"} ContactMasks[]? personFields = ()) returns 
                                  @tainted @display {label: "Person"} Person|error {
        string path = CREATE_CONTACT_PATH + QUESTION_MARK;
        json payload = check createContact.cloneWithType(json);
        http:Request request = new;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        request.setJsonPayload(payload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(pathWithPersonFields, request);
        var response = check handleResponse(httpResponse);
        return check response.cloneWithType(Person);
    }

    # Fetch a contact.
    # 
    # + resourceName - Contact resource name
    # + personFields - Restrict which fields on the person are returned
    # + return - `Person` on success else an `error`
    @display {label: "Get a Contact"}
    isolated remote function getContact(@display {label: "Contact Resource Name"} string resourceName, 
                               @display {label: "Person Fields"} ContactMasks[] personFields) returns 
                               @tainted @display {label: "Person"} Person|error {
        string path = SLASH + resourceName + QUESTION_MARK;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields);
        var response = check handleResponse(httpResponse);
        return check response.cloneWithType(Person);
    }

    # Search a contacts.
    # 
    # + query - String to be searched
    # + return - `Person[]` on success else an `error`
    @display {label: "Search a Contact"}
    isolated remote function searchPeople(@display {label: "Searchable substring"} string query,
                                 @display {label: "Read Masks"} ContactMasks[] readMasks) returns 
                                 @tainted @display {label: "Array of Person"} Person[]|error {
        string path = SLASH + SEARCH_CONTACT_PATH + QUESTION_MARK;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        string pathWithQuery = pathWithReadMasks + QUERY_PATH + query;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithQuery);
        var response = check handleResponse(httpResponse);
        var searchResponse = check response.cloneWithType(SearchResponse);
        Person[] persons = [];
        int i = persons.length();
        foreach var result in searchResponse.results {
            var personResult = result.person;
            if(personResult is json) {
                persons[i] = check personResult.cloneWithType(Person);
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
        request.setJsonPayload(updatePayload);
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

    # Batch get contacts.
    # 
    # + resourceNames - String array of contact resource names
    # + personFields - Restrict which fields on the person are returned
    # + return - `Person[]` on success, else an `error`
    @display {label: "Batch Get Contacts"}   
    isolated remote function batchGetContacts(@display {label: "Contact Resource Names"} string[] resourceNames, 
                                     @display {label: "Person Fields"} ContactMasks[] personFields) returns 
                                     @tainted @display {label: "Array of Person"} Person[]|error {
        string path = SLASH + BATCH_CONTACT_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        string pathWithPersonFields = prepareUrlWithPersonFields(pathWithResources + AMBERSAND, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields);
        var response = check handleResponse(httpResponse);
        var batchResponse = check response.cloneWithType(BatchGetResponse);
        Person[] persons = [];
        int i = persons.length();
        foreach var result in batchResponse.responses {
            var personResult = result.person;
            if(personResult is json) {
                persons[i] = check personResult.cloneWithType(Person);
                i = i + 1;
            }
        }
        return persons;
    }

    # Update a contact.
    # 
    # + resourceName - Contact resource name
    # + updatePersonFields - Restrict which fields on the person are returned
    # + personFields - Restrict which fields on the person are returned
    # + return - `Person` on success else an `error`
    @display {label: "Update a Contact"}  
    isolated remote function updateContact(@display {label: "Contact Resource Name"} string resourceName, 
                                  @display {label: "Contact details"} CreatePerson createContact, 
                                  @display {label: "Person Fields to be Updated"} ContactMasks[] updatePersonFields,
                                  @display {label: "Person Fields"} ContactMasks[]? personFields = ()) returns 
                                  @tainted @display {label: "Person"} Person|error {
        string getPath = SLASH + resourceName + QUESTION_MARK;
        string getPathWithPersonFields = prepareUrlWithPersonFields(getPath, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(getPathWithPersonFields);
        var getResponse = check handleResponse(httpResponse);
        var getContact = getResponse.cloneWithType(Person);
        if (getContact is Person) {
            string path = SLASH + resourceName + ":updateContact" + QUESTION_MARK;
            string pathWithUpdatePersonFields = prepareUrlWithUpdatePersonFields(path, updatePersonFields);
            string pathWithFields = pathWithUpdatePersonFields + AMBERSAND;
            http:Request request = new;
            string pathWithPersonFields = prepareUrlWithPersonFields(pathWithFields, personFields);
            var names = createContact?.names;
            if(names is Name[]){
                getContact.names = names;
            }
            var emailAddresses = createContact?.emailAddresses;
            if(emailAddresses is EmailAddress[]){
                getContact.emailAddresses = emailAddresses;
            }
            json payload = check getContact.cloneWithType(json);
            request.setJsonPayload(payload);
            http:Response updateResponse = <http:Response>check self.googleContactClient->patch(pathWithPersonFields, request);
            var response = check handleResponse(updateResponse);
            return check response.cloneWithType(Person);
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
    # + return - `stream<Person>` on success or else an `error`
    @display {label: "List Contacts"}
    isolated remote function listPeoples(@display {label: "Person Fields"} ContactMasks[] personFields, 
                                @display {label: "Optional query parameters"} ContactListOptions? options = ()) returns
                                @tainted @display {label: "Stream of Persons"} stream<Person>|error {
        string path = SLASH + LIST_PEOPLE_PATH;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        Person[] persons = [];
        return getContactsStream(self.googleContactClient, persons, pathWithPersonFields, options);
    }

    isolated remote function getListContactsResponse(ContactMasks[]? personFields = (), string? token = ())
                                        returns @tainted SyncConnectionsResponse|error {
        if(token is string){
            string path = LIST_CONTACTS;
            string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
            string finalPath = pathWithPersonFields + "&requestSyncToken=true&syncToken="+token;
            http:Response httpResponse = <http:Response>check self.googleContactClient->get(finalPath);
            var response = check handleResponse(httpResponse);
            return check response.cloneWithType(SyncConnectionsResponse);
        } else {
            string path = LIST_CONTACTS;
            string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
            string finalPath = pathWithPersonFields + "&requestSyncToken=true";
            http:Response httpResponse = <http:Response>check self.googleContactClient->get(finalPath);
            var response = check handleResponse(httpResponse);
            return check response.cloneWithType(SyncConnectionsResponse);
        }
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

    # Batch get contact groups.
    # 
    # + resourceNames - Name of the `ContactGroup` to be fetched
    # + return - `ContactGroup[]` on success else an `error`
    @display {label: "Batch Get Contact Groups"}   
    isolated remote function batchGetContactGroup(@display {label: "Resource Names"} string[] resourceNames) returns 
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

    # Fetch `ContactGroups` of authenticated user.
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

    # Fetch a `ContactGroup`.
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

    # Update a `ContactGroup`.
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
            request.setJsonPayload(newpayload);
            http:Response httpResponse = <http:Response>check self.googleContactClient->put(path, request);
            var response = check handleResponse(httpResponse);
            return check response.cloneWithType(ContactGroup);
        } else {
            return error(getContactGroup.toString());
        }
    }

    # Delete a Contact Group.
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
    # + return - json on success, else an `error`
    @display {label: "Modify contacts in a Contact Group"}
    isolated remote function modifyContactGroup(string contactGroupResourceName, string[]? resourceNameToAdd = (), string[]? resourceNameToRemove = ()) returns 
                                       @tainted json|error {
        string path = SLASH + contactGroupResourceName + "/members:modify";
        http:Request request = new;
        json payload =  {
                            "resourceNamesToAdd": resourceNameToAdd,
                            "resourceNamesToRemove": resourceNameToRemove
                        };
        request.setJsonPayload(payload);
        http:Response response = <http:Response>check self.googleContactClient->post(path, request);
        return handleResponse(response);
    }    
}
