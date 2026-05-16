# frozen_string_literal: true

# Patch for Ruby 4.0+ which removed tainted?/untaint/taint methods
# Liquid 4.0.x calls these methods on various object types

module TaintPatch
  def tainted?
    false
  end

  def taint
    self
  end

  def untaint
    self
  end
end

[String, Array, Hash, Numeric, TrueClass, FalseClass, NilClass, Symbol].each do |klass|
  klass.prepend(TaintPatch) unless klass.instance_methods.include?(:tainted?)
end
