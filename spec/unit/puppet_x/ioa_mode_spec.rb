#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet_x/dell_iom/model'
require 'puppet_x/dell_iom/model/ioa_mode'
require 'puppet_x/dell_iom/model/ioa_mode/base'

describe PuppetX::Dell_iom::Model::Ioa_mode do
  let(:model) { PuppetX::Dell_iom::Model::Ioa_mode::Base }
  let(:facts) { {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'} }
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
    @transport.should_receive(:command).with('stack-unit 0 iom-mode programmable-mux')
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'vlt'})
    iom_mode.retrieve
    new_params = iom_mode.params_to_hash.dup
    new_params[:iom_mode] = 'pmux_vlt'
    expect(facts["iom_mode"]).to eq("pmux_vlt")
  end

  it 'should set fullswitch mode' do
    @transport.should_receive(:command).with('stack-unit 0 iom-mode full-switch')
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'Dell PowerEdge FN 410S IOM'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'fullswitch'})
    expect(facts["iom_mode"]).to eq("full-switch")
  end

  it 'should set standalone mode' do
    @transport.should_receive(:command).with('stack-unit 0 iom-mode standalone')
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'pmux_vlt'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'standalone'})
  end

  it 'should not set any mode for mxl switch' do
    @transport.should_not_receive(:command)
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'pmux_vlt'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'vlt_settings'})
  end

  it 'should set programmable-mux mode' do
    @transport.should_receive(:command).with('stack-unit 0 iom-mode programmable-mux')
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'pmux'})
  end

  it 'should configure portchannels' do
    interface_port=["Tengigabitethernet 0/33", "Tengigabitethernet 0/37"]
    port_channel=128
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'pmux_vlt'})

    @transport.should_receive(:command).once.ordered.with('show config').and_return('port-channel-protocol lacp')
    @transport.should_receive(:command).once.ordered.with('no port-channel-protocol lacp')
    @transport.should_receive(:command).once.ordered.with('exit')

    @transport.should_receive(:command).once.ordered.with('show config').and_return('port-channel-protocol lacp')
    @transport.should_receive(:command).once.ordered.with('no port-channel-protocol lacp')
    @transport.should_receive(:command).once.ordered.with('exit')

    @transport.should_receive(:command).once.ordered.with("interface port-channel #{port_channel}")
    @transport.should_receive(:command).once.ordered.with('channel-member Tengigabitethernet 0/33')
    @transport.should_receive(:command).once.ordered.with('channel-member Tengigabitethernet 0/37')
    @transport.should_receive(:command).once.ordered.with('no shutdown')
    @transport.should_receive(:command).once.ordered.with('end')
    PuppetX::Dell_iom::Model::Ioa_mode::Base.configureportchannel(@transport, port_channel, interface_port)
  end

  it 'configure vlt domain ' do
    vlt={"port_channel" => '128', "ip_destination" => "172.25.189.28", "unit-id" => "0"}
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'}
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'pmux_vlt'})
    @transport.should_receive(:command).ordered.with('enable')
    @transport.should_receive(:command).ordered.with('configure terminal', :prompt => /\(conf\)#\z/n)
    @transport.should_receive(:command).ordered.with('vlt domain 1')
    @transport.should_receive(:command).ordered.with("peer-link port-channel #{vlt["port_channel"]}")
    @transport.should_receive(:command).ordered.with("back-up destination #{vlt["ip_destination"]}")
    @transport.should_receive(:command).ordered.with("unit-id #{vlt["unit-id"]}")
    PuppetX::Dell_iom::Model::Ioa_mode::Base.configure_vltdomain(@transport, vlt)
  end

  it 'should remove vlt uplinks' do
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'}
    model.should_receive(:remove_vlt_domain_setting_uplink).with(@transport)
    model.should_receive(:get_existing_port_channels).with(@transport).and_return(["128 "])
    @transport.should_receive(:command).ordered.with('enable')
    @transport.should_receive(:command).ordered.with('configure terminal', :prompt => /\(conf\)#\z/n)
    @transport.should_receive(:command).ordered.with('int port-channel 128 ')
    @transport.should_receive(:command).ordered.with('show config').and_return('channel-member Te0/44')
    @transport.should_receive(:command).ordered.with('no channel-member Te0/44')
    @transport.should_receive(:command).ordered.with('shutdown')
    @transport.should_receive(:command).ordered.with('exit')
    @transport.should_receive(:command).ordered.with('no interface port-channel 128 ')
    @transport.should_receive(:command).ordered.with('end')
    PuppetX::Dell_iom::Model::Ioa_mode::Base.remove_vlt_uplinks(@transport)
  end

  it "should also handle uplinks if no port-channel was found" do
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'}
    model.should_receive(:remove_vlt_domain_setting_uplink).with(@transport)
    model.should_receive(:get_existing_port_channels).with(@transport).and_return(nil)
    @transport.should_receive(:command).ordered.with('enable')
    @transport.should_receive(:command).ordered.with('configure terminal', :prompt => /\(conf\)#\z/n)
    @transport.should_not_receive(:command).with('int port-channel 128 ')
    @transport.should_not_receive(:command).with('show config')
    @transport.should_not_receive(:command).with('no channel-member Te0/44')
    @transport.should_not_receive(:command).with('shutdown')
    @transport.should_not_receive(:command).with('exit')
    @transport.should_not_receive(:command).with('no interface port-channel 128 ')
    @transport.should_receive(:command).ordered.with('end')
    PuppetX::Dell_iom::Model::Ioa_mode::Base.remove_vlt_uplinks(@transport)
  end

  it 'should configure vlt settings' do
    facts = {'ioa_ethernet_mode' => 'mock', 'iom_mode' => 'standalone', 'product_name' => 'iomock-2100'}
    interface_port=["Tengigabitethernet 0/33", "Tengigabitethernet 0/37"]
    vltdomain = {"port_channel" => 128, "ip_destination" => "172.17.2.223", "unit-id" => "0"}
    port = 128
    destination_ip = "172.17.2.223"
    device_id = "0"
    model.should_receive(:remove_vlt_uplinks).with(@transport)
    model.should_receive(:configureportchannel).with(@transport, port, interface_port)
    model.should_receive(:configure_vltdomain).with(@transport, vltdomain)
    PuppetX::Dell_iom::Model::Ioa_mode::Base.configure_vlt_setting(@transport, interface_port, destination_ip, device_id, port)
  end

  it 'should list the existing port channels' do
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'pmux_vlt'})
    @transport.should_receive(:command).with('show interface port-channel brief').and_return(" 128  L2    down         00:00:00    Fo 0/33")
    port_channels = PuppetX::Dell_iom::Model::Ioa_mode::Base.get_existing_port_channels(@transport)
    expect(port_channels).to eq(["128 "])
  end

  it 'should remove vlt domain settings' do
    iom_mode = PuppetX::Dell_iom::Model::Ioa_mode.new(@transport, facts, {:name => 'pmux_vlt'})
    @transport.should_receive(:command).ordered.with('enable')
    @transport.should_receive(:command).ordered.with('configure terminal', :prompt => /\(conf\)#\z/n)
    @transport.should_receive(:command).ordered.with('vlt domain 1')
    @transport.should_receive(:command).ordered.with('show config').and_return('peer-link port-channel')
    @transport.should_receive(:command).ordered.with('no peer-link')
    PuppetX::Dell_iom::Model::Ioa_mode::Base.remove_vlt_domain_setting_uplink(@transport)
  end


end
