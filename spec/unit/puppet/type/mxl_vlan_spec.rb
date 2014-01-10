#! /usr/bin/env ruby

require 'spec_helper'



describe Puppet::Type.type(:mxl_vlan) do




  let :resource do
    described_class.new(
        	:name => '145',
  		:shutdown    => true,
                :vlan_name => 'SomeVlan',
                :mtu => '1200' 
	)
  end

  it "should have a 'name' parameter'" do
    described_class.new(:name => resource.name)[:name].should == '145'
  end



  describe "when validating attributes" do
    [ :name ].each do |param|
      it "should have a #{param} param" do
        described_class.attrtype(param).should == :param
      end
    end

    [ :shutdown ].each do |property|
      it "should have a #{property} property" do
        described_class.attrtype(property).should == :property
      end
    end
  end




  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end

    describe "for name" do
      it "should allow valid vlan" do
        resource.name.should eq( '145')
      end
    end

    describe "for shutdown" do
      it "should allow a valid shutdown" do
        described_class.new(:name => resource.name, :shutdown => :true)[:shutdown].should == :true
      end
    end

    describe "for shutdown" do
      it "should not allow a invalid shutdown" do
        expect { described_class.new(:name => resource.name, :shutdown => '100')[:shutdown].should == '100' }.to raise_error
      end
    end

    describe "for vlan_name" do
      it "should allow a valid name" do
        described_class.new(:name => resource.name, :vlan_name => 'somename')[:vlan_name].should == 'somename'
      end
    end

    describe "for mtu" do
      it "should allow a valid mtu" do
        described_class.new(:name => resource.name, :mtu => '1900')[:mtu].should == '1900'
      end
    end

    describe "for mtu negative test case" do
      it "should not allow a invalid mtu" do
        expect { described_class.new(:name => resource.name, :mtu => 'abc')[:mtu].should == 'abc' }.to raise_error
      end
    end




 end


  
end



