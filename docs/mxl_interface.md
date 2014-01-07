# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The Dell IOM switch module uses Telnet or SSH to access Dell Force10 MXL 10/40GbE Switch IO Module.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Add port channel to interface

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Add port channel to interface

     This method maps the port channel to the interface. If the port channel does not exist, it creates and maps it to the interface. 


# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------

    name: (Required)This parameter defines the name of the interface to which the port channel should be mapped.
	
	portchannel: This parameter defines the name of the port channel that is to be mapped.
				If the port channel exist, it maps to the interface.
				If port channel does not exist, it creates and adds to the interface.
				The port channel value must be between 1 and 128.
				
	mtu: This parameter sets the mtu for the interface.
		 If the value exist, it sets that value to the mtu properties of the interface.
		 If the value does not exist, property remains unchanged (default or old values).
		 The mtu value must be between  594 and 12000.
		
	shutdown: This parameter defines whether or not to shut down the interface. 
			  The possible values are "true" or "false". The default value is "false".
			  If the value is "true", it shuts down the interface.				
				
	switchport: This parameter defines whether to enable or disable the switch port. 
				The possible values are "true" or "false". The default value is "false".
				If the value is "true", it enables the switch port.
	
    
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

#Provide transport and Map properties

    mxl_interface {
						'te 0/6':
						switchport  => true,
						portchannel=>'124',
						mtu=>'600',
						shutdown=>true;
	

					} 

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
  Refer to the examples in the manifest directory.
  The following file contains the details of the sample init.pp and the supported files:
   
    - sample_mxl_interface_mapportchannel.pp
   
  You can create a init.pp file based on the above sample files and run the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
