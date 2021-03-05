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

public type GoogleContactsError distinct error;

public type OtherContactList record {
    Person[] otherContacts;
};

# Define a Person.
#
# + resourceName - String of the resource name
# + etag - ETag of the resource
# + metadata - Metadata about person
# + addresses - Person's street addresses.
# + ageRanges - Person's age ranges.
# + biographies - Person's biographies
# + birthdays - Person's birthdays.
# + braggingRights - Person's bragging rights.
# + calendarUrls - Person's calendar URLs.
# + clientData - Person's client data.
# + coverPhotos - Person's cover photos.
# + emailAddresses - Person's email addresses.
# + events - Person's events.
# + externalIds - Person's external IDs.
# + fileAses - Person's file-ases.
# + genders - Person's genders. 
# + imClients - Person's instant messaging clients.
# + interests - Person's interests.
# + locales - Person's locale preferences.
# + locations - Person's locations.
# + memberships - Person's group memberships.
# + miscKeywords - Person's miscellaneous keywords.
# + names - Person's names.
# + nicknames - Person's nicknames.
# + occupations - Person's occupations.
# + organizations - Person's organizations.
# + phoneNumbers - Person's phoneNumbers.
# + photos - Person's photos.
# + relations - Person's relations.
# + sipAddresses - Person's sipAddresses.
# + skills - Person's skills.
# + urls - Person's URLs.
# + userDefined - user defined data
public type Person record {
    string resourceName;
    string etag;
    PersonMetadata metadata?;
    Address[] addresses?;
    AgeRangeType[] ageRanges?;
    Biography[] biographies?;
    Birthday[] birthdays?;
    BraggingRights[] braggingRights?;
    CalendarUrl[] calendarUrls?;
    ClientData[] clientData?;
    CoverPhoto[] coverPhotos?;
    EmailAddress[] emailAddresses?;
    Event[] events?;
    ExternalId[] externalIds?;
    FileAs[] fileAses?;
    Gender[] genders?;
    ImClient[] imClients?;
    Interest[] interests?;
    Locale[] locales?;
    Location[] locations?;
    Membership[] memberships?;
    MiscKeyword[] miscKeywords?;
    Name[] names?;
    Nickname[] nicknames?;
    Occupation[] occupations?;
    Organization[] organizations?;
    PhoneNumber[] phoneNumbers?;
    Photo[] photos?;
    Relation[] relations?;
    SipAddress[] sipAddresses?;
    Skill[] skills?;
    Url[] urls?;
    UserDefined[] userDefined?;
};

# Define a Person's meta data.
#
# + sources - sources of data for the person
# + objectType - type of the person object.
public type PersonMetadata record {
    json[] 'sources?;
    string objectType?;
};

# Define a Create Person Payload.
#
# + addresses - Person's street addresses.
# + biographies - Person's biographies
# + birthdays - Person's birthdays.
# + braggingRights - Person's bragging rights.
# + calendarUrls - Person's calendar URLs.
# + clientData - Person's client data.
# + emailAddresses - Person's email addresses.
# + events - Person's events.
# + externalIds - Person's external IDs.
# + fileAses - Person's file-ases.
# + genders - Person's genders. 
# + imClients - Person's instant messaging clients.
# + interests - Person's interests.
# + locales - Person's locale preferences.
# + locations - Person's locations.
# + memberships - Person's group memberships.
# + miscKeywords - Person's miscellaneous keywords.
# + names - Person's names.
# + nicknames - Person's nicknames.
# + occupations - Person's occupations.
# + organizations - Person's organizations.
# + phoneNumbers - Person's phoneNumbers.
# + relations - Person's relations.
# + sipAddresses - Person's sipAddresses.
# + skills - Person's skills.
# + urls - Person's URLs.
# + userDefined - user defined data
public type CreatePerson record {
    Address[] addresses?;
    Biography[] biographies?;
    Birthday[] birthdays?;
    BraggingRights[] braggingRights?;
    CalendarUrl[] calendarUrls?;
    ClientData[] clientData?;
    EmailAddress[] emailAddresses?;
    Event[] events?;
    ExternalId[] externalIds?;
    FileAs[] fileAses?;
    Gender[] genders?;
    ImClient[] imClients?;
    Interest[] interests?;
    Locale[] locales?;
    Location[] locations?;
    Membership[] memberships?;
    MiscKeyword[] miscKeywords?;
    Name[] names?;
    Nickname[] nicknames?;
    Occupation[] occupations?;
    Organization[] organizations?;
    PhoneNumber[] phoneNumbers?;
    Relation[] relations?;
    SipAddress[] sipAddresses?;
    Skill[] skills?;
    Url[] urls?;
    UserDefined[] userDefined?;
};

# Define a Address.
#
# + metadata - Metadata about Address
# + formattedValue - The unstructured value of the address.
# + type - The type of the address. 
# + formattedType - The type of the address formatted
# + poBox - Post box Number of the address
# + streetAddress - The street address.
# + extendedAddress - The extended address of the address
# + city - The city of the address
# + region - The region of the address
# + postalCode - The postal code of the address.
# + country - The country of the address.
# + countryCode - country code of the address.
public type Address record {
    FieldMetaData metadata?;
    string formattedValue?;
    string 'type?;
    string formattedType?;
    string poBox?;
    string streetAddress?;
    string extendedAddress?;
    string city?;
    string region?;
    string postalCode?;
    string country?;
    string countryCode?;
};

# Define a PhoneNumber.
#
# + metadata - Metadata about PhoneNumber
# + value - 
# + canonicalForm - 
# + type - 
# + formattedType - 
public type PhoneNumber record {
    FieldMetaData metadata?;
    string value?;
    string canonicalForm?;
    string 'type?;
    string formattedType?;
};

# Define a Name.
#
# + metadata - Metadata about Name
# + displayName - 
# + displayNameLastFirst - 
# + unstructuredName - 
# + familyName - 
# + givenName - 
# + middleName - 
# + honorificPrefix - 
# + honorificSuffix - 
# + phoneticFullName - 
# + phoneticFamilyName - 
# + phoneticGivenName - 
# + phoneticMiddleName - 
# + phoneticHonorificPrefix - 
# + phoneticHonorificSuffix - 
public type Name record {
    FieldMetaData metadata?;
    string displayName?;
    string displayNameLastFirst?;
    string unstructuredName?;
    string familyName?;
    string givenName?;
    string middleName?;
    string honorificPrefix?;
    string honorificSuffix?;
    string phoneticFullName?;
    string phoneticFamilyName?;
    string phoneticGivenName?;
    string phoneticMiddleName?;
    string phoneticHonorificPrefix?;
    string phoneticHonorificSuffix?;
};

# Define an Email Address.
#
# + metadata - Metadata about Email Address
# + value - The email address.
# + type - The type of the email address. (home/work)
# + formattedType - type of the email address formatted 
# + displayName - display name of the email.
public type EmailAddress record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
    string formattedType?;
    string displayName?;
};

# Define a Photo.
#
# + metadata - Metadata about Photo
# + url - 
# + default - 
public type Photo record {
    FieldMetaData metadata?;
    string url?;
    boolean 'default?;
};

# Define an Age Range.
#
# + metadata - Metadata about Age Range
# + ageRange - The age range.
public type AgeRangeType record {
    FieldMetaData metadata?;
    AgeRange ageRange?;
};

# Define an Biography.
#
# + metadata - Metadata about Biography
# + value - The age range.
# + contentType - The age range.
public type Biography record {
    FieldMetaData metadata?;
    string value?;
    ContentType contentType?;
};

# Define an Birthday.
#
# + metadata - Metadata about Birthday
# + text -  string representing the user's birthday.
# + date - date of BirthDay.
public type Birthday record {
    FieldMetaData metadata?;
    string text?;
    Date date?;
};

# Define an BraggingRights.
#
# + metadata - Metadata about BraggingRights
# + value - The age range.
public type BraggingRights record {
    FieldMetaData metadata?;
    string value?;
};

# Define a Calendar Url.
#
# + metadata - Metadata about Calendar Url
# + url - The calendar URL.
# + type - type of the calendar URL.
# + formattedType - type of the calendar URL formatted
public type CalendarUrl record {
    FieldMetaData metadata?;
    string url?;
    string 'type?;
    string formattedType?;
};

# Define an Arbitrary client data that is populated by clients.
#
# + metadata - Metadata about client data
# + key - client specified key of the client data.
# + value - client specified value of the client data
public type ClientData record {
    FieldMetaData metadata?;
    string key?;
    string value?;
};

# Define an Cover photo.
#
# + metadata - Metadata about cover photo
# + url - URL of the cover photo.
# + default - True if the cover photo is the default
public type CoverPhoto record {
    FieldMetaData metadata?;
    string url?;
    boolean 'default?;
};

# Define an Event.
#
# + metadata - Metadata about Event
# + date - The date of the event.
# + type - type of the event. 
# + formattedType -  type of the event formatted
public type Event record {
    FieldMetaData metadata?;
    Date date?;
    string 'type?;
    string formattedType?;
};

# Define an External entity.
#
# + metadata - Metadata about External entity
# + value - value of the external ID.
# + type - type of the external ID. 
# + formattedType -  type of the External entity formatted
public type ExternalId record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
    string formattedType?;
};

# Define a name that should be used to sort the person in a list
#
# + metadata - Metadata about file-as
# + value - value of the file-as.
public type FileAs record {
    FieldMetaData metadata?;
    string value?;
};

# Define an Gender.
#
# + metadata - Metadata about Gender
# + value - gender for the person
# + formattedValue - type of the Gender formatted
# + addressMeAs -   type that should be used to address the person
public type Gender record {
    FieldMetaData metadata?;
    string value?;
    string formattedValue?;
    string addressMeAs?;
};

# Define an  IM client.
#
# + metadata - Metadata about IM client.
# + username - user name used in the IM client.
# + type - The type of the IM client
# + formattedType - type that should be used to address the person
# + protocol - The protocol of the IM client.
# + formattedProtocol - The protocol of the IM client formatted
public type ImClient record {
    FieldMetaData metadata?;
    string username?;
    string 'type?;
    string formattedType?;
    string protocol?;
    string formattedProtocol?;
};

# Define an  Interest.
#
# + metadata - Metadata about Interest.
# + value - name of the Interest.
public type Interest record {
    FieldMetaData metadata?;
    string value?;
};

# Define an  Locale.
#
# + metadata - Metadata about Locale.
# + value - IETF BCP 47 language tag representing the locale.
public type Locale record {
    FieldMetaData metadata?;
    string value?;
};

# Define an  Location.
#
# + metadata - Metadata about Location.
# + value - value of the location..
# + type - The type of the location.
# + current - Whether the location is the current location.
# + buildingId - building identifier.
# + floor - floor name identifier.
# + floorSection - floor section in a floor
# + deskCode - desk location.
public type Location record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
    string current?;
    string buildingId?;
    string floor?;
    string floorSection?;
    string deskCode?;
};

# Define a miscellaneous keyword.
#
# + metadata - Metadata about miscellaneous keyword
# + value - value of the miscellaneous keyword.
# + type - type of the miscellaneous keyword. 
# + formattedType -  type of the miscellaneous keyword formatted
public type MiscKeyword record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
    string formattedType?;
};

# Define a Membership
#
# + metadata - Metadata about Membership
# + contactGroupMembership - group membership
# + domainMembership - domain membership
public type Membership record {
    FieldMetaData metadata?;
    string contactGroupMembership?;
    string domainMembership?;
};

# Define an Nickname
#
# + metadata - Metadata about Nickname
# + value - value of the nick name
# + type - type of the nick name
public type Nickname record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
};

# Define an Occupation
#
# + metadata - Metadata about Occupation
# + value - value of the occupation
public type Occupation record {
    FieldMetaData metadata?;
    string value?;
};

# Define an Organization.
#
# + metadata - Metadata about the organization
# + type - type of the organization.
# + formattedType - type organization formatted
# + startDate - start date in the organization
# + endDate - end date in the organization
# + current - whether it is the current organization
# + name - name of the organization
# + phoneticName - phonetic name of the organization
# + department - department at the organization
# + title - job title at the organization
# + jobDescription - job description in the organization
# + symbol - symbol of the occupation.
# + domain - domain name of the organization
# + location - location of the organization
public type Organization record {
    FieldMetaData metadata?;
    string 'type?;
    string formattedType?;
    Date startDate?;
    Date endDate?;
    string current?;
    string name?;
    string phoneticName?;
    string department?;
    string title?;
    string jobDescription?;
    string symbol?;
    string domain?;
    string location?;
};

# Define a Relation.
#
# + metadata - Metadata about relation
# + person - name of the relation
# + type - type of the relation
# + formattedType -  type of the relation formatted
public type Relation record {
    FieldMetaData metadata?;
    string person?;
    string 'type?;
    string formattedType?;
};

# Define a SIP address
#
# + metadata - Metadata about SIP address
# + value - name of the SIP address
# + type - type of the SIP address
# + formattedType -  type of the SIP address formatted
public type SipAddress record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
    string formattedType?;
};

# Define a Skill
#
# + metadata - Metadata about Skill
# + value - name of the skill
public type Skill record {
    FieldMetaData metadata?;
    string value?;
};

# Define an Url
#
# + metadata - Metadata about Url
# + value - name of the url
# + type - type of the url
# + formattedType -  type of the url formatted
public type Url record {
    FieldMetaData metadata?;
    string value?;
    string 'type?;
    string formattedType?;
};

# Define a Arbitrary user data.
#
# + metadata - Metadata about user defined data.
# + key - user specified key of the user defined data.
# + value - user specified value of the user defined data. 
public type UserDefined record {
    FieldMetaData metadata?;
    string key?;
    string value?;
};

# Define an FieldMetaData.
#
# + primary - True if the field is the primary field
# + verified - True if the field is verified
# + sources - source of the field.
public type FieldMetaData record {
    boolean primary?;
    boolean verified?;
    MetaDataSource 'sources?;
};

# Define an MetaDataSource
#
# + type - source type.
# + id - identifier within the source
public type MetaDataSource record {
    string 'type?;
    string id?;
};

# Define an ContactGroupResponse
#
# + requestedResourceName - resource requested.
# + status - status of resource
# + contactGroup - detail of contactGroup
public type ContactGroupResponse record {
    string requestedResourceName;
    json status;
    json contactGroup;
};

# Define an ContactGroup
#
# + resourceName - resource name.
# + etag - entity tag of the resource.
# + metadata - metadata about the contact group.
# + groupTypecontact - contact group type
# + name - contact group name set by the group owner or a system
# + formattedName - name in formatted
# + memberResourceNames - list of contact person names that are members of the contact group
# + memberCount - total number of contacts
# + clientData - contact group's client data.
public type ContactGroup record {
    string resourceName;
    string etag?;
    ContactGroupMetadata metadata?;
    GroupType groupTypecontact?;
    string name?;
    string formattedName?;
    string[] memberResourceNames?;
    int memberCount?;
    GroupClientData[] clientData?;
};

# Define an ContactGroupMetadata
#
# + updateTime - Time of update
# + deleted - Whether deleted is true
public type ContactGroupMetadata record {
    string updateTime?;
    boolean deleted?;
};

public enum AgeRange {
    AGE_RANGE_UNSPECIFIED,
    LESS_THAN_EIGHTEEN,
    EIGHTEEN_TO_TWENTY,
    TWENTY_ONE_OR_OLDER
}

public enum GroupType {
    GROUP_TYPE_UNSPECIFIED,
    USER_CONTACT_GROUP,
    SYSTEM_CONTACT_GROUP
}

public enum ContentType {
    CONTENT_TYPE_UNSPECIFIED,
    TEXT_PLAIN,
    TEXT_HTML
}

# Define a Date entity
#
# + year - Year of the date
# + month - Month of the date
# + day - Day of the date
public type Date record {
    int year?;
    int month?;
    int day?;
};

# Define a Contact Group Client Data
#
# + key - client specified key of the client data.
# + value - client specified value of the client data
public type GroupClientData record {
    string key?;
    string value?;
};

# Define a Contact Group List
#
# + contactGroups - Array of Contact Group
# + totalItems - total contacts
# + nextSyncToken - next sync token
public type ContactGroupList record {
    ContactGroup[] contactGroups;
    int totalItems;
    string nextSyncToken;
};

# Define a Contact Group Batch Result
#
# + responses - Array of Contact Group Responses
public type ContactGroupBatch record {
    ContactGroupResponse[] responses;
};

# Define a SearchResponse
#
# + results - Array of results
public type SearchResponse record {
    json[] results;
};

# Define a SearchResult
#
# + person - Type of Person
public type SearchResult record {
    Person person;
};

# Define a People Connection response
#
# + connections - Array of Person of authenticated user
# + nextPageToken - next page token
# + nextSyncToken - next sync token
# + totalPeople - total contacts
# + totalItems - total pages
public type ConnectionsResponse record {
    Person[] connections;
    string nextPageToken?;
    string nextSyncToken?;
    int totalPeople?;
    int totalItems?;
};

# Define a OtherContact List Response
#
# + otherContacts - Array of Person of in Other contacts
# + nextPageToken - next page token
# + nextSyncToken - next sync token
public type OtherContactListResponse record {
    Person[] otherContacts;
    string nextPageToken?;
    string nextSyncToken?;
};

# Define a BatchGetResponse
#
# + responses - Array of PersonResponse
public type BatchGetResponse record {
    PersonResponse[] responses?;
};

# Define a PersonResponse
#
# + httpStatusCode - Http Status Code
# + person - response of type Person
# + requestedResourceName - resource name requested
# + status - Status of the response
public type PersonResponse record {
    int httpStatusCode?;
    Person person?;
    string requestedResourceName?;
    json status?;
};

# Define a Stream response of a connection/Person
#
# + nextSyncToken - next sync token
# + totalPeople - total contacts
# + totalItems - total pages
# + connections - stream of type Person
public type ConnectionsStreamResponse record {
    string nextSyncToken?;
    int totalPeople?;
    int totalItems?;
    stream<Person> connections?;
};

# Define a Stream response of a connection/Person
#
# + pageToken - page token
# + requestSyncToken - whether request is needed
# + syncToken - sync token
public type ContactListOptions record {
    string? pageToken = ();
    boolean? requestSyncToken = ();
    string? syncToken = ();
};
