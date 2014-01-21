#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/ioa_interface/dell_iom'

describe "Integration test for IOA Interface" do

  #device_conf =  YAML.load_file(my_deviceurl('dell_powerconnect','device_conf.yml'))
  provider_class = Puppet::Type.type(:ioa_interface).provider(:dell_iom)

  before do
    #Facter.stub(:value).with(:url).and_return(device_conf['url'])
    @device = provider_class.device("ssh://root:calvin@172.152.0.80")
  end

  let :config_ioa_interface do
    Puppet::Type.type(:ioa_interface).new(
    :name  => 'TenGigabitEthernet 0/14',
    :vlan_tagged => '34',
    :vlan_untagged => '33',
    :shutdown => true
    )
  end

  context 'when configuring ioa interface' do
    it "should configure ioa interface" do
      preresult = provider_class.lookup(@device, config_ioa_interface[:name])

      @device.switch.ioa_interface(config_ioa_interface[:name]).update(preresult,{:vlan_tagged => config_ioa_interface[:vlan_tagged], :vlan_untagged => config_ioa_interface[:vlan_untagged], :shutdown =>config_ioa_interface[:shutdown]})

      postresult = provider_class.lookup(@device, config_ioa_interface[:name])
      postresult.should eq({:ensure => :present, :vlan_tagged => config_ioa_interface[:vlan_tagged], :vlan_untagged => config_ioa_interface[:vlan_untagged], :shutdown => config_ioa_interface[:shutdown]})
    end
  end

end

