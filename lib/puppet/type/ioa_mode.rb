# Type for IOA Mode
# Parameters are
#   name - Resource name
#   model - Possible values SMUX, PMUX, VLT

Puppet::Type.newtype(:ioa_mode) do
  @doc = 'This represents Dell IOA mode management.'

  ensurable

  newparam(:name) do
    desc 'Mode that needs to be configured on the switch, if not already configured'
    newvalues('smux','pmux','vlt','fullswitch','vlt_settings')
    isrequired
    isnamevar
  end

  newproperty(:vlt) do
    desc 'flag to  remove existing vlt configuration'
    newvalues(:true, :false)
  end

  newproperty(:default_configuration) do
    desc 'Flag to manage the default configuration change of the switch. true - change the configuration to default'
    newvalues(:true,:false)
  end

  newparam(:iom_mode) do
    desc 'Mode that needs to be configured on the switch, if not already configured'
    newvalues('smux','pmux','vlt','fullswitch')
  end

  newproperty(:ioa_ethernet_mode) do
    desc 'flag to decide if ioa ethernet mode needs to be enabled'
    newvalues(:true,:false)
  end

  newproperty(:port_channel) do
    desc 'for vlt peer-port channel'
    validate do |value|
      return if value == :absent || value.nil?
    end
  end

  newproperty(:destination_ip) do
    desc 'vlt destination_ip for backup link'
    validate do |value|
      return if value == :absent || value.empty?
    end
  end

  newproperty(:unit_id) do
    desc 'device_id for priority'
    validate do |value|
      return if value == :absent || value.empty?
    end
  end

  newproperty(:interface) do
    desc 'interface ports to be assigned to the port channel'
    validate do |value|
      return if value == :absent || value.empty?
    end
  end

end

