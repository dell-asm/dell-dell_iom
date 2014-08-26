require 'puppet/util/network_device'
require 'puppet/provider/dell_iom'
require 'puppet/dell_iom/util'

Puppet::Type.type(:mxl_firmware).provide :dell_iom, :parent => Puppet::Provider do
  desc "Dell MXL switch provider for configuration of the firmware"

  def exists?
    @fw = {}
    @fw['version'] = resource[:version]
    @fw['path']    = resource[:path]
    @fw_host       = resource[:asm_hostname]
    $stack_to_update = get_current_version(@fw['version'])
    if $stack_to_update.count != 0
      false
    else
      true
    end
  end

  def get_current_version(fw_version)
    stack_units = {}
    dev = Puppet::Util::NetworkDevice.current
    output = dev.transport.command('show boot system stack-unit all')
    output.each_line do |ln|
      ln.downcase!
      if ln.start_with? 'stack-unit' and !ln.include? 'not present'
        stack_units[ln.split(' ')[1]] = {'B' => ln.split(' ').last, 'A' => ln.split(' ')[-2]}
      end
    end
    Puppet.debug("****************************************************************")
    Puppet.debug("versions: #{stack_units}")
    stack = {}
    stack_units.each do |k,v|
      if v['A'].include? 'boot'
        boot = 'A'
        version = v['A'].gsub('[boot]','').gsub(/[^a-z0-9\s]/i, '.')
        if version.end_with? '.'
          version.chop!
        end
      elsif v['B'].include? 'boot'
        boot = 'B'
        version = v['B'].gsub('[boot]','').gsub(/[^a-z0-9\s]/i, '.')
        if version.end_with? '.' 
          version.chop!
        end
      end 
      stack[k] = {:version => version, :boot => boot}
    end
    to_update = []
    stack.each do |k,v|
      if v[:version] != fw_version
        Puppet.debug "Firmware update needed for stack-unit = #{k}.  Current version: #{v[:version]} | required version #{fw_version}.  Partition: #{v[:boot]}"
        to_update << { :unit => k, :properties => v}
      else
        Puppet.debug "Firmware version up to date for stack unit: #{k}"
      end
    end
    to_update
  end



  def create
    location = @fw['path']
    dev = Puppet::Util::NetworkDevice.current 
    Puppet.debug("#{$stack_to_update}")
    $stack_to_update.each do |s| 
      @nonboot = s[:properties][:boot] == 'A' ? 'b' : 'a'
      Puppet.debug("updating stack unit: #{s[:unit]}")
      update_cmd = "upgrade system tftp://#{@fw_host}/#{location} #{@nonboot}:"
      output = dev.transport.command(update_cmd)
      if !output.include? 'System image upgrade completed successfully'
        raise Puppet::Error, "Failed to updrade stack unit #{s[:unit]}"
      end
    end
    change_boot_stack(dev,@nonboot)
    change_startup
    Puppet::DellIom::Util.tryrebootswitch()
  end


  def change_boot_stack(dev,newboot)
    dev.transport.command("config")
    dev.transport.command("boot system stack-unit all primary system #{newboot}:")
    dev.transport.command("exit")
  end

  def change_startup
    dev = Puppet::Util::NetworkDevice.current
    dev.transport.command("copy running-config startup-config") do |out|
      if out.include? 'Proceed'
        break
      end
    end
    dev.transport.command("yes")
  end

end
