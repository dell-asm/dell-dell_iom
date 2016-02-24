require 'puppet_x/dell_iom/model'
require 'puppet_x/dell_iom/model/ioa_autolag'

module PuppetX::Dell_iom::Model::Ioa_autolag::Base
  def self.ifprop(base, param, base_command = param, &block)

    base.register_scoped param, /(.*)/ do
      cmd 'show io-aggregator auto-lag  status'
      match /disabled|enabled/
      add do |transport, value|
        transport.command("#{base_command} #{value}")
      end
      remove do |transport, old_value|
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
      default :present
      add { |*_| }
      remove { |*_| }
    end

  end

end
