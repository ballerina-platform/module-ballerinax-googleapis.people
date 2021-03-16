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
// import ballerina/os;
import ballerina/test;

//Create an endpoint to use Google People API Connector
GoogleContactsConfiguration googleContactConfig = {oauthClientConfig: {
        clientId: os:getEnv("CLIENT_ID"),
        clientSecret: os:getEnv("CLIENT_SECRET"),
        refreshUrl: REFRESH_URL,
        refreshToken: os:getEnv("REFRESH_TOKEN")
    }};

Client googleContactClient = check new (googleContactConfig);

string otherContactResourceName = "";

@test:Config {}
function testListOtherContacts() {
    log:print("Running List Other Contact Test");
    OtherContactMasks[] readMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    var listContacts = googleContactClient->listOtherContacts(readMasks);
    if (listContacts is stream<Person>) {
        error? e = listContacts.forEach(isolated function (Person person) {
            log:print(person.toString());
        });
        test:assertTrue(true, msg = "List Other Contacts Failed");
    } else {
        test:assertFail(msg = listContacts.message());
    }
}

@test:Config  {dependsOn: [testListOtherContacts]}
function testCopyOtherContactToMyContact() {
    log:print("Running copy OtherContact To MyContact Test");
    OtherContactMasks[] copyMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    ContactMasks[] readMasks = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    var copyContacts = googleContactClient->copyOtherContactToMyContact("otherContacts/c8846080985039646639", copyMasks, readMasks);
    if (copyContacts is Person) {
        log:print(copyContacts.toString());
        test:assertTrue(true, msg = "List Other Contacts Failed");
    } else {
        test:assertFail(msg = copyContacts.message());
    }
}

@test:Config {}
function testSearchOtherContacts() {
    log:print("Running Search Other Contacts Test");
    OtherContactMasks[] readMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    Person[]|error searchOtherContacts = googleContactClient->searchOtherContacts("R", readMasks);
    if (searchOtherContacts is Person[]) {
        log:print(searchOtherContacts.toString());
        test:assertTrue(true, msg = "Get Contact Failed");
    } else {
        test:assertFail(msg = searchOtherContacts.message());
    }
}

string contactResourceName = "";

@test:Config {}
function testCreateContact() {
    log:print("Running Create Contact Test");
    CreatePerson createContact = {
        "emailAddresses": [],
        "names": [{
            "displayName": "Kapilraaj Perinpanayagam",
            "familyName": "Perinpanayagam",
            "givenName": "Test",
            "displayNameLastFirst": "Perinpanayagam, Kapilraaj",
            "unstructuredName": "Kapilraaj Perinpanayagam"
        }]
    };
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    Person|error createdContact = googleContactClient->createContact(createContact, personFields);
    if (createdContact is Person) {
        contactResourceName = <@untainted>createdContact.resourceName;
        log:print(createdContact.toString());
        test:assertTrue(true, msg = "Create Contact Failed");
    } else {
        test:assertFail(msg = createdContact.message());
    }
}

@test:Config {dependsOn: [testCreateContact]}
function testGetContact() {
    log:print("Running Get Contact Test");
    runtime:sleep(10);
    ContactMasks[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    Person|error getPeople = googleContactClient->getContact(contactResourceName, personFields);
    if (getPeople is Person) {
        log:print(getPeople.toString());
        test:assertTrue(true, msg = "Get Contact Failed");
    } else {
        test:assertFail(msg = getPeople.message());
    }
}

@test:Config {dependsOn: [testCreateContact]}
function testBatchGetContacts() {
    log:print("Running Batch Contact Test");
    runtime:sleep(10);
    string[] personFields = ["names", "phoneNumbers"];
    string[] contactResourceNames = [contactResourceName];
    var batchGetContacts = googleContactClient->batchGetContacts(contactResourceNames, personFields);
    if (batchGetContacts is Person[]) {
        log:print(batchGetContacts.toString());
        test:assertTrue(true, msg = "Batch Get People Failed");
    } else {
        test:assertFail(msg = batchGetContacts.message());
    }
}

@test:Config {dependsOn: [testGetContact]}
function testSearchPeople() {
    log:print("Running Search People Test");
    runtime:sleep(10);
    ContactMasks[] readMasks = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    Person[]|error searchPeople = googleContactClient->searchPeople("K", readMasks);
    if (searchPeople is Person[]) {
        log:print(searchPeople.toString());
        test:assertTrue(true, msg = "Get Contact Failed");
    } else {
        test:assertFail(msg = searchPeople.message());
    }
}

@test:Config {dependsOn: [testCreateContact]}
function testUpdateContactPhoto() {
    log:print("Running Update Contact Photo Test");
    runtime:sleep(10);
    var updateContactPhoto = googleContactClient->updateContactPhoto(contactResourceName, "tests/image.png");
    if (updateContactPhoto is ()) {
        test:assertTrue(true, msg = "Update Contact Photo Failed");
    } else {
        test:assertFail(msg = updateContactPhoto.message());
    }
}

@test:Config {dependsOn: [testUpdateContactPhoto]}
function testDeleteContactPhoto() {
    log:print("Running Delete Contact Photo Test");
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
    log:print("Running Update Contact Test");
    runtime:sleep(10);
    CreatePerson updateContactDetail = {
        "emailAddresses": [],
        "names": [{
            "displayName": "KapilraajEdited PerinpanayagamEdited",
            "familyName": "Perinpanayagam",
            "givenName": "TestA",
            "displayNameLastFirst": "Perinpanayagam, Kapilraaj",
            "unstructuredName": "Kapilraaj Perinpanayagam"
        }]
    };
    string[] updatePersonFields = ["names", "phoneNumbers"];
    string[] personFields = ["names", "phoneNumbers"];
    var updateContactResponse = googleContactClient->updateContact(contactResourceName, updateContactDetail, 
                                                                   updatePersonFields, personFields);
    if (updateContactResponse is Person) {
        log:print(updateContactResponse.toString());        
        test:assertTrue(true, msg = "Update Contact Failed");
    } else {
        test:assertFail(msg = updateContactResponse.message());
    }
}

@test:Config {dependsOn: [testCreateContact, testGetContact, testUpdateContact]}
function testDeleteContact() {
    log:print("Running Delete Contact Test");
    runtime:sleep(10);
    var deleteContact = googleContactClient->deleteContact(contactResourceName);
    if (deleteContact is ()) {
        test:assertTrue(true, msg = "Delete Contact Failed");
    } else {
        test:assertFail(msg = deleteContact.message());
    }
}

string contactGroupResourceName = "";

@test:Config {}
function testCreateContactGroup() {
    log:print("Running Create Contact Group Test");
    string[] readGroupFields = ["name", "clientData", "groupType", "metadata"];
    var createContactGroup = googleContactClient->createContactGroup("TestContactGroup", readGroupFields);
    if (createContactGroup is ContactGroup) {
        log:print(createContactGroup.toString());
        contactGroupResourceName = createContactGroup.resourceName;
        test:assertTrue(true, msg = "Creating Contact Group Failed");
    } else {
        test:assertFail(msg = createContactGroup.message());
    }
}

@test:Config {dependsOn: [testCreateContactGroup]}
function testGetContactGroup() {
    log:print("Running Get Contact Group Test");
    runtime:sleep(10);
    var getContactGroup = googleContactClient->getContactGroup(contactGroupResourceName, 10);
    if (getContactGroup is ContactGroup) {
        log:print(getContactGroup.toString());
        contactGroupResourceName = getContactGroup.resourceName;
        test:assertTrue(true, msg = "Fetching Contact Group Failed");
    } else {
        test:assertFail(msg = getContactGroup.message());
    }
}

@test:Config {dependsOn: [testGetContactGroup]}
function testbatchGetContactGroup() {
    log:print("Running BatchGet Contact Group Test");
    runtime:sleep(10);
    string[] resourceNames = [contactGroupResourceName];
    var batchGetContactGroup = googleContactClient->batchGetContactGroup(resourceNames);
    if (batchGetContactGroup is ContactGroup[]) {
        log:print(batchGetContactGroup.toString());
        test:assertTrue(true, msg = "Batch Get Contact Group Failed");
    } else {
        test:assertFail(msg = batchGetContactGroup.message());
    }
}

@test:Config {dependsOn: [testbatchGetContactGroup]}
function testListContactGroup() {
    log:print("Running List Contact Group Test");
    var listContactGroup = googleContactClient->listContactGroup();
    if (listContactGroup is ContactGroup[]) {
        log:print(listContactGroup.toString());
        test:assertTrue(true, msg = "List Contact Group Failed");
    } else {
        test:assertFail(msg = listContactGroup.message());
    }
}

@test:Config {dependsOn: [testListContactGroup]}
function testUpdateContactGroup() {
    log:print("Running Update Contact Group Test");
    var updateContactGroup = googleContactClient->updateContactGroup(contactGroupResourceName, "TestUpdated");
    if (updateContactGroup is ContactGroup) {
        log:print(updateContactGroup.toString());
        contactGroupResourceName = updateContactGroup.resourceName;
        test:assertTrue(true, msg = "Update Contact Group Failed");
    } else {
        test:assertFail(msg = updateContactGroup.message());
    }
}

@test:Config {dependsOn: [testUpdateContactGroup]}
function testDeleteContactGroup() {
    log:print("Running Delete Contact Group Test");
    var deleteContactGroup = googleContactClient->deleteContactGroup(contactGroupResourceName);
    if (deleteContactGroup is ()) {
        test:assertTrue(true, msg = "Delete Contact Group Failed");
    } else {
        test:assertFail(msg = deleteContactGroup.message());
    }
}

@test:Config {}
function testModifyContactGroup() {
    log:print("Running Modify contacts in Contact Group Test");
    var response = googleContactClient->modifyContactGroup("contactGroups/32efb68589c850da", ["people/c1471841616970342660"], ["people/c5177160596799145947"]);
    if (response is json) {
        test:assertTrue(true, msg = "Modify contacts in Contact Group Failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {}
function testListPeopleConnection() {
    log:print("Running List People Connection Test");
    string[] personFields = ["names", "emailAddresses", "phoneNumbers", "photos"];
    var listPeopleConnection = googleContactClient->listPeoples(personFields);
    if (listPeopleConnection is stream<Person>) {
        error? e = listPeopleConnection.forEach(isolated function(Person person) {
            log:print(person.toString());
        });
        test:assertTrue(true, msg = "List People Connection Failed");
    } else {
        test:assertFail(msg = listPeopleConnection.message());
    }
}
