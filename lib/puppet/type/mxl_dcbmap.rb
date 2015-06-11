# Type for mxl dcb map configuration
# Parameters are

Puppet::Type.newtype(:mxl_dcbmap) do
  @doc = "This represents Dell Force10 MXL dcbmap configuration."

  newparam(:name) do
    desc "This parameter describes the dcb-map name to be created on the Force10 switch.
          The valid dcb-map name does not allow blank value, special character except _ ,numeric char at the start, and length above 64 chars"
    isnamevar
    validate do |value|
      all_valid_characters = value =~ /^[A-Za-z0-9_]+$/
      raise ArgumentError, "Invalid dcb-map name" unless all_valid_characters
    end
  end

  newproperty(:priority_group_info) do
    desc "Priority group information. Needs to be in a hash"
    validate do |value|
      raise ArgumentError, "Invalid format" unless value.is_a?(Hash)
      value.keys.each do |key|
        bandwidth = ( value[key]['bandwidth'] || 0 )
        pfc = ( value[key]['pfc'] || '' )
        raise ArgumentError, 'Incorrect bandwith %' unless bandwidth.to_i.between?(1,100)
        raise ArgumentError, 'Incorrect pfc value' unless ['on','off'].include?(pfc)
      end
    end
  end

  newproperty(:priority_pgid) do
      desc "DCB Map Priority group id"
      validate do |value|
        all_valid_characters = value =~ /^\d\s\d\s\d\s\d\s\d\s\d\s\d\s\d$/
        raise ArgumentError, "Invalid priority-pgid. Example value '0 0 0 1 0 0 0 0'" unless all_valid_characters
      end
    end

 end
