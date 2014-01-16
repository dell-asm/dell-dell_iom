require 'puppet/util/network_device/dell_iom/model'
require 'puppet/util/network_device/dell_iom/model/ioa_interface'

module Puppet::Util::NetworkDevice::Dell_iom::Model::Ioa_interface::Base
  def self.ifprop(base, param, base_command = param, &block)
    interfaceval = base.name

    base.register_scoped param, /(^Name: (\S*\s+\S*).*^\s+)/m do
      cmd "show interfaces switchport #{interfaceval}"
      match /^\s*#{base_command}\s+(.*?)\s*$/
      add do |transport, value|
        Puppet.debug(" command #{base_command} value  #{value}" )
        transport.command("#{base_command} #{value}")
      end
      remove do |transport, old_value|
        Puppet.debug(" No  command #{base_command} value  #{value}" )
        transport.command("no #{base_command} #{old_value}")
      end
      evaluate(&block) if block
    end
  end

  def self.register(base)
    interfaceval = base.name
    txt = ''
    ifprop(base, :ensure) do
      match do |txt|
      	:present
      end
      default :present
      add { |*_| }
      remove { |*_| }
    end

    ifprop(base, :vlan_tagged) do
      match do |txt|
        paramsarray=txt.match(/^T\s+(\S+)/)
        if paramsarray.nil?
           param1 = :absent
        else
           param1 = paramsarray[1]
        end
        param1
      end
      add do |transport, value|
        transport.command("no vlan tagged 1-4094")
        transport.command("vlan tagged #{value}")
      end
      remove do |transport, old_value|
        transport.command("no vlan tagged #{old_value}")
      end
    end

    ifprop(base, :vlan_untagged) do
      match  do |txt|
        paramsarray=txt.match(/^U\s+(\S+)/)
        if paramsarray.nil?
           param1 = :absent
        else
           param1 = paramsarray[1]
        end
        param1
      end

      add do |transport, value|
        transport.command("no vlan untagged 1-4094")
        transport.command("vlan untagged #{value}")
      end
      remove do |transport, old_value|
        transport.command("no vlan untagged #{old_value}")
      end
    end
     
    general_scope = /^((#{interfaceval}).*)/m

    base.register_scoped :shutdown, general_scope do
      match do |txt|
          paramsarray=txt.match(/^#{interfaceval} is up/)
          if paramsarray.nil?
            param1 = :true
          else
            param1 = :false
          end
          param1
      end

      cmd "show interfaces #{interfaceval}"
      add do |transport, value|
        if value==:true
          transport.command("shutdown")
        else
          transport.command("no shutdown")
        end
      end
      remove { |*_| }
    end

  end
end
