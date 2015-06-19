# analyse overloaded and generic functions
# generate normal c function nodes

module Minotaur
  def self.expand_ast(typed_data)
    Expander.new(**typed_data).expand
  end

  class Expander
    def initialize(ast:, functions:, instances:, types:)
      @ast = ast
      @functions = functions
      @instances = instances
      @types = types
      @expanded_types = []
      @expanded_functions = []
      prepare
    end

    def expand
      expand_types
      expand_functions
      n(:module,
        includes: @includes,
        types: @expanded_types,
        functions: @expanded_functions)
    end

    def expand_instances
      @instances.each do |type, sets|
        sets.each do |set|
          expand_instance(type, set)
        end
      end
    end

    def expand_instance(type, set)
      @type_nodes.each do |node|
        if node.c_type.generic?
          g = node.c_type.type_args.select { |arg| arg.generic? }.map {
            g.pointer? ? g.base : g }
          ig = comb(g.map { |arg| @instances[arg.base.label] })
          ig.each do |j|
            new_node = node.dup
            new_node.c_type = GenericInstanceType.new(node.c_type,
              node.c_type.type_args.map { |arg| clean_generic(arg, j) })
            new_node.fields.each do |f|
              f.c_type = clean_generic(f.c_type, generic_map)
            end
            @expanded_types << new_node
          end
        end
      end

      @function_nodes.each do |node|
        if node.c_type.generic?
          g = node.c_type.type_args.select { |arg| arg.generic? }.map {
            g.pointer? ? g.base : g }
          ig = comb(g.map { |arg| @instances[arg.base.label] })
          ig.each do |j|
            new_node = node.dup
            new_node.args.each { |arg| arg.c_type = clean_generic(arg.c_type, j) }
            new_node.return_type = clean_generic(node.return_type, j)
            new_node.body.each { |child| clean_node_generic(child, j) }
            @expanded_functions << new_node
          end
        else
          @expanded_functions << node
        end
      end
    end

    def prepare
      @include_nodes, @type_nodes, @function_nodes, main = [], [], [], []
      @ast.children.each do |child|
        if [:include, :include_file].include?(child.kind)
          @include_nodes << child
        elsif [:struct, :enum, :variant].include?(child.kind)
          @type_nodes << child
        elsif [:function].include?(child.kind)
          @function_nodes << child
        else
          main << child
        end
      end
      @function_nodes << n(:function, label: :main, args:
                      [n(:arg, c_type: Builtin::Size, label: :argc),
                       n(:arg, c_type: Builtin::CharPtr, label: :argv)],
                     return_type: Builtin::Int,
                     body: main)
    end
  end
end
