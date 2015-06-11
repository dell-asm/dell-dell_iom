#Provide for MXL 'Port-channel' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_portchannel).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods

 desc "Dell MXL switch provider for port-channel configuration."

  def self.get_current(name)
    transport.switch.portchannel(name).params_to_hash
  end

  def flush
    transport.switch.portchannel(name).update(former_properties, properties)
    super
  end
end
