include("graph.jl")
using Random
using Distributions

const x = [3 2 12 7  9  3 16 11 9 2]
const y = [1 4 2 4.5 9 1.5 11 8 10 7]

struct Ant
    current_point::Point
    visited_points::Vector{Point}
end

point1 = Point(1, 1)
point2 = Point(2, 1)
point3 = Point(3, 1)
# point4 = Point(4, 1)
# point5 = Point(5, 1)
# point6 = Point(6, 1)
# point7 = Point(7, 1)
# point8 = Point(8, 1)
# point9 = Point(9, 1)

path1 = UndirectedPath(Pair(point1.id, point2.id), 0, 2)
path2 = UndirectedPath(Pair(point1.id, point2.id), 0, 1)
path3 = UndirectedPath(Pair(point2.id, point3.id), 0, 1)
path4 = UndirectedPath(Pair(point2.id, point3.id), 0, 2)
# path5 = UndirectedPath(Pair(point4.id, point5.id), 0, 2)

# path6 = UndirectedPath(Pair(point5.id, point6.id), 0, 2)
# path7 = UndirectedPath(Pair(point5.id, point7.id), 0, 1)
# path8 = UndirectedPath(Pair(point6.id, point8.id), 0, 1)
# path9 = UndirectedPath(Pair(point7.id, point8.id), 0, 1)

# path10 = UndirectedPath(Pair(point8.id, point9.id), 0, 0)
graph = Graph([], [])

points = [point1, point2, point3] #, point4, point5, point6, point7, point8, point9]
paths = [path1, path2, path3, path4] #, path5, path6, path7, path8, path9, path10]

graph.paths = paths
graph.points = points

println(graph.paths)

function generate_map(x_coordinates, y_coordinates)
    points = []
    paths = []
    len_x = length(x_coordinates)
    
    if len_x == length(y_coordinates)
        for i in 1:len_x
            append!(points, Point(i, 0, [x_coordinates[i], y_coordinates[i]]))
            if i > 1
                for point in points[1, end-1]
                    append!(path, UndirectedPath(Pair(point.id, points[end]), 1, 0))
                end
            end
        end
    end

    return Graph(points, paths)
end

function choose_branch(point, paths)
    k = 20
    d = 2
    PR(paths, k, d)
end

function PR(paths, k, d)
    return ((paths[1].ants_crossed + k)^d) / (((paths[1].ants_crossed + k)^d) + ((paths[2].ants_crossed + k)^d))  
end

function rulette_choose(paths, k, d)

end

function init_ants(graph::Graph, number_of_ants::Int)
    ants = []
    for i in 1:number_of_ants
        append!(ants, Ant(graph.points[rand(1, number_of_ants)], []))
    end
end

function init_ants(starting_point::Point, number_of_ants::Int)
    ants = []
    for i in 1:number_of_ants
        append!(ants, Ant(starting_point, []))
    end
end

function show_ants(ants::Vector{Ant})
    for ant in ants
        println(ant)
    end
end

function all_paths_from(graph::Graph, point::Point)
    paths_from_point = []

    for path in graph.paths
        if point.id in path.connection
            append!(paths_from_point, path)
        end
    end

    return paths_from_point
end

function traveling_sales(graph::Graph, starting_point_id::Int, finish_point_id::Int)
    # Initialization
    map = graph
    number_of_points = length(graph.points)
    ants = init_ants(graph, number_of_points)
    k = 20
    d = 2

    starting_point = point_at(graph, starting_point_id)
    finish_point = point_at(graph, finish_point_id)

    for ant in ants
        while ant.current_point != finish_point
            # Check if point has a crossroad
            paths = all_paths_from(graph, ant.current_point)
            if lenght(paths) > 1
                decision = rulette_choose(paths, k, d)
            end
            # If true then choose one with rulette
            # Give feromone to the taken path
            # Else proceed
            # check the point as visited
        end
    end
end

function ant_system(grapg::Graph)
    # Initialization
    map = graph
    number_of_points = length(graph.points)
    ants = init_ants(graph, number_of_points)
    k = 20
    d = 2

    starting_point = point_at(graph, starting_point_id)
    finish_point = point_at(graph, finish_point_id)

    for ant in ants
        while ant.current_point != finish_point
            # Check if point has a crossroad
            # If true then choose one with rulette
            # Else proceed
            # check the point as visited
        end
    end
end

function intro_ants(graph::Graph)
    k = 20
    d = 2

    for i in 1:n*2
        probability_right = PR(paths, k, d)  
        
        decision = rand(Uniform(0.0, 1.0))

        if decision <= probability_right
            paths[1].ants_crossed += 1
        else
            paths[2].ants_crossed += 1
        end
    end
    
    println(paths[1])
    println(paths[2])
end

# ants(paths)
# ants(paths)
# ants(paths)
# ants(paths)



