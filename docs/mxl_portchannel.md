# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The Dell IOM switch module uses Telnet or SSH to access Dell Force10 MXL 10/40GbE Switch IO Module.

#-------------------------------------------------------------------------------
# Functionality Supported
#-------------------------------------------------------------------------------

- Create Portchannels
- Remove Portchannels

#-------------------------------------------------------------------------------
# Description
#-------------------------------------------------------------------------------

The port channel type or provider supports the functionality to create and delete the port channels on the MXL.

#-------------------------------------------------------------------------------
# Summary of Properties
#-------------------------------------------------------------------------------

    name: (Required)This parameter defines the name of the port channel to be created or removed.
	
	desc: This parameter defines the description for the port channel.
				
	mtu:	  - This parameter sets the mtu for the interface.
				If the value exist, it sets the value to the mtu properties of the interface.
				If the value does not exists, the property remains unchanged (default or old values).
				The mtu value must be between  594 and 12000.
		
	shutdown: - This parameter specifies whether or not to shut down the interface. 
				The possible values are true or false. The default value is "false".
				If the value is "true", it shuts down the interface.				
				
	ensure: - This parameter specifies whether to create the specified port channel or delete the specified port channel from the switch.
	          The possible values are "present" or "absent".
	
    
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

#Provide transport and Map properties

    mxl_portchannel {
						'128':
						desc  => 'Port Channel for server connectivity',
						mtu=>'600',
						shutdown=>true,
						ensure=>present;
	

					} 

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
  Refer to the examples in the manifest directory.
  The following file contains the details for the sample init.pp and the supported files:
   
    - sample_mxl_portchannel.pp
   
   You can create a init.pp file based on the above sample files and run the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
