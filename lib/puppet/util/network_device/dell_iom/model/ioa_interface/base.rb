require 'puppet/util/network_device/dell_iom/model'
require 'puppet/util/network_device/dell_iom/model/ioa_interface'

module Puppet::Util::NetworkDevice::Dell_iom::Model::Ioa_interface::Base
  def self.ifprop(base, param, base_command = param, &block)
    base.register_scoped param, /^(interface\s+(\S+).*?)^!/m do
      cmd 'sh run'
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
    txt = ''
    ifprop(base, :ensure) do
      match do |txt|
        unless txt.nil?
          txt.match(/\S+/) ? :present : :absent
        else
          :absent
        end
      end
      default :absent
      add { |*_| }
      remove { |*_| }
    end

    ifprop(base, :vlan_tagged) do
      match /^\s*vlan tagged\s+(.*?)\s*$/
      add do |transport, value|
        transport.command("vlan tagged #{value}")
      end
      remove do |transport, old_value|
        transport.command("no vlan tagged #{old_value}")
      end
    end

    ifprop(base, :vlan_untagged) do
      match /^\s*vlan untagged\s+(.*?)\s*$/
      add do |transport, value|
        transport.command("vlan untagged #{value}")
      end
      remove do |transport, old_value|
        transport.command("no vlan untagged #{old_value}")
      end
    end

    ifprop(base, :shutdown) do
      match /^\s*shutdown\s+(.*?)\s*$/
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
