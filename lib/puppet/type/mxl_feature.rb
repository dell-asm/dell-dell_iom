# Type for MXL VLAN
# Parameters are
#     name - Feature name. Currently supported is "fip-snooping"

Puppet::Type.newtype(:mxl_feature) do
  @doc = "This represents Dell MXL features."

  ensurable

  newparam(:name) do
    desc "feature that needs to be enabled / disabled on the switch"
    isnamevar
    isrequired
    newvalues('fip-snooping','fc')
  end


end
