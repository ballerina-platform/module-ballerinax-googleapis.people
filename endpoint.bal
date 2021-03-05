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
import ballerina/io;

# Object for Google Contacts configuration.
#
# + oauthClientConfig - OAuth client configuration
# + secureSocketConfig - HTTP client configuration
public type GoogleContactsConfiguration record {
    http:OAuth2DirectTokenConfig oauthClientConfig;
    http:ClientSecureSocket secureSocketConfig?;
};

# Google Contacts Client.
#
# + googleContactClient - The HTTP Client
public client class Client {
    public http:Client googleContactClient;

    public function init(GoogleContactsConfiguration googleContactConfig) returns error? {
        http:ClientSecureSocket? socketConfig = googleContactConfig?.secureSocketConfig;
        self.googleContactClient = check new (BASE_URL, {
            auth: googleContactConfig.oauthClientConfig,
            secureSocket: socketConfig
        });
    }

    # Fetch all from "Other Contacts".
    # 
    # + readMasks - Restrict which fields on the person are returned
    # + return - `Person` Array on success else an `error`
    remote function listOtherContacts(string[] readMasks, ContactListOptions? options = ()) returns @tainted 
    stream<Person>|error {
        string path = LIST_OTHERCONTACT_PATH;
        http:Request request = new;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        Person[] persons = [];
        return getOtherContactsStream(self.googleContactClient, persons, pathWithReadMasks, options);
    }

    # copies an "Other contact" to a new contact in the user's "myContacts" group.
    # 
    # + copyMasks - Restrict which fields on the person are to be copied
    # + readMasks - Restrict which fields on the person are returned
    # + otherContacts - OtherContacts resource name
    # + return - `Person` on success else an `error`
    remote function copyOtherContactToMyContact(string[] copyMasks, string[] readMasks, string otherContacts) returns @tainted 
                                                Person|error {
        string path = SLASH + otherContacts + COPY_CONTACT_PATH;
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
        Person person = check response.cloneWithType(Person);
        return person;
    }

    # Search a "Other contacts"(contacts created automatically by emails and google+).
    # 
    # + query - String to be searched
    # + return - `SearchResponse` on success else an `error`
    remote function searchOtherContacts(string query) returns @tainted SearchResponse|error {
        string path = SEARCH_OTHERCONTACT_PATH + READ_MASK_PATH + QUERY_PATH + query;
        http:Request request = new;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path, request);
        json searchResponse = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode is http:STATUS_OK) {
            SearchResponse|error searchResult = searchResponse.cloneWithType(SearchResponse);
            if (searchResult is SearchResponse) {
                return searchResult;
            } else {
                return createError(SEARCH_ERROR);
            }
        } else {
            return createError(searchResponse.toString());
        }
    }

    # Create a contact.
    # 
    # + createContact - Record of type of `CreatePerson`
    # + personFields - Restrict which fields on the person are returnedy
    # + return - `Person` on success else an `error`
    remote function createContact(CreatePerson createContact, string[]? personFields = ()) returns 
                                   @tainted Person|error {
        string path = CREATE_CONTACT_PATH + QUESTION_MARK;
        json payload = check createContact.cloneWithType(json);
        http:Request request = new;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        request.setJsonPayload(payload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(pathWithPersonFields, request);
        var response = check handleResponse(httpResponse);
        Person person = check response.cloneWithType(Person);
        return person;
    }

    # Fetch a contact.
    # 
    # + resourceName - Calendar name
    # + personFields - Restrict which fields on the person are returned
    # + return - `Person` on success else an `error`
    remote function getContact(string resourceName, string[]? personFields = ()) returns 
                                @tainted Person|error {
        string path = SLASH + resourceName + QUESTION_MARK;
        http:Request request = new;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields, request);
        var response = check handleResponse(httpResponse);
        Person person = check response.cloneWithType(Person);
        return person;
    }

    # Search a `Person`.
    # 
    # + query - String to be searched
    # + return - `Person` on success else an `error`
    remote function searchPeople(string query) returns @tainted SearchResponse|error {
        string path = SLASH + SEARCH_CONTACT_PATH + READ_MASK_PATH + QUERY_PATH + query;
        http:Request request = new;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path, request);
        json searchResponse = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode is http:STATUS_OK) {
            SearchResponse|error searchResult = searchResponse.cloneWithType(SearchResponse);
            if (searchResult is SearchResponse) {
                return searchResult;
            } else {
                return createError(SEARCH_ERROR);
            }
        } else {
            return createError(searchResponse.toString());
        }
    }

    # Update contact photo for a contact.
    # 
    # + resourceName - Contact resource name
    # + imagePath - Path to image from root directory
    # + return - () on success, else an 'error'
    remote function updateContactPhoto(string resourceName, string imagePath) returns 
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
    remote function deleteContactPhoto(string resourceName) returns @tainted error? {
        string path = SLASH + resourceName + COLON + DELETE_PHOTO_PATH;
        http:Response deleteResponse = <http:Response>check self.googleContactClient->delete(path);
        return handleDeleteResponse(deleteResponse);
    }

    # Batch get contacts.
    # 
    # + resourceNames - String array of contact resource names
    # + personFields - Restrict which fields on the person are returned
    # + return - `BatchGetResponse` on success, else an `error`
    remote function batchGetContacts(string[] resourceNames, string[] personFields) returns 
                                      @tainted BatchGetResponse|error {
        string path = SLASH + BATCH_CONTACT_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        string pathWithPersonFields = prepareUrlWithPersonFields(pathWithResources + AMBERSAND, personFields);
        http:Request request = new;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields, request);
        var response = check handleResponse(httpResponse);
        BatchGetResponse batchResult = check response.cloneWithType(BatchGetResponse);
        return batchResult;
    }

    # Delete a Contact.
    # 
    # + resourceName - Contact resource name
    # + return - () on success, else an `error`
    remote function deleteContact(string resourceName) returns @tainted error? {
        string path = SLASH + resourceName + COLON + DELETE_CONTACT_PATH;
        http:Response deleteResponse = <http:Response>check self.googleContactClient->delete(path);
        return handleDeleteResponse(deleteResponse);
    }

    // Only Authenticated user's contacts can be obtained
    # Get connections
    # 
    # + personFields - Restrict which fields on the person are returned
    # + options - Record that contains options
    # + return - `stream<Person>` on success or else an `error`
    remote function listPeopleConnection(string[] personFields, ContactListOptions? options = ()) returns 
                                          @tainted stream<Person>|error {
        string path = SLASH + LIST_PEOPLE_PATH;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        io:println(pathWithPersonFields);
        Person[] persons = [];
        return getContactsStream(self.googleContactClient, persons, pathWithPersonFields, options);
    }

    # Create a `ContactGroup`.
    # 
    # + contactGroupName - Name of the `ContactGroup` to be created
    # + readGroupFields - Restrict which fields are returned(clientData, groupType, metadata, name)
    # + return - `ContactGroup` on success else an `error`
    remote function createContactGroup(string contactGroupName, string[] readGroupFields) returns 
                                        @tainted ContactGroup|error {
        string path = SLASH + CONTACT_GROUP_PATH;
        http:Request request = new;
        string readGroupField = prepareReadGroupFieldsString(readGroupFields);
        json createContactJsonPayload = {
            "contactGroup": {"name": contactGroupName},
            "readGroupFields": readGroupField
        };
        request.setJsonPayload(createContactJsonPayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(path, request);
        var response = check handleResponse(httpResponse);
        ContactGroup contactGroup = check response.cloneWithType(ContactGroup);
        return contactGroup;

    }

    # Batch get contact groups.
    # 
    # + resourceNames - Name of the `ContactGroup` to be fetched
    # + return - `ContactGroup` on success else an `error`
    remote function batchGetContactGroup(string[] resourceNames) returns @tainted ContactGroupBatch|error {
        string path = SLASH + CONTACT_GROUP_PATH + BATCH_CONTACT_GROUP_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithResources);
        var response = check handleResponse(httpResponse);
        ContactGroupBatch contactGroupBatch = check response.cloneWithType(ContactGroupBatch);
        return contactGroupBatch;
    }

    # Fetch `ContactGroups` of authenticated user.
    # 
    # + return - `ContactGroup[]` on success else an `error`
    remote function listContactGroup() returns @tainted ContactGroup[]|error {
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
    # + return - `ContactGroup` on success else an `error`
    remote function getContactGroup(string resourceName) returns @tainted ContactGroup|error {
        var path = SLASH + resourceName;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path);
        var response = check handleResponse(httpResponse);
        ContactGroup contactGroup = check response.cloneWithType(ContactGroup);
        return contactGroup;
    }

    # Update a `ContactGroup`.
    # 
    # + resourceName - Name of the `ContactGroup` to be created
    # + contactGroupPayload - Update payload
    # + return - `ContactGroup` on success else an `error`
    remote function updateContactGroup(string resourceName, json contactGroupPayload) returns                             
                                        @tainted ContactGroup|error {
        string path = SLASH + resourceName;
        http:Request request = new;
        json payload = check contactGroupPayload.cloneWithType(json);
        json newpayload = {"contactGroup": payload};
        request.setJsonPayload(newpayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->put(path, request);
        var response = check handleResponse(httpResponse);
        ContactGroup contactGroup = check response.cloneWithType(ContactGroup);
        return contactGroup;
    }

    # Delete a Contact Group.
    # 
    # + resourceName - Contact Group resource name
    # + return - () on success, else an `error`
    remote function deleteContactGroup(string resourceName) returns @tainted error? {
        string path = SLASH + resourceName;
        http:Response deleteResponse = <http:Response>check self.googleContactClient->delete(path);
        return handleDeleteResponse(deleteResponse);
    }
}
