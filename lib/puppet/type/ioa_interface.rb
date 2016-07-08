# Type for IOA Interface
# Parameters are
#   name - Interface Name
#   shutdown - The shutdown flag of the interface, true means Shutdown else no shutdown
#   vlan_tagged - Tag the given vlan numbers to the interface
#   vlan_untagged - UnTag the given vlan numbers to the interface

Puppet::Type.newtype(:ioa_interface) do
  @doc = "This represents Dell IOA interface."

  newparam(:name) do
    desc "Interface name, represents interface."
    isrequired
    newvalues(/^\Atengigabitethernet\s*\S+/i, /te\s*\S+$/i,/^fortygige\s*\S+$/i,/^fo\s*\S+$/i, /po\s*\d+/i)
    isnamevar
  end

  newproperty(:shutdown) do
    desc "The shutdown flag of the interface, true means Shutdown else no shutdown"
    defaultto(:false)
    newvalues(:false,:true)
  end

  newproperty(:mtu) do
    desc "MTU value"
    newvalues(/^\d+$/)

    validate do |value|
      return if value == :absent
      raise ArgumentError, "An invalid 'mtu' value is entered. The 'mtu' value must be between 594 and 12000." unless value.to_i >=594 && value.to_i <= 12000
    end
  end

  newproperty(:vlan_tagged) do
    desc "Tag the given vlan numbers to the interface."
    munge do |value|
      #If the list is empty, we send back nil so Puppet doesn't try to do anything with the property
      #Sorting the values makes it easier to compare later.
      value.split(',').sort.join(',')
    end
    validate do |value|
      return if value == :absent || value.empty?
      raise ArgumentError, "Invalid vlan list: #{value}" if value.include?(',') && !(value.split(',').size > 0)
      value.split(',').each do |vlan_value|
        raise ArgumentError, "Invalid range definition: #{value}" if value.include?('-') && value.split('-').size != 2
        vlan_value.split('-').each do |vlan|
          all_valid_characters = vlan =~ /^[0-9]+$/
          raise ArgumentError, "An invalid VLAN ID #{vlan_value} is entered.All VLAN values must be between 1 and 4094." unless all_valid_characters && vlan.to_i >= 1 && vlan.to_i <= 4094
        end
      end
    end

  end

  newproperty(:vlan_untagged) do
    desc "UnTag the given vlan numbers to the interface."
    munge do |value|
      #If the list is empty, we send back nil so Puppet doesn't try to do anything with the property
      value.empty? ? nil : value
    end
    validate do |value|
      return if value == :absent || value.empty?
      all_valid_characters = value =~ /^[0-9]+$/
      raise ArgumentError, "An invalid VLAN ID #{value} is entered. The VLAN ID must be between 1 and 4094." unless all_valid_characters && value.to_i >= 1 && value.to_i <= 4094

    end

  end

  newproperty(:switchport) do
    desc "The switchport flag of the interface, true means move the interface to Layer2, else interface will be in Layer1"
    #newvalues(:false,:true)
  end

  newproperty(:portmode) do
    desc "property to set the portmode setting on the port"
    newvalues('hybrid')
  end

  newproperty(:portchannel) do
    desc "Port-channel name which needs to be associated with this interface"
    newvalues(/^\d+$/)
    validate do |value|
      unless value.to_i >=0 && value.to_i <= 128
        raise ArgumentError, "An invalid 'portchannel' value is entered. The 'portchannel' value must be between 0 and 128."
      end
    end
  end

end

