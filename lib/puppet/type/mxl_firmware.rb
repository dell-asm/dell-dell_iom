Puppet::Type.newtype(:mxl_firmware) do 
  @doc = "This will update the firmware on the mxl chassis"
  apply_to_device

  ensurable
  newparam(:name, :namevar => true) do
    desc "Name of the resource"
  end
  
  newparam(:version) do
    desc "The vresion that the firmware should be on"
  end
  
  newparam(:asm_hostname) do 
    desc " The host ip for the remote location of the firmware"
  end

  newparam(:path) do
    desc " The path for the remote lcoation of the firmware"
  end

end
