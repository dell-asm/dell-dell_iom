#! /usr/bin/env ruby

require 'spec_helper'



describe Puppet::Type.type(:mxl_vlan) do




  let :resource do
    described_class.new(
        	:name => '145',
  		:shutdown    => true
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




 end


  
end



