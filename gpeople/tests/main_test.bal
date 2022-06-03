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

import ballerina/lang.'float;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/random;
import ballerina/test;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");

//Create an endpoint to use Google People API Connector
ConnectionConfig googleContactConfig = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken
    }
};

Client googleContactClient = check new (googleContactConfig);

string contactGroupResourceName = "";
string contactResourceName = "";
string beforeSuiteResourceName = "";

@test:BeforeSuite
function beforeSuit() returns error? {
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
    PersonResponse createdContact = check googleContactClient->createContact(createContact, personFields);
    beforeSuiteResourceName = createdContact.resourceName;
    log:printInfo(createdContact.toString());
}

@test:Config { enable: true }
function testListOtherContacts() returns error? {
    log:printInfo("Running List Other Contact Test");
    OtherContactFieldMask[] readMasks = [OTHER_CONTACT_NAME, OTHER_CONTACT_PHONE_NUMBER, OTHER_CONTACT_EMAIL_ADDRESS];
    stream<PersonResponse> listContacts = check googleContactClient->listOtherContacts(readMasks);
    _ = listContacts.forEach(isolated function (PersonResponse person) {
            log:printInfo(person.toString());
        });
}

@test:Config {}
function testCreateContactGroup() returns error? {
    log:printInfo("Running Create Contact Group Test");
    string contactGroupName = genRandName();
    ContactGroup createContactGroup = check googleContactClient->createContactGroup(contactGroupName);
    log:printInfo(createContactGroup.toString());
    contactGroupResourceName = createContactGroup.resourceName;
}

@test:Config {dependsOn: [testCreateContactGroup]}
function testCreateContact() returns error? {
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
    PersonResponse createdContact = check googleContactClient->createContact(createContact, personFields);
    contactResourceName = createdContact.resourceName;
    log:printInfo(createdContact.toString());
}

@test:Config {dependsOn: [testCreateContact]}
function testListContacts() returns error? {
    log:printInfo("Running List People Connection Test");
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS, PHOTO];
    stream<PersonResponse> listContacts = check googleContactClient->listContacts(personFields);
    _ = listContacts.forEach(isolated function(PersonResponse person) {
            log:printInfo(person.toString());
        });
}

@test:Config {dependsOn: [testListContacts]}
function testModifyContactGroup() returns error? {
    log:printInfo("Running Modify contacts in Contact Group Test");
    check googleContactClient->modifyContactGroup(contactGroupResourceName, [contactResourceName], []);
}

@test:Config {dependsOn: [testModifyContactGroup]}
function testGetContact() returns error? {
    log:printInfo("Running Get Contact Test");
    runtime:sleep(10);
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    PersonResponse getPeople =check googleContactClient->getContact(contactResourceName, personFields);
    log:printInfo(getPeople.toString());
}

@test:Config {dependsOn: [testGetContact], enable: false}
function testSearchContact() returns error? {
    log:printInfo("Running Search Contact Test");
    runtime:sleep(10);
    FieldMask[] readMasks = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    PersonResponse[] searchContact = check googleContactClient->searchContacts("Sh", readMasks);
    log:printInfo(searchContact.toString());
}

@test:Config {dependsOn: [testGetContact]}
function testGetBatchContacts() returns error? {
    log:printInfo("Running Get Batch Contact Test");
    runtime:sleep(10);
    FieldMask[] personFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    string[] contactResourceNames = [contactResourceName];
    PersonResponse[] getBatchContacts = check googleContactClient->getBatchContacts(contactResourceNames, personFields);
    log:printInfo(getBatchContacts.toString());
}

@test:Config {dependsOn: [testGetBatchContacts]}
function testUpdateContactPhoto() returns error? {
    log:printInfo("Running Update Contact Photo Test");
    runtime:sleep(10);
    check googleContactClient->updateContactPhoto(contactResourceName, "tests/test.png");
}

@test:Config {dependsOn: [testUpdateContactPhoto]}
function testDeleteContactPhoto() returns error? {
    log:printInfo("Running Delete Contact Photo Test");
    runtime:sleep(10);
    check googleContactClient->deleteContactPhoto(contactResourceName);
}

@test:Config {dependsOn: [testDeleteContactPhoto]}
function testUpdateContact() returns error? {
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
    PersonResponse updateContactResponse = check googleContactClient->updateContact(contactResourceName, 
            updateContactDetail, updatePersonFields, personFields);
    log:printInfo(updateContactResponse.toString()); 
}

@test:Config {dependsOn: [testUpdateContact]}
function testGetContactGroup() returns error? {
    log:printInfo("Running Get Contact Group Test");
    runtime:sleep(10);
    ContactGroup getContactGroup = check googleContactClient->getContactGroup(contactGroupResourceName, 10);
    log:printInfo(getContactGroup.toString());
    contactGroupResourceName = getContactGroup.resourceName;
}

@test:Config {dependsOn: [testGetContactGroup]}
function testbatchGetContactGroup() returns error? {
    log:printInfo("Running Get Batch Contact Group Test");
    runtime:sleep(10);
    string[] resourceNames = [contactGroupResourceName];
    ContactGroup[] getBatchContactGroup = check googleContactClient->getBatchContactGroup(resourceNames);
    log:printInfo(getBatchContactGroup.toString());
}

@test:Config {dependsOn: [testbatchGetContactGroup]}
function testListContactGroup() returns error? {
    log:printInfo("Running List Contact Group Test");
    ContactGroup[] listContactGroup = check googleContactClient->listContactGroup();
    log:printInfo(listContactGroup.toString());
}

@test:Config {dependsOn: [testListContactGroup]}
function testUpdateContactGroup() returns error? {
    log:printInfo("Running Update Contact Group Test");
    ContactGroup updateContactGroup = check googleContactClient->updateContactGroup(contactGroupResourceName, "TestUpdated");
    log:printInfo(updateContactGroup.toString());
    contactGroupResourceName = updateContactGroup.resourceName;
}

@test:AfterSuite { }
function afterSuite() returns error? {
    log:printInfo("AfterSuite");
    runtime:sleep(10);
    if (beforeSuiteResourceName != "") {
        error? deleteContact = googleContactClient->deleteContact(beforeSuiteResourceName);
        if (deleteContact is error) {
            log:printError("Delete Contact Failed for resource name: " + beforeSuiteResourceName);
        } else {
            log:printInfo("Contact deleted sucessfully");
        }
        runtime:sleep(10); 
    }

    if (contactResourceName != "") {
        error? deleteContact = googleContactClient->deleteContact(contactResourceName);
        if (deleteContact is error) {
            log:printError("Delete Contact Failed for resource name: " + contactResourceName);
        } else {
            log:printInfo("Contact deleted sucessfully");
        }
        runtime:sleep(10);
    }
    
    if (contactGroupResourceName != "") {
        error? deleteContactGroup = googleContactClient->deleteContactGroup(contactGroupResourceName);
        if (deleteContactGroup is error) {
            log:printError("Delete Contact group Failed for resource name" + contactGroupResourceName);
        } else {
            log:printInfo("Contact group deleted sucessfully");
        }
    }
}

isolated function genRandName() returns string {
    float ranNumFloat = random:createDecimal()*10000000.0;
    anydata ranNumInt = <int> float:round(ranNumFloat);
    string contactGroupName = "TestContactGroup" + ranNumInt.toString();
    return contactGroupName;
}
