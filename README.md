# BlueHive

BlueHive is HoneyPot user management tool built on top of Universal Dashboards by Ironman software. This utility can be used to create and manage Honeypot user accounts and service accounts via and interactive web dashboard.

## Features
* Create Honey Pot Users with randomized names / properties
  * Users
  * Service Accounts (with SPN)
* Target creation of of account on a specifc domain / controller
* PowerShell based Dashboards showing status of HoneyPot users
* Track History of Honey User Deployments
* Remove Honey Users from Active Directory

## Drawbacks / Issues
* Data storage via json files on disk
* Only "half-way" supports multiple domains, needs some data management work
* "OtherName" of created token objects have value of 1337 - this is the identifier for a honey object
* Many values in the Ad Objects COULD be populated but are not
