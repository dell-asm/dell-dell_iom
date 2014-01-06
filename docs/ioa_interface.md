# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The Dell IOA switch module uses telnet/SSH to access Dell IOA switches.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Add port channel to interface

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Add vlans to interface

     This method maps the vlans to the interface. 

# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------

    name: (Required)This parameter defines the name of the interface to which the vlans to be mapped.
	
	vlan_tagged: This parameter defines vlan or vlan range  that is to be mapped in tagged mode.
				 The vlan value or range must be in between 1 and 4094.
				
	vlan_untagged: This parameter defines vlan or vlan range  that is to be mapped in untagged mode.
				   The vlan value or range must be in between 1 and 4094.
		
	shutdown:   This parameter defines whether or not to shut down the interface. 
				The possible values are "true" or "false". The default value is "false".
				If the value is 'true", it shuts down the interface.
				The value must be between 594 and 2000
				
	
    
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

#Provide transport and Map properties

    ioa_interface {
						'te 0/6':
						vlan_tagged => '100-110',
						vlan_untagged => '88',
						shutdown=>true;
					} 

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
   Refer to the examples in the manifest directory.
  The following file contains the details of the sample init.pp and the supported files:
   
    - sample_ioa_interface.pp
   
   A user can create a init.pp file based on the above sample files and call the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
