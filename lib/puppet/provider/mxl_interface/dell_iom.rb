#Provide for MXL 'Interface' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:mxl_interface).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods
  desc "Dell MXL switch provider for interface configuration."

  def self.get_current(name)
    if !name.nil?
      name=name.gsub(/te |tengigabitethernet /i, "TenGigabitEthernet ")
      name=name.gsub(/fo |fortygige /i, "fortyGigE ")
      name=name.gsub(/fc\s*/i, "fibreChannel ")
    end
    transport.switch.interface(name).params_to_hash
  end

  def flush
    transport.switch.interface(name).update(former_properties, properties)
    super
  end
end
