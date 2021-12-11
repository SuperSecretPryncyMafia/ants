
mutable struct DirectedPath
    connection::Pair{Int, Int}
end

mutable struct UndirectedPath
    id::Int
    weight::Real
    pheromones::Float64
    directions::Pair{Pair{Int,Int}, Pair{Int, Int}}
    Δτ::Float64
    number_of_ants_crossed::Int

    function UndirectedPath(id, connection, weight, pheromones)
        directions = Pair(connection, reverse(connection))
        new(id, weight, directions, pheromones, 0, 0)
    end
end

mutable struct Point
    id::Int
    value::Float16
    coordinates::Vector{Real}
    connections::Vector{UndirectedPath}
end

#UndirectedPath(id, connection, weight, pheromones ) = UndirectedPath(Pair{DirectedPath(id, connection, weight, pheromones, 0, 0), DirectedPath(id, reverse(connection), weight, pheromones, 0, 0 )})

Point(id, value) = Point(id, value, [], [])
Point(id, value, coordinates) = Point(id, value, coordinates, [])

mutable struct Graph
    points::Vector{Point}
    paths::Vector{UndirectedPath}
end

function add_path(point::Point, path::UndirectedPath)
    append!(point.connections, [path])
end

function add_paths(point::Point, paths::Vector{UndirectedPath})
    for path in paths
        add_path(point, [path])
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


# function all_paths_from(graph::Graph, point::Point)
#     paths_from_point = []

#     for path in graph.paths
#         if point.id in path.connection
#             append!(paths_from_point, path)
#         end
#     end

#     return paths_from_point
# end


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

# raw"""
# point1 ----- point3 ----- point5         
#     \              \     /
#      \              \   /
#       point2 ----- point 4

# """

# point1 = Point(1, 5, [2,2])
# point2 = Point(2, 4, [3,8])
# point3 = Point(3, 3, [4,6])
# point4 = Point(4, 2, [5,4])
# point5 = Point(5, 1, [6,1])

# path1 = UndirectedPath(Pair(point1.id, point2.id), 2)
# path2 = UndirectedPath(Pair(point1.id, point3.id), 5)
# path3 = UndirectedPath(Pair(point2.id, point4.id), 2)
# path4 = UndirectedPath(Pair(point3.id, point4.id), 1)
# path5 = UndirectedPath(Pair(point3.id, point5.id), 1)
# path6 = UndirectedPath(Pair(point4.id, point5.id), 1)

# graph = Graph([],[])

# points = [point1, point2, point3, point4, point5]
# paths = [path1, path2, path3, path4, path5, path6]

# graph.paths = paths
# graph.points = points

# #graph = Graph(points, paths)

# test_graph(graph)

# dijiksta(3, 5, graph)
