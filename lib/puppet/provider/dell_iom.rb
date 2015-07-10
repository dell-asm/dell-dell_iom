require 'puppet_x/dell_iom/transport'
require 'puppet/provider/dell_ftos'

# This is the base Class of all prefetched Dell IOA device providers
class Puppet::Provider::Dell_iom < Puppet::Provider::Dell_ftos
  def self.transport
    @transport ||= PuppetX::Dell_iom::Transport.new(Puppet[:certname])
  end
end