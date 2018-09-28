import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

class ContactsService {
  static const MethodChannel _channel =
      MethodChannel('github.com/clovisnicolas/flutter_contacts');

  /// Fetches all contacts, or when specified, the contacts with a name
  /// matching [query]
  static Future<Iterable<Contact>> getContacts({String query}) async {
    Iterable contacts = await _channel.invokeMethod('getContacts', query);
    return contacts.map((m) => Contact.fromMap(m));
  }

  /// Adds the [contact] to the device contact list
  static Future addContact(Contact contact) =>
      _channel.invokeMethod('addContact', Contact._toMap(contact));

  /// Deletes the [contact] if it has a valid identifier
  static Future deleteContact(Contact contact) =>
      _channel.invokeMethod('deleteContact', Contact._toMap(contact));
}

class Contact {
  Contact(
      {this.givenName,
      this.middleName,
      this.prefix,
      this.suffix,
      this.familyName,
      this.company,
      this.jobTitle,
      this.emails,
      this.phones,
      this.postalAddresses,
      this.avatar,
      this.note});

  String identifier,
      displayName,
      givenName,
      middleName,
      prefix,
      suffix,
      familyName,
      company,
      jobTitle,
      note;
  Iterable<Item> emails = [];
  Iterable<Item> phones = [];
  Iterable<PostalAddress> postalAddresses = [];
  Uint8List avatar;

  Contact.fromMap(Map m) {
    identifier = m["identifier"];
    displayName = m["displayName"];
    givenName = m["givenName"];
    middleName = m["middleName"];
    familyName = m["familyName"];
    prefix = m["prefix"];
    suffix = m["suffix"];
    company = m["company"];
    jobTitle = m["jobTitle"];
    emails = (m["emails"] as Iterable)?.map((m) => Item.fromMap(m));
    phones = (m["phones"] as Iterable)?.map((m) => Item.fromMap(m));
    postalAddresses = (m["postalAddresses"] as Iterable)
        ?.map((m) => PostalAddress.fromMap(m));
    avatar = m["avatar"];
    note = m["note"];
  }

  static Map _toMap(Contact contact) {
    var emails = [];
    for (Item email in contact.emails ?? []) {
      emails.add(Item._toMap(email));
    }
    var phones = [];
    for (Item phone in contact.phones ?? []) {
      phones.add(Item._toMap(phone));
    }
    var postalAddresses = [];
    for (PostalAddress address in contact.postalAddresses ?? []) {
      postalAddresses.add(PostalAddress._toMap(address));
    }
    return {
      "identifier": contact.identifier,
      "displayName": contact.displayName,
      "givenName": contact.givenName,
      "middleName": contact.middleName,
      "familyName": contact.familyName,
      "prefix": contact.prefix,
      "suffix": contact.suffix,
      "company": contact.company,
      "jobTitle": contact.jobTitle,
      "emails": emails,
      "phones": phones,
      "postalAddresses": postalAddresses,
      "avatar": contact.avatar,
      "note": contact.note
    };
  }

  Map toMap() {
    return Contact._toMap(this);
  }

  /// The [+] operator fills in this contact's empty fields with the fields from [other]
  operator +(Contact other) => Contact(
      givenName: this.givenName ?? other.givenName,
      middleName: this.middleName ?? other.middleName,
      prefix: this.prefix ?? other.prefix,
      suffix: this.suffix ?? other.suffix,
      familyName: this.familyName ?? other.familyName,
      company: this.company ?? other.company,
      jobTitle: this.jobTitle ?? other.jobTitle,
      emails: this.emails == null
          ? other.emails
          : Iterable.castFrom(this.emails.toSet().union(other.emails.toSet())),
      phones: this.phones == null
          ? other.phones
          : Iterable.castFrom(this.phones.toSet().union(other.phones.toSet())),
      postalAddresses: this.postalAddresses == null
          ? other.postalAddresses
          : Iterable.castFrom(this
              .postalAddresses
              .toSet()
              .union(other.postalAddresses.toSet())),
      avatar: this.avatar ?? other.avatar);

  /// Returns true if all items in this contact are identical.
  @override
  bool operator ==(other) {
    if (other is! Contact) return false;

    Map otherMap = (other as Contact).toMap(); // ignore: test_types_in_equals
    Map thisMap = this.toMap();

    for (var key in otherMap.keys) {
      if (otherMap[key] is! Iterable) {
        if (thisMap[key] != otherMap[key]) {
          return false;
        }
      } else if (otherMap[key] is Iterable) {
        var equal = DeepCollectionEquality.unordered()
            .equals(thisMap[key], otherMap[key]);
        if (!equal) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return this.hashCode;
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

class PostalAddress {
  PostalAddress(
      {this.label,
      this.street,
      this.city,
      this.postcode,
      this.region,
      this.country});

  String label, street, city, postcode, region, country;

  PostalAddress.fromMap(Map m) {
    label = m["label"];
    street = m["street"];
    city = m["city"];
    postcode = m["postcode"];
    region = m["region"];
    country = m["country"];
  }

  static Map _toMap(PostalAddress address) => {
        "label": address.label,
        "street": address.street,
        "city": address.city,
        "postcode": address.postcode,
        "region": address.region,
        "country": address.country
      };
}

/// Item class used for contact fields which only have a [label] and
/// a [value], such as emails and phone numbers
class Item {
  Item({this.label, this.value});

  String label, value;

  Item.fromMap(Map m) {
    label = m["label"];
    value = m["value"];
  }

  static Map _toMap(Item i) => {"label": i.label, "value": i.value};
}
