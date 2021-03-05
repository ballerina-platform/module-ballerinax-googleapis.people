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
