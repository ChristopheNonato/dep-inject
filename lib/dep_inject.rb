# frozen_string_literal: true

require_relative "dep_inject/version"

module DepInject
  class PublicMethodError < StandardError; end
  class DuplicatedExecutionMethodError < StandardError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def provide(dependencies={})
      define_singleton_method :build do
        new(**prepare_dependencies(dependencies))
      end

      define_method :initialize do |**injected|
        injected.each do |name, dependency|
          instance_variable_set("@#{name}", dependency)
        end

        has_execute = self.class.instance_methods.include?(:execute)
        has_call = self.class.instance_methods.include?(:call)
        unless has_execute || has_call
          raise NotImplementedError, "Class #{self.class} must define an `execution` method"
        end

        if has_execute && has_call
          raise DuplicatedExecutionMethodError, "Class #{self.class} should only define one `execution` trigger"
        end

        public_methods_except_execute = self.class.public_instance_methods(false) - [:execute, :call]
        unless public_methods_except_execute.empty?
          raise PublicMethodError, "Class #{self.class} should only define `execution` trigger as a public method. Additional public methods: #{public_methods_except_execute.join(', ')}"
        end

      end
    end

    private

    def prepare_dependencies(dependencies)
      dependencies.transform_values do |dependency|
        instantiate_dependency(dependency)
      end
    end

    def instantiate_dependency(dependency)
      if dependency.respond_to?(:build)
        dependency.build
      elsif dependency.respond_to?(:new)
        dependency.new
      else
        dependency
      end
    end

  end
end
