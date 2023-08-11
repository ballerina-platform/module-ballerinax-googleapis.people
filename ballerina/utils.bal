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

import ballerina/url;
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

# Prepare URL with for batch operations.
# 
# + pathReceived - Recieved path
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
# + return - PersonResponse stream on success, else an error
isolated function convertImageToBase64String(string imagePath) returns string|error {
    byte[] bytes = check io:fileReadBytes(imagePath);
    string encodedString = bytes.toBase64();
    return encodedString;
}

# Get persons stream.
# 
# + googleContactClient - Contact client
# + persons - PersonResponse array
# + pathProvided -Provided path
# + options - Record that contains options parameters
# + return - PersonResponse stream on success, else an error
isolated function getContactsStream(http:Client googleContactClient, PersonResponse[] persons, string pathProvided = EMPTY_STRING, 
                           ContactListOptions? options = ()) returns stream<PersonResponse>|error {
    string path = prepareUrlWithContactOptions(pathProvided, options);
    http:Response|error httpResponse = googleContactClient->get(path);
    json response = check checkAndSetErrors(httpResponse);
    map<json> mapResponse = <map<json>> response;
    if (mapResponse.length() != 0) {
        ConnectionsResponse|error contactResponse = response.cloneWithType(ConnectionsResponse);
        if (contactResponse is ConnectionsResponse) {
            int i = persons.length();
            foreach PersonResponse person in contactResponse.connections {
                persons[i] = person;
                i = i + 1;
            }
            stream<PersonResponse> contactStream = (persons).toStream();
            string? pageToken = contactResponse?.nextPageToken;
            if (pageToken is string && options is ContactListOptions) {
                options.pageToken = pageToken;
                _ = check getContactsStream(googleContactClient, persons, EMPTY_STRING, options);
            }
            return contactStream;
        } else {
            return error(CONNECTION_RESPONSE_ERROR);
        }
    } else {
        return error("Contacts is empty");
    }
}

# Get persons stream.
# 
# + googleContactClient - Contact client
# + persons - PersonResponse array
# + pathProvided -Provided path
# + options - Record that contains options parameters
# + return - PersonResponse stream on success, else an error
isolated function getOtherContactsStream(http:Client googleContactClient, PersonResponse[] persons, 
                                string pathProvided = EMPTY_STRING, ContactListOptions? options = ()) 
                                returns stream<PersonResponse>|error {
    string path = prepareUrlWithContactOptions(pathProvided, options);
    http:Response|error httpResponse = googleContactClient->get(path);
    json response = check checkAndSetErrors(httpResponse);
    map<json> mapResponse = <map<json>> response;
    if (mapResponse.length() != 0) {
        OtherContactListResponse|error otherResponse = response.cloneWithType(OtherContactListResponse);
        if (otherResponse is OtherContactListResponse) {
            int i = persons.length();
            foreach PersonResponse person in otherResponse.otherContacts {
                persons[i] = person;
                i = i + 1;
            }
            stream<PersonResponse> contactStream = (persons).toStream();
            string? pageToken = otherResponse?.nextPageToken;
            if (pageToken is string && options is ContactListOptions) {
                options.pageToken = pageToken;
                _ = check getContactsStream(googleContactClient, persons, EMPTY_STRING, options);
            }
            return contactStream;
        } else {
            return error(OTHERCONTACT_RESPONSE_ERROR);
        }
    } else {
        return error("Other Contacts is empty");
    }
}

# Prepare URL with contact list options.
# 
# + pathProvided - An string of path
# + options - Record that contains options parameters
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
    return url;
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
        var encoded = url:encode(value, "utf-8");
        if (encoded is string) {
            if (first) {
                url = url + name + EQUAL + encoded;
                first = false;
            } else {
                url = url + AMBERSAND + name + EQUAL + encoded;
            }
        } else {
            log:printError("Unable to encode value: " + value);
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
isolated function checkAndSetErrors(http:Response|error httpResponse) returns json|error {
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
isolated function handleResponse(http:Response httpResponse) returns json|error {
    json response = check httpResponse.getJsonPayload();
    if (httpResponse.statusCode is http:STATUS_OK) {
        return response;
    } else {
        json err = check response.'error.message;
        return error(err.toString());
    }
}

# Handle http response which can have empty if value not exists.
# 
# + httpResponse - Received http response
# + return - JSON on success else an error
isolated function handleResponseWithNull(http:Response httpResponse) returns json|()|error {
    json response = check httpResponse.getJsonPayload();
    if (httpResponse.statusCode is http:STATUS_OK) {
        map<json> mapResponse = <map<json>> response;
        if (mapResponse.length() != 0) {
            return response;
        } else {
            return error("Search result is empty");
        }
    } else {
        json err = check response.'error.message;
        return error(err.toString());
    }
}

# Handle http response for delete response.
# 
# + httpResponse - Received http response
# + return - () on success else an error
isolated function handleDeleteResponse(http:Response httpResponse) returns error? {
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
isolated function handleUploadPhotoResponse(http:Response httpResponse) returns error? {
    if (httpResponse.statusCode is http:STATUS_OK) {
        return ();
    } else {
        json uploadPhotoResponse = check httpResponse.getJsonPayload();
        json err = check uploadPhotoResponse.'error.message;
        return error(err.toString());
    }
}

# Handle http response for modify contact group response.
# 
# + httpResponse - Received http response
# + return - () on success else an error
isolated function handleModifyResponse(http:Response httpResponse) returns error? {
    if (httpResponse.statusCode is http:STATUS_OK) {
        return ();
    } else {
        json uploadPhotoResponse = check httpResponse.getJsonPayload();
        json err = check uploadPhotoResponse.'error.message;
        return error(err.toString());
    }
}

isolated function prepareUpdate(Person updateContact, Person getContact) returns Person {
    var names = updateContact?.names;
    if(names is Name[]){
        getContact.names = names;
    }
    var emailAddresses = updateContact?.emailAddresses;
    if(emailAddresses is EmailAddress[]){
        getContact.emailAddresses = emailAddresses;
    }
    var biographies = updateContact?.biographies;
    if(biographies is Biography[]){
        getContact.biographies = biographies;
    }
    var birthdays = updateContact?.birthdays;
    if(birthdays is Birthday[]){
        getContact.birthdays = birthdays;
    }
    var braggingRights = updateContact?.braggingRights;
    if(braggingRights is BraggingRights[]){
        getContact.braggingRights = braggingRights;
    }
    var calendarUrls = updateContact?.calendarUrls;
    if(calendarUrls is CalendarUrl[]){
        getContact.calendarUrls = calendarUrls;
    }
    var clientData = updateContact?.clientData;
    if(clientData is ClientData[]){
        getContact.clientData = clientData;
    }
    var events = updateContact?.events;
    if(events is Event[]){
        getContact.events = events;
    }
    var externalIds = updateContact?.externalIds;
    if(externalIds is ExternalId[]){
        getContact.externalIds = externalIds;
    }
    var fileAses = updateContact?.fileAses;
    if(fileAses is FileAs[]){
        getContact.fileAses = fileAses;
    }
    var genders = updateContact?.genders;
    if(genders is Gender[]){
        getContact.genders = genders;
    }
    var imClients = updateContact?.imClients;
    if(imClients is ImClient[]){
        getContact.imClients = imClients;
    }
    var interests = updateContact?.interests;
    if(interests is Interest[]){
        getContact.interests = interests;
    }
    var locales = updateContact?.locales;
    if(locales is Locale[]){
        getContact.locales = locales;
    }
    var locations = updateContact?.locations;
    if(locations is Location[]){
        getContact.locations = locations;
    }
    var memberships = updateContact?.memberships;
    if(memberships is Membership[]){
        getContact.memberships = memberships;
    }
    var miscKeywords = updateContact?.miscKeywords;
    if(miscKeywords is MiscKeyword[]){
        getContact.miscKeywords = miscKeywords;
    }
    var nicknames = updateContact?.nicknames;
    if(nicknames is Nickname[]){
        getContact.nicknames = nicknames;
    }
    var occupations = updateContact?.occupations;
    if(occupations is Occupation[]){
        getContact.occupations = occupations;
    }
    var organizations = updateContact?.organizations;
    if(organizations is Organization[]){
        getContact.organizations = organizations;
    }
    var phoneNumbers = updateContact?.phoneNumbers;
    if(phoneNumbers is PhoneNumber[]){
        getContact.phoneNumbers = phoneNumbers;
    }
    var relations = updateContact?.relations;
    if(relations is Relation[]){
        getContact.relations = relations;
    }
    var sipAddresses = updateContact?.sipAddresses;
    if(sipAddresses is SipAddress[]){
        getContact.sipAddresses = sipAddresses;
    }
    var skills = updateContact?.skills;
    if(skills is Skill[]){
        getContact.skills = skills;
    }
    var urls = updateContact?.urls;
    if(urls is Url[]){
        getContact.urls = urls;
    }
    var userDefined = updateContact?.userDefined;
    if(userDefined is UserDefined[]){
        getContact.userDefined = userDefined;
    }
    return getContact;
}
