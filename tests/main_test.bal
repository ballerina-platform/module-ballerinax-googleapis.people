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

string contactGroupResourceName = "";
string contactResourceName = "";
string beforeSuiteResourceName = "";

@test:BeforeSuite
function beforeSuit() {
    log:printInfo("BeforeSuite");
    Person createContact = {
        "emailAddresses": [],
        "names": [{
            "familyName": "Hardy",
            "givenName": "Shane",
            "unstructuredName": "Shane Hardy"
        }]
    };
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    PersonResponse|error createdContact = googleContactClient->createContact(createContact, personFields);
    if (createdContact is PersonResponse) {
        beforeSuiteResourceName = <@untainted>createdContact.resourceName;
        log:printInfo(createdContact.toString());
        test:assertTrue(true, msg = "Create Contact Failed");
    } else {
        test:assertFail(msg = createdContact.message());
    }
}

@test:Config { enable: true }
function testListOtherContacts() {
    log:printInfo("Running List Other Contact Test");
    OtherContactFieldMask[] readMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    var listContacts = googleContactClient->listOtherContacts(readMasks);
    if (listContacts is stream<PersonResponse>) {
        error? e = listContacts.forEach(isolated function (PersonResponse person) {
            log:printInfo(person.toString());
        });
        test:assertTrue(true, msg = "List Other Contacts Failed");
    } else {
        test:assertFail(msg = listContacts.message());
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
    Person createContact = {
        "emailAddresses": [],
        "names": [{
            "familyName": "Hardy",
            "givenName": "Jason",
            "unstructuredName": "Jason Hardy"
        }]
    };
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    PersonResponse|error createdContact = googleContactClient->createContact(createContact, personFields);
    if (createdContact is PersonResponse) {
        contactResourceName = <@untainted>createdContact.resourceName;
        log:printInfo(createdContact.toString());
        test:assertTrue(true, msg = "Create Contact Failed");
    } else {
        test:assertFail(msg = createdContact.message());
    }
}

@test:Config {dependsOn: [testCreateContact]}
function testListContacts() {
    log:printInfo("Running List People Connection Test");
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS, PHOTO];
    var listContacts = googleContactClient->listContacts(personFields);
    if (listContacts is stream<PersonResponse>) {
        error? e = listContacts.forEach(isolated function(PersonResponse person) {
            log:printInfo(person.toString());
        });
        test:assertTrue(true, msg = "List People Connection Failed");
    } else {
        test:assertFail(msg = listContacts.message());
    }
}

@test:Config {dependsOn: [testListContacts]}
function testModifyContactGroup() {
    log:printInfo("Running Modify contacts in Contact Group Test");
    var response = googleContactClient->modifyContactGroup(contactGroupResourceName, [contactResourceName], []);
    if (response is ()) {
        test:assertTrue(true, msg = "Modify contacts in Contact Group Failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {dependsOn: [testModifyContactGroup]}
function testGetContact() {
    log:printInfo("Running Get Contact Test");
    runtime:sleep(10);
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    PersonResponse|error getPeople = googleContactClient->getContact(contactResourceName, personFields);
    if (getPeople is PersonResponse) {
        log:printInfo(getPeople.toString());
        test:assertTrue(true, msg = "Get Contact Failed");
    } else {
        test:assertFail(msg = getPeople.message());
    }
}

@test:Config {dependsOn: [testGetContact], enable: false}
function testSearchPeople() {
    log:printInfo("Running Search People Test");
    runtime:sleep(10);
    FieldMask[] readMasks = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    PersonResponse[]|error searchPeople = googleContactClient->searchPeople("Sh", readMasks);
    if (searchPeople is PersonResponse[]) {
        log:printInfo(searchPeople.toString());
        test:assertTrue(true, msg = "Search Contact Failed");
    } else {
        test:assertFail(msg = searchPeople.message());
    }
}

@test:Config {dependsOn: [testGetContact]}
function testGetBatchContacts() {
    log:printInfo("Running Get Batch Contact Test");
    runtime:sleep(10);
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    string[] contactResourceNames = [contactResourceName];
    var getBatchContacts = googleContactClient->getBatchContacts(contactResourceNames, personFields);
    if (getBatchContacts is PersonResponse[]) {
        log:printInfo(getBatchContacts.toString());
        test:assertTrue(true, msg = "Get Batch Contacts Failed");
    } else {
        test:assertFail(msg = getBatchContacts.message());
    }
}

@test:Config {dependsOn: [testGetBatchContacts]}
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
    Person updateContactDetail = {
        "emailAddresses": [],
        "names": [{
            "familyName": "Shawn",
            "givenName": "Jason",
            "unstructuredName": "Jason Shawn"
        }]
    };
        FieldMask[] updatePersonFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
     FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    var updateContactResponse = googleContactClient->updateContact(contactResourceName, updateContactDetail, 
                                                                       updatePersonFields, personFields);
    if (updateContactResponse is PersonResponse) {
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
    log:printInfo("Running Get Batch Contact Group Test");
    runtime:sleep(10);
    string[] resourceNames = [contactGroupResourceName];
    var getBatchContactGroup = googleContactClient->getBatchContactGroup(resourceNames);
    if (getBatchContactGroup is ContactGroup[]) {
        log:printInfo(getBatchContactGroup.toString());
        test:assertTrue(true, msg = "Get Batch Contact Group Failed");
    } else {
        test:assertFail(msg = getBatchContactGroup.message());
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

@test:AfterSuite { }
function afterSuite() {
    log:printInfo("AfterSuite");
    runtime:sleep(10);
    var deleteContact = googleContactClient->deleteContact(beforeSuiteResourceName);
    if (deleteContact is ()) {
        test:assertTrue(true, msg = "Delete Contact Failed");
    } else {
        test:assertFail(msg = deleteContact.message());
    }
}
