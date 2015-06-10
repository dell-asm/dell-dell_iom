#Provide for force10 MXL 'FCoE MAP' Type

require 'puppet/provider/dell_ftos'

Puppet::Type.type(:mxl_fcoemap).provide :dell_ftos, :parent => Puppet::Provider::Dell_ftos do
  mk_resource_methods

  desc "This represents Dell Force10 MXL switch fcoe-map configuration."

  def self.get_current(name)
    transport.switch.fcoemap(name).params_to_hash
  end

  def flush
    transport.switch.fcoemap(name).update(former_properties, properties)
    super
  end
  
  
end
