# converts from parser's s-expr representation to
# minotaur's ast representation

require 'parser'
require_relative 'ast'
require_relative 'c_type'

module Minotaur
  def self.convert(ast)
  	Converter.new.convert(ast)
  end

  class Converter
  	def convert(ast)
  	  n(:program, body: convert_body(ast))
  	end

  	def convert_node(node)
  	  send :"convert_#{node.type}", node
  	end

  	def convert_body(node)
  	  if node.type == :begin
  	  	convert_begin(node)
  	  else
  	  	[convert_node(node)]
  	  end.flatten
  	end

  	def convert_begin(node)
  	  node.children.map(&method(:convert_node))
  	end

  	def convert_class(node)
  	  b = node.children[1].type == :begin ? node.children[1].children : [node.children[1]]
	  m = b.find_index { |c| c.type == :def } || b.length
	  fields, methods = b[0..m - 1], b[m..-1]
  	  [n(:class,
  	  	label: node.children[0].children[2],
  	  	fields: fields.map(&:convert_field))] +
  	  methods.map { |m| convert_def(m, klass: node.children[0].children[2]) }
  	end

  	def convert_field(node)
  	  n(:field_declaration,
  	  	label: node.children[1].children[0],
  	  	c_type: CType.new(node.children[2].children[0]))
  	end
  end
end


