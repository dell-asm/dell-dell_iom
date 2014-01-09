# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The Dell MXL switch module uses telnet/SSH to access Dell MXL switches.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Add/Update switch 'running' configuration
	- Add/Update switch 'startup' configuration

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Add/Update switch running configuration

     This method supports the functionality to add or update the switch 'running' configuration. 
  2. Add/Update switch startup configuration

     The method supports the functionality to add or update the switch 'startup' configuration. 


# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------

    name: (Required)This parameter defines the name of the operation. The parameter name can contain any string.
	
	url:This parameter defines the TFTP URL of the configuration file.				
				
	force:Use this parameter to force configuration update on the switch.
		If the value is set to "true", it will force configuration update on the switch even if configuration changes are not required.
		If the value is set to "false", it will not update the configuration on the switch if configuration changes are not required.
		The possible values are "true" or "false".		
    
# -------------------------------------------------------------------------
# Parameter signature 
# -------------------------------------------------------------------------

#Provide transport and Map properties

   mxl_config{
	'apply config':    	
		url     => 'tftp://172.152.0.36/running-config',    
		startup_config => false,
		force=>false; 
	}


# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
  Refer to the examples in the manifest directory.
  The following file contain the details for the sample init.pp and the supported files:
   
    - sample_mxl_config.pp
   
   A user can create a init.pp file based on the above sample files and call the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
