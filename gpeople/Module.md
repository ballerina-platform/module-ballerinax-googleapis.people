## Overview
Ballerina connector for Google People API is connecting the Google People API via Ballerina language easily. It provides capability to perform operations related to contacts and contact groups in Google Contacts.

This module supports [Google People API](https://developers.google.com/people) v1.0 version and only allows to perform functions behalf of the currently logged in user.

This module supports Ballerina Swan Lake Beta 2 version

## Configuring connector
### Prerequisites
- Google account

### Obtaining tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google People API scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token. 
8. Add the project configuration file by creating a `Config.toml` file under the root path of the project structure. Config file should have following configurations. Add the tokens obtained in the previous step to the `Config.toml` file.
```ballerina
[ballerinax.googleapis.people]
clientId = "<client_id">
clientSecret = "<client_secret>"
refreshToken = "<refresh_token>"
refreshUrl = "<refresh_URL>"
```

## Quickstart

### Create a contact
#### Step 1: Import Google People API module
First, import the ballerinax/googleapis.people module into the Ballerina project.
```ballerina
import ballerinax/googleapis.people as people;
```
#### Step 2: Initialize the Google People API Client giving necessary credentials

You can now enter the credentials in the Google People API client configuration and create Google People API client by passing the configuration:

```ballerina
people:GoogleContactsConfiguration googleContactConfig = {
    oauth2Config: {
        clientId: "<CLIENT_ID>",
        clientSecret: <CLIENT_SECRET>,
        refreshUrl: people:REFRESH_URL,
        refreshToken: <REFRESH_TOKEN>
    }
};

people:Client googleContactClient = check new (googleContactConfig);
```

#### Step 3: Create a contact

You can get create a contact as follows with `createContact` method by passing a `Person` record and `FieldMask[]` as parameters. Successful creation returns the created contact as a `PersonResponse` and the error cases returns an `error` object.

```ballerina
people:Person person = {
    emailAddresses: [],
    names: [{
        familyName: "Hardy",
        givenName: "Jason",
        unstructuredName: "Jason Hardy"
    }]
};
people:FieldMask[] personFields = [people:NAME, people:PHONE_NUMBER, people:EMAIL_ADDRESS];
people:PersonResponse createContact = check googleContactClient->createContact(person, personFields);
```
## Snippets
Snippets of some operations.

- Create a contact
    ``` ballerina
    people:Person person = {
        emailAddresses: [],
        names: [{
            familyName: "Hardy",
            givenName: "Jason",
            unstructuredName: "Jason Hardy"
        }]
    };
    people:FieldMask[] personFields = [people:NAME, people:PHONE_NUMBER, people:EMAIL_ADDRESS];
    people:PersonResponse createContact = check googleContactClient->createContact(person, personFields);
    ```

- Get contact by resource name
    ```ballerina
    people:FieldMask[] getPersonFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    people:PersonResponse getResponse = check googleContactClient->getPeople(<Contact_Resource_Name>, getPersonFields);
    ```

- Create a contact group
    ```ballerina
    people:ContactGroup createContactGroup = check googleContactClient->createContactGroup("TestContactGroup");
    ```

### [You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.people/tree/main/gpeople/samples)
