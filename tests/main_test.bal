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

import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/test;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");

//Create an endpoint to use Google People API Connector
GoogleContactsConfiguration googleContactConfig = {oauth2Config: {
    clientId: clientId,
    clientSecret: clientSecret,
    refreshUrl: REFRESH_URL,
    refreshToken: refreshToken
}};

Client googleContactClient = check new (googleContactConfig);

string otherContactResourceName = "";
string contactGroupResourceName = "";
string contactResourceName = "";

@test:Config { enable: false }
function testListOtherContacts() {
    log:printInfo("Running List Other Contact Test");
    OtherContactMasks[] readMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    var listContacts = googleContactClient->listOtherContacts(readMasks);
    if (listContacts is stream<Person>) {
        error? e = listContacts.forEach(isolated function (Person person) {
            log:printInfo(person.toString());
        });
        test:assertTrue(true, msg = "List Other Contacts Failed");
    } else {
        test:assertFail(msg = listContacts.message());
    }
}

@test:Config { dependsOn: [testListOtherContacts], enable: false }
function testCopyOtherContactToMyContact() {
    log:printInfo("Running copy OtherContact To MyContact Test");
    OtherContactMasks[] copyMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    ContactMasks[] readMasks = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    var copyContacts = googleContactClient->copyOtherContactToMyContact(otherContactResourceName, copyMasks, readMasks);
    if (copyContacts is Person) {
        log:printInfo(copyContacts.toString());
        test:assertTrue(true, msg = "List Other Contacts Failed");
    } else {
        test:assertFail(msg = copyContacts.message());
    }
}

@test:Config { enable: false }
function testSearchOtherContacts() {
    log:printInfo("Running Search Other Contacts Test");
    OtherContactMasks[] readMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    Person[]|error searchOtherContacts = googleContactClient->searchOtherContacts("Test", readMasks);
    if (searchOtherContacts is Person[]?) {
        log:printInfo(searchOtherContacts.toString());
        test:assertTrue(true, msg = "Search Contact Failed");
    } else {
        test:assertFail(msg = searchOtherContacts.message());
    }
}

@test:Config {}
function testCreateContactGroup() {
    log:printInfo("Running Create Contact Group Test");
    var createContactGroup = googleContactClient->createContactGroup("TestContactGroup");
    if (createContactGroup is ContactGroup) {
        log:printInfo(createContactGroup.toString());
        contactGroupResourceName = createContactGroup.resourceName;
        test:assertTrue(true, msg = "Creating Contact Group Failed");
    } else {
        test:assertFail(msg = createContactGroup.message());
    }
}

@test:Config {dependsOn: [testCreateContactGroup]}
function testCreateContact() {
    log:printInfo("Running Create Contact Test");
    CreatePerson createContact = {
        "emailAddresses": [],
        "names": [{
            "displayName": "FName LName",
            "familyName": "LName",
            "givenName": "FName",
            "displayNameLastFirst": "LName, FName",
            "unstructuredName": "FName LName"
        }]
    };
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    Person|error createdContact = googleContactClient->createContact(createContact, personFields);
    if (createdContact is Person) {
        contactResourceName = <@untainted>createdContact.resourceName;
        log:printInfo(createdContact.toString());
        test:assertTrue(true, msg = "Create Contact Failed");
    } else {
        test:assertFail(msg = createdContact.message());
    }
}

@test:Config {dependsOn: [testCreateContact]}
function testListPeopleConnection() {
    log:printInfo("Running List People Connection Test");
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS, PHOTO];
    var listPeopleConnection = googleContactClient->listPeoples(personFields);
    if (listPeopleConnection is stream<Person>) {
        error? e = listPeopleConnection.forEach(isolated function(Person person) {
            log:printInfo(person.toString());
        });
        test:assertTrue(true, msg = "List People Connection Failed");
    } else {
        test:assertFail(msg = listPeopleConnection.message());
    }
}

@test:Config {dependsOn: [testListPeopleConnection]}
function testModifyContactGroup() {
    log:printInfo("Running Modify contacts in Contact Group Test");
    var response = googleContactClient->modifyContactGroup(contactGroupResourceName, [contactResourceName], []);
    if (response is json) {
        test:assertTrue(true, msg = "Modify contacts in Contact Group Failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {dependsOn: [testModifyContactGroup]}
function testGetContact() {
    log:printInfo("Running Get Contact Test");
    runtime:sleep(10);
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    Person|error getPeople = googleContactClient->getContact(contactResourceName, personFields);
    if (getPeople is Person) {
        log:printInfo(getPeople.toString());
        test:assertTrue(true, msg = "Get Contact Failed");
    } else {
        test:assertFail(msg = getPeople.message());
    }
}

@test:Config {dependsOn: [testGetContact]}
function testBatchGetContacts() {
    log:printInfo("Running Batch Contact Test");
    runtime:sleep(10);
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    string[] contactResourceNames = [contactResourceName];
    var batchGetContacts = googleContactClient->batchGetContacts(contactResourceNames, personFields);
    if (batchGetContacts is Person[]) {
        log:printInfo(batchGetContacts.toString());
        test:assertTrue(true, msg = "Batch Get People Failed");
    } else {
        test:assertFail(msg = batchGetContacts.message());
    }
}

@test:Config {dependsOn: [testBatchGetContacts], enable: false }
function testSearchPeople() {
    log:printInfo("Running Search People Test");
    runtime:sleep(10);
    ContactMasks[] readMasks = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    Person[]|error searchPeople = googleContactClient->searchPeople("F", readMasks);
    if (searchPeople is Person[]) {
        log:printInfo(searchPeople.toString());
        test:assertTrue(true, msg = "Get Contact Failed");
    } else {
        test:assertFail(msg = searchPeople.message());
    }
}

@test:Config {dependsOn: [testBatchGetContacts]}
function testUpdateContactPhoto() {
    log:printInfo("Running Update Contact Photo Test");
    runtime:sleep(10);
    var updateContactPhoto = googleContactClient->updateContactPhoto(contactResourceName, "tests/test.png");
    if (updateContactPhoto is ()) {
        test:assertTrue(true, msg = "Update Contact Photo Failed");
    } else {
        test:assertFail(msg = updateContactPhoto.message());
    }
}

@test:Config {dependsOn: [testUpdateContactPhoto]}
function testDeleteContactPhoto() {
    log:printInfo("Running Delete Contact Photo Test");
    runtime:sleep(10);
    var deleteContactPhoto = googleContactClient->deleteContactPhoto(contactResourceName);
    if (deleteContactPhoto is ()) {
        test:assertTrue(true, msg = "Delete Contact Photo Failed");
    } else {
        test:assertFail(msg = deleteContactPhoto.message());
    }
}

@test:Config {dependsOn: [testDeleteContactPhoto]}
function testUpdateContact() {
    log:printInfo("Running Update Contact Test");
    runtime:sleep(10);
    CreatePerson updateContactDetail = {
        "emailAddresses": [],
        "names": [{
            "displayName": "FNameEdited LNameEdited",
            "familyName": "LName",
            "givenName": "FName",
            "displayNameLastFirst": "LName, FName",
            "unstructuredName": "FName LName"
        }]
    };
    ContactMasks[] updatePersonFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    var updateContactResponse = googleContactClient->updateContact(contactResourceName, updateContactDetail, 
                                                                   updatePersonFields, personFields);
    if (updateContactResponse is Person) {
        log:printInfo(updateContactResponse.toString());        
        test:assertTrue(true, msg = "Update Contact Failed");
    } else {
        test:assertFail(msg = updateContactResponse.message());
    }
}

@test:Config {dependsOn: [testCreateContact, testGetContact, testUpdateContact]}
function testDeleteContact() {
    log:printInfo("Running Delete Contact Test");
    runtime:sleep(10);
    var deleteContact = googleContactClient->deleteContact(contactResourceName);
    if (deleteContact is ()) {
        test:assertTrue(true, msg = "Delete Contact Failed");
    } else {
        test:assertFail(msg = deleteContact.message());
    }
}

@test:Config {dependsOn: [testDeleteContact]}
function testGetContactGroup() {
    log:printInfo("Running Get Contact Group Test");
    runtime:sleep(10);
    var getContactGroup = googleContactClient->getContactGroup(contactGroupResourceName, 10);
    if (getContactGroup is ContactGroup) {
        log:printInfo(getContactGroup.toString());
        contactGroupResourceName = getContactGroup.resourceName;
        test:assertTrue(true, msg = "Fetching Contact Group Failed");
    } else {
        test:assertFail(msg = getContactGroup.message());
    }
}

@test:Config {dependsOn: [testGetContactGroup]}
function testbatchGetContactGroup() {
    log:printInfo("Running BatchGet Contact Group Test");
    runtime:sleep(10);
    string[] resourceNames = [contactGroupResourceName];
    var batchGetContactGroup = googleContactClient->batchGetContactGroup(resourceNames);
    if (batchGetContactGroup is ContactGroup[]) {
        log:printInfo(batchGetContactGroup.toString());
        test:assertTrue(true, msg = "Batch Get Contact Group Failed");
    } else {
        test:assertFail(msg = batchGetContactGroup.message());
    }
}

@test:Config {dependsOn: [testbatchGetContactGroup]}
function testListContactGroup() {
    log:printInfo("Running List Contact Group Test");
    var listContactGroup = googleContactClient->listContactGroup();
    if (listContactGroup is ContactGroup[]) {
        log:printInfo(listContactGroup.toString());
        test:assertTrue(true, msg = "List Contact Group Failed");
    } else {
        test:assertFail(msg = listContactGroup.message());
    }
}

@test:Config {dependsOn: [testListContactGroup]}
function testUpdateContactGroup() {
    log:printInfo("Running Update Contact Group Test");
    var updateContactGroup = googleContactClient->updateContactGroup(contactGroupResourceName, "TestUpdated");
    if (updateContactGroup is ContactGroup) {
        log:printInfo(updateContactGroup.toString());
        contactGroupResourceName = updateContactGroup.resourceName;
        test:assertTrue(true, msg = "Update Contact Group Failed");
    } else {
        test:assertFail(msg = updateContactGroup.message());
    }
}

@test:Config {dependsOn: [testUpdateContactGroup]}
function testDeleteContactGroup() {
    log:printInfo("Running Delete Contact Group Test");
    var deleteContactGroup = googleContactClient->deleteContactGroup(contactGroupResourceName);
    if (deleteContactGroup is ()) {
        test:assertTrue(true, msg = "Delete Contact Group Failed");
    } else {
        test:assertFail(msg = deleteContactGroup.message());
    }
}
