#Provide for IOA 'Interface' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:ioa_interface).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods
  desc "Dell IOA provider for interface configuration."

  def self.get_current(name)
    if !name.nil?
      name=name.gsub(/te |tengigabitethernet /i, "TenGigabitEthernet ")
      name=name.gsub(/fo |fortygige /i, "fortyGigE ")
      name=name.gsub(/fc /i, "fibreChannel ")
      name=name.gsub(/po /i, 'Port-channel ')
    end
    transport.switch.ioa_interface(name).params_to_hash
  end

  def flush
    transport.switch.ioa_interface(name).update(former_properties, properties)
    super
  end
end
