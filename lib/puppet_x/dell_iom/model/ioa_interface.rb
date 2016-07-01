# This is  force 10 interface module.
require 'puppet/util/network_device/ipcalc'
require 'puppet_x/dell_iom/model'

class PuppetX::Dell_iom::Model::Ioa_interface < PuppetX::Force10::Model::Base

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
    return 'puppet_x/dell_iom/model/ioa_interface'
  end

  def mod_const_base
    return PuppetX::Dell_iom::Model::Ioa_interface
  end

  def param_class
    return PuppetX::Force10::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

  def before_update(params_to_update=[])

    transport.command("show interfaces #{@name}")do |out|
      if out =~/Error:\s*(.*)/
        Puppet.debug "errror msg ::::#{$1}"
        raise "The entered interface does not exist. Enter the correct interface."
      end
    end

    super

    transport.command("interface #{@name}", :prompt => /\(conf-if-\S+\)#\z/n)

    # Remove interface from portchannel unless we're trying to set it up on one
    unless params_to_update.find{|param| param.name == :portchannel}
      transport.command("no port-channel-protocol lacp")
    end
  end

  def after_update
    transport.command("exit")
    super
  end

end
