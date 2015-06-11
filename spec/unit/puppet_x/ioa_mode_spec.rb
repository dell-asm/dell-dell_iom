#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet_x/dell_iom/model'
require 'puppet_x/dell_iom/model/ioa_mode'
require 'puppet_x/dell_iom/model/ioa_mode/base'

describe PuppetX::Dell_iom::Model::Ioa_mode do
  before do
    @transport = double('transport').as_null_object
    @transport.stub(:command)
    @transport.stub(:connect)
    @transport.stub(:close)
    PuppetX::Force10::Transport::Ssh.any_instance.stub(:send).and_return("")
    PuppetX::Dell_iom::Model::Ioa_mode.any_instance.stub(:before_update)
    PuppetX::Dell_iom::Model::Ioa_mode.any_instance.stub(:after_update)
    PuppetX::Force10::Model::ScopedValue.any_instance.stub(:sleep)

  end

  it 'should set vlt mode' do
    @transport.should_receive(:command).with('stack-unit 0 iom-mode vlt')
    facts = {'ioa_ethernet_mode'=>'mock', 'iom_mode'=>'standalone', 'product_name'=>'iomock-2100'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name=>'vlt'})
    iom_mode.retrieve
    new_params = iom_mode.params_to_hash.dup
    new_params[:iom_mode] = 'vlt'
    iom_mode.update(iom_mode.params_to_hash, new_params)

  end

  it 'should set standalone mode' do
    @transport.should_receive(:command).with('stack-unit 0 iom-mode standalone')
    facts = {'ioa_ethernet_mode'=>'mock', 'iom_mode'=>'vlt'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name=>'standalone'})
    iom_mode.retrieve
    new_params = iom_mode.params_to_hash.dup
    new_params[:iom_mode] = 'standalone'
    iom_mode.update(iom_mode.params_to_hash, new_params)
  end

  it 'should set programmable-mux mode' do
    @transport.should_receive(:command).with('stack-unit 0 iom-mode programmable-mux')
    facts = {'ioa_ethernet_mode'=>'mock', 'iom_mode'=>'standalone'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name=>'pmux'})
    iom_mode.retrieve
    new_params = iom_mode.params_to_hash.dup
    new_params[:iom_mode] = 'pmux'
    iom_mode.update(iom_mode.params_to_hash, new_params)
  end
end
