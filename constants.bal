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

const string BASE_URL = "https://people.googleapis.com/v1";
# Holds the value for URL of refresh token end point
public const string REFRESH_URL = "https://www.googleapis.com/oauth2/v4/token";
const string EMPTY_STRING = "";
const string SPACE = " ";
const string SLASH = "/";
const string COLON = ":";
const string QUESTION_MARK = "?";
const string AMBERSAND = "&";
const string EQUAL = "=";
const string COMMA = ",";
# Constant for paths.
const string CONTACT_GROUP_PATH = "contactGroups";
const string BATCH_CONTACT_GROUP_PATH = ":batchGet?";
const string LIST_PEOPLE_PATH = "people/me/connections?requestSyncToken=true&";
const string LIST_CONTACTS = "/people/me/connections?";
const string TOKEN_PATH = "/people/me/connections?personFields=names,emailAddresses&pageSize=1&requestSyncToken=true";
const string PERSON_FIELDS = "?personFields=";
const string CREATE_CONTACT_PATH = "/people:createContact";
const string QUERY_PATH = "&query=";
const string CONTACTGROUP_PATH = "resourceNames=";
const string UPDATE_PHOTO_PATH = "updateContactPhoto";
const string DELETE_PHOTO_PATH = "deleteContactPhoto";
const string UPDATE_CONTACT_PATH = ":updateContact";
const string DELETE_CONTACT_PATH = "deleteContact";
const string LIST_DIRECTORY_PEOPLE_PATH = "/people:listDirectoryPeople";
const string READ_MASK_PATH = "?readMask=names,emailAddresses,phoneNumbers";
const string SOURCE_PATH = "&sources=DIRECTORY_SOURCE_TYPE_DOMAIN_CONTACT";
const string BATCH_CONTACT_PATH = "people:batchGet?";
const string BATCH_RESOURCE_PATH = "resourceNames=people/me";
const string PERSON_FIELDS_PATH = "personFields=";
const string UPDATE_PERSON_FIELDS_PATH = "updatePersonFields=";
const string SEARCH_CONTACT_PATH = "people:searchContacts";
const string SEARCH_OTHERCONTACT_PATH = "/otherContacts:search";
const string COPY_CONTACT_PATH = ":copyOtherContactToMyContactsGroup";
const string LIST_OTHERCONTACT_PATH = "/otherContacts?readMask=";
const string OTHERCONTACT_RESPONSE_ERROR = "Error in fetching OtherContacts";
const string CONNECTION_RESPONSE_ERROR = "Error in fetching ConnectionsResponse";
const string JSON_PAYLOAD_ERROR = "Error occurred while accessing the JSON payload of the response.";
const string HTTP_RESPONSE_ERROR = "Error occurred while getting the HTTP response : ";
const string PAYLOAD_ERROR = "Error occured while extracting errors from payload.";
const string SEARCH_ERROR = "Search query not matched";
