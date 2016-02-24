# Type for IOA Mode
# Parameters are
#   name - Resource name
#   model - Possible values SMUX, PMUX, VLT

Puppet::Type.newtype(:ioa_autolag) do
  @doc = 'This represents Dell IOA auto-lag management.'

  ensurable

  newparam(:name) do
    desc "Resource name"
    isnamevar
  end

end

