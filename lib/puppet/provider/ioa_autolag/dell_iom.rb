#Provide for IOA 'AutoLag' Type

require 'puppet/provider/dell_iom'

Puppet::Type.type(:ioa_autolag).provide :dell_iom, :parent => Puppet::Provider::Dell_iom do
  mk_resource_methods
  desc 'Dell IOA provider for autolag configuration.'

  def self.get_current(name)
    transport.switch.ioa_autolag(name).params_to_hash
  end

  def flush
    transport.switch.ioa_autolag(name).update(former_properties, properties)
    super
  end

end
