# Type for IOA Mode
# Parameters are
#   name - Resource name
#   model - Possible values SMUX, PMUX, VLT

Puppet::Type.newtype(:ioa_mode) do
  @doc = 'This represents Dell IOA mode management.'

  apply_to_device
  ensurable

  newparam(:name) do
    desc 'Mode that needs to be configured on the switch, if not already configured'
    newvalues('smux','pmux','vlt')
    isrequired
    isnamevar
  end

  newproperty(:default_configuration) do
    desc 'Flag to manage the default configuration change of the switch. true - change the configuration to default'
    newvalues(:true,:false)
  end

  newparam(:iom_mode) do
    desc 'Mode that needs to be configured on the switch, if not already configured'
    newvalues('smux','pmux','vlt')
  end

  newproperty(:ioa_ethernet_mode) do
    desc 'flag to decide if ioa ethernet mode needs to be enabled'
    newvalues(:true,:false)
  end

end

