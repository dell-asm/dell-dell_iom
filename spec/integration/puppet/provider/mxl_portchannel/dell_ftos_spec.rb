#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/mxl_portchannel/dell_iom'


describe "Integration test for IOA Interface" do

  provider_class = Puppet::Type.type(:mxl_portchannel).provider(:dell_iom)

  before do
    #Facter.stub(:value).with(:url).and_return(device_conf['url'])
    @device = provider_class.device("ssh://root:calvin@10.94.147.190")   
  end  

  let :config_mxl_portchannel do
    Puppet::Type.type(:mxl_portchannel).new(
    :name  => '126',
    :desc => 'Port channel test decsription',
    :mtu => '3300',
    :shutdown => true,
    :ensure => :present
    )
  end



  context 'when configuring portchannel' do 
    it "should configure force10 portchannel" do 
      preresult = provider_class.lookup(@device, config_mxl_portchannel[:name])

      @device.switch.portchannel(config_mxl_portchannel[:name]).update(preresult,{:ensure => :present, :desc => config_mxl_portchannel[:desc], :mtu => config_mxl_portchannel[:mtu], :shutdown =>config_mxl_portchannel[:shutdown]})


      postresult = provider_class.lookup(@device, config_mxl_portchannel[:name])
      postresult.should eq({:ensure => :present, :desc => config_mxl_portchannel[:desc], :mtu => config_mxl_portchannel[:mtu], :switchport => config_mxl_portchannel[:switchport], :shutdown => config_mxl_portchannel[:shutdown]})
    end
  end

end


