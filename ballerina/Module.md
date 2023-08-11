## Overview
Ballerina connector for Google People API connects the Google People API via Ballerina language with ease. It provides capability to perform operations related to contacts and contact groups in Google Contacts.

This module supports [Google People API](https://developers.google.com/people/api/rest) v1.0.

## Prerequisites
Before using this connector in your Ballerina application, complete the following:
* Create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?hl=en&flowName=GlifWebSignIn&flowEntry=SignUp)
* Obtain tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Google People API connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the ballerinax/googleapis.people module into the Ballerina project.
```ballerina
import ballerinax/googleapis.people as people;
```
### Step 2: Create a new connector instance

Enter the credentials in the Google People API client configuration, and create the Google People API client by passing the configuration.

```ballerina
people:ConnectionConfig googleContactConfig = {
    auth: {
        clientId: "<CLIENT_ID>",
        clientSecret: <CLIENT_SECRET>,
        refreshUrl: people:REFRESH_URL,
        refreshToken: <REFRESH_TOKEN>
    }
};

people:Client googleContactClient = check new (googleContactConfig);
```

### Step 3: Invoke connector operation

1. Create a contact via the `createContact` method by passing a `Person` record and `FieldMask[]` as parameters.

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

**[You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.people/tree/main/gpeople/samples)**
