# Type for mxl uplink state group configuration
# Parameters are

Puppet::Type.newtype(:mxl_uplinkstategroup) do
  @doc = "This represents Dell Force10 MXL uplink-state-group configuration."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "This parameter describes the uplink-state-group name to be created on the Force10 switch.
          The valid uplink-state-group is numeric, ranging from 1 - 16"
    isnamevar
    validate do |value|
      all_valid_characters = value =~ /^\d+/
      raise ArgumentError, "Invalid uplink-state-group" unless
      ( all_valid_characters and value.to_i.between?(1,16))
    end
  end
  
  newproperty(:downstream_interface) do
    desc "Interface / Port-Channel that needs to be added to the downstream"
    isrequired
    newvalues(/^\Atengigabitethernet\s*\S+/i, /te\s*\S+$/i,/^fortygige\s*\S+$/i,/^fo\s*\S+$/i, /^Port-channel\s*\S+$/i)
  end
  
  newproperty(:upstream_interface) do
    desc "Interface / Port-Channel that needs to be added to the upstream"
    isrequired
    newvalues(/^\Atengigabitethernet\s*\S+/i, /te\s*\S+$/i,/^fortygige\s*\S+$/i,/^fo\s*\S+$/i, /^Port-channel\s*\S+$/i)
  end
  
  newproperty(:downstream_property) do
    desc "property that needs to be configured to the downstream"
    newvalues('auto-recover','disable')
  end

 end
