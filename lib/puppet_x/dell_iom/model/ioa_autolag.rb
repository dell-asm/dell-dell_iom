# This is  force 10 interface module.
require 'puppet/util/network_device/ipcalc'
require 'puppet_x/dell_iom/model'

class PuppetX::Dell_iom::Model::Ioa_autolag < PuppetX::Force10::Model::Base

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
    return 'puppet_x/dell_iom/model/ioa_autolag'
  end

  def mod_const_base
    return PuppetX::Dell_iom::Model::Ioa_autolag
  end

  def param_class
    return PuppetX::Force10::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

  def update(is = {}, should = {})
    return unless configuration_changed?(is, should, :keep_ensure => true)
    missing_commands = [is.keys, should.keys].flatten.uniq.sort - @params.keys.flatten.uniq.sort
    missing_commands.delete(:ensure)
    raise Puppet::Error, "Undefined commands for #{missing_commands.join(', ')}" unless missing_commands.empty?
    [is.keys, should.keys].flatten.uniq.sort.each do |property|
      next if property == :acl_type
      next if should[property] == :undef
      @params[property].value = :absent if should[property] == :absent || should[property].nil?
      @params[property].value = should[property] unless should[property] == :absent || should[property].nil?
    end
    before_update
    perform_update(is, should)
    after_update
  end

  def perform_update(is, should)
    features = []
    case @params[:ensure].value
      when :present
        Puppet.debug("should: #{should}")
        response = transport.command("io-aggregator auto-lag enable", :prompt => /\(conf\)#\s?\z/n)
        raise(Exception,"Command failed with response: #{response}") if response.include?('Error:')
      when :absent
        transport.command("no io-aggregator auto-lag enable", :prompt => /\(conf\)#\s?\z/n)
      else
        Puppet.debug("No value given for ensure")
    end
  end

end