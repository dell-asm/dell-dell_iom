#Provide for MXL 'Interface' Type for managing the quad port

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_quadmode).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods
  desc "Dell MXL switch provider for interface quadmode configuration."

  def self.get_current(name)
    transport.switch.quadmode(name).params_to_hash
  end

  def flush
    transport.switch.quadmode(name).update(former_properties, properties, self.resource[:reboot_required])
    super
  end
end
