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

import ballerinax/googleapis_people as contacts;
import ballerina/log;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

contacts:GoogleContactsConfiguration googleContactConfig = {
    oauthClientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: contacts:REFRESH_URL,
        refreshToken: refreshToken
    }
};

contacts:Client googleContactClient = checkpanic new (googleContactConfig);

public function main() {

    string contactResourceName = "";

    CreatePerson createContact = {
        "emailAddresses": [],
        "names": [{
            "displayName": "Test1 Test2",
            "familyName": "Test",
            "givenName": "Test",
            "displayNameLastFirst": "Test2, Test1",
            "unstructuredName": "Test Test"
        }]
    };
    string[] personFields = ["names", "phoneNumbers"];
    string[] sources = ["READ_SOURCE_TYPE_CONTACT"];
    contacts:Person|error createdContact = googleContactClient->createContact(createContact, personFields, sources);
    if (response is contacts:Person) {
        contactResourceName = <@untainted>createdContact.resourceName;
        log:print("Person/Contacts Details: " + response.toString());
        log:print(response.resourceName.toString());
    } else {
        log:printError("Error: " + response.toString());
    }

    // Fetch information about Contact Group  
    contacts:ContactGroup|error getPeople = googleContactClient->getContactGroup(contactGroupResourceName, personFields, sources);
    if (response is contacts:ContactGroup) {
        log:print("Contact Group Details: " + response.toString());
        log:print(response.resourceName.toString());
    } else {
        log:printError("Error: " + response.toString());
    }
    
    //Update a contact group
    var updateContactGroup = googleContactClient->updateContactGroup(contactGroupResourceName, "TestUpdated");
    if (updateContactGroup is ContactGroup) {
        log:print(updateContactGroup.toString());
        contactGroupResourceName = updateContactGroup.resourceName;
        log:print("Updated Contact Group");
    } else {
        log:printError(msg = updateContactGroup.toString());
    }
}
