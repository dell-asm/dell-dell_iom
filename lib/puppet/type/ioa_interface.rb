Puppet::Type.newtype(:ioa_interface) do
  @doc = "This represents a IOA switch interface."

  apply_to_device

  newparam(:name) do
    desc "The interface's name."
    isrequired
    newvalues(/^\A+tengigabitethernet\s*\S+/i, /te\s*\S+$/i,/^fortygige\s*\S+$/i,/^fo\s*\S+$/i)
    isnamevar
  end

  newproperty(:shutdown) do
    desc "Enable or disable  the interface."
    defaultto(:false)
    newvalues(:false,:true)
  end

  newproperty(:vlan_tagged) do
    desc "Tag the vlan numbers to the interface."
    validate do |value|
      return if value == :absent
      all_valid_characters = value =~ /^[0-9]+$/
      paramsarray=value.match(/(\d*)\s*[,-]\s*(\d*)/)
      if paramsarray.nil?
       raise ArgumentError, "An invalid VLAN ID is entered.The VLAN ID must be between 1 and 4094. And it should be in a format like 67,89 or 50-100 or 89" unless all_valid_characters && value.to_i >= 1 && value.to_i <= 4094
      else
       param1 = paramsarray[1]
       param2 = paramsarray[2]
       raise ArgumentError, "An invalid VLAN ID is entered.The VLAN ID must be between 1 and 4094." unless all_valid_characters && param1.to_i >= 1 && param1.to_i <= 4094
       raise ArgumentError, "An invalid VLAN ID is entered.The VLAN ID must be between 1 and 4094." unless all_valid_characters && param2.to_i >= 1 && param2.to_i <= 4094
  
      end
      raise ArgumentError, "An invalid VLAN ID is entered. The VLAN ID must be between 1 and 4094." unless all_valid_characters && value.to_i >= 1 && value.to_i <= 4094

    end



  end

  newproperty(:vlan_untagged) do
    desc "UnTag the vlan numbers to the interface."
    validate do |value|
      return if value == :absent
      all_valid_characters = value =~ /^[0-9]+$/
      raise ArgumentError, "An invalid VLAN ID is entered. The VLAN ID must be between 1 and 4094." unless all_valid_characters && value.to_i >= 1 && value.to_i <= 4094
 
    end


  end

end

