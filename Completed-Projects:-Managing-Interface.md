## Introduction

Libreswan Managing Interface is an interface for Libreswan VPN software,
built using Django. There are shell scripts for creating X.509
certificates, revoking certificates and signing CRLs and scripts for the
creation of Profile certificate files for certain devices such as Linux,
Apple OS X, Windows, iOS, etc., these require careful specification of
various certificate attributes so that these certificates work on a
variety of devices: Android, Windows, iOS/OSX, Linux, etc. The goal of
this project is to gather all that knowledge into a simple interface.

## Implementation

Various Functionalities of Libreswan Managing Interface are as follows:

- Add User
- Create VPN for remote host connection profiles
- Create Subnet to Subnet VPN connection profiles
- Generate Private Key (CA private key)
- Generate root certificate (Using CA private key)
- Create certificate configurations (for user certificates)
- Generate user certificates
- Revoke user certificates
- Enable user (Allow User to login)
- Disable user (Disallow User to login)
- Delete User Data (Keys & Certificates)
- Delete all certificates (User, CA & Default Certificate configuration)
- Account activation (email verification)
- Download the certificate generated for the user

## Initial project setup/First time installation

[Installation
Instructions](https://github.com/Rishabh04-02/Libreswan-managing-interface/blob/master/INSTALLATION_INSTRUCTIONS.md)
for the Managing interface is available at the given link.

## Libreswan Administration guide

This is a guide on how to use different functionalities of the Libreswan
Managing Interface. This aims to improve the user experience when using
[Libreswan Administration
Interface](https://github.com/Rishabh04-02/Libreswan-managing-interface/blob/master/ADMINISTRATION_GUIDE.md).

## Source code

code status: Development complete, waiting for release.

The code of the Managing Interface can be found at
[GitHub:Libreswan-managing-interface](https://github.com/Rishabh04-02/Libreswan-managing-interface)
The developer of this Interface is [Rishabh
Chaudhary](https://github.com/Rishabh04-02). The project was developed
under the expert guidance/mentorship of Tuomo Soini & Kim Heino. This
project was sponsored by Google as a part of [Google Summer of
Code](https://summerofcode.withgoogle.com) 2018 Program.

## License

This project(Libreswan Managing Interface) is Licensed under [GNU
General Public License
v2.0](https://github.com/Rishabh04-02/Libreswan-managing-interface/blob/master/LICENSE)