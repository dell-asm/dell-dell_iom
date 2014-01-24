#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/mxl_vlan/dell_iom'
require 'pp'
require 'spec_lib/puppet_spec/deviceconf'

include PuppetSpec::Deviceconf

describe "Integration test for mxl vlan" do
  device_conf =  YAML.load_file(my_deviceurl('dell_iom','device_conf_mxl.yml'))
  provider_class = Puppet::Type.type(:mxl_vlan).provider(:dell_iom)

  let :mxl_vlan do
    Puppet::Type.type(:mxl_vlan).new(
    :name  => '190',
    :desc      => 'test desc',
    :vlan_name => 'test name',
    :ensure => 'present'
    )
  end

  before do
    @device = provider_class.device(device_conf['url'])
  end

  context 'when configuring vlan' do
    it "should configure vlan" do
      resultexpected={:desc => mxl_vlan[:desc], :vlan_name => mxl_vlan[:vlan_name]}
      preresult = provider_class.lookup(@device, mxl_vlan[:name])
      @device.switch.vlan(mxl_vlan[:name]).update(preresult,{:ensure => mxl_vlan[:ensure], :desc => mxl_vlan[:desc], :vlan_name => mxl_vlan[:vlan_name]})
      postresult = provider_class.lookup(@device, mxl_vlan[:name])
      postresult.should include(resultexpected)

    end
  end

end

