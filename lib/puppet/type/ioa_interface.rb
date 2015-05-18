# Type for IOA Interface
# Parameters are
#   name - Interface Name
#   shutdown - The shutdown flag of the interface, true means Shutdown else no shutdown
#   vlan_tagged - Tag the given vlan numbers to the interface
#   vlan_untagged - UnTag the given vlan numbers to the interface

Puppet::Type.newtype(:ioa_interface) do
  @doc = "This represents Dell IOA interface."

  apply_to_device

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

  newproperty(:vlan_tagged) do
    desc "Tag the given vlan numbers to the interface."
    munge do |value|
      #If the list is empty, we send back nil so Puppet doesn't try to do anything with the property
      value.empty? ? nil : value
    end
    validate do |value|
      return if value == :absent || value.empty?
      all_valid_characters = value =~ /^[0-9]+$/
      paramsarray=value.match(/(\d*)\s*[,-]\s*(\d*)/)
      param1 = paramsarray[1]
      param2 = paramsarray[2]
      all_valid_characters = param1 =~ /^[0-9]+$/
      raise ArgumentError, "An invalid VLAN ID #{param1} is entered.The VLAN ID must be between 1 and 4094." unless all_valid_characters && param1.to_i >= 1 && param1.to_i <= 4094
      all_valid_characters = param2=~ /^[0-9]+$/
      raise ArgumentError, "An invalid VLAN ID #{param2} is entered.The VLAN ID must be between 1 and 4094." unless all_valid_characters && param2.to_i >= 1 && param2.to_i <= 4094
      raise ArgumentError, "An invalid VLAN ID #{value} is entered. The VLAN ID must be between 1 and 4094." unless all_valid_characters && value.to_i >= 1 && value.to_i <= 4094
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

end

