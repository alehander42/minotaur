module Minotaur
  class Node
    attr_reader :kind
    attr_accessor :c_type
    attr_reader :node_fields

    def initialize(kind, c_type: nil, **kwargs)
      @kind = kind
      @c_type = c_type
      kwargs.each do |k, v|
        instance_variable_set("@#{k}", v)
        self.class.send :attr_reader, :"#{k}"
      end
      @node_fields = kwargs.keys
    end

    def ==(other)
      self.class == other.class && @kind == other.kind &&
      @node_fields.all? { |f| send(f) == other.send(f) }
    end
  end

  def self.n(kind, c_type: nil, **kwargs)
    Node.new(kind, c_type: c_type, **kwargs)
  end
end
