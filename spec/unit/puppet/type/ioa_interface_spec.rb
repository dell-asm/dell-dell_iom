#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:ioa_interface) do

  let :resource do
    described_class.new(
    :name => 'te 0/7',
    :vlan_tagged => '100-110',
    :vlan_untagged => '88',
    :shutdown    => true
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

    [ :vlan_tagged, :vlan_untagged, :shutdown ].each do |property|
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

    describe "for vlan tagged" do
      it "should allow a valid vlan tags" do
        described_class.new(:name => resource.name, :vlan_tagged => '100-120')[:vlan_tagged].should == '100-120'
        described_class.new(:name => resource.name, :vlan_tagged => '100,120')[:vlan_tagged].should == '100,120'
        described_class.new(:name => resource.name, :vlan_tagged => '1020')[:vlan_tagged].should == '1020'
        described_class.new(:name => resource.name, :vlan_tagged => '100 - 120')[:vlan_tagged].should == '100 - 120'
      end
    end

    describe 'for vlan tagged ngtve' do

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => resource.name, :vlan_tagged => 'xyz') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_tagged => '5000') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_tagged => '12$234&67') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_tagged => '89+89') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_tagged => '76.78') }.to raise_error

      end
    end

    describe "for vlan untagged" do
      it "should allow a valid vlan untags" do
        described_class.new(:name => resource.name, :vlan_untagged => '1020')[:vlan_untagged].should == '1020'
      end
    end

    describe 'for vlan untagged ngtve' do

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => resource.name, :vlan_untagged => 'xyz') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_untagged => '5000') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_untagged => '12$234&67') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_untagged => '89+89') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_untagged => '76.78') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_untagged => '500-899') }.to raise_error
        expect { described_class.new(:name => resource.name, :vlan_untagged => '900,990') }.to raise_error
      end
    end

  end

end

