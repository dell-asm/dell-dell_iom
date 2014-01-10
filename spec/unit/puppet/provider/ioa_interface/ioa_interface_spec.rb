#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/ioa_interface/dell_iom'

provider_class = Puppet::Type.type(:ioa_interface).provider(:dell_iom)

describe provider_class do

  before do
    @ioa_interface = stub_everything 'ioa_interface'
    @ioa_interface.stubs(:name).returns('te 0/6')
    @ioa_interface.stubs(:params_to_hash)
    @ioa_interfaces = [ @ioa_interface ]

    @switch = stub_everything 'switch'
    @switch.stubs(:ioa_interface).returns(@ioa_interfaces)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub('resource', :desc => "INT")

    @provider = provider_class.new(@device, @resource)

  end

  it "should have a parent of Puppet::Provider::Dell_iom" do
    provider_class.should < Puppet::Provider::Dell_iom
  end

  it "should have an instances method" do
    provider_class.should respond_to(:instances)
  end

  describe "when looking up instances at prefetch" do
    before do
      @device.stubs(:command).yields(@device)
    end

    it "should delegate to the device ioa_interface fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:ioa_interface).with('te 0/6').returns(@ioa_interface)
      @ioa_interface.expects(:params_to_hash)
      provider_class.lookup(@device, 'te 0/6')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:ioa_interface).with('te 0/6').returns(@ioa_interface)
      @ioa_interface.expects(:params_to_hash).returns({ :desc => "INT" })
      provider_class.lookup(@device, 'te 0/6').should == { :desc => "INT" }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => 'te 0/6', :vlan_tagged => '100-110')
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('te 0/6')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:ioa_interface).with('te 0/6').returns(@ioa_interface)
      @switch.stubs(:facts).returns({})
      @ioa_interface.expects(:update).with({:ensure => :present, :name => 'te 0/6', :vlan_tagged => '100-110'},
      {:ensure => :present, :name => 'te 0/6', :vlan_tagged => '100-110'})
      @ioa_interface.expects(:update).never

      #@instance.desc = "FOOBAR"
      @instance.flush
    end
  end

end

