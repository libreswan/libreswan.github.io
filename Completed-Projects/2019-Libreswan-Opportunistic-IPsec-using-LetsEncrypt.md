## Introduction

Libreswan Opportunistic IPsec using LetsEncrypt is a project created
during Google Summer of Code 2019. It adds a utility `letsencrypt` to
the `ipsec`. The `letsencrypt` program allows using various available
utilities required to establish and control an Opportunistic connection.
The letsencrypt program has several features, and can be used by running
a specified {command} with a specified \[argument\].

It is a program in libreswan, which integrates libreswan with
Opportunistic Encryption utilities. The script provides various OE
functionality e.g., initial OE setup, testing configuration/connection,
generating and updating Let's Encrypt certificates. The details about
the utilities and using them is available in the [Documentation:
Libreswan Opportunistic IPsec using
LetsEncrypt](/HOWTO/Opportunistic-IPsec-using-LetsEncrypt).
Also, the documentation includes the sample output for each {command}
and \[argument\].

## Implementation

Various functionalities of the project are listed below:

- Can establish the secure OE (Opportunistic Encryption) connections
  between two hosts (client and server).
- Checks for the success in establishing the OE connection.
- Easy to install on the hosts (client and server).
- Can test OE connections between two hosts.
- Checks if certbot is installed (on the server).
- Can generate Let's Encrypt certificates for the server using certbot.
- Generates the certbot configuration for reusing the private key.
- Enables automatic update of the generated certificates using crontabs,
  keeping the private key same.
- Manual updating of keys also implemented.
- Generates the \#pkcs12 file.
- Imports the generated certificates into NSS Database to be used for
  OE.
- Downloads the LetsEncrypt CA and intermediate certificates.
- Saves the default client/server configuration.
- Displays OE connection status to the user.
- Displays the certificates installed in NSS database.
- Disables ipsec and deletes configuration files saved in /etc/ipsec.d.
- Provides details about various available utilities, {commands} and
  \[arguments\].

## Source code

The source code of Libreswan Opportunistic IPsec using LetsEncrypt is
merged in the master branch of the [libreswan
repository](https://github.com/libreswan/libreswan). The commits made
for the development of the project are available at the following URLs:

- [letsencrypt: Added "ipsec letsencrypt"
  command](https://github.com/libreswan/libreswan/commit/e9ecb49534310336e800c7a90fd03f5a86c2d699)
- [documentation: Updated Opportunistic IPsec for LetsEncrypt
  configuration
  files](https://github.com/libreswan/libreswan/commit/1de84ec1777bd8f776f565ae6e7153d3390248bf)
- [testing: Add test cases for various asymmetric authentication use
  cases](https://github.com/libreswan/libreswan/commit/03cfc61175c5d250adf40934ed28aa5c4d9c2254)
- [testing: updated
  TESTLIST](https://github.com/libreswan/libreswan/commit/ede549206262b8846f7d73d53fc2f87b2e7782ba)

All the above commits are also available at this URL [Libreswan
Opportunistic IPsec using LetsEncrypt
Commits](https://github.com/libreswan/libreswan/commits?author=Rishabh04-02)

The original developer of the program is
[Rishabh](https://github.com/Rishabh04-02). The project is developed
under the expert guidance/mentorship of Paul Wouters & Tuomo Soini.
Google sponsored this project as a part of [Google Summer of Code
2019](https://summerofcode.withgoogle.com/) Program.

## Future Scope

Following are the future Scopes of the project:

- NSS certificates reload needs to restart IPSec.
- Option for testing connection for any custom server.
- Enabling server to server communication.
- Fixing the issue when 2 tunnels are up for the same connection,
  whenever the server/client restarts or crashes.
- Adding functionality to choose from multiple configurations for
  clients and servers.
- Auto detecting whether the other host is server or client and choose
  from the available configurations accordingly.
- Add functionality to fix the commonly found issues automatically.
  E.g., when the user has more than one configuration files in
  /etc/ipsec.d directory OR when there is no host IP in
  policies/private-\*.

## License

This project is Licensed under [GNU General Public License
v2.0](https://github.com/libreswan/libreswan/blob/master/LICENSE).