require 'rgl/adjacency'
require 'rgl/dot'

module Dependency 
  class GraphGenerator 
    @module_spec_hash
    @graph
    
    def dependency_spces(spec) 
      dependencies = []
      spec.dependencies.each { | dependency |
        d_spec = JsonGenerator.module_spec_hash[dependency.name]
        next unless d_spec.source
        dependencies << d_spec 
      }
      dependencies
    end

    def dfs_graph(parent, specs) 
      specs.each { | spec |
        next unless spec.source
        @graph.add_edge(parent, spec)
        dfs_graph(spec, dependency_spces(spec))
      }
    end

    # @param  [UmbrellaTargetDescription] umbrella_target the CocoaPods umbrella targets generated by the installer.
    # @param  [Hash{<String, Specification>}] module_spec_hash 
    #
    def generate(umbrella_target, module_spec_hash)
      @graph = RGL::DirectedAdjacencyGraph.new
      
      target_name = umbrella_target.cocoapods_target_label
      root_node = {:target => target_name} 
      dfs_graph(root_node, umbrella_target.specs)
      
      @graph.print_dotted_on
      @graph.write_to_graphic_file('jpg')
    end
  end
end