#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/util/network_device/dell_iom/device'
require 'puppet/provider/mxl_interface/dell_iom'
require 'pp'
require 'spec_lib/puppet_spec/deviceconf'

include PuppetSpec::Deviceconf

describe "Integration test for mxl interface" do

  device_conf =  YAML.load_file(my_deviceurl('dell_iom','device_conf_mxl.yml'))
  provider_class = Puppet::Type.type(:mxl_interface).provider(:dell_iom)

  let :mxl_interface do
    Puppet::Type.type(:mxl_interface).new(
    :name  => 'te 0/7',
    :mtu => '600',
    :shutdown => 'true'
    )
  end

  before do
    @device = provider_class.device(device_conf['url'])
  end

  context 'when configuring interface' do
    it "should configure interface" do
      resultexpected={:mtu => mxl_interface[:mtu], :shutdown => mxl_interface[:shutdown]}
      preresult = provider_class.lookup(@device, mxl_interface[:name])
      @device.switch.interface(mxl_interface[:name]).update(preresult,{:mtu => mxl_interface[:mtu], :shutdown => mxl_interface[:shutdown]})
      postresult = provider_class.lookup(@device, mxl_interface[:name])
      postresult.should include(resultexpected)
    end
  end

end

