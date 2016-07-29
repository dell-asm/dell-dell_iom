require 'puppet/provider/dell_iom'

Puppet::Type.type(:ioa_portchannel).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do

  desc "Dell IOM switch provider for port-channel configuration."

  mk_resource_methods

  def self.get_current(name)
    transport.switch.ioa_portchannel(name).params_to_hash
  end

  def flush
    transport.switch.ioa_portchannel(name).update(former_properties, properties)
    super
  end
end
