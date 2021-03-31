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
    // Copy a contact created in Other Contact to MyContact
    string[] copyMask = ["names", "emailAddresses", "phoneNumbers"];
    string[] readMask = ["names", "emailAddresses", "phoneNumbers"];
    var copyContacts = googleContactClient->copyOtherContactToMyContact(copyMask, readMask, "otherContacts/c8846080985039646639");
    if (copyContacts is Person) {
        log:print(copyContacts.toString());
        test:assertTrue(true, msg = "List Other Contacts Failed");
    } else {
        test:assertFail(msg = copyContacts.message());
    }
}