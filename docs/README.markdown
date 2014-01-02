# Dell IOM(IOA/MXL) switch module

**Table of Contents**

- [Dell IOM switch module](#Dell-IOM-switch-module)
	- [Overview](#overview)
	- [Features](#features)
	- [Requirements](#requirements)
	- [Usage](#usage)
		- [Device Setup](#device-setup)
		- [Dell IOM operations](#Dell-IOM-operations)

## Overview
The Dell IOM switch module is designed to extend the support for managing Dell IOM switch configuration using Puppet and its Network Device functionality.

The Dell IOM switch module has been written and tested against the following Dell IOM switch models. However, this module may be compatible with other models and 
their firmware versions.
-S4810(software version 9.2(0.2))) 
However, this module may be compatible with other models & their software versions.


## Features
This module supports the following functionality:

 * VLAN Creation and Deletion
 * Interface Configuration
 * Port Channel Creation and Deletion
 * Configuration Updates
 * Firmware Updates

## Requirements
Because the Puppet agent cannot be directly installed on a Dell IOM switch, the agent can be managed either using the Puppet Master server,
or through an intermediate proxy system running a Puppet agent. The following are the requirements for the proxy system:

 * Puppet 2.7.+

## Usage

### Device Setup
To configure a Dell IOM switch, the device *type* must be `dell_ftos`.
The device can either be configured within */etc/puppet/device.conf*, or, preferably, create an individual config file for each device within a sub-folder.
This is preferred because it allows the user to run the Puppet against individual devices, rather than all devices configured.

To run the Puppet against a single device, use the following command:

    puppet device --deviceconfig /etc/puppet/device/[device].conf

Example configuration `/etc/puppet/device/iom.example.com.conf:

      [iom.example.com]
      type dell_ftos
      url ssh://admin:password@force10.example.com/?enable=password

### Dell Force10 Operations
This module can be used to configure VLANs, interfaces, and port channels on Dell IOM switch.
For example: 

node "iom.example.com" {
    mxl_portchannel { '128':
      desc     => 'Port Channel for server connectivity',
      mtu      => '600',
      shutdown => true,
      ensure   => present;
    }
  }

This creates a port channel `128` on MXL, based on the values defined for various parameters in the above definition.
node "iom.example.com" {
	#Add MXL VLAN 180
	mxl_vlan {
	  '180':    	
		desc     => 'test',
		ensure => present;
	}	

	# This will add TenGigabitEthernet 0/16 and 0/17 interfaces to MXL vlan 180 as tagged
	mxl_vlan {
	  '180':    	
		desc     => 'test',
		ensure => present, 
		tagged_tengigabitethernet => '0/16-17';    
	}
}
This creates VLAN 180 and add TenGigabitEthernet 0/16 and 0/17 interfaces as tagged in the above definition.
This module can be used to configure VLANs, interfaces, and port channels on Dell IOA switch.
#TODO
You can also use any of the above operations individually, or create new defined types, as required. The details of each operation and parameters 
are mentioned in the following readme files that are shipped with the following modules:

  - mxl_interface.md
  - mxl_portchannel.md
  - mxl_vlan.md



