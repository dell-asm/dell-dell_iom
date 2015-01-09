#Provide for IOA 'Mode' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:ioa_mode).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  desc 'Dell IOA provider for mode configuration.'
  mk_resource_methods
  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    if !name.nil?
      name=name.to_s.gsub(/smux/i, "standalone")
      name=name.to_s.gsub(/pmux/i, "programmable-mux")
      name=name.to_s.gsub(/vlt/i, "vlt")
    end
    device.switch.ioa_mode(name).params_to_hash
  end

  def flush
    device.switch.ioa_mode(name).update(former_properties, properties)
    super
  end

end
