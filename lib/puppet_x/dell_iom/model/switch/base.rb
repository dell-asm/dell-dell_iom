require 'puppet_x/force10/model'
require 'puppet_x/force10/model/model_value'
require 'puppet_x/force10/model/interface'
require 'puppet_x/force10/model/vlan'
require 'puppet_x/force10/model/feature'
require 'puppet_x/force10/model/fcoemap'
require 'puppet_x/force10/model/dcbmap'
require 'puppet_x/force10/model/uplinkstategroup'
require 'puppet_x/force10/model/portchannel'
require 'puppet_x/force10/model/quadmode'
require 'puppet_x/dell_iom/model'
require 'puppet_x/dell_iom/model/switch'
require 'puppet_x/dell_iom/model/ioa_interface'

module PuppetX::Dell_iom::Model::Switch::Base
  def self.register(base)

    #base.register_model(:vlan, PuppetX::Force10::Model::Vlan, /^(\d+)\s\S+/, 'show vlan brief')
    #base.register_model(:interface, PuppetX::Force10::Model::Interface, /^interface\s+(\S+)\r*$/, 'show running-config')
    #base.register_model(:portchannel, PuppetX::Force10::Model::Portchannel, /^L*\s*(\d+)\s+.*/, 'show interfaces port-channel brief')
    #base.register_model(:ioa_interface, Puppet::Util::NetworkDevice::Dell_iom::Model::Ioa_interface, /^.*(Te\s+\S+)\s+.*$/, 'show interface status')

  end
end
