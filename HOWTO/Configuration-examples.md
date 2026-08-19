Below are the most common type of IPsec configurations people use. While
written for libreswan, the instructions will work for openswan as well
unless specifically noted.

# VPN server to VPN server configurations

[host to host VPN](/HOWTO/Host-to-host-VPN)

[subnet to subnet VPN](/HOWTO/Subnet-to-subnet-VPN)

[host to host VPN with PSK](/HOWTO/Host-to-host-VPN-with-PSK)

[subnet to subnet VPN with
PSK](/HOWTO/Subnet-to-subnet-VPN-with-PSK)

[EoIP shared ethernet LAN using
IPsec](/HOWTO/EoIP-shared-ethernet-LAN-using-IPsec)

[subnet to subnet using NAT](/HOWTO/Subnet-to-subnet-using-NAT)

[SElinux and Labeled IPsec
VPN](/HOWTO/SElinux-and-Labeled-IPsec-VPN)

# VPN server for VPN client configurations

[VPN server for remote clients using
IKEv2](/HOWTO/VPN-server-for-remote-clients-using-IKEv2)

[VPN server for remote clients using IKEv2 split
VPN](/HOWTO/VPN-server-for-remote-clients-using-IKEv2-split-VPN)

[libreswan as client to a Cisco (ASA or VPN3000)
server](/HOWTO/Libreswan-as-client-to-a-Cisco-ASA-or-VPN3000-server)

[subnet extrusion](/HOWTO/Subnet-extrusion)

# VPN configurations to connect to cloud providers

[Opportunistic IPsec mesh for Amazon EC2 instances on
AWS](https://aws.amazon.com/quickstart/architecture/libreswan-ipsec-mesh/)

[Creating a Secure Connection Between Oracle Cloud Infrastructure and
Other Cloud Providers with
Libreswan](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/libreswan.htm)

[Using libreswan in OpenStack as
VPNaaS](https://wiki.openstack.org/wiki/Neutron/VPNaaS/HowToInstall)

[High Availability / Failover VPN in AWS using
libreswan](/HOWTO/High-Availability-Fallover-VPN-in-AWS)

[Microsoft Azure configuration](/HOWTO/Microsoft-Azure-configuration)

[OpenShift Cloud Encryption with
libreswan](https://docs.openshift.com/container-platform/3.3/admin-guide/ipsec.html)

# Libreswan's Test Cases

Libreswan's
[testsuite](https://github.com/libreswan/libreswan/tree/main/testing/pluto/TESTLIST)
is also a good source of examples. Especially when looking for something
demonstrating a more esoteric feature or option.

In addition, the [test results](https://testing.libreswan.org/) are
published [nightly](https://testing.libreswan.org/current) (see also
[Testing](/Testing)).

# Misc items

[Using Apache to serve PKCS#12 format .p12
files](/HOWTO/Using-Apache-to-serve-PKCS)
