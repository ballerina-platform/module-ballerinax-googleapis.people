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

import ballerina/http;
import ballerinax/'client.config;

# Client configuration details.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    # Configurations related to client authentication
    http:BearerTokenConfig|config:OAuth2RefreshTokenGrantConfig auth;
|};

# Define a Person.
#
# + resourceName - String of resource name
# + etag - ETag of resource
# + metadata - Metadata about person
# + ageRanges - Person's age ranges
# + coverPhotos - Person's cover photos
# + photos - Person's photos
public type PersonResponse record {
    string resourceName;
    string etag?;
    PersonMetadata metadata?;
    AgeRangeType[] ageRanges?;
    CoverPhoto[] coverPhotos?;
    Photo[] photos?;
    * Person;
};

# Define a Person's meta data.
#
# + sources - Sources of data for person
# + previousResourceNames - Previous resource name if changed
# + linkedPeopleResourceNames - Resource names of linked contacts
# + deleted - Show status whether deleted
# + objectType - Type of person object
public type PersonMetadata record {
    json[] 'sources?;
    string[] previousResourceNames?;
    string[] linkedPeopleResourceNames?;
    boolean deleted?;
    string objectType?;
};

# Define a Create Person Payload.
#
# + addresses - Person's addresses
# + biographies - Person's biographies
# + birthdays - Person's birthdays
# + braggingRights - Person's bragging rights
# + calendarUrls - Person's calendar URLs
# + clientData - Person's client data
# + emailAddresses - Person's email addresses
# + events - Person's events
# + externalIds - Person's external IDs
# + fileAses - Person's file-ases
# + genders - Person's genders
# + imClients - Person's instant messaging clients
# + interests - Person's interests
# + locales - Person's locale preferences
# + locations - Person's locations
# + memberships - Person's group memberships
# + miscKeywords - Person's miscellaneous keywords
# + names - Person's names
# + nicknames - Person's nicknames
# + occupations - Person's occupations
# + organizations - Person's organizations
# + phoneNumbers - Person's phoneNumbers
# + relations - Person's relations
# + sipAddresses - Person's sipAddresses
# + skills - Person's skills
# + urls - Person's URLs
# + userDefined - user defined data
public type Person record {
    @display {label: "Address"}
    Address[] addresses?;
    @display {label: "Biography"}
    Biography[] biographies?;
    @display {label: "Birthday"}
    Birthday[] birthdays?;
    @display {label: "Bragging Rights"}
    BraggingRights[] braggingRights?;
    @display {label: "Calendar Url"}
    CalendarUrl[] calendarUrls?;
    @display {label: "Client Data"}
    ClientData[] clientData?;
    @display {label: "Email Address"}
    EmailAddress[] emailAddresses?;
    @display {label: "Event"}
    Event[] events?;
    @display {label: "External Entity Identifier"}
    ExternalId[] externalIds?;
    @display {label: "Name For Sort"}
    FileAs[] fileAses?;
    @display {label: "Gender"}
    Gender[] genders?;
    @display {label: "Instant Messaging Client"}
    ImClient[] imClients?;
    @display {label: "Interest"}
    Interest[] interests?;
    @display {label: "Locale Preference"}
    Locale[] locales?;
    @display {label: "Location"}
    Location[] locations?;
    @display {label: "Membership In Group"}
    Membership[] memberships?;
    @display {label: "Miscellaneous Keyword"}
    MiscKeyword[] miscKeywords?;
    @display {label: "Name"}
    Name[] names?;
    @display {label: "Nickname"}
    Nickname[] nicknames?;
    @display {label: "Organization"}
    Occupation[] occupations?;
    @display {label: "Organization"}
    Organization[] organizations?;
    @display {label: "Phone Number"}
    PhoneNumber[] phoneNumbers?;
    @display {label: "Relation"}
    Relation[] relations?;
    @display {label: "SIP Address"}
    SipAddress[] sipAddresses?;
    @display {label: "Skill Of Person"}
    Skill[] skills?;
    @display {label: "Associated URL"}
    Url[] urls?;
    @display {label: "Arbitrary User Data"}
    UserDefined[] userDefined?;
};

# Define a Address.
#
# + metadata - Metadata about Address
# + formattedValue - Unstructured value of address
# + type - Type of address
# + formattedType - Type of address formatted
# + poBox - Post box Number of address
# + streetAddress - Street address
# + extendedAddress - Extended address of address
# + city - City of address
# + region - Region of address
# + postalCode - Postal code of address
# + country - Country of address
# + countryCode - Country code of address
public type Address record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Unstructured Address"}
    string formattedValue?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Address Type"}
    string formattedType?;
    @display {label: "Post Office Box"}
    string poBox?;
    @display {label: "Street address"}
    string streetAddress?;
    @display {label: "Extended Street Address"}
    string extendedAddress?;
    @display {label: "City"}
    string city?;
    @display {label: "Region"}
    string region?;
    @display {label: "Postal Code"}
    string postalCode?;
    @display {label: "Country"}
    string country?;
    @display {label: "Country Code"}
    string countryCode?;
};

# Define a PhoneNumber.
#
# + metadata - Metadata about PhoneNumber
# + value - Phone number
# + canonicalForm - Canonicalized ITU-T E.164 form of phone number
# + type - Type of phone number
# + formattedType - Phone number formatted
public type PhoneNumber record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Phone Number"}
    string value?;
    @display {label: "Canonicalized Form"}
    string canonicalForm?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
};

# Define a Name.
#
# + metadata - Metadata about Name
# + displayName - Display name formatted
# + displayNameLastFirst - Display name with last name
# + unstructuredName - Free form name value
# + familyName - Family name
# + givenName - Given name
# + middleName - Middle name
# + honorificPrefix - Honorific prefixes, such as Mrs. or Dr
# + honorificSuffix - Honorific suffixes, such as Jr.
# + phoneticFullName - Full name spelled as it sounds
# + phoneticFamilyName - Family name spelled as it sounds
# + phoneticGivenName - Given name spelled as it sounds
# + phoneticMiddleName - Middle name spelled as it sounds
# + phoneticHonorificPrefix - Honorific prefixes spelled as they sound
# + phoneticHonorificSuffix - Honorific suffixes spelled as they sound
public type Name record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Formatted Name"}
    string displayName?;
    @display {label: "Formatted Last Name First"}
    string displayNameLastFirst?;
    @display {label: "Unstructured Name"}
    string unstructuredName?;
    @display {label: "Family Name"}
    string familyName?;
    @display {label: "Given Name"}
    string givenName?;
    @display {label: "Middle Name"}
    string middleName?;
    @display {label: "Honorific Prefixes"}
    string honorificPrefix?;
    @display {label: "Honorific Suffixes"}
    string honorificSuffix?;
    @display {label: "Full Name As Pronounced"}
    string phoneticFullName?;
    @display {label: "Family Name As Pronounced"}
    string phoneticFamilyName?;
    @display {label: "Given Name As Pronounced"}
    string phoneticGivenName?;
    @display {label: "Middle Name As Pronounced"}
    string phoneticMiddleName?;
    @display {label: "Honorific Prefixes As Pronounced"}
    string phoneticHonorificPrefix?;
    @display {label: "Honorific Suffixes As Pronounced"}
    string phoneticHonorificSuffix?;
};

# Define an Email Address.
#
# + metadata - Metadata about Email Address
# + value - Value of email address
# + type - Type of email address(home/work)
# + formattedType - Type of email address formatted 
# + displayName - Display name of email
public type EmailAddress record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Email Address"}
    string value?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
    @display {label: "Formatted Email Address"}
    string displayName?;
};

# Define a Photo.
#
# + metadata - Metadata about Photo
# + url - URL to Photo
# + default - Whether default or not
public type Photo record {
    FieldMetaData metadata?;
    string url?;
    boolean 'default?;
};

# Define an Age Range.
#
# + metadata - Metadata about Age Range
# + ageRange - Age range
public type AgeRangeType record {
    FieldMetaData metadata?;
    AgeRange ageRange?;
};

# Define an Biography.
#
# + metadata - Metadata about Biography
# + value - Age range value
# + contentType - Age range
public type Biography record {
    @display {label: "Formatted Type"}
    FieldMetaData metadata?;
    @display {label: "Biography"}
    string value?;
    @display {label: "Content Type"}
    ContentType contentType?;
};

# Define an Birthday.
#
# + metadata - Metadata about Birthday
# + text - String representing user's birthday
# + date - Date of BirthDay
public type Birthday record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Date Of Birthday"}
    string text?;
    @display {label: "String Birthday Value"}
    Date date?;
};

# Define an BraggingRights.
#
# + metadata - Metadata about BraggingRights
# + value - Age range
public type BraggingRights record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Bragging Rights"}
    string value?;
};

# Define a Calendar Url.
#
# + metadata - Metadata about Calendar Url
# + url - Calendar URL
# + type - Type of calendar URL
# + formattedType - Type of calendar URL formatted
public type CalendarUrl record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Url"}
    string url?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
};

# Define an Arbitrary client data that is populated by clients.
#
# + metadata - Metadata about client data
# + key - Client specified key of client data
# + value - Client specified value of client data
public type ClientData record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Key"}
    string key?;
    @display {label: "Value"}
    string value?;
};

# Define an Cover photo.
#
# + metadata - Metadata about cover photo
# + url - URL of cover photo
# + default - True if cover photo is default
public type CoverPhoto record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Url"}
    string url?;
    @display {label: "Default Or Not"}
    boolean 'default?;
};

# Define an Event.
#
# + metadata - Metadata about Event
# + date - Date of event
# + type - Type of event
# + formattedType - Type of event formatted
public type Event record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Date"}
    Date date?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formated Type"}
    string formattedType?;
};

# Define an External entity.
#
# + metadata - Metadata about External entity
# + value - Value of external ID
# + type - Type of external ID 
# + formattedType - Type of External entity formatted
public type ExternalId record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formated Type"}
    string formattedType?;
};

# Define a name that should be used to sort person in a list.
#
# + metadata - Metadata about file-as
# + value - Value of file-as
public type FileAs record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
};

# Define an Gender.
#
# + metadata - Metadata about Gender
# + value - Gender for person
# + formattedValue - Type of Gender formatted
# + addressMeAs - Type that should be used to address person
public type Gender record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Formatted Type"}
    string formattedValue?;
    @display {label: "Type"}
    string addressMeAs?;
};

# Define an  Instant Messaging client.
#
# + metadata - Metadata about Instant Messaging client
# + username - Username used in Instant Messaging client
# + type - Type of Instant Messaging client
# + formattedType - Type that should be used to address person
# + protocol - Protocol of Instant Messaging client
# + formattedProtocol - Protocol of Instant Messaging client formatted
public type ImClient record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Username"}
    string username?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
    @display {label: "Protocol"}
    string protocol?;
    @display {label: "Formatted Protocol"}
    string formattedProtocol?;
};

# Define an  Interest.
#
# + metadata - Metadata about Interest
# + value - Name of Interest
public type Interest record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
};

# Define an  Locale.
#
# + metadata - Metadata about locale
# + value - IETF BCP 47 language tag representing locale
public type Locale record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
};

# Define an  Location.
#
# + metadata - Metadata about Location
# + value - Value of location
# + type - Type of location
# + current - Whether location is current location
# + buildingId - Building identifier
# + floor - Floor name identifier
# + floorSection - Floor section in a floor
# + deskCode - Desk location.
public type Location record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Current Location Or Not"}
    string current?;
    @display {label: "Building Id"}
    string buildingId?;
    @display {label: "Floor Name Id"}
    string floor?;
    @display {label: "Floor Section"}
    string floorSection?;
    @display {label: "Desk Location"}
    string deskCode?;
};

# Define a miscellaneous keyword.
#
# + metadata - Metadata about miscellaneous keyword
# + value - Value of miscellaneous keyword
# + type - Type of miscellaneous keyword
# + formattedType - Type of miscellaneous keyword formatted
public type MiscKeyword record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
};

# Define a Membership.
#
# + metadata - Metadata about Membership
# + contactGroupMembership - Group membership
# + domainMembership - Domain membership
public type Membership record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Group membership"}
    json contactGroupMembership?;
    @display {label: "Domain membership"}
    string domainMembership?;
};

# Define an Nickname.
#
# + metadata - Metadata about Nickname
# + value - Value of nick name
# + type - Type of nick name
public type Nickname record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Type"}
    string 'type?;
};

# Define an Occupation.
#
# + metadata - Metadata about Occupation
# + value - Value of occupation
public type Occupation record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
};

# Define an Organization.
#
# + metadata - Metadata about organization
# + type - Type of organization.
# + formattedType - Type organization formatted
# + startDate - Start date in organization
# + endDate - End date in organization
# + current - Whether it is current organization
# + name - Name of organization
# + phoneticName - Phonetic name of organization
# + department - Department at organization
# + title - Job title at organization
# + jobDescription - Job description in organization
# + symbol - Symbol of organization.
# + domain - Domain name of organization
# + location - Location of organization
public type Organization record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
    @display {label: "Joined Date"}
    Date startDate?;
    @display {label: "Date Left"}
    Date endDate?;
    @display {label: "Current Organization Or Not"}
    string current?;
    @display {label: "Name"}
    string name?;
    @display {label: "Phonetic Name"}
    string phoneticName?;
    @display {label: "Department"}
    string department?;
    @display {label: "Title"}
    string title?;
    @display {label: "Job Description"}
    string jobDescription?;
    @display {label: "Symbol"}
    string symbol?;
    @display {label: "Domain Name"}
    string domain?;
    @display {label: "Location"}
    string location?;
};

# Define a Relation.
#
# + metadata - Metadata about relation
# + person - Name of relation
# + type - Type of relation
# + formattedType - Type of relation formatted
public type Relation record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Relation Name"}
    string person?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
};

# Define a SIP address.
#
# + metadata - Metadata about SIP address
# + value - Name of SIP address
# + type - Type of SIP address
# + formattedType - Type of SIP address formatted
public type SipAddress record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
};

# Define a Skill.
#
# + metadata - Metadata about Skill
# + value - Name of skill
public type Skill record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
};

# Define an Url.
#
# + metadata - Metadata about Url
# + value - Name of url
# + type - Type of url
# + formattedType -  Type of url formatted
public type Url record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Value"}
    string value?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Formatted Type"}
    string formattedType?;
};

# Define a Arbitrary user data.
#
# + metadata - Metadata about user defined data
# + key - User specified key of user defined data
# + value - User specified value of user defined data 
public type UserDefined record {
    @display {label: "Metadata"}
    FieldMetaData metadata?;
    @display {label: "Key"}
    string key?;
    @display {label: "Value"}
    string value?;
};

# Define an FieldMetaData.
#
# + primary - True if field is primary field
# + verified - True if field is verified
# + sources - Source of field
public type FieldMetaData record {
    @display {label: "Primary Or Not"}
    boolean primary?;
    @display {label: "Verified Or Not"}
    boolean verified?;
    @display {label: "Metadata Source"}
    MetaDataSource 'sources?;
};

# Define an MetaDataSource.
#
# + type - Source type
# + id - Identifier within source
public type MetaDataSource record {
    @display {label: "Type"}
    string 'type?;
    @display {label: "Id"}
    string id?;
};

# Define an ContactGroup.
#
# + resourceName - Resource name
# + etag - Entity tag of resource
# + metadata - Metadata about contact group
# + groupType - Contact group type
# + name - Contact group name set by group owner or a system
# + formattedName - Name in formatted
# + memberResourceNames - List of contact person names that are members of contact group
# + memberCount - Total number of contacts
# + clientData - Contact group's client data
public type ContactGroup record {
    string resourceName;
    string etag?;
    ContactGroupMetadata metadata?;
    GroupType groupType?;
    string name?;
    string formattedName?;
    string[] memberResourceNames?;
    int memberCount?;
    GroupClientData[] clientData?;
};

# Define an ContactGroupMetadata.
#
# + updateTime - Time of update
# + deleted - Whether deleted is true
public type ContactGroupMetadata record {
    string updateTime?;
    boolean deleted?;
};

# Define an age range.
#
# + AGE_RANGE_UNSPECIFIED - Unspecified
# + LESS_THAN_EIGHTEEN - Younger than eighteen
# + EIGHTEEN_TO_TWENTY - Between eighteen and twenty
# + TWENTY_ONE_OR_OLDER - Twenty-one and older
public enum AgeRange {
    AGE_RANGE_UNSPECIFIED,
    LESS_THAN_EIGHTEEN,
    EIGHTEEN_TO_TWENTY,
    TWENTY_ONE_OR_OLDER
}

# Define an contact group type.
#
# + GROUP_TYPE_UNSPECIFIED - Unspecified
# + USER_CONTACT_GROUP - User defined contact group
# + SYSTEM_CONTACT_GROUP - System defined contact group
public enum GroupType {
    GROUP_TYPE_UNSPECIFIED,
    USER_CONTACT_GROUP,
    SYSTEM_CONTACT_GROUP
}

# Define biography type of content.
#
# + CONTENT_TYPE_UNSPECIFIED - Unspecified
# + TEXT_PLAIN - Plain text
# + TEXT_HTML - HTML text
public enum ContentType {
    CONTENT_TYPE_UNSPECIFIED,
    TEXT_PLAIN,
    TEXT_HTML
}

# Define a Date entity.
#
# + year - Year of date
# + month - Month of date
# + day - Day of date
public type Date record {
    int year?;
    int month?;
    int day?;
};

# Define a Contact Group Client Data.
#
# + key - Client specified key of client data.
# + value - Client specified value of client data
public type GroupClientData record {
    string key?;
    string value?;
};

# Define a Contact Group List.
#
# + contactGroups - Array of Contact Group
# + totalItems - Total contacts
# + nextSyncToken - Next sync token
public type ContactGroupList record {
    ContactGroup[] contactGroups;
    int totalItems;
    string nextSyncToken;
};

# Define a contact group batch result.
#
# + responses - Array of contact group responses
public type ContactGroupBatch record {
    json[] responses;
};

# Define a SearchResponse.
#
# + results - Array of results
public type SearchResponse record {
    json[] results;
};

# Define a people connection response.
#
# + connections - Array of PersonResponse of authenticated user
# + nextPageToken - Next page token
# + nextSyncToken - Next sync token
# + totalPeople - Total contacts
# + totalItems - Total pages
public type ConnectionsResponse record {
    PersonResponse[] connections;
    string nextPageToken?;
    string nextSyncToken?;
    int totalPeople?;
    int totalItems?;
};

# Define a OtherContact List Response.
#
# + otherContacts - Array of Person of in Other contacts
# + nextPageToken - Next page token
# + nextSyncToken - Next sync token
public type OtherContactListResponse record {
    PersonResponse[] otherContacts;
    string nextPageToken?;
    string nextSyncToken?;
};

# Define a BatchGetResponse.
#
# + responses - Array of PersonResponse
public type BatchGetResponse record {
    json[] responses;
};

# Define a Stream response of a Connection/Person.
#
# + pageToken - Page token
# + requestSyncToken - Whether request is needed
# + syncToken - Sync token
public type ContactListOptions record {
    string? pageToken = ();
    boolean? requestSyncToken = ();
    string? syncToken = ();
};
