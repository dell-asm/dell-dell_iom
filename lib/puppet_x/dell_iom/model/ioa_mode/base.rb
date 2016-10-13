require 'puppet_x/dell_iom/model'
require 'puppet_x/dell_iom/model/ioa_mode'

module PuppetX::Dell_iom::Model::Ioa_mode::Base
  def self.ifprop(base, param, base_command = param, &block)

    base.register_scoped param, /((.*))/ do
      cmd 'show system stack-unit 0 iom-mode'
      Puppet.debug("Name: #{base.name}")
      match /.*/
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
    Puppet.debug("base: #{base.name}")
    txt = ''
    ifprop(base, :ensure) do
      match do |txt|
        if txt.match(/base.name/)
          :present
        else
          :absent
        end
      end
      default :absent

      add { |*_| }
      remove { |*_| }
    end

    ifprop(base, :vlt) do
      add do |transport, value|
        if value.eql? :false
          PuppetX::Dell_iom::Model::Ioa_mode::Base.remove_vlt_domain_setting_uplink(transport)
        end
      end
    end

    ifprop(base, :ioa_ethernet_mode) do
      Puppet.debug("IOA Ethernet mode , base name: #{base.name}")
      match do |txt|
        :present
      end
      default :absent

      add do |transport, value|
        Puppet.debug("Updating the ethernet mode of the switch")
        if value == :true
          if base.facts['product_name'].match(/2210S/) and
              (base.facts['ioa_ethernet_mode'].nil?)
            Puppet.debug('Switch is not in ethernet mode')
            transport.command('enable')
            transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
            transport.command('stack-unit 0 port-group 0 portmode ethernet',:prompt => /confirm.*/ )
            transport.command('yes')
            transport.command('end')
            # Save the configuration and reload switch
            transport.command('enable')
            transport.command('write memory')
            transport.command('reload', :prompt => /confirm.*/i)
            transport.command('yes')
            # Close connection and call connect method to restore the connection
            transport.close
            # Sleeping for a minute
            (1..9).each do |retry_count|
              sleep(60)
              begin
                transport.connect
                break
              rescue Exception => e
                Puppet.debug("Failed to connect, retry counter #{retry_count}")
              end
            end
            base.facts['ioa_ethernet_mode'] = 'stack-unit 0 port-group 0 portmode ethernet'
          end
        else
          Puppet.debug("Flag for setting the ethernet mode is false")
        end
      end
      remove { |*_| }
    end

    #TODO:  This is pretty inconsistent with the way we usually do the properties.  Usually it's in the "add" block.  Might be nice to change for consistency's sake.
    ifprop(base, :iom_mode) do
      Puppet.debug("Base name: #{base.name}")
      if !base.name.downcase.match(/vlt_settings/)
      desired_iom_mode = 'programmable-mux' if base.name.downcase.match(/pmux|programmable*/)
      desired_iom_mode = 'standalone' if base.name.downcase.match(/smux|stand*/)
      desired_iom_mode = 'pmux_vlt' if base.name.downcase.match(/^vlt/)
      desired_iom_mode ='full-switch' if base.name.downcase.match(/fullswitch*/)
      Puppet.debug("desired iom mode: #{desired_iom_mode}")
      match do |txt|
        Puppet.debug("TXT for matching: #{txt}")
        :present
      end
      default :absent

      if base.facts['iom_mode'] != desired_iom_mode
        # For VLT, change the switch to ethernet mode for FN 2210S IOA
        if desired_iom_mode == 'pmux_vlt' and base.facts['product_name'].match(/2210/) and base.facts['ioa_ethernet_mode'].nil?
          transport.command('enable')
          transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
          transport.command('stack-unit 0 port-group 0 portmode ethernet', :prompt => /confirm.*/)
          transport.command('yes')
          transport.command('end')
          # Save the configuration and reload switch
          transport.command('enable')
          transport.command('write memory')
          transport.command('reload', :prompt => /confirm.*/i)
          transport.command('yes')
          # Close connection and call connect method to restore the connection
          transport.close
          # Sleeping for a minute
          (1..5).each do |retry_count|
            sleep(60)
            begin
              transport.connect
              break
            rescue Exception => e
              Puppet.debug("Failed to connect, retry counter #{retry_count}")
            end
          end
          base.facts['ioa_ethernet_mode'] = 'stack-unit 0 port-group 0 portmode ethernet'
        end
        transport.command('enable')
        transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
        if desired_iom_mode.eql? 'pmux_vlt'
          transport.command('stack-unit 0 iom-mode programmable-mux')
        else
          transport.command("stack-unit 0 iom-mode #{desired_iom_mode}")
        end
        transport.command('end')
        # Save the configuration and reload switch
        transport.command('write memory')
        transport.command('reload', :prompt => /confirm.*/)
        transport.command('yes')
        base.facts['iom_mode'] = desired_iom_mode
        # Close connection and call connect method to restore the connection
        transport.close
        # Sleeping for a minute
        (1..5).each do |retry_count|
          Puppet.debug("sleeping for 1 minute and the trying to connect")
          sleep(60)
          begin
            transport.connect
            # Sleeping for additional minute to allow switch to come to normal state
            Puppet.debug('Sleeping for additional minute to allow switch to come to normal state')
            sleep(60)
            break
          rescue Exception => e
            Puppet.debug("Failed to connect, retry counter #{retry_count}")
          end
        end
      end
      end
      add { |*_|}
      remove { |*_|}
    end

    ifprop(base, :port_channel) do
      add do |transport, value|
        base.port = value
      end
    end

    ifprop(base, :destination_ip) do
      add do |transport, value|
        base.destination_ip = value
      end
    end

    ifprop(base, :unit_id) do
      add do |transport, value|
        base.device_id = value
      end
    end

    ifprop(base, :interface) do
      add do |transport, value|
        interfaceports = JSON.parse(value)
        interfaceports.each do |i|
          # checks if interface port is taken as fc as fc is not available in full-switch mode
          # changes to Te if iom is in full-switch mode
          if i.include?("Fc")
            if base.facts["iom_mode"] == "full-switch"
              i.gsub!('Fc', 'Te')
            end
          end

          i.gsub!('Fo', 'fortyGigE')
          i.gsub!('Te', 'Tengigabitethernet')
        end
        interfaceports.each do |interface|
          transport.command('enable')
          transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
          transport.command("int #{interface}")
          transport.command('no shutdown')
          transport.command('end')
        end
        base.interfaceport = interfaceports
        PuppetX::Dell_iom::Model::Ioa_mode::Base.configure_vlt_setting(transport, base.interfaceport, base.destination_ip, base.device_id, base.port)
      end
    end
  end

  def self.configure_vlt_setting(transport, interface_ports, destination_ip, device_id, port_channel)
    vltdomain = {}
    vltdomain['port_channel'] = port_channel
    vltdomain['ip_destination'] = destination_ip
    vltdomain['unit-id'] = device_id
    PuppetX::Dell_iom::Model::Ioa_mode::Base.remove_vlt_uplinks(transport)
    PuppetX::Dell_iom::Model::Ioa_mode::Base.configureportchannel(transport, port_channel, interface_ports)
    PuppetX::Dell_iom::Model::Ioa_mode::Base.configure_vltdomain(transport, vltdomain)
  end

  def self.configureportchannel(transport, port_channel, interface_port)
    transport.command('enable')
    transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
    interface_port.each do |interface|
      transport.command("int #{interface}")
      port_channel_protocol_results = transport.command('show config')
      if port_channel_protocol_results.include? "port-channel-protocol"
        transport.command('no port-channel-protocol lacp')
        transport.command('exit')
      end
    end
    transport.command("interface port-channel #{port_channel}")
    interface_port.each do |port|
      transport.command("channel-member #{port}")
    end
    transport.command('no shutdown')
    transport.command('end')
  end

  def self.configure_vltdomain(transport, vlt)
    transport.command('enable')
    transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
    transport.command('vlt domain 1')
    transport.command("peer-link port-channel #{vlt["port_channel"]}")
    transport.command("back-up destination #{vlt["ip_destination"]}")
    transport.command("unit-id #{vlt["unit-id"]}")
    transport.command('end')
  end

  def self.remove_vlt_uplinks(transport)
    Puppet.debug("removing existing uplinks")
    PuppetX::Dell_iom::Model::Ioa_mode::Base.remove_vlt_domain_setting_uplink(transport)
    existingportschannels = PuppetX::Dell_iom::Model::Ioa_mode::Base.get_existing_port_channels(transport)
    transport.command('enable')
    transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
    if existingportschannels
      existingportschannels.each do |portchannel|
        transport.command("int port-channel #{portchannel}")
        cmdout=transport.command('show config')
        portconfig=cmdout.split("\n")
        portconfig.each do |line|
          if line.include? 'channel-member'
            transport.command("no #{line}")
            transport.command('shutdown')
          end
        end
        transport.command('exit')
        transport.command("no interface port-channel #{portchannel}")
      end
    end
    transport.command('end')
  end

  def self.remove_vlt_domain_setting_uplink(transport)
    Puppet.debug(" removing existing vlt port settings")
    transport.command('enable')
    transport.command('configure terminal', :prompt => /\(conf\)#\z/n)
    transport.command('vlt domain 1')
    vlt_domaindata=transport.command('show config')
    if vlt_domaindata.include? 'peer-link port-channel'
      transport.command('no peer-link')
    end
    transport.command('end')
  end

  def self.get_existing_port_channels(transport)
    existingportschannels=[]
    port_Channels= transport.command('show interface port-channel brief')
    if !port_Channels.include? "No such interface"
      cmdresult=port_Channels.split("\n")
      cmdresult.each do |line|
        if line =~ /\s(\d+\s)/
          existingportschannels << $1
        end
      end
      existingportschannels
    end
  end

end
