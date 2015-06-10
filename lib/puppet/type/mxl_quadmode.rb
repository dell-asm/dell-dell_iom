# Type for configuring quad mode for interfaces
# Seperate resource is create for quad mode considering the complexity
# Parameters are
#

Puppet::Type.newtype(:mxl_quadmode) do
  @doc = "This represents Dell MXL interface quad mode."

  ensurable

  newparam(:name) do
    desc "Interface name, for which quad port needs to be enabled / disabled."
    isrequired
    isnamevar
  end

  newparam(:reboot_required) do
    desc "Flag to inidicate if switch needs to be rebooted after change."
    newvalues(:true,:false)
    defaultto(:false)
  end

end
