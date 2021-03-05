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
# + oauthClientConfig - OAuth client configuration.
# + secureSocketConfig - HTTP client configuration.
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

    # Fetch all from OtherContact
    # 
    # + readMasks - Restrict which fields on the person are returned
    # + return - Person Array on success else an error
    remote function listOtherContacts(string[] readMasks, ContactListOptions? options = ()) returns @tainted 
    stream<Person>|error {
        string path = LIST_OTHERCONTACT_PATH;
        http:Request request = new;
        string pathWithReadMasks = prepareUrlWithReadMasks(path, readMasks);
        Person[] persons = [];
        return getOtherContactsStream(self.googleContactClient, persons, pathWithReadMasks, options);
    }

    # Copy a Contact from OtherContact to MyContact.
    # 
    # + copyMasks - Restrict which fields on the person are to be copied
    # + readMasks - Restrict which fields on the person are returned
    # + otherContacts - OtherContacts resource name
    # + return - Person on success else an error
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
        json copyResponse = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode == http:STATUS_OK) {
            Person person = check copyResponse.cloneWithType(Person);
            return person;
        } else {
            return createError(copyResponse.toString());
        }
    }

    # Search a OtherContacts.
    # 
    # + query - String to be searched
    # + return - SearchResponse on success else an error
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

    # Create a Contact.
    # 
    # + createContact - Record of type of CreatePerson
    # + personFields - Restrict which fields on the person are returned
    # + sources - A mask of what source types to return
    # + return - Created Person on success else an error
    remote function createContact(CreatePerson createContact, string[] personFields, string[]? sources = ()) returns @tainted 
    Person|error {
        string path = CREATE_CONTACT_PATH + PERSON_FIELDS;
        json payload = check createContact.cloneWithType(json);
        http:Request request = new;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        string pathWithOptionalSources = prepareUrlWithOptionalSources(pathWithPersonFields, sources);
        request.setJsonPayload(payload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(pathWithOptionalSources, 
        request);
        json createPerson = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode == http:STATUS_OK) {
            Person person = check createPerson.cloneWithType(Person);
            return person;
        } else {
            return createError(createPerson.toString());
        }
    }

    # Fetch a Person.
    # 
    # + resourceName - Calendar name
    # + personFields - Restrict which fields on the person are returned
    # + sources - A mask of what source types to return
    # + return - Person on success else an error
    remote function getPeople(string resourceName, string[] personFields, string[]? sources = ()) returns @tainted 
    Person|error {
        string path = SLASH + resourceName + PERSON_FIELDS;
        http:Request request = new;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        string pathWithOptionalSources = prepareUrlWithOptionalSources(pathWithPersonFields, sources);
        http:Response httpResponse = 
        <http:Response>check self.googleContactClient->get(pathWithOptionalSources, request);
        json getPeopleResponse = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode is http:STATUS_OK) {
            Person person = check getPeopleResponse.cloneWithType(Person);
            return person;
        } else {
            return createError(getPeopleResponse.toString());
        }
    }

    # Search a Person.
    # 
    # + query - String to be searched
    # + return - Person on success else an error
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

    # Update a Contact Photo.
    # 
    # + resourceName - Contact resource name
    # + imagePath - Path to image from root directory
    # + return - True on success, else an error
    remote function updateContactPhoto(string resourceName, string imagePath) returns @tainted boolean|error {
        string path = SLASH + resourceName + UPDATE_PHOTO_PATH;
        http:Request request = new;
        string encodedString = check convertImageToBase64String(imagePath);
        json updatePayload = {"photoBytes": encodedString};
        request.setJsonPayload(updatePayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->patch(path, request);
        if (httpResponse.statusCode is http:STATUS_OK) {
            return true;
        } else {
            json updateResponse = check httpResponse.getJsonPayload();
            return createError(updateResponse.toString());
        }
    }

    # Delete a Contact Photo.
    # 
    # + resourceName - Contact resource name
    # + return - True on success, else an error
    remote function deleteContactPhoto(string resourceName) returns @tainted boolean|error {
        string path = SLASH + resourceName + DELETE_PHOTO_PATH;
        http:Request request = new;
        http:Response httpResponse = <http:Response>check self.googleContactClient->delete(path, request);
        string statusCode = httpResponse.statusCode.toString();
        if (httpResponse.statusCode is http:STATUS_OK) {
            return true;
        } else {
            json deleteResponse = check httpResponse.getJsonPayload();
            return createError(deleteResponse.toString());
        }
    }

    # Batch get Contacts.
    # 
    # + resourceNames - String array of Contact resource name
    # + personFields - Restrict which fields on the person are returned
    # + return - BatchGetResponse on success, else an error
    remote function batchGetPeople(string[] resourceNames, string[] personFields) returns @tainted BatchGetResponse|error {
        string path = SLASH + BATCH_CONTACT_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        http:Request request = new;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithPersonFields, request);
        json getPeopleResponse = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode is http:STATUS_OK) {
            BatchGetResponse|error batchResult = getPeopleResponse.cloneWithType(BatchGetResponse);
            if (batchResult is BatchGetResponse) {
                return batchResult;
            } else {
                return createError(CONNECTION_RESPONSE_ERROR);
            }
        } else {
            return createError(getPeopleResponse.toString());
        }
    }

    # Delete a Contact.
    # 
    # + resourceName - Contact resource name
    # + return - True on success, else an error
    remote function deleteContact(string resourceName) returns @tainted boolean|error {
        string path = SLASH + resourceName + DELETE_CONTACT_PATH;
        http:Request request = new;
        http:Response httpResponse = <http:Response>check self.googleContactClient->delete(path, request);
        if (httpResponse.statusCode is http:STATUS_OK) {
            return true;
        } else {
            json deleteContactResponse = check httpResponse.getJsonPayload();
            return createError(deleteContactResponse.toString());
        }
    }

    // Only Authenticated user's contacts can be obtained
    # Get Connections
    # 
    # + personFields - Restrict which fields on the person are returned
    # + options - Record that contains options
    # + return - Stream of Person on success or else an error
    remote function listPeopleConnection(string[] personFields, ContactListOptions? options = ()) returns @tainted 
    stream<Person>|error {
        string path = SLASH + LIST_PEOPLE_PATH;
        string pathWithPersonFields = prepareUrlWithPersonFields(path, personFields);
        Person[] persons = [];
        return getContactsStream(self.googleContactClient, persons, pathWithPersonFields, options);
    }

    # Create a Contact group.
    # 
    # + contactGroupName - Name of the Contact group to be created
    # + readGroupFields - Restrict which fields are returned(clientData, groupType, metadata, name)
    # + return - Created Contact Group on success else an error
    remote function createContactGroup(string contactGroupName, string[] readGroupFields) 
    returns @tainted ContactGroup|error {
        string path = SLASH + CONTACT_GROUP_PATH;
        http:Request request = new;
        string readGroupField = prepareReadGroupFieldsString(readGroupFields);
        json createContactJsonPayload = {
            "contactGroup": {"name": contactGroupName},
            "readGroupFields": readGroupField
        };
        request.setJsonPayload(createContactJsonPayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->post(path, request);
        json createContactGroup = check httpResponse.getJsonPayload();
        ContactGroup|error contactGroup = createContactGroup.cloneWithType(ContactGroup);
        if (contactGroup is ContactGroup) {
            return contactGroup;
        } else {
            return createError(createContactGroup.toString());
        }
    }

    # Batch get Contact groups.
    # 
    # + resourceNames - Name of the Contact group to be fetched
    # + return - Contact Group on success else an error
    remote function batchGetContactGroup(string[] resourceNames) returns @tainted ContactGroupBatch|error {
        string path = SLASH + CONTACT_GROUP_PATH + BATCH_CONTACTGROUP_PATH;
        string pathWithResources = prepareResourceString(path, resourceNames);
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(pathWithResources);
        string statusCode = httpResponse.statusCode.toString();
        json batchGetPeoples = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode == http:STATUS_OK) {
            ContactGroupBatch contactGroupList = check batchGetPeoples.cloneWithType(ContactGroupBatch);
            return contactGroupList;
        } else {
            return createError(batchGetPeoples.toString());
        }
    }

    # Fetch Contact groups of authenticated user.
    # 
    # + return - ContactGroup Array on success else an error
    remote function listContactGroup() returns @tainted ContactGroup[]|error {
        string path = SLASH + CONTACT_GROUP_PATH;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path);
        json listPayload = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode == http:STATUS_OK) {
            ContactGroupList contactGroupList = check listPayload.cloneWithType(ContactGroupList);
            ContactGroup[] contactGroupArray = contactGroupList.contactGroups;
            return contactGroupArray;
        } else {
            return createError(listPayload.toString());
        }
    }

    # Fetch a Contact group.
    # 
    # + resourceName - Name of the Contact group to be created
    # + return - ContactGroup on success else an error
    remote function getContactGroup(string resourceName) returns @tainted ContactGroup|error {
        var path = SLASH + resourceName;
        http:Response httpResponse = <http:Response>check self.googleContactClient->get(path);
        json getContactGroup = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode is http:STATUS_OK) {
            ContactGroup contactGroup = check getContactGroup.cloneWithType(ContactGroup);
            return contactGroup;
        } else {
            return createError(getContactGroup.toString());
        }
    }

    # Update a Contact group.
    # 
    # + resourceName - Name of the Contact group to be created
    # + contactGroupPayload - Update payload
    # + return - ContactGroup on success else an error
    remote function updateContactGroup(string resourceName, string contactGroupName) 
    returns @tainted ContactGroup|error {
        string path = SLASH + resourceName;
        http:Request request = new;
        json contactGroupPayload = {"contactGroup": {"name":contactGroupName}};
        request.setJsonPayload(contactGroupPayload);
        http:Response httpResponse = <http:Response>check self.googleContactClient->put(path, request);
        json getContactGroup = check httpResponse.getJsonPayload();
        if (httpResponse.statusCode is http:STATUS_OK) {
            ContactGroup contactGroup = check getContactGroup.cloneWithType(ContactGroup);
            return contactGroup;
        } else {
            return createError(getContactGroup.toString());
        }
    }

    # Delete a Contact Group.
    # 
    # + resourceName - Contact Group resource name
    # + return - True on success, else an error
    remote function deleteContactGroup(string resourceName) returns @tainted boolean|error {
        string path = SLASH + resourceName;
        http:Response httpResponse = <http:Response>check self.googleContactClient->delete(path);
        if (httpResponse.statusCode is http:STATUS_OK) {
            return true;
        } else {
            json deleteContactGroupResponse = check httpResponse.getJsonPayload();
            return createError(deleteContactGroupResponse.toString());
        }
    }
}
