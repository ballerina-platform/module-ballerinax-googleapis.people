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
import ballerina/io;
import ballerina/http;
import ballerina/encoding;
import ballerina/log;

# Create Error.
# 
# + message - message to be attached to error
# + err - error to be set
# + return - returns a GoogleContactsError
isolated function createError(string message, error? err = ()) returns error {
    error googleContactsError;
    if (err is error) {
        googleContactsError = error GoogleContactsError(message, err);
    } else {
        googleContactsError = error GoogleContactsError(message);
    }
    return googleContactsError;
}

# Prepare URL with PersonFields.
# 
# + url - Url to be appended
# + personFields - An string array of fields to be fetched
# + return - The prepared URL string
isolated function prepareUrlWithPersonFields(string url, string[] personFields) returns string {
    string path = url;
    int count = 0;
    while (count < (personFields.length() - 1)) {
        path = path + personFields[count] + ",";
        count = count + 1;
    }
    path = path + personFields[count];
    return path;
}

# Prepare URL with ReadMasks.
# 
# + url - Url to be appended
# + readMasks - An string array of fields to be fetched
# + return - The prepared URL string
isolated function prepareUrlWithReadMasks(string url, string[] readMasks) returns string {
    string path = url;
    int count = 0;
    while (count < (readMasks.length() - 1)) {
        path = path + readMasks[count] + ",";
        count = count + 1;
    }
    path = path + readMasks[count];
    return path;
}

# Prepare URL with Optional Sources.
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
            path = path + sources[count] + ",";
            count = count + 1;
        }
        path = path + sources[count];
    }
    return path;
}

# Prepare URL with CopyMask.
# 
# + copyMasks - An string array of fields to be copied
# + return - The prepared URL string
isolated function prepareCopyMaskString(string[] copyMasks) returns string {
    string path = "";
    int count = 0;
    while (count < (copyMasks.length() - 1)) {
        path = path + copyMasks[count] + ",";
        count = count + 1;
    }
    path = path + copyMasks[count];
    return path;
}

# Prepare URL with ReadMaskFields.
# 
# + readMasks - An string array of fields to be fetched
# + return - The prepared URL string
isolated function prepareReadMaskString(string[] readMasks) returns string {
    string path = "";
    int count = 0;
    while (count < (readMasks.length() - 1)) {
        path = path + readMasks[count] + ",";
        count = count + 1;
    }
    path = path + readMasks[count];
    return path;
}

# Prepare URL with ReadGroupFields.
# 
# + readGroupFields - An string array of fields to be fetched
# + return - The prepared URL string
isolated function prepareReadGroupFieldsString(string[] readGroupFields) returns string {
    string path = "";
    int count = 0;
    while (count < (readGroupFields.length() - 1)) {
        path = path + readGroupFields[count] + ",";
        count = count + 1;
    }
    path = path + readGroupFields[count];
    return path;
}

# Prepare URL with For Batch Operations.
# 
# + resourceNames - An string array of resourceNames
# + return - The prepared URL string
isolated function prepareResourceString(string pathReceived, string[] resourceNames) returns string {
    string path= pathReceived;
    int count = 0;
    while (count < (resourceNames.length() - 1)) {
        path = path + CONTACTGROUP_PATH + resourceNames[count] + "&";
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
function getContactsStream(http:Client googleContactClient, @tainted Person[] persons, string pathProvided = "", 
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
function getOtherContactsStream(http:Client googleContactClient, @tainted Person[] persons, string pathProvided = "", 
                                ContactListOptions? options = ()) returns @tainted stream<Person>|error {
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

# Prepare URL with Contact Optional.
# 
# + pathProvided - An string of path
# + return - The prepared URL string
isolated function prepareUrlWithContactOptions(string pathProvided = "", ContactListOptions? options = ()) 
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
    string url = "";
    if (paths.length() > 0) {
        foreach var path in paths {
            if (!path.startsWith("/")) {
                url = url + "/";
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
    url = url + "?";
    boolean first = true;
    int i = 0;
    foreach var name in queryParamNames {
        string value = queryParamValues[i];
        var encoded = encoding:encodeUriComponent(value, "utf-8");
        if (encoded is string) {
            if (first) {
                url = url + name + "=" + encoded;
                first = false;
            } else {
                url = url + "&" + name + "=" + encoded;
            }
        } else {
            log:printError("Unable to encode value: " + value, err = encoded);
            break;
        }
        i = i + 1;
    }
    return url;
}

# Check HTTP response and return JSON payload on success else an error.
# 
# + httpResponse - HTTP respone or HTTP payload or error
# + return - JSON result on success else an error
isolated function checkAndSetErrors(http:Response|http:PayloadType|error httpResponse) returns @tainted json|error {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_OK || httpResponse.statusCode == http:STATUS_CREATED) {
            json|error jsonResponse = httpResponse.getJsonPayload();
            if (jsonResponse is json) {
                return jsonResponse;
            } else {
                return error(JSON_PAYLOAD_ERROR, jsonResponse);
            }
        } else if (httpResponse.statusCode == http:STATUS_NO_CONTENT) {
            return {};
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
