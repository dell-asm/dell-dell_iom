#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/ioa_interface/dell_iom'
require 'pp'
require 'spec_lib/puppet_spec/deviceconf'

include PuppetSpec::Deviceconf

describe "Integration test for IOA Interface" do

  device_conf =  YAML.load_file(my_deviceurl('dell_iom','device_conf_ioa.yml'))
  provider_class = Puppet::Type.type(:ioa_interface).provider(:dell_iom)

  let :config_ioa_interface do
    Puppet::Type.type(:ioa_interface).new(
    :name  => 'TenGigabitEthernet 0/15',
    :vlan_tagged => '34',
    :vlan_untagged => '33',
    :shutdown => true
    )
  end

  before do
    @device = provider_class.device(device_conf['url'])
  end

  context 'when configuring ioa interface' do
    it "should configure ioa interface" do
      resultexpected={:ensure => :present, :vlan_tagged => config_ioa_interface[:vlan_tagged], :vlan_untagged => config_ioa_interface[:vlan_untagged], :shutdown => config_ioa_interface[:shutdown]}
      preresult = provider_class.lookup(@device, config_ioa_interface[:name])

      @device.switch.ioa_interface(config_ioa_interface[:name]).update(preresult,{:vlan_tagged => config_ioa_interface[:vlan_tagged], :vlan_untagged => config_ioa_interface[:vlan_untagged], :shutdown =>config_ioa_interface[:shutdown]})

      postresult = provider_class.lookup(@device, config_ioa_interface[:name])
      postresult.should eq(resultexpected)
    end
  end

end

