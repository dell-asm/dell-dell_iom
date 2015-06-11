#Provide for MXL 'VLAN' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_vlan).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods

  desc "Dell MXL switch provider for vlan configuration."

  def self.get_current(name)
    transport.switch.vlan(name).params_to_hash
  end

  def flush
    transport.switch.vlan(name).update(former_properties, properties)
    super
  end
end
