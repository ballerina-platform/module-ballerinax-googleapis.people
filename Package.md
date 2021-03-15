# Ballerina Google People Connector 
Connects to Google People using Ballerina.

# Introduction
## Google People
[Google People](https://developers.google.com/people) is a contact-management service developed by Google. It lets users to organize their schedule and share events with others. The Google People endpoint allows you to access the Google People API Version v1 through Ballerina.

## Key Features of Google People
* Manage Contacts
* Manage Contact Groups

## Connector Overview

The Google People Ballerina Connector allows you to access the Google People API Version V1 through Ballerina. The connector can be used to implement some of the most common use cases of Google People. The connector provides the capability to programmatically manage contacts and contact groups, CRUD operations on contacts and contact groups operations through the connector endpoints and listener for the events created in the contacts.

# Prerequisites

* Java 11 Installed
  Java Development Kit (JDK) with version 11 is required.

* Download the Ballerina [distribution](https://ballerinalang.org/downloads/) SLAlpha2
  Ballerina Swan Lake Alpha Version 2 is required.

* Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for BasicAuth and OAuth 2.0. Google People uses OAuth 2.0 to authenticate and authorize requests. 
  * The Google People connector can be minimally instantiated in the HTTP client config using client ID, client secret, and refresh token.
    * Client ID
    * Client Secret
    * Refresh Token
    * Refresh URL
  * In order to use listener address, resource id and channel id are additionally required. Address URL is url path of the listener. Channel id and resource id will be provided when channel is registered using watch operation.
    * Address URL
    * Resource ID
    * Channel ID

## Compatibility

|                             |            Versions             |
|:---------------------------:|:-------------------------------:|
|    Ballerina Language       |       Swan Lake Alpha 2         |
|     Google People API       |               V1                |


Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for OAuth 2.0. Google People uses OAuth 2.0 to authenticate and authorize requests. The Google People connector can be minimally instantiated in the HTTP client config using client ID, client secret, and refresh token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google People API scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token. 

**Add project configurations file**

Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the tokens obtained in the previous step to the `Config.toml` file.

#### For client operations
```
[ballerinax.googleapis_people]
clientId = "<client_id">
clientSecret = "<client_secret>"
refreshToken = "<refresh_token>"
refreshUrl = "<refresh_URL>"

```
```
# **Samples**

### Create a Contact
```ballerina
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

contacts:Client googleContactClient = check new (googleContactConfig);

public function main() {
    // Create Person/Contact with given name
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
        log:print("Person/Contacts Details: " + response.toString());
        log:print(response.resourceName.toString());
    } else {
        log:printError("Error: " + response.toString());
    }
}
```
### Fetch a Contact
```ballerina
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

contacts:Client googleContactClient = check new (googleContactConfig);

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

    // Fetch information about Person/Contact
    string[] personFields = ["names", "phoneNumbers"];
    string[] sources = ["READ_SOURCE_TYPE_CONTACT"];
    Person|error getPeople = googleContactClient->getPeople(contactResourceName, personFields, sources);
    if (response is contacts:Person) {
        log:print("Person/Contacts Details: " + response.toString());
        log:print(response.resourceName.toString());
    } else {
        log:printError("Error: " + response.toString());
    }
}
```
### Search a Contact using a string value
```ballerina
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

contacts:Client googleContactClient = check new (googleContactConfig);

public function main() {
    // Search a Person/Contact with a string
    SearchResponse|error searchPeople = googleContactClient->searchPeople("Test");
    if (response is contacts:Person) {
        log:print("Person/Contacts Details: " + response.toString());
        log:print(response.resourceName.toString());
    } else {
        log:printError("Error: " + response.toString());
    }
}
```

### Delete a Contact
```ballerina
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

contacts:Client googleContactClient = check new (googleContactConfig);

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

    var response = googleContactClient->deleteContact(contactResourceName);
    if (response is boolean) {
        log:print("Deleted");
    } else {
        log:printError("Error: " + response.toString());
    }
}
```

### Create a Contact Group
```ballerina
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

contacts:Client googleContactClient = check new (googleContactConfig);

public function main() {
    // Create Contact Group with given name
    string[] readGroupFields = ["name", "clientData", "groupType", "metadata"];
    var createContactGroup = googleContactClient->createContactGroup("TestContactGroup", readGroupFields);
    if (response is contacts:ContactGroup) {
        log:print("Contact Group Details: " + response.toString());
        log:print(response.resourceName.toString());
    } else {
        log:printError("Error: " + response.toString());
    }
}
```
### Fetch a Contact Group
```ballerina
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

contacts:Client googleContactClient = check new (googleContactConfig);

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
}
```
