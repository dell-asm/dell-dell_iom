require 'puppet_x/dell_iom/model/ioa_interface'

module PuppetX::Dell_iom::Model::Ioa_interface::Base
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

    ifprop(base, :switchport) do
      match do |switchporttxt|
        unless switchporttxt.nil?
          switchporttxt.downcase.include? "vlan membership"
        end
      end
      add do |transport, value|
        unless value.nil?
          cmd = value ? 'switchport' : 'no switchport'
          transport.command(cmd) do |out|
            if out =~/Error:\s*(.*)/
              Puppet.debug "#{$1}"
            end
          end
        end
      end
      remove { |*_| }
    end

    ifprop(base, :portmode) do
      match do |txt|
        txt =~ /Hybrid/i ? :hybrid : nil
      end

      add do |transport, value|
        Puppet.debug('Need to remove existing configuration to set portmode')
        existing_config=(transport.command('show config') || '').split("\n").reverse
        updated_config = existing_config.find_all {|x| x.match(/dcb|switchport|spanning|vlan/)}
        updated_config.each do |remove_command|
          remove_command = remove_command.split(" ")[0..-2].join(" ") if remove_command.match /vlan untagged/
          transport.command("no #{remove_command}")
        end
        transport.command('portmode hybrid')
        updated_config.reverse.each do |remove_command|
          transport.command("#{remove_command}")
        end
      end
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
        if base.facts["system_type"].match(/PE-FN.*-IOM/) && base.facts["iom_mode"].eql?("full-switch")
          transport.command("exit")
          value.split(',').map{ |value|
            transport.command("interface vlan #{value}")
            existing_config = transport.command("show config")
            existing_config.split("\n").map{|line|
              (transport.command("no #{line}")) if line =~ /tagged TenGigabitEthernet\s\d+..*/
              (transport.command("no #{line}")) if line =~ /untagged TenGigabitEthernet\s\d+..*/
            }
            transport.command("tagged #{scope_name}")
            transport.command("tagged #{exit}")
          }
          transport.command("interface #{scope_name}")
        else
          # Find the VLANS which are already configured
          existing_config = transport.command("show config")
          tagged_vlan = ( existing_config.scan(/vlan tagged\s+(.*?)$/m).flatten.first || '' )
          vlans = tagged_vlan.split(",")
          # This array will just contain all the currently tagged vlans individually, instead of being in a range such as 1-5
          unranged_tagged_vlans = []
          vlans.each_with_index do |vlan,index|
            if vlan.include?('-')
              vlan_range = vlan.split("-").flatten
              vlan_value = (vlan_range[0]..vlan_range[1]).to_a
              unranged_tagged_vlans.concat(vlan_value)
            else
              unranged_tagged_vlans.push(vlan)
            end
          end
          requested_vlans = value.split(",").uniq.sort
          Puppet.debug "Requested_vlans: #{requested_vlans}"

          # Find VLANs that need to be skipped
          missing_vlans = []
          vlans_toadd = []
          (1..4094).each do |vlan_id|
            missing_vlans.push(vlan_id) if !requested_vlans.include?(vlan_id.to_s)
          end

          missing_vlans = missing_vlans.to_ranges.join(",").gsub(/\.\./,'-')
          Puppet.debug "Missing VLAN Range: #{missing_vlans}"

          if unranged_tagged_vlans == requested_vlans
            Puppet.debug "No change"
          else
            if unranged_tagged_vlans.empty?
              vlans_toadd = value
            else
              requested_vlans.map { |x| vlans_toadd.push(x) if !unranged_tagged_vlans.include?(x) }
              vlans_toadd = vlans_toadd.compact.flatten.uniq.to_ranges.join(",").gsub(/\.\./,'-')
            end
          end

          # Untag VLAN needs to be updated only if there is a overlap of untag VLAN with existing list of tag vlans
          untag_vlan = ( existing_config.scan(/vlan untagged\s+(.*?)$/m).flatten.first || '' )

          transport.command("no vlan untagged") if requested_vlans.include?(untag_vlan)

          transport.command("no vlan tagged #{missing_vlans}") if !missing_vlans.nil?
          transport.command("vlan tagged #{vlans_toadd}") if !vlans_toadd.nil?

        end
      end

      remove { |*_| }
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
        if base.facts["system_type"].match(/PE-FN.*-IOM/) && base.facts["iom_mode"].eql?("full-switch")
          transport.command("exit")
          value.split(',').map{ |value|
            transport.command("interface vlan #{value}")
            existing_config = transport.command("show config")

            existing_config.split("\n").map{|line|
              (transport.command("no #{line}")) if line =~ /untagged TenGigabitEthernet\s\d+..*/
            }
            transport.command("untagged #{scope_name}")
            transport.command("exit")
          }
          transport.command("interface #{scope_name}")
        else
          transport.command("no vlan untagged")
          transport.command("no vlan tagged #{value}")
          transport.command("vlan untagged #{value}")
        end
      end
      remove do |transport, old_value|
        transport.command("no vlan untagged")
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
