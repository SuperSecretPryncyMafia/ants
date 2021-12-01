include("graph.jl")

using Random
using Distributions


const x = [3 2 12 7  9  3 16 11 9 2]
const y = [1 4 2 4.5 9 1.5 11 8 10 7]

mutable struct Ant
    current_point::Point
    visited_points::Vector{Point}
    used_paths::Vector{UndirectedPath}
end

function data_init()

    point1 = Point(1, 1)
    point2 = Point(2, 1)
    point3 = Point(3, 1)

    path1 = UndirectedPath(Pair(point1.id, point2.id), 2, 1, 0)
    path2 = UndirectedPath(Pair(point1.id, point2.id), 1, 1, 0)
    path3 = UndirectedPath(Pair(point2.id, point3.id), 1, 1, 0)
    path4 = UndirectedPath(Pair(point2.id, point3.id), 2, 1, 0)

    graph = Graph([], [])

    points = [point1, point2, point3]
    paths = [path1, path2, path3, path4] 

    graph.paths = paths
    graph.points = points

    return graph
end

function generate_map(x_coordinates, y_coordinates)

    points = Vector{Point}()
    paths = Vector{UndirectedPath}()
    len_x = length(x_coordinates)
    
    if len_x == length(y_coordinates)
        for i in 1:len_x
            append!(points, [Point(i, 0, [x_coordinates[i], y_coordinates[i]])])
            if i > 1
                for point in points[1:end-1]
                    path = UndirectedPath(Pair(point.id, points[end].id), sqrt(x_coordinates[i]^2 + y_coordinates[i]^2), 0, 0)
                    append!(paths, [path])
                    add_path(point, path)
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

function rulette_choose_lower(paths, decision_table, k, d, point)
    println(decision_table[point.id])
    upper_bound = maximum(decision_table[point.id])
    println("Decision table at key point.id:    ", decision_table[point.id])
    scalled = [i/upper_bound for i in decision_table[point.id]]
    println(scalled)
    decision = rand(Uniform(0, 1))
    
    for (i, path) in enumerate(scalled)
        if path >= decision
            return point.connections[i]
        end
    end
    
end

function rulette_choose_higher(paths, decision_table, k, d, point)
    println(decision_table[point.id])
    upper_bound = maximum(decision_table[point.id])
    println("Decision table at key point.id:    ", decision_table[point.id])
    scalled = [i/upper_bound for i in decision_table[point.id]]
    println(scalled)
    decision = rand(Uniform(0, 1))
    
    for (i, path) in enumerate(scalled)
        if path <= decision
            return point.connections[i]
        end
    end
    
end

function rulette_choose(decision_table, point)
    upper_bound = maximum(decision_table[point.id])
    println("Decision table at key point.id:    ", point.id, "\t", decision_table[point.id])
    scalled = [i/upper_bound for i in decision_table[point.id]]
    decision = rand(Uniform(0, 1))
    for (i, path) in enumerate(scalled)
        if path >= decision
            return point.connections[i]
        end
    end
    
end

function init_ants(graph::Graph, number_of_ants::Int)
    ants = []
    for i in 1:number_of_ants
        append!(ants, Ant(graph.points[rand(1, number_of_ants)], [], []))
    end
    return ants
end

function init_ants(starting_point::Point, number_of_ants::Int)
    ants = []
    for i in 1:number_of_ants
        append!(ants, [Ant(starting_point, [], [])])
    end
    return ants
end

function init_pheromones(graph::Graph, amount_of_pheromone::Float16)
    for path in graph.paths
        path.pheromones = amount_of_pheromone
    end
end

function show_ants(ants::Vector{Ant})
    for ant in ants
        println(ant)
    end
end

function init_decision_table(graph::Graph)
    β = 5
    decision_table = Dict()
    for point in graph.points
        find_all_paths_with_point(graph, point)
        decision_table[point.id] = []

        for path in point.connections
            append!(decision_table[point.id], 1/length(point.connection))
        end
    end
    return decision_table
end

function leave_pheromones(path::UndirectedPath)
    path.pheromones += 1/path.weight
end

function Δτ(ant)
    """
    Calculating the Δτ 
    """
    sum = 0
    for path in ant.used_paths
        sum += 1/path.weight
    end

    return sum
end

function update_decision_table(graph::Graph, decision_table, ants::Vector{Any})
    """
    Updates the decision table after changes.
    """
    α = 1
    β = 5
    ρ = 0.5
    for ant in ants
        for point in graph.points
            sum_decisions = 0
            
            for (i, path) in enumerate(point.connections)
                sum_decisions += (path.pheromones^α)*((1/path.weight)^β)
            end
            
            for (i, path) in enumerate(point.connections)
                path.pheromones = ρ*path.pheromones + Δτ(ant)
                decision_table[point.id][i] = (path.pheromones^α)*((1/path.weight)^β)/sum_decisions
            end
        end
    end
    return decision_table
end

function ant_move_to(path::UndirectedPath, point::Point, ant::Ant)
    """
    Transports the ant to the next point with choosen path and updates ant memory.
    path - UndiractedPath - Choosen path
    point - Point - Next point
    ant - Ant - Ant that made the decision 
    """
    
    append!(ant.used_paths, [path])
    ant.current_point = point
    append!(ant.visited_points, [point])
end

function traveling_sales(graph::Graph, starting_point_id::Int, finish_point_id::Int)
    # Initialization
    starting_point = point_at(graph, starting_point_id)
    finish_point = point_at(graph, finish_point_id)

    number_of_points = length(graph.points)
    ants = init_ants(starting_point, number_of_points)
    decision_table = init_decision_table(graph)

    for ant in ants
        while ant.current_point != finish_point
            # Check if point has a crossroad
            paths = ant.current_point.connections
            if length(paths) > 1
                decision = rulette_choose(decision_table, ant.current_point)
############################################################################################
                ant_move_to(decision, graph.points[decision.connection.second], ant)
            end
            leave_pheromones(decision)
            
            # TODO:
            # - reimplement updating of decision table
        end
        decision_table = update_decision_table(graph, decision_table, ants)
#############################################################################################
        # leave_pheromones(decision)
        # decision_table = update_decision_table(graph, decision_table)
    end
end

function evaporation(graph::Graph)

end

function ant_system(graph::Graph, max_iter::Int=200)
    # Initialization
    number_of_points = length(graph.points)
    ants = init_ants(graph, number_of_points) 
    iteration = 0
    k = 20
    d = 2

    starting_point = point_at(graph, starting_point_id)
    finish_point = point_at(graph, finish_point_id)
    
    for iteration in 1:max_iter
        for ant in ants
            while ant.current_point != finish_point
                # Check if point has a crossroad
                # If true then choose one with rulette
                # Else proceed
                # check the point as visited
            end
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

function main()
    graph = data_init()
    # generate_map(x, y)
    traveling_sales(graph, 1, 3)
end

main()
# find_all_paths_with_point(graph, point1)
# dt = init_decision_table(graph)
# traveling_sales(graph, 1, 3)
# println(rulette_choose(dt, point1))
# println(rulette_choose(dt, point2))



