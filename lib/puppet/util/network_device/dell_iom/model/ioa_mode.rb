# This is  force 10 interface module.
require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/dell_ftos/model'
require 'puppet/util/network_device/dell_ftos/model/base'
require 'puppet/util/network_device/dell_ftos/model/scoped_value'
require 'puppet/util/network_device/dell_iom/model'

class Puppet::Util::NetworkDevice::Dell_iom::Model::Ioa_mode < Puppet::Util::NetworkDevice::Dell_ftos::Model::Base

  attr_reader :params, :name
  def initialize(transport, facts, options)
    super(transport, facts)
    # Initialize some defaults
    @params         ||= {}
    @name           = options[:name] if options.key? :name
    # Register all needed Modules based on the availiable Facts
    register_modules
  end

  def mod_path_base
    return 'puppet/util/network_device/dell_iom/model/ioa_mode'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Dell_iom::Model::Ioa_mode
  end

  def param_class
    return Puppet::Util::NetworkDevice::Dell_ftos::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

end
