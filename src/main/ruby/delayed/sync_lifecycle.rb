require 'monitor'

module Delayed
  module SyncLifecycle

    def self.extended(base)
      klass = base.singleton_class
      klass.send :alias_method, :setup_lifecycle_impl, :setup_lifecycle
      klass.send :alias_method, :setup_lifecycle, :setup_lifecycle_sync
      klass.send :private, :setup_lifecycle_impl
    end

    def setup_lifecycle_sync
      # not really necessary, but a plugin might expect setup to run exactly once
      (@lifecycle ||= nil) || synchronize do
        unless @lifecycle
          setup_lifecycle_impl
          #@lifecycle = Delayed::Lifecycle.new
          #lifecycle = @lifecycle
        end
      end
    end

    MUTEX = Monitor.new
    private_constant :MUTEX if respond_to?(:private_constant)

    def synchronize(&block)
      MUTEX.synchronize(&block)
    end
    private :synchronize

  end
end