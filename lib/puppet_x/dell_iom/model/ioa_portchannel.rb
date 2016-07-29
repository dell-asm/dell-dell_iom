#This class has the responsibility of creating and deleting the portchannel resource
require 'puppet_x/force10/model/portchannel'

class PuppetX::Dell_iom::Model::Ioa_portchannel < PuppetX::Force10::Model::Portchannel
  def mod_path_base
    'puppet_x/dell_iom/model/ioa_portchannel'
  end

  def mod_const_base
    PuppetX::Dell_iom::Model::Ioa_portchannel
  end
end
