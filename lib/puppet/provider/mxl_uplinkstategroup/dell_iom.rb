#Provide for force10 MXL 'uplink-state-group' Type

require 'puppet/provider/dell_ftos'

Puppet::Type.type(:mxl_uplinkstategroup).provide :dell_ftos, :parent => Puppet::Provider::Dell_ftos do
  mk_resource_methods

  desc "This represents Dell Force10 MXL switch uplink-state-group configuration."

  def self.get_current(name)
    transport.switch.uplinkstategroup(name).params_to_hash
  end

  def flush
    transport.switch.uplinkstategroup(name).update(former_properties, properties)
    super
  end
  
  
end
