#Provide for MXL 'Interface' Type for managing the quad port

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_quadmode).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  desc "Dell MXL switch provider for interface quadmode configuration."
  mk_resource_methods
  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.quadmode(name).params_to_hash
  end

  def flush
    device.switch.quadmode(name).update(former_properties, properties, self.resource[:reboot_required])
    super
  end
end
