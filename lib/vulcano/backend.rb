# encoding: utf-8
# copyright: 2015, Dominik Richter
# license: All rights reserved
# author: Dominik Richter
# author: Christoph Hartmann

require 'train'

module Vulcano
  module Backend
    # Create the transport backend with aggregated resources.
    #
    # @param [Hash] config for the transport backend
    # @return [TransportBackend] enriched transport instance
    def self.create(config)
      conf = Train.target_config(config)
      name = conf[:backend] || :local
      transport = Train.create(name, conf)
      if transport.nil?
        fail "Can't find transport backend '#{name}'."
      end

      connection = transport.connection
      if connection.nil?
        fail "Can't connect to transport backend '#{name}'."
      end

      cls = Class.new do
        define_method :backend do
          connection
        end
        Vulcano::Resource.registry.each do |id, r|
          define_method id.to_sym do |*args|
            r.new(self, id.to_s, *args)
          end
        end
      end

      cls.new
    end
  end
end
