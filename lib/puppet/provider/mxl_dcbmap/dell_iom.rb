#Provide for force10 MXL 'DCB MAP' Type

require 'puppet/provider/dell_ftos'

Puppet::Type.type(:mxl_dcbmap).provide :dell_ftos, :parent => Puppet::Provider::Dell_ftos do
  mk_resource_methods

  desc "This represents Dell Force10 MXL switch dcb-map configuration."

  def self.get_current(name)
    transport.switch.dcbmap(name).params_to_hash
  end

  def flush
    transport.switch.dcbmap(name).update(former_properties, properties)
    super
  end
  
  
end
