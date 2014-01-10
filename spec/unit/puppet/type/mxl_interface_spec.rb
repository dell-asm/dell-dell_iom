#! /usr/bin/env ruby

require 'spec_helper'



describe Puppet::Type.type(:mxl_interface) do




  let :resource do
    described_class.new(
        	:name => 'te 0/7',
  		:shutdown    => true,
                :portchannel => '110',
                :mtu => '7899',
                :switchport => 'true'
	)
  end

  it "should have a 'name' parameter'" do
    described_class.new(:name => resource.name)[:name].should == 'te 0/7'
  end



  describe "when validating attributes" do
    [ :name ].each do |param|
      it "should have a #{param} param" do
        described_class.attrtype(param).should == :param
      end
    end

    [ :shutdown,:portchannel,:mtu,:switchport ].each do |property|
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
      it "should allow valid interface" do
        resource.name.should eq( 'te 0/7')
      end
    end

    describe "for portchannel" do
      it "should allow a valid portchannel" do
        described_class.new(:name => resource.name, :portchannel => '100')[:portchannel].should == '100'
      end
    end

    describe "for portchannel negative" do
      it "should not allow a invalid portchannel" do
        expect { described_class.new(:name => resource.name, :portchannel => '100')[:portchannel].should == '100' }.to raise_error
      end
    end


    describe "for shutdown" do
      it "should allow a valid shutdown value" do
        described_class.new(:name => resource.name, :shutdown => 'true')[:shutdown].should == 'true'
      end
    end

    describe "for shutdown negative" do
      it "should not allow a invalid shutdown" do
        expect { described_class.new(:name => resource.name, :shutdown => 'yuyj')[:shutdown].should == 'yuyj' }.to raise_error
      end
    end


    describe "for mtu" do
      it "should allow a valid mtuportchannel" do
        described_class.new(:name => resource.name, :mtu => '1000')[:mtu].should == '1000'
      end
    end

    describe "for mtu negative" do
      it "should not allow a invalid mtu" do
        expect { described_class.new(:name => resource.name, :mtu => 'abcd')[:portchannel].should == 'abcd' }.to raise_error
      end
    end


    describe "for switchport" do
      it "should allow a valid switchport" do
        described_class.new(:name => resource.name, :switchport => 'true')[:switchport].should == 'true'
      end
    end

    describe "for switchport negative" do
      it "should not allow a invalid switchport" do
        expect { described_class.new(:name => resource.name, :switchport => '898')[:switchport].should == '898' }.to raise_error
      end
    end




 end


  
end



