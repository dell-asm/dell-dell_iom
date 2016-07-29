require 'puppet_x/force10/model/portchannel/base'
require 'puppet_x/force10/model/portchannel/generic'

module PuppetX::Dell_iom::Model::Ioa_portchannel::Base
  extend PuppetX::Force10::Model::Portchannel::Generic

  def self.register(base)
    portchannel_scope = /^(L*\s*(\d+)\s+(.*))/

    register_main_params(base)

    base.register_scoped :tagged_vlan, portchannel_scope do
      cmd "show interface port-channel %s" % base.name
      match do |txt|
        params_array=txt.match(/^T\s+(\S+)/)
        if params_array.nil?
          param = :absent
        else
          param = params_array[1]
        end
        param
      end
      add do |transport, value|
        # Find the VLANS which are already configured
        existing_config = transport.command("show config")
        tagged_vlan = ( existing_config.scan(/vlan tagged\s+(.*?)$/m).flatten.first || "" )
        vlans = tagged_vlan.split(",")
        # This array will just contain all the currently tagged vlans individually, instead of being in a range such as 1-5
        unranged_tagged_vlans = []
        vlans.each do |vlan|
          if vlan.include?("-")
            vlan_range = vlan.split("-").flatten
            vlan_value = (vlan_range[0]..vlan_range[1]).to_a
            unranged_tagged_vlans.concat(vlan_value)
          else
            unranged_tagged_vlans.push(vlan)
          end
        end
        requested_vlans = value.split(",").uniq.sort

        # Find VLANs that need to be skipped
        missing_vlans = []
        vlans_to_add = []
        (1..4094).each do |vlan_id|
          missing_vlans.push(vlan_id) unless requested_vlans.include?(vlan_id.to_s)
        end

        missing_vlans = missing_vlans.to_ranges.join(",").gsub(/\.\./,"-")
        Puppet.debug "Missing VLAN Range: #{missing_vlans}"

        if unranged_tagged_vlans == requested_vlans
          Puppet.debug "No change to tagged_vlans"
        else
          if unranged_tagged_vlans.empty?
            vlans_to_add = value
          else
            requested_vlans.map { |x| vlans_to_add.push(x) if !unranged_tagged_vlans.include?(x) }
            vlans_to_add = vlans_to_add.compact.flatten.uniq.to_ranges.join(",").gsub(/\.\./,'-')
          end
        end

        # Untag VLAN needs to be updated only if there is a overlap of untag VLAN with existing list of tag vlans
        untag_vlan = ( existing_config.scan(/vlan untagged\s+(.*?)$/m).flatten.first || "" )
        transport.command("no vlan untagged") if requested_vlans.include?(untag_vlan)

        transport.command("no vlan tagged #{missing_vlans}") if !missing_vlans.nil?
        transport.command("vlan tagged #{vlans_to_add}") if !vlans_to_add.nil?
      end

      remove { |*_| }
    end

    base.register_scoped :untagged_vlan, portchannel_scope do
      cmd "show interface port-channel %s" % base.name
      match  do |txt|
        params_array=txt.match(/^U\s+(\S+)/)
        if params_array.nil?
          param = :absent
        else
          param = params_array[1]
        end
        param
      end

      add do |transport, value|
        transport.command("no vlan untagged")
        transport.command("no vlan tagged #{value}")
        transport.command("vlan untagged #{value}")
      end
      remove do |transport, old_value|
        transport.command("no vlan untagged")
      end
    end
  end
end
