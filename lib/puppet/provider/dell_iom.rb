require 'puppet_x/force10/transport'
require 'puppet/provider/dell_ftos'

# This is the base Class of all prefetched Dell IOA device providers
class Puppet::Provider::Dell_iom < Puppet::Provider::Dell_ftos
end