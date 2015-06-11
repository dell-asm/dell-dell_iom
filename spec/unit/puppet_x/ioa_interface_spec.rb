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
      before do
        name = 'TenGigabitEthernet 0/3'
        @interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
        @interface.retrieve
        @old_params = @interface.params_to_hash
        @new_params = @old_params.dup
      end

      it 'should set vlan to untagged' do
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

    describe 'when adding tagged vlans' do
      before do
        name = 'TenGigabitEthernet 0/3'
        config = "interface TenGigabitEthernet 0/3\n mtu 12000\n portmode hybrid\n switchport\n vlan tagged 20,23,28\n vlan untagged 18\n!"
        @transport.stub(:command).with("show config").and_return(config)
        @interface = PuppetX::Dell_iom::Model::Ioa_interface.new(@transport, @config, {:name=>name})
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

      it 'should remove untagged vlan if already tagged' do
        @new_params[:vlan_tagged] = '20'
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