#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/mxl_portchannel/dell_iom'
require 'pp'
require 'spec_lib/puppet_spec/deviceconf'


include PuppetSpec::Deviceconf

describe "Integration test for IOA Interface" do

  device_conf =  YAML.load_file(my_deviceurl('dell_iom','device_conf_mxl.yml'))
  provider_class = Puppet::Type.type(:mxl_portchannel).provider(:dell_iom)

  

  let :config_mxl_portchannel do
    Puppet::Type.type(:mxl_portchannel).new(
    :name  => '126',
    :desc => 'Port channel test decsription',
    :mtu => '3300',
    :shutdown => true,
    :ensure => :present
    )
  end
  
  before do
     @device = provider_class.device(device_conf['url'])
   end

  context 'when configuring portchannel' do
    it "should configure force10 portchannel" do
      resultexpected={:ensure => :present, :desc => config_mxl_portchannel[:desc], :mtu => config_mxl_portchannel[:mtu], :switchport => config_mxl_portchannel[:switchport], :shutdown => config_mxl_portchannel[:shutdown]}
      preresult = provider_class.lookup(@device, config_mxl_portchannel[:name])

      @device.switch.portchannel(config_mxl_portchannel[:name]).update(preresult,{:ensure => :present, :desc => config_mxl_portchannel[:desc], :mtu => config_mxl_portchannel[:mtu], :shutdown =>config_mxl_portchannel[:shutdown]})

      postresult = provider_class.lookup(@device, config_mxl_portchannel[:name])
      postresult.should include(resultexpected)
    end
  end

end

