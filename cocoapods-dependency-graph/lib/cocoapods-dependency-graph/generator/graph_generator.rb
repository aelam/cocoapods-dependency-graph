require 'rgl/adjacency'
require 'rgl/dot'

module Dependency 
  class GraphGenerator 
    def dependency_spces(spec) 
      dependencies = []

      if spec.respond_to?(:subspecs)
        spec.subspecs.each { | subspec |
          d_spec = @module_spec_hash[subspec.name]
          dependencies << d_spec 
        }
      end

      if spec.respond_to?(:dependencies)
        spec.dependencies.each { | dependency |
          d_spec = @module_spec_hash[dependency.name]
          puts d_spec
          dependencies << d_spec 
        }
      end

      dependencies
    end

    def dfs_graph(parent, specs) 
      specs.each { | spec |
        @graph.add_edge(parent, spec)
        dfs_graph(spec, dependency_spces(spec))
      }
    end

    # @param  [UmbrellaTargetDescription] umbrella_target the CocoaPods umbrella targets generated by the installer.
    # @param  [Hash{<String, Specification>}] module_spec_hash 
    #
    def generate(umbrella_target, module_spec_hash)
      @graph = RGL::DirectedAdjacencyGraph.new
      @module_spec_hash = module_spec_hash
       
      target_name = umbrella_target.cocoapods_target_label
      root_node = {:target => target_name} 
      dfs_graph(root_node, umbrella_target.specs)
      
      @graph.print_dotted_on
      dot_file = "#{target_name}_dependency_graph"
      @graph.write_to_graphic_file('png', dot_file)
    end
  end
end