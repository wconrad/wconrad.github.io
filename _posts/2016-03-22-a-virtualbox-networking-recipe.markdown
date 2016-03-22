---
layout: post
title: "A Virtualbox Networking Recipe"
date: 2016-03-22 00:00:00 -07:00
categories: network admin
---

This is a recipe for setting up a virtual network when using Oracle's
VirtualBox software.

# The requirements

* There are multiple virtual machines on a virtual network

* Each virtual machine needs to be able to talk to any other virtual
  machine on the same virtual network.

* The host also needs to be able to talk to any of those virtual
  machines.

* Each virtual machine has internet access.

# Conditions

I tested this recipe with:

* Host OS: Debian 8 (Jessie), 64-bit, amd64

* Guest OS: "

* VirtualBox 5.0.16 r105871

* The host is on the class C network 192.168.0.0/24

# The recipe

In this recipe, each VM is dual-homed.The first network interfaces
gives the VM access to the internet through the NatNetwork, and also
gives the host access to the VMs.  The second network interface
connects the host and VMs together through a "host-only network."

# Configuring the Host-only network

* In VirtualBox, select File/Preferences/Network

* Select the "Host-only Networks" tab

* Configure a host-only network.  By default, there's one called
  vboxnet0.  You can use it, or create another.  The settings:

  * IPv4 Address: 192.168.51.1

  * IPv4 Network Mask: 255.255.255.0

  * IPv6 Address: (blank)

  * IPv5 Netowrk Mask Length: 0

* DHCP Server:

  * Enable Server: not checked

# Configuring each VM's VirtualBox Network

* In VirtualBox, select the VM's Settings

* Select the Network tab.

* Leave Adapter 1 set to "NAT".  This is the adapter that gives the VM
  access to the internet.

* Enable Adapter 2.

* Attach adapter 2 to "host only adapter"

* Select the virtual network you configured above (probably
  "vboxnet0")

# Configuring each VM OS's network.

We now configure each VM's OS to be dual-homed, with one DHCP
interface for internet, and one static interface for communicating
with other VMs and the host.

Edit /etc/apt/interfaces.  You should see something like this:

```
...
allow-hotplug eth0
iface eht0 inet dhcp
```

This is the configuration for the NAT interface, the one that connects
the VM to the internet.  Add the configuration for the "host-only
network" interface, the one that connects the VM to other VMs and to
the host:

```
auto eth1
iface eth1 inet static
    address 192.168.51.2      # Unique for each VM.  Do not use .1.
    netmask 255.255.255.0
```

Now bring up the interface using `ifup eth1`

Do this for each VM.

# Testing

From each VM, you should be able to get to the internet:

    ping google.com

You should be able to get to another vm:

    ping 192.168.51.2

From the host, you should be able to get to each vm:

    ping 192.168.51.2
    ping 192.168.51.3
