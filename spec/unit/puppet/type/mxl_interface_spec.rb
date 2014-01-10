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
        expect { described_class.new(:name => resource.name, :portchannel => '130')[:portchannel].should == '100' }.to raise_error
      end
    end

    describe 'for shutdown' do
      [ :true, :false ].each do |val|
        it "should allow the value #{val.inspect}" do
          described_class.new(:name => resource.name, :shutdown => val)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => resource.name, :shutdown => :foobar) }.to raise_error
      end
    end

    describe "for mtu " do
      it "should allow a valid mtu" do
        described_class.new(:name => resource.name, :mtu => '600')[:mtu].should == '600'
      end
    end
    describe 'for mtu  invalid input ' do

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => resource.name, :mtu => 'xyz') }.to raise_error
        expect { described_class.new(:name => resource.name, :mtu => '500') }.to raise_error
        expect { described_class.new(:name => resource.name, :mtu=> '13000') }.to raise_error

      end
    end

    describe 'for switchport' do
      [ :true, :false ].each do |val|
        it "should allow the value #{val.inspect}" do
          described_class.new(:name => resource.name, :switchport => val)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => resource.name, :switchport => :foobar) }.to raise_error
      end
    end

  end

end
