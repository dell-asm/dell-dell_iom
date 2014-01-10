#Provide for MXL 'Port-channel' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_portchannel).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do

  desc "Dell force10 switch provider for port channel configuration."

  mk_resource_methods
  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.portchannel(name).params_to_hash
  end

  def flush
    device.switch.portchannel(name).update(former_properties, properties)
    super
  end
end
