
mutable struct UndirectedPath
    id::Int
    weight::Real
    pheromones::Float64
    connection::Pair{Int,Int}
    number_of_ants_crossed::Int
    Δτ::Float64

    function UndirectedPath(id, connection, weight, pheromones)
        new(id, weight, pheromones, connection, 0, 0)
    end
end

mutable struct Point
    id::Int
    value::Float16
    coordinates::Vector{Real}
    connections::Vector{UndirectedPath}
end

Point(id, value) = Point(id, value, [], [])
Point(id, value, coordinates) = Point(id, value, coordinates, [])

mutable struct Graph
    points::Vector{Point}
    paths::Vector{UndirectedPath}
end

function find_path(a::Point, b::Point)
    for path in a.connections
        if  path.connection.first == b.id ||
            path.connection.second == b.id
            return path
        end
    end
    for path in b.connections
        if  path.connection.first == a.id ||
            path.connection.second == a.id
            return path
        end
    end
end

function describe(point::Point)
    # TODO
end

function describe(path::UndirectedPath)
    # TODO
end

function point_at(graph::Graph, point_id::Int)
    for point in graph.points
        if point.id == point_id
            return point
        end
    end
    println("No point witch such ID.")
    return NaN
end

function path_at(graph::Graph, path_id::Int)
    for path in graph.paths
        if path.id == path_id
            return path
        end
    end
    println("No path witch such ID.")
    return NaN
end

function find_all_connections(graph::Graph, point::Point)
    for path in graph.paths
        if path.connection.first == point.id || path.connection.second == point.id
            append!(point.connections, [path])
        end
    end
end

function find_all_paths_with_point(graph::Graph, point::Point)
    conns = [] 
    for path in graph.paths
        if path.connection.first == point.id || path.connection.second == point.id
            append!(conns, [path])
        end
    end
    return conns
end

function find_all_connections(paths::Vector{UndirectedPath}, point::Point)
    for path in paths
        if path.connection.first == point.id || path.connection.second == point.id
            append!(point.connections, [path])
        end
    end
end

function find_all_paths_with_point(paths::Vector{UndirectedPath}, point::Point)
    conns = [] 
    for path in paths
        if path.connection.first == point.id || path.connection.second == point.id
            append!(conns, [path])
        end
    end
    return conns
end

function point_id(graph::Graph, point_at::Point)
    for index in 1:length(graph.points)
        if graph.points[index] == point_at
            return graph.points[index].id
        end
    end
end

function test_graph(graph::Graph)
    println(graph.points)
    println(graph.paths)
end

function dijiksta(start_point_id::Int, end_point_id::Int, graph::Graph)
    """ Dijikstra algorith for shortest path in the graph.
    
        Parameters:
            start_point_id - "s"
            end_point_id   - "e"
            graph          - "g"
    """

    distances = init_distances(start_point_id::Int, graph::Graph)

    println(distances)

    println(point_at(graph, 2))
end

function init_distances(start_point_id::Int, graph::Graph)
    distances = Dict()
    
    for point in graph.points
        distances[point.id] = Inf
    end
    distances[start_point_id] = 0
    
    return distances
end

# Example of usage
#
# raw"""
# point1 ----- point2 ---- point3         
#     \       /      \      /
#      \     /        \    /
#       \ __/          \__/
#
# """
# point1 = Point(1, 1)
# point2 = Point(2, 1)
# point3 = Point(3, 1)

# path1 = UndirectedPath(1,Pair(point1.id, point2.id), 2, 1.0)
# path2 = UndirectedPath(2,Pair(point1.id, point2.id), 1, 1.0)
# path3 = UndirectedPath(3,Pair(point2.id, point3.id), 2, 1.0)
# path4 = UndirectedPath(4,Pair(point2.id, point3.id), 1, 1.0)

# point1.connections = Vector{UndirectedPath}([path1, path2])
# point2.connections = Vector{UndirectedPath}([path3, path4])
# graph = Graph([], [])

# points = [point1, point2, point3]
# paths = [path1, path2, path3, path4] 

# graph.paths = paths
# graph.points = points

# return graph