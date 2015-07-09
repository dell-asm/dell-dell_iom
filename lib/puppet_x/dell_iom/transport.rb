require 'puppet_x/force10/transport'

module PuppetX
  #TODO:  Module needs to be DellIom instead of Dell_iom to keep with Ruby best practices.
  module Dell_iom
    class Transport < PuppetX::Force10::Transport
      def init_switch
        require 'puppet_x/dell_iom/model/switch'
        @switch ||= PuppetX::Dell_iom::Model::Switch.new(session, @facts.facts_to_hash)
        @switch.retrieve
      end
    end
  end
end