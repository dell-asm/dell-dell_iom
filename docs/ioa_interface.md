# --------------------------------------------------------------------------
# Access Mechanism 
# --------------------------------------------------------------------------

The Dell IOM switch module uses Telnet or SSH to access Dell PowerEdge M I/O Aggregator.

# --------------------------------------------------------------------------
#  Supported Functionality
# --------------------------------------------------------------------------

	- Add VLANs to interface

# -------------------------------------------------------------------------
# Functionality Description
# -------------------------------------------------------------------------


  1. Add VLANs to interface

     This method maps the VLANs to the interface. 

# -------------------------------------------------------------------------
# Summary of Parameters
# -------------------------------------------------------------------------

    name: (Required)This parameter defines the name of the interface to which the VLANs should be mapped.
	
	vlan_tagged: This parameter defines VLAN or VLAN range that is to be mapped in tagged mode.
				 The VLAN value or range must be in between 1 and 4094.
				
	vlan_untagged: This parameter defines VLAN or VLAN range  that is to be mapped in untagged mode.
				   The VLAN value or range must be in between 1 and 4094.
		
	shutdown:   This parameter defines whether or not to shut down the interface. 
				The possible values are "true" or "false". The default value is "false".
				If the value is "true", it shuts down the interface.				
				
	
    
# -------------------------------------------------------------------------
# Parameter Signature 
# -------------------------------------------------------------------------

#Provide transport and Map properties

    ioa_interface {'te 0/6':
						vlan_tagged => '100-110',
						vlan_untagged => '88,60',
						shutdown=>true;
					} 

# --------------------------------------------------------------------------
# Usage
# --------------------------------------------------------------------------
  Refer to the examples in the manifest directory.
  The following file contains the details of the sample init.pp and the supported files:
   
    - sample_ioa_interface.pp
   
   You can create a init.pp file based on the above sample files and run the "puppet device" command , for example: 
   # puppet device

#-------------------------------------------------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------------------------------------------------	
