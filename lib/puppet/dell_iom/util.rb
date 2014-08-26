module Puppet
  module DellIom
    module Util
      def self.tryrebootswitch()
        #Some times sending reload command returning with console prompt without doing anything; in that case retry reload, for max 3 times
        for i in 0..2
          if rebootswitch()
            break
          end
        end
      end
    
      def self.rebootswitch()
        dev = Puppet::Util::NetworkDevice.current
        flagfirstresponse=false
        flagsecondresponse=false
        flagthirdresponse=false
    
        dev.transport.command("reload")  do |out|
          firstresponse =out.scan("System configuration has been modified")
          secondresponse = out.scan("Proceed with reload")
          unless firstresponse.empty?
            flagfirstresponse=true
            break
          end
          unless secondresponse.empty?
            flagsecondresponse=true
            break
          end
        end
    
        #Some times sending reload command returning with console prompt without doing anything, in that case retry reload
        if !flagfirstresponse && !flagsecondresponse
          return false
        end
    
        if flagfirstresponse
          dev.transport.command("no") do |out|
            thirdresponse = out.scan("Proceed with reload")
            unless thirdresponse.empty?
              flagthirdresponse=true
              break
            end
          end
          if flagthirdresponse
            dev.transport.command("yes") do |out|
              #without this block expecting for prompt and so hanging
              break
            end
          else
            Puppet.debug "ELSE BLOCK1.2"
          end
        else
          Puppet.debug "ELSE BLOCK1.1"
        end
        if flagsecondresponse
          dev.transport.command("yes") do |out|
            #without this block expecting for prompt and so hanging
            break
          end
        else
          Puppet.debug "ELSE BLOCK2"
        end
    
        #Sleep for 2 mins to wait for switch to come up
        Puppet.info("Going to sleep for 2 minutes, for switch reboot...")
        sleep 120
    
        Puppet.info("Checking if switch is up, pinging now...")
        for i in 0..20
          if pingable?(dev.transport.host)
            Puppet.info("Ping Succeeded, trying to reconnect to switch...")
            break
          else
            Puppet.info("Switch is not up, will retry after 1 min...")
            sleep 60
          end
        end
    
        #Re-esatblish transport session
        dev.connect_transport
        dev.switch.transport=dev.transport
        Puppet.info("Session established...")
        return true
      end
    
      def self.pingable?(addr)
        output = `ping -c 4 #{addr}`
        !output.include? "100% packet loss"
      end
    
      def self.sendnotification(msg)
        dev = Puppet::Util::NetworkDevice.current
        dev.transport.command("send *",:prompt => /Enter message./)
        if dev.transport.class.name.include? "Telnet"
          dev.transport.command(msg+"\x1A",:prompt => /Send message./)
        else
          dev.transport.sendwithoutnewline(msg+"\x1A")
        end
        dev.transport.command("\r")
        dev.transport.command("\r")
      end
    end
  end
end

    
