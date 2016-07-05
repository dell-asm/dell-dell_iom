#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet_x/dell_iom/model'
require 'puppet_x/dell_iom/model/ioa_interface'

describe PuppetX::Dell_iom::Model::Ioa_interface do


  before do
    @config = File.read('spec/fixtures/ioa_config.out')
    @transport = double('transport').as_null_object
    @transport.stub(:command)
    @transport.stub(:command).with("sh run", :cache => true, :noop => false).and_return(@config)
    PuppetX::Force10::Transport::Ssh.any_instance.stub(:send).and_return("")
    PuppetX::Dell_iom::Model::Ioa_interface.any_instance.stub(:before_update)
    PuppetX::Dell_iom::Model::Ioa_interface.any_instance.stub(:after_update)
    PuppetX::Force10::Model::ScopedValue.any_instance.stub(:sleep)
  end

  describe 'when looking up an interface' do
    it 'finds existing interface' do
      name = 'TenGigabitEthernet 0/1'
      interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
      params = interface.retrieve
      params[:ensure].should == :present
    end

    it 'finds existing interface with downcased/unspaced name' do
      name = 'tengigabitethernet0/1'
      interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
      config = interface.retrieve
      config[:ensure].should == :present
    end
  end

  describe 'when configuration needs updating' do
    it 'should enable switchport' do
      name = 'TenGigabitEthernet 0/1'
      interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
      interface.retrieve
      old_params = interface.params_to_hash
      new_params = old_params.dup
      new_params[:switchport] = :true
      @transport.should_receive(:command).with("switchport")
      interface.update(old_params, new_params)
    end

    it 'should enable hybrid mode' do
      name = 'TenGigabitEthernet 0/2'
      interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
      interface.retrieve
      old_params = interface.params_to_hash
      new_params = old_params.dup
      new_params[:portmode] = :true
      @transport.should_receive(:command).with("portmode hybrid")
      interface.update(old_params, new_params)
    end

    describe 'when adding untagged vlans' do

      let(:base){double('base').as_null_object}
      let(:facts){{"system_type"=>"PE-FN-410S-IOM", "iom_mode" => "programable-mux"}}

      before do
        name = 'TenGigabitEthernet 0/3'
        @interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, facts, {:name=>name})
        @interface.retrieve
        @old_params = @interface.params_to_hash
        @new_params = @old_params.dup
      end

      it 'should set vlan to untagged' do
          base.stub(:facts)
        @new_params[:vlan_untagged] = '15'
        @transport.should_receive(:command).with("vlan untagged 15")
        @interface.update(@old_params, @new_params)
      end

      it 'should remove existing untagged' do
        @new_params[:vlan_untagged] = '18'
        @transport.should_receive(:command).with("no vlan untagged")
        @interface.update(@old_params, @new_params)
      end

      it 'should remove tagged vlan if already untagged' do
        @new_params[:vlan_untagged] = '20'
        @transport.should_receive(:command).with("no vlan tagged 20")
        @interface.update(@old_params, @new_params)
      end
    end

    describe 'when adding vlans when switch is in full-switch mode' do
      let(:facts){{"system_type"=>"PE-FN-410S-IOM", "iom_mode" => "full-switch"}}
      before do
        name = 'TenGigabitEthernet 0/3'
        config = "interface TenGigabitEthernet 0/3\n mtu 12000\n portmode hybrid\n switchport\n vlan tagged 20,23,28\n vlan untagged 18\n!"
        @transport.stub(:command).with("show config").and_return(config)
        @interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, facts, {:name=>name})
        @interface.retrieve
        @old_params = @interface.params_to_hash
        @new_params = @old_params.dup
      end

      it "should add a tagged vlan to an interface when iom is in full-switch" do
        @new_params[:vlan_tagged] = '15'
        @transport.should_receive(:command).with("interface vlan 15")
        @transport.should_receive(:command).with("show config").and_return("tagged TenGigabitEthernet 0/4\n \ntagged Port-channel 15")
        @transport.should_receive(:command).with("no tagged TenGigabitEthernet 0/4" )
        @transport.should_receive(:command).with("tagged TenGigabitEthernet 0/3" )
        @interface.update(@old_params, @new_params)
      end

      it "should add untagged vlan to an interface when iom is in full switch" do
        @new_params[:vlan_untagged] = '18'
        @transport.should_receive(:command).with("interface vlan 18" )
        @transport.should_receive(:command).with("show config").and_return("untagged TenGigabitEthernet 0/4\n \ntagged Port-channel 15")
        @transport.should_receive(:command).with("no untagged TenGigabitEthernet 0/4" )
        @transport.should_receive(:command).with("tagged TenGigabitEthernet 0/3" )
        @interface.update(@old_params, @new_params)
      end

      it "should add multiple tagged vlans to an interface port" do
        @new_params[:vlan_tagged] = "15,16,20"
        @transport.should_receive(:command).with("interface vlan 15")
        @transport.should_receive(:command).with("interface vlan 16")
        @transport.should_receive(:command).with("interface vlan 20")
        @transport.should_receive(:command).exactly(3).with("show config").and_return("tagged TenGigabitEthernet 0/4\n \ntagged Port-channel 15")
        @interface.update(@old_params, @new_params)
      end

    end

    describe 'when adding tagged vlans' do
      let(:facts){{"system_type"=>"PE-FN-410S-IOM", "iom_mode" => "programable-mux"}}
      before do
        name = 'TenGigabitEthernet 0/3'
        config = "interface TenGigabitEthernet 0/3\n mtu 12000\n portmode hybrid\n switchport\n vlan tagged 20,23,28\n vlan untagged 18\n!"
        @transport.stub(:command).with("show config").and_return(config)
        @interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, facts, {:name=>name})
        @interface.retrieve
        @old_params = @interface.params_to_hash
        @new_params = @old_params.dup
      end

      it 'should set vlan to tagged' do
        @new_params[:vlan_tagged] = '15'
        @transport.should_receive(:command).with("vlan tagged 15-15")
        @interface.update(@old_params, @new_params)
      end

      it 'should add range of vlans' do
        @new_params[:vlan_tagged] = '15,16'
        @transport.should_receive(:command).with("vlan tagged 15-16")
        @interface.update(@old_params, @new_params)
      end

      it 'should remove vlan as untagged if setting to tagged' do
        @new_params[:vlan_tagged] = '18'
        @transport.should_receive(:command).with("no vlan untagged")
        @interface.update(@old_params, @new_params)
      end
    end

    it 'should configure shutdown' do
      name = 'TenGigabitEthernet 0/5'
      interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
      interface.retrieve
      old_params = interface.params_to_hash
      new_params = old_params.dup
      new_params[:shutdown] = :false
      @transport.should_receive(:command).with("no shutdown")
      interface.update(old_params, new_params)
    end
  end
end