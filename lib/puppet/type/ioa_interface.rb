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
  end

  newproperty(:vlan_untagged) do
    desc "UnTag the vlan numbers to the interface."
  end

end

