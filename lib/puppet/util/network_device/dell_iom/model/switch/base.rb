require 'puppet/util/network_device/dell_ftos/model'
require 'puppet/util/network_device/dell_ftos/model/model_value'
require 'puppet/util/network_device/dell_ftos/model/interface'
require 'puppet/util/network_device/dell_ftos/model/vlan'
require 'puppet/util/network_device/dell_ftos/model/portchannel'
require 'puppet/util/network_device/dell_iom/model'
require 'puppet/util/network_device/dell_iom/model/switch'
require 'puppet/util/network_device/dell_iom/model/ioa_interface'

module Puppet::Util::NetworkDevice::Dell_iom::Model::Switch::Base
  def self.register(base)

    base.register_model(:vlan, Puppet::Util::NetworkDevice::Dell_ftos::Model::Vlan, /^(\d+)\s\S+/, 'show vlan brief')
    base.register_model(:interface, Puppet::Util::NetworkDevice::Dell_ftos::Model::Interface, /^interface\s+(\S+)\r*$/, 'show running-config')
    base.register_model(:portchannel, Puppet::Util::NetworkDevice::Dell_ftos::Model::Portchannel, /^L*\s*(\d+)\s+.*/, 'show interfaces port-channel brief')
    base.register_model(:ioa_interface, Puppet::Util::NetworkDevice::Dell_iom::Model::Ioa_interface, /^.*(Te\s+\S+)\s+.*$/, 'show interface status')

  end
end
