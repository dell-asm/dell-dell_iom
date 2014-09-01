#Provide for force10 MXL 'uplink-state-group' Type

require 'puppet/provider/dell_ftos'

Puppet::Type.type(:mxl_uplinkstategroup).provide :dell_ftos, :parent => Puppet::Provider::Dell_ftos do

  desc "This represents Dell Force10 MXL switch uplink-state-group configuration."

  mk_resource_methods
  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.uplinkstategroup(name).params_to_hash
  end

  def flush
    device.switch.uplinkstategroup(name).update(former_properties, properties)
    super
  end
  
  
end
