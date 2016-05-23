#Provide for IOA 'Mode' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:ioa_mode).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods
  desc 'Dell IOA provider for mode configuration.'

  def self.get_current(name)
    if !name.nil?
      name=name.to_s.gsub(/smux/i, "standalone")
      name=name.to_s.gsub(/pmux/i, "programmable-mux")
      name=name.to_s.gsub(/vlt/i, "vlt")
      name=name.to_s.gsub(/fullswitch/i, "fullswitch")
    end
    transport.switch.ioa_mode(name).params_to_hash
  end

  def flush
    transport.switch.ioa_mode(name).update(former_properties, properties)
    super
  end

end
