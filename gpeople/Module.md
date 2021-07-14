## Overview
Ballerina connector for Google People API is connecting the Google People API via Ballerina language easily. It provides capability to perform operations related to contacts and contact groups in Google Contacts.

This module supports [Google People API](https://developers.google.com/people) V1.0 version.

## Prerequisites
Before using this connector in your Ballerina application, complete the following:
* Create [Google Account](https://accounts.google.com/signup/v2/webcreateaccount?hl=en&flowName=GlifWebSignIn&flowEntry=SignUp)
* Obtaining tokens
        
    Follow [this link](https://developers.google.com/identity/protocols/oauth2) and obtain the client ID, client secret and refresh token.

## Quickstart

To use the Google People API connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
First, import the ballerinax/googleapis.people module into the Ballerina project.
```ballerina
import ballerinax/googleapis.people as people;
```
### Step 2: Create a new connector instance

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

### Step 3: Invoke connector operation

1. You can create a contact as follows with `createContact` method by passing a `Person` record and `FieldMask[]` as parameters. Successful creation returns the created contact as a `PersonResponse` and the error cases returns an `error` object.

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
2. Use `bal run` command to compile and run the Ballerina program. 

## Quick reference
The following code snippets shows how the connector operations can be used in different scenarios after initializing the client.
* Create a contact
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

* Get contact by resource name
    ```ballerina
    people:FieldMask[] getPersonFields = [NAME, PHONE_NUMBER, EMAIL_ADDRESS];
    people:PersonResponse getResponse = check googleContactClient->getPeople(<Contact_Resource_Name>, getPersonFields);
    ```

* Create a contact group
    ```ballerina
    people:ContactGroup createContactGroup = check googleContactClient->createContactGroup("TestContactGroup");
    ```

**[You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.people/tree/main/gpeople/samples)**
