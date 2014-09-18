# Type for configuring quad mode for interfaces
# Seperate resource is create for quad mode considering the complexity
# Parameters are
#     

Puppet::Type.newtype(:mxl_quadmode) do
  @doc = "This represents Dell MXL interface quad mode."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "Interface name, for which quad port needs to be enabled / disabled."
    isrequired
    newvalues(/^\Atengigabitethernet\s*\S+/i, /te\s*\S+$/i,/^fortygige\s*\S+$/i,/^fo\s*\S+$/i)
    isnamevar
  end

end
