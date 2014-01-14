#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/mxl_config/dell_iom'
require 'fixtures/unit/puppet/provider/mxl_config/mxl_config_fixture'

describe Puppet::Type.type(:mxl_config).provider(:dell_iom) do

  before(:each) do
    @fixture = Mxl_config_fixture_with_startupconfig.new

  end

  context "when dell force10 config is created " do

    it "should have parent 'Puppet::Provider'" do
      described_class.new.should be_kind_of(Puppet::Provider)
    end

    it "should have run method defined for applying the configuration" do
      described_class.instance_method(:run).should_not == nil
    end

    it "should have tryrebootswitch method defined for executing commands" do
      described_class.instance_method(:tryrebootswitch).should_not == nil
    end

    it "should have sendnotification method defined for getting the file md5" do
      described_class.instance_method(:sendnotification).should_not == nil
    end

    it "should have rebootswitch defined for reloading the switch" do
      described_class.instance_method(:rebootswitch).should_not == nil
    end
  end

end
