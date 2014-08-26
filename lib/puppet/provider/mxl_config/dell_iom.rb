#Provider for MXL 'CONFIG' Type
#Compares provided configuration MD5 with existing configuration MD5 and so apply the configuration if any change found
#Can use Force option for applying configuration always

require 'puppet/util/network_device'
require 'puppet/provider/dell_iom'
require 'puppet/dell_iom/util'
require 'digest/md5'

Puppet::Type.type(:mxl_config).provide :dell_iom, :parent => Puppet::Provider do
  desc "Dell MXL switch provider for configuration updates."
  def run(url, startup_config, force)
    if startup_config == :true
      return applyconfig(url,'startup-config',force)
    else
      return applyconfig(url,'running-config',force)
    end
  end

  def applyconfig(url, config, force)
    dev = Puppet::Util::NetworkDevice.current
    txt = ''
    digesttftpfile=''
    digestlocalfile=''
    configexists=true
    startupconfigchanged=false

    #delete temporary configuration files if exists
    dev.transport.command('delete flash://temp-config no-confirm')
    dev.transport.command('delete flash://last-config no-confirm')

    #Calculate MD5 for running configuration, if exists
    localfilecontent  =''
    if config=='startup-config'
      if dev.transport.class.name.include? "Telnet"
        dev.transport.command('show file flash://startup-config') do |out|
          localfilecontent<< out
        end
      else
        # In case of SSH 'out' is not returning continuous chunks of the console output
        # SSH 'out' chunks having repeat data i.e. each chunk having data from command output 'starting line'
        # And so clearing localfilecontent in loop, and so taking last output chunk
        dev.transport.command('show file flash://startup-config') do |out|
          localfilecontent =''
          localfilecontent<< out
        end
      end
    else
      dev.transport.command('copy running-config flash://last-config')
      if dev.transport.class.name.include? "Telnet"
        dev.transport.command('show file flash://last-config') do |out|
          localfilecontent<< out
        end
      else
        dev.transport.command('show file flash://last-config') do |out|
          localfilecontent =''
          localfilecontent<< out
        end
      end
    end
    if localfilecontent =~/Error:\s*(.*)/
      Puppet.info "No current configuration exists "
      configexists=false
    else
      #Remove the following information(sections) from content and so calculate MD5
      #command string(show file flash://last-config)
      #version
      #Last configuration change date
      #startup config last updated date
      for i in 0..3
        localfilecontent.slice!(0..localfilecontent.index('!'))
      end

      digestlocalfile = Digest::MD5.hexdigest(localfilecontent)
    end

    #Copy TFTP file to local
    tftpcopytxt=''
    dev.transport.command('copy ' +url+' flash://temp-config') do |out|
      tftpcopytxt<< out
    end
    parseforerror(tftpcopytxt,'copy the TFTP file')

    #Calculate MD5 for TFTP config file
    tftpfilecontent=''
    if dev.transport.class.name.include? "Telnet"
      dev.transport.command('show file flash://temp-config') do |out|
        tftpfilecontent<< out
      end
    else
      dev.transport.command('show file flash://temp-config') do |out|
        tftpfilecontent=''
        tftpfilecontent<< out
      end
    end
    parseforerror(tftpfilecontent,'retrieve the locally stored TFTP config file')

    #Remove the following information(sections) from content and so calculate MD5
    #command string(show file flash://last-config)
    #version
    #Last configuration change date
    #startup config last updated date

    for i in 0..3
      tftpfilecontent.slice!(0..tftpfilecontent.index('!'))
    end

    digesttftpfile = Digest::MD5.hexdigest(tftpfilecontent)

    Puppet.debug "MD5 for Local:"+digesttftpfile
    Puppet.debug "MD5 for Tftp:"+digestlocalfile

    #Compare MD5 and so apply config if required
    if digesttftpfile==digestlocalfile && force == :false
      Puppet.info "No Configuration change"
    else
      #TODO:Sending notification to all opened terminals
      Puppet.info "Configuration changed, applying configuration now!!!"
      Puppet::DellIom::Util.sendnotification("Applying configuration now!!!")

      #Taking Backup of existing configuration
      #Delete existing backup file
      dev.transport.command('delete flash://'+config+'-backup  no-confirm')
      dev.transport.command('copy '+config+' flash://'+config+'-backup')

      #In case startup-config already exists it will prompt for overwrite confirmation
      if config=='startup-config'
        if configexists
          dev.transport.command('copy flash://temp-config '+config, :prompt => /.\n/)
          dev.transport.command("yes")
        else
          dev.transport.command('copy flash://temp-config '+config) do |out|
            txt<< out
          end
        end
        startupconfigchanged=true
      else
        dev.transport.command('copy flash://temp-config '+config) do |out|
          txt<< out
        end
        parseforerror(txt,"apply the running configuration")
      end
    end

  rescue Exception => e
    Puppet.err e.message
    Puppet.err e.backtrace.inspect

    #ensure: Always delete the temporary files
  ensure
    dev.transport.command('delete flash://last-config no-confirm')
    dev.transport.command('delete flash://temp-config no-confirm')

    if startupconfigchanged
      #TODO:Sending notification to all opened terminals
      Puppet.info("Rebooting the switch Now!!!")
      Puppet::DellIom::Util.sendnotification("Rebooting the switch Now!!!")

      #Reboot the switch
      Puppet::DellIom::Util.tryrebootswitch()

    end
    return txt
  end

  def parseforerror(outtxt,placestr)
    if outtxt =~/Error:\s*(.*)/
      raise "Unable to "+placestr+".Reason:#{$1}"
    end
  end

end
