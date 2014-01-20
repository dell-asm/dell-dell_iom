#Provide for IOA 'Interface' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:ioa_interface).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  desc "force 10 IOA Switch Interface Provider for Device Configuration."
  mk_resource_methods
  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)  
    

    if !name.nil?
      name=name.gsub(/te |tengigabitethernet /i, "TenGigabitEthernet ")
      name=name.gsub(/fo |fortygige /i, "fortyGigE ")
    end

    paramstohash = device.switch.ioa_interface(name).params_to_hash
    device.switch.ioa_interface(name).params_to_hash
  end

  def flush


    device.switch.ioa_interface(name).update(former_properties, properties)
    super
  end
end
