# Dell IOM(IOA/MXL) switch module

**Table of Contents**

- [Dell IOM switch module](#Dell-IOM-switch-module)
	- [Overview](#overview)
	- [Features](#features)
	- [Requirements](#requirements)
	- [Usage](#usage)
		- [Device Setup](#device-setup)
		- [Dell IOM Operations](#dell-iom-operations)

## Overview
The Dell IOM switch module is designed to extend the support for managing Dell PowerEdge M I/O Aggregator or Dell Force10 MXL 10/40GbE Switch IO Module configuration using Puppet and its Network Device functionality.

The Dell IOM switch module has been written and tested against the following Dell IOM switch models. However, this module may be compatible with other models and their software versions.

- Dell PowerEdge M I/O Aggregator(software version 9.2(0.2))
- Dell Force10 MXL 10/40GbE Switch IO Module(software version 9.2(0.2))


## Features
This module supports the following functionality:

 * MXL VLAN Creation and Deletion
 * MXL Interface Configuration
 * MXL Port Channel Creation and Deletion
 * MXL Configuration Updates
 * IOA Interface Configuration


## Requirements
The agent can be managed either using the Puppet Master server or through an intermediate proxy system running a Puppet agent because the Puppet agent cannot be directly installed on a Dell PowerEdge M I/O Aggregator or Dell Force10 MXL 10/40GbE Switch IO Module.
The following are the requirements for the proxy system:

 * Puppet 2.7.+

## Usage

### Device Setup
To configure a Dell IOA/MXL switch, the device *type* specified in `device.conf` must be `dell_iom`.
The device can either be configured within */etc/puppet/device.conf*, or, preferably, create an individual config file for each device within a sub-folder.
This is preferred because it allows the user to run the Puppet against individual devices, rather than all devices configured.

To run the Puppet against a single device, run the following command:

    puppet device --deviceconfig /etc/puppet/device/[device].conf

Example configuration `/etc/puppet/device/iom.example.com.conf`:

      [iom.example.com]
      type dell_iom
      url ssh://admin:password@iom.example.com/?enable=password

### Dell IOM Operations
This module can be used to configure VLANs, interfaces, and port channels on Dell Force10 MXL 10/40GbE Switch IO Module, also can be used for configuring interfaces on Dell PowerEdge M I/O Aggregator.
For example: 
```puppet
mxl_firmware { "update":
 ensure       => present,
 version      => '9.5.0.1',
 path         => 'mxl_9_50/FTOS-XL-9.5.0.1.bin',
 asm_hostname => '172.18.4.100',
}
```

```
node "iom.example.com" {
  mxl_portchannel { '128':
    desc     => 'Port Channel for server connectivity',
    mtu      => '600',
    shutdown => true,
    ensure   => present;
  }
}
```
This creates a port channel `128` on MXL, based on the values defined for various parameters in the above definition.
```
node "iom.example.com" {
  # Add MXL VLAN 180
  mxl_vlan { '180':
    desc   => 'test',
    ensure => present;
  }

  # This will add TenGigabitEthernet 0/16 and 0/17 interfaces to MXL vlan 180 as tagged
  mxl_vlan { '180':
    desc   => 'test',
    ensure => present,
    tagged_tengigabitethernet => '0/16-17';
  }
}
```
This creates VLAN `180` on MXL and add TenGigabitEthernet `0/16` and `0/17` interfaces as tagged in the above definition.
```
node "iom.example.com" {
  ioa_interface { 'TenGigabitEthernet 0/6':
    vlan_tagged   => '180,181',
    vlan_untagged => '2-20',
    shutdown      => true;
  }
}
```
This change will apply shutdown,tag VLAN `180`,`181` and untag `0-20` VLANs for TenGigabitEthernet `0/6` on IOA.

You can also use any of the above operations individually, or create new defined types, as required.

For additional examples, see tests folder.

