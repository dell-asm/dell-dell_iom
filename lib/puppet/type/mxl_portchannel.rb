# Type for MXL Port-channel
# Parameters are
#     name - Port-channel name
# Properties are
#   desc - description for Port-channel
#   mtu - mtu value for Port-channel
#   shutdown - The shutdown flag of the Port-channel, true means Shutdown else no shutdown

Puppet::Type.newtype(:mxl_portchannel) do
  @doc = "This represents Dell MXL switch port-channel."

  ensurable

  newparam(:name) do
    desc "Port-channel name, represents Port-channel"
    isnamevar
    newvalues(/^\d+$/)

    validate do |value|
      return if value == :absent
      raise ArgumentError, "An invalid 'portchannel' value is entered. The 'portchannel' value must be between 1 and 128." unless value.to_i >=1 &&	value.to_i <= 128
    end

  end

  newproperty(:desc) do
    desc "Port-channel Description"
    newvalues(/^(\w\s*)*?$/)
  end

  newproperty(:mtu) do
    desc "MTU value"
    newvalues(/^\d+$/)

    validate do |value|
      return if value == :absent
      raise ArgumentError, "An invalid 'mtu' value is entered. The 'mtu' value must be between 594 and 12000." unless value.to_i >=594 && value.to_i <= 12000
    end
  end

  newproperty(:switchport) do
    desc "The switchport flag of the Port-channel, true mean move the port-channel to Layer2, else interface will be in Layer1"
    defaultto(:false)
    newvalues(:false,:true)
  end

  newproperty(:portmode) do
    desc "property to set the portmode setting on the port"
    newvalues("hybrid")
  end

  newproperty(:shutdown) do
    desc "The shutdown flag of the Port-channel, true means Shutdown else no shutdown"
    defaultto(:false)
    newvalues(:false,:true)
  end

  newproperty(:fcoe_map) do
    desc "fcoe map that needs to be associated with the port-channel"
    validate do |value|
      all_valid_characters = value =~ /^[A-Za-z0-9_]+$/
      raise ArgumentError, "Invalid fcoe-map name" unless all_valid_characters
    end
  end

  newproperty(:fip_snooping_fcf) do
    desc "enable / disable fip-snooping fcf setting"
    newvalues(:false,:true)
  end

  newproperty(:vltpeer) do
    desc "enable / disable fip-snooping fcf setting"
    newvalues(:false,:true)
  end

  newproperty(:ungroup) do
    desc "Force this port-channel's members to become switchports if not up"
    defaultto(:false)
    newvalues(:false,:true)
  end

  newproperty(:portfast) do
    desc "property to set the spanning tree portfast setting"
    newvalues("portfast")
  end

  newproperty(:edge_port) do
    desc "property to set the spanning-tree edge-port setting"
    validate do |value|
      return if value.empty?
    end
  end

  newproperty(:tagged_vlan) do
    desc "Tag the given vlan numbers to the interface."
    munge do |value|
      #Sorting the values makes it easier to compare later.
      value.split(',').sort.join(',')
    end
    validate do |value|
      return if value == :absent || value.empty?
      raise ArgumentError, "Invalid vlan list: #{value}" if value.include?(',') && !(value.split(',').size > 0)
      value.split(',').each do |vlan_value|
        raise ArgumentError, "Invalid range definition: #{value}" if value.include?('-') && value.split('-').size != 2
        vlan_value.split('-').each do |vlan|
          Puppet::Type::Mxl_portchannel.validate_vlan(vlan)
        end
      end
    end
  end

  newproperty(:untagged_vlan) do
    desc "untag the given vlan numbers to the interface."
    munge do |value|
      # Nil value ensures Puppet won't do anything
      value.empty? ? nil : value
    end
    validate do |value|
      return if value == :absent || value.empty?
      Puppet::Type::Mxl_portchannel.validate_vlan(value)
    end
  end

  def self.validate_vlan(vlan)
    all_valid_characters = vlan =~ /^[0-9]+$/
    unless all_valid_characters && vlan.to_i >= 1 && vlan.to_i <= 4094
      raise ArgumentError, "An invalid VLAN ID #{vlan} is entered. The VLAN ID must be between 1 and 4094."
    end
  end

end
