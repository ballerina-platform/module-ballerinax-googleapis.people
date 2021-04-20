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

    Person createContact = {
        "emailAddresses": [],
        "names": [{
            "familyName": "Hardy",
            "givenName": "Jason",
            "unstructuredName": "Jason Hardy"
        }]
    };
    string[] personFields = ["names", "phoneNumbers"];
    string[] sources = ["READ_SOURCE_TYPE_CONTACT"];
    contacts:PersonResponse|error createContact = googleContactClient->createContact(createContact, personFields, sources);
    if (createContact is contacts:PersonResponse) {
        contactResourceName = <@untainted>createContact.resourceName;
        log:printInfo("Person/Contacts Details: " + createContact.toString());
        log:printInfo(createContact.resourceName.toString());
    } else {
        log:printError("Error: " + createContact.toString());
    }

    // Update a contact photo
    var updateContactPhoto = googleContactClient->updateContactPhoto(contactResourceName, "tests/image.png");
    if (updateContactPhoto is ()) {
        log:printInfo("Updated Contact Photo");
    } else {
        log:printError(updateContactPhoto.toString());
    }

    // Delete a contact photo
    var deleteContactPhoto = googleContactClient->deleteContactPhoto(contactResourceName);
    if (deleteContactPhoto is ()) {
        log:printInfo("Delete Contact Photo Deleted");
    } else {
        log:printError(deleteContactPhoto.toString());
    }
}
