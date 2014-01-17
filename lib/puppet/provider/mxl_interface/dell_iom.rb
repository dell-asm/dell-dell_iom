#Provide for MXL 'Interface' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_interface).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  desc "Dell MXL switch provider for interface configuration."
  mk_resource_methods
  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.interface(name).params_to_hash
  end

  def flush
    device.switch.interface(name).update(former_properties, properties)
    super
  end
end
