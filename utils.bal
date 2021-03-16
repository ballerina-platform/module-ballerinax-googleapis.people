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

import ballerina/encoding;
import ballerina/http;
import ballerina/io;
import ballerina/log;

# Prepare URL with string parameters.
# 
# + url - Url to be appended
# + option - String of option to be added as query parameters
# + return - The prepared URL string
isolated function prepareUrlWithStringParameter(string url, string? option) returns string {
    string path = url;
    if(option is string){
        path = path + "?maxMembers=" + option;
    }
    return path;
}

# Prepare URL with person fields.
# 
# + url - Url to be appended
# + personFields - String array of fields to be fetched
# + return - The prepared URL string
isolated function prepareUrlWithPersonFields(string url, string[]? personFields = ()) returns string {
    string path = url + PERSON_FIELDS_PATH;
    int count = 0;
    if(personFields is string[]){
        while (count < (personFields.length() - 1)) {
            path = path + personFields[count] + COMMA;
            count = count + 1;
        }
        path = path + personFields[count];
    }
    return path;
}

# Prepare URL with update person fields.
# 
# + url - Url to be appended
# + updatePersonFields - String array of fields to be fetched
# + return - The prepared URL string
isolated function prepareUrlWithUpdatePersonFields(string url, string[]? updatePersonFields = ()) returns string {
    string path = url + UPDATE_PERSON_FIELDS_PATH;
    int count = 0;
    if(updatePersonFields is string[]){
        while (count < (updatePersonFields.length() - 1)) {
            path = path + updatePersonFields[count] + COMMA;
            count = count + 1;
        }
        path = path + updatePersonFields[count];
    }
    return path;
}

# Prepare URL with read masks.
# 
# + url - Url to be appended
# + readMasks - String array of fields to be fetched
# + return - The prepared URL string
isolated function prepareUrlWithReadMasks(string url, string[]? readMasks = ()) returns string {
    string path = url + "readMask=";
    int count = 0;
    if(readMasks is string[]){
        while (count < (readMasks.length() - 1)) {
            path = path + readMasks[count] + COMMA;
            count = count + 1;
        }
        path = path + readMasks[count];
    }
    return path;
}

# Prepare URL with optional sources.
# 
# + url - Url to be appended
# + sources - An string array of sources to be restricted
# + return - The prepared URL string
isolated function prepareUrlWithOptionalSources(string url, string[]? sources) returns string {
    string path = url;
    if (sources is string[]) {
        path = url + "&sources=";
        int count = 0;
        while (count < (sources.length() - 1)) {
            path = path + sources[count] + COMMA;
            count = count + 1;
        }
        path = path + sources[count];
    }
    return path;
}

# Prepare URL with copy masks.
# 
# + copyMasks - An string array of fields to be copied
# + return - The prepared URL string
isolated function prepareCopyMaskString(string[] copyMasks) returns string {
    string path = EMPTY_STRING;
    int count = 0;
    while (count < (copyMasks.length() - 1)) {
        path = path + copyMasks[count] + COMMA;
        count = count + 1;
    }
    path = path + copyMasks[count];
    return path;
}

# Prepare URL with read masks.
# 
# + readMasks - String array of fields to be fetched
# + return - The prepared URL string
isolated function prepareReadMaskString(string[]? readMasks) returns string {
    string path = EMPTY_STRING;
    int count = 0;
    if(readMasks is string[]){
        while (count < (readMasks.length() - 1)) {
            path = path + readMasks[count] + COMMA;
            count = count + 1;
        }
        path = path + readMasks[count];
    }
    return path;
}

# Prepare URL with read group fields.
# 
# + readGroupFields - String array of fields to be fetched
# + return - The prepared URL string
isolated function prepareReadGroupFieldsString(string[] readGroupFields) returns string {
    string path = EMPTY_STRING;
    int count = 0;
    while (count < (readGroupFields.length() - 1)) {
        path = path + readGroupFields[count] + COMMA;
        count = count + 1;
    }
    path = path + readGroupFields[count];
    return path;
}

# Prepare URL with for batch operations.
# 
# + resourceNames - String array of resource names
# + return - The prepared URL string
isolated function prepareResourceString(string pathReceived, string[] resourceNames) returns string {
    string path= pathReceived;
    int count = 0;
    while (count < (resourceNames.length() - 1)) {
        path = path + CONTACTGROUP_PATH + resourceNames[count] + AMBERSAND;
        count = count + 1;
    }
    path = path + CONTACTGROUP_PATH + resourceNames[count];
    return path;
}

# Convert image to base64-encoded string.
# 
# + imagePath - Path to image source from root directory
# + return - Person stream on success, else an error
function convertImageToBase64String(string imagePath) returns string|error {
    byte[] bytes = check io:fileReadBytes(imagePath);
    string encodedString = bytes.toBase64();
    return encodedString;
}

# Get persons stream.
# 
# + googleContactClient - Contact client
# + persons - Person array
# + options - Record that contains options parameters
# + return - Person stream on success, else an error
function getContacts(http:Client googleContactClient, @tainted Person[] persons, string pathProvided = EMPTY_STRING, 
                           ContactListOptions? options = ()) returns @tainted stream<Person>|ContactsTriggerResponse|error {
    string path = <@untainted>prepareUrlWithContactOptions(pathProvided, options);
    var httpResponse = googleContactClient->get(path);
    json getResponse = check checkAndSetErrors(httpResponse);
    ConnectionsResponse|ContactsTriggerResponse|error response = getResponse.cloneWithType(ConnectionsResponse);
    if (response is ConnectionsResponse) {
        int i = persons.length();
        foreach Person person in response.connections {
            persons[i] = person;
            i = i + 1;
        }
        stream<Person> contactStream = (<@untainted>persons).toStream();
        string? pageToken = response?.nextPageToken;
        if (pageToken is string && options is ContactListOptions) {
            options.pageToken = pageToken;
            var streams = check getContactsStream(googleContactClient, persons, EMPTY_STRING, options);
        }
        return contactStream;
    } else {
        ContactsTriggerResponse | error triggerResponse = getResponse.cloneWithType(ContactsTriggerResponse);
        if (triggerResponse is ContactsTriggerResponse) {
        string? syncToken = triggerResponse?.nextSyncToken;
        if (syncToken is string && options is ContactListOptions) {
            options.syncToken = syncToken;
            var getContacts = check getContacts(googleContactClient, persons, EMPTY_STRING, options);
        }
        return triggerResponse;
        } else {
            return error(CONNECTION_RESPONSE_ERROR);
        }
    }
}

# Get persons stream.
# 
# + googleContactClient - Contact client
# + persons - Person array
# + options - Record that contains options parameters
# + return - Person stream on success, else an error
function getContactsStream(http:Client googleContactClient, @tainted Person[] persons, string pathProvided = EMPTY_STRING, 
                           ContactListOptions? options = ()) returns @tainted stream<Person>|error {
    string path = <@untainted>prepareUrlWithContactOptions(pathProvided, options);
    var httpResponse = googleContactClient->get(path);
    json resp = check checkAndSetErrors(httpResponse);
    ConnectionsResponse|error res = resp.cloneWithType(ConnectionsResponse);
    if (res is ConnectionsResponse) {
        int i = persons.length();
        foreach Person person in res.connections {
            persons[i] = person;
            i = i + 1;
        }
        stream<Person> contactStream = (<@untainted>persons).toStream();
        string? pageToken = res?.nextPageToken;
        if (pageToken is string && options is ContactListOptions) {
            options.pageToken = pageToken;
            var streams = check getContactsStream(googleContactClient, persons, EMPTY_STRING, options);
        }
        return contactStream;
    } else {
        return error(CONNECTION_RESPONSE_ERROR);
    }
}

# Get persons stream.
# 
# + googleContactClient - Contact client
# + persons - Person array
# + options - Record that contains options parameters
# + return - Person stream on success, else an error
function getOtherContactsStream(http:Client googleContactClient, @tainted Person[] persons, 
                                string pathProvided = EMPTY_STRING, ContactListOptions? options = ()) 
                                returns @tainted stream<Person>|error {
    string path = <@untainted>prepareUrlWithContactOptions(pathProvided, options);
    var httpResponse = googleContactClient->get(path);
    json resp = check checkAndSetErrors(httpResponse);
    OtherContactListResponse|error res = resp.cloneWithType(OtherContactListResponse);
    if (res is OtherContactListResponse) {
        int i = persons.length();
        foreach Person person in res.otherContacts {
            persons[i] = person;
            i = i + 1;
        }
        stream<Person> contactStream = (<@untainted>persons).toStream();
        string? pageToken = res?.nextPageToken;
        if (pageToken is string && options is ContactListOptions) {
            options.pageToken = pageToken;
            var streams = check getContactsStream(googleContactClient, persons, EMPTY_STRING, options);
        }
        return contactStream;
    } else {
        return error(OTHERCONTACT_RESPONSE_ERROR);
    }
}

# Get persons stream.
# 
# + googleContactClient - Contact client
# + contactgroups - Array of contact groups
# + options - Record that contains options parameters
# + return - Person stream on success, else an error
function getContactGroupStream(http:Client googleContactClient, @tainted ContactGroup[] contactgroups, 
                                string pathProvided = EMPTY_STRING, ContactListOptions? options = ()) 
                                returns @tainted stream<ContactGroup>|error {
    string path = <@untainted>prepareUrlWithContactOptions(pathProvided, options);
    var httpResponse = googleContactClient->get(path);
    json resp = check checkAndSetErrors(httpResponse);
    ContactGroupListResponse|error res = resp.cloneWithType(ContactGroupListResponse);
    if (res is ContactGroupListResponse) {
        int i = contactgroups.length();
        foreach ContactGroup person in res.contactGroups {
            contactgroups[i] = person;
            i = i + 1;
        }
        stream<ContactGroup> contactStream = (<@untainted>contactgroups).toStream();
        string? pageToken = res?.nextPageToken;
        if (pageToken is string && options is ContactListOptions) {
            options.pageToken = pageToken;
            var streams = check getContactGroupStream(googleContactClient, contactgroups, EMPTY_STRING, options);
        }
        return contactStream;
    } else {
        return error(OTHERCONTACT_RESPONSE_ERROR);
    }
}

# Prepare URL with contact list options.
# 
# + pathProvided - An string of path
# + return - The prepared URL string
isolated function prepareUrlWithContactOptions(string pathProvided = EMPTY_STRING, ContactListOptions? options = ()) 
                                               returns string {
    string[] value = [];
    map<string> optionsMap = {};
    string path = pathProvided;
    if (options is ContactListOptions) {
        if (options.pageToken is string) {
            optionsMap["pageToken"] = options.pageToken.toString();
        }
        if (options.requestSyncToken is boolean) {
            optionsMap["requestSyncToken"] = options.requestSyncToken.toString();
        }
        if (options.syncToken is string) {
            optionsMap["syncToken"] = options.syncToken.toString();
        }
        foreach var val in optionsMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionsMap.keys(), value);
    }
    return path;
}

# Prepare URL.
# 
# + paths - An array of paths prefixes
# + return - The prepared URL
isolated function prepareUrl(string[] paths) returns string {
    string url = EMPTY_STRING;
    if (paths.length() > 0) {
        foreach var path in paths {
            if (!path.startsWith(SLASH)) {
                url = url + SLASH;
            }
            url = url + path;
        }
    }
    return <@untainted>url;
}

# Prepare URL with encoded query.
# 
# + paths - An array of paths prefixes
# + queryParamNames - An array of query param names
# + queryParamValues - An array of query param values
# + return - The prepared URL with encoded query
isolated function prepareQueryUrl(string[] paths, string[] queryParamNames, string[] queryParamValues) returns string {
    string url = prepareUrl(paths);
    url = url + QUESTION_MARK;
    boolean first = true;
    int i = 0;
    foreach var name in queryParamNames {
        string value = queryParamValues[i];
        var encoded = encoding:encodeUriComponent(value, "utf-8");
        if (encoded is string) {
            if (first) {
                url = url + name + EQUAL + encoded;
                first = false;
            } else {
                url = url + AMBERSAND + name + EQUAL + encoded;
            }
        } else {
            log:printError("Unable to encode value: " + value, err = encoded);
            break;
        }
        i = i + 1;
    }
    return url;
}

# Check http response and return JSON payload on success else an error.
# 
# + httpResponse - HTTP respone or http payload or error
# + return - JSON result on success else an error
isolated function checkAndSetErrors(http:Response|http:PayloadType|error httpResponse) returns @tainted json|error {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_OK) {
            json|error jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return jsonResponse;
            } else {
                return error(JSON_PAYLOAD_ERROR, jsonResponse);
            }
        } else {
            json|error jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                json err = check jsonResponse.'error.message;
                return error(HTTP_RESPONSE_ERROR + err.toString());
            } else {
                return error(PAYLOAD_ERROR, jsonResponse);
            }
        }
    } else {
        return error(HTTP_RESPONSE_ERROR + (<error>httpResponse).message());
    }
}

# Handle http response.
# 
# + httpResponse - Received http response
# + return - JSON on success else an error
isolated function handleResponse(http:Response httpResponse) returns @tainted json|error {
    json response = check httpResponse.getJsonPayload();
    if (httpResponse.statusCode is http:STATUS_OK) {
        return response;
    } else {
        json err = check response.'error.message;
        return error(err.toString());
    }
}

# Handle http response for delete response.
# 
# + httpResponse - Received http response
# + return - () on success else an error
isolated function handleDeleteResponse(http:Response httpResponse) returns @tainted error? {
    if (httpResponse.statusCode is http:STATUS_OK) {
        return ();
    } else {
        json deleteResponse = check httpResponse.getJsonPayload();
        json err = check deleteResponse.'error.message;
        return error(err.toString());
    }
}

# Handle http response for upload photo response.
# 
# + httpResponse - Received http response
# + return - () on success else an error
isolated function handleUploadPhotoResponse(http:Response httpResponse) returns @tainted error? {
    if (httpResponse.statusCode is http:STATUS_OK) {
        return ();
    } else {
        json uploadPhotoResponse = check httpResponse.getJsonPayload();
        json err = check uploadPhotoResponse.'error.message;
        return error(err.toString());
    }
}

function getSyncContactsStream(http:Client googleContactClient, string[] personFields, @tainted ConnectionsStreamResponse 
response, @tainted Person[] persons, int? count = (), string? syncToken = (), string? pageToken = ()) 
returns @tainted ConnectionsStreamResponse|error {
    string[] value = [];
    map<string> optionals = {};
    if (count is int) {
        optionals["maxResults"] = count.toString();
    }
    if (pageToken is string) {
        optionals["pageToken"] = pageToken;
    }
    optionals.forEach(function(string val) {
        value.push(val);
    });
    string path = <@untainted> prepareQueryUrlForToken(TOKEN_PATH, optionals.keys(), value);
    var httpResponse = googleContactClient->get(path);
    json resp = check checkAndSetErrors(httpResponse);
    ConnectionsResponse|error res = resp.cloneWithType(ConnectionsResponse);
    if (res is ConnectionsResponse) {
        int i = persons.length();
        foreach Person person in res.connections {
            persons[i] = person;
            i = i + 1;
        }
        stream<Person> eventStream = (<@untainted>persons).toStream();
        string? nextPageToken = res?.nextPageToken;
        if (nextPageToken is string) {
            var streams = check getSyncContactsStream(googleContactClient, personFields, response, persons, count,
            syncToken, nextPageToken);          
        } 
        else {
            string? nextSyncToken = res?.nextSyncToken;
            if (nextSyncToken is string) {    
                response.nextSyncToken = nextSyncToken;       
            }        
        }
        response.connections = eventStream;          
        return response;      
    } else {
        return error("ERR_EVENT_RESPONSE", res);
    }
}

isolated function prepareQueryUrlForToken(string path, string[] queryParamNames, string[] queryParamValues) 
returns string {
    string url = path;
    boolean first = true;
    int i = 0;
    foreach var name in queryParamNames {
        string value = queryParamValues[i];
        var encoded = encoding:encodeUriComponent(value, "utf-8");
        if (encoded is string) {
            if (first) {
                url = url + AMBERSAND + name + EQUAL + encoded;
                first = false;
            } else {
                url = url + AMBERSAND + name + EQUAL + encoded;
            }
        } else {
            log:printError("Unable to encode value: " + value, err = encoded);
            break;
        }
        i = i + 1;
    }
    return url;
}
