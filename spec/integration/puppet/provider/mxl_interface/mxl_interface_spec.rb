#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/mxl_interface/dell_iom'
require 'pp'

describe "Integration test for mxl interface" do

  provider_class = Puppet::Type.type(:mxl_interface).provider(:dell_iom)

  before do

    @device = provider_class.device("telnet://root:calvin@10.94.147.190/")
  end

  let :mxl_interface do
    Puppet::Type.type(:mxl_interface).new(
    :name  => 'te 0/7',
    :mtu => '600',
    :shutdown => 'true'
    )
  end

  context 'when configuring interface' do
    it "should configure interface" do
      preresult = provider_class.lookup(@device, mxl_interface[:name])
      pp "preresult = #{preresult }"
      @device.switch.interface(mxl_interface[:name]).update(preresult,{:mtu => mxl_interface[:mtu], :shutdown => mxl_interface[:shutdown]})
      postresult = provider_class.lookup(@device, mxl_interface[:name])
      postresult.should include({:mtu => mxl_interface[:mtu], :shutdown => mxl_interface[:shutdown]})
    end
  end

end

