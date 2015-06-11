# This is  force 10 interface module.
require 'puppet/util/network_device/ipcalc'
require 'puppet_x/dell_iom/model'

class PuppetX::Dell_iom::Model::Ioa_mode < PuppetX::Force10::Model::Base

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
    return 'puppet_x/dell_iom/model/ioa_mode'
  end

  def mod_const_base
    return PuppetX::Dell_iom::Model::Ioa_mode
  end

  def param_class
    return PuppetX::Force10::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

end