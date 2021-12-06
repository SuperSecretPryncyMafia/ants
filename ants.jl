include("graph.jl")

using Random
using Distributions


const x = [3 2 12 7 ]  # 9  3 16 11 9 2]
const y = [1 4 2  4.5 ]  # 9 1.5 11 8 10 7]

mutable struct Ant
    current_point::Point
    visited_points::Vector{Point}
    used_paths::Vector{UndirectedPath}
end

function data_init()

    point1 = Point(1, 1)
    point2 = Point(2, 1)
    point3 = Point(3, 1)

    path1 = UndirectedPath(Pair(point1.id, point2.id), 2, 1.0, 0)
    path2 = UndirectedPath(Pair(point1.id, point2.id), 1, 1.0, 0)
    path3 = UndirectedPath(Pair(point2.id, point3.id), 2, 1.0, 0)
    path4 = UndirectedPath(Pair(point2.id, point3.id), 1, 1.0, 0)

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
        end

        for i in 1:len_x
            for j in 1:len_x
                if points[i] != points[j]
                    path = UndirectedPath(Pair(points[i].id, points[j].id), sqrt(abs(x_coordinates[i]-x_coordinates[j])^2 + abs(y_coordinates[i]-y_coordinates[j])^2), 1, 0)
                    append!(paths, [path])
                    add_path(points[i], path)
                end
            end
        end
    end
    for i in points
        println(i)
    end
    for i in paths
        println(i)
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
    # println("Decision table at key point.id:    ", point.id, "\t", decision_table[point.id])
    scalled = []
    for i in decision_table[point.id]
        new_value = i/upper_bound
        if !isempty(scalled)
            summed = sum(scalled)
        else
            summed = 0
        end
        append!(scalled, [summed + new_value])
    end
    #scalled = [i/upper_bound for i in decision_table[point.id]]
    upper_bound = maximum(scalled)
    decision = rand(Uniform(0, 1))*upper_bound
    for (i, choice) in enumerate(scalled)
        if choice >= decision
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

function best_ant(ants::Vector{Any})
    best_ant_len = Inf
    best_ant_index = -1
    for (i, ant) in enumerate(ants)
        summed = 0
        for path in ant.used_paths
           summed += path.weight 
        end

        if summed < best_ant_len
            best_ant_len = summed
            best_ant_index = i
        end
    end
    println("The best ant: ", best_ant_len, "\t", ants[best_ant_index])
end

function init_decision_table(graph::Graph)
    β = 5
    decision_table = Dict()
    for point in graph.points
        find_all_paths_with_point(graph, point)
        decision_table[point.id] = []

        for path in point.connections
            append!(decision_table[point.id], 1)
        end
    end
    return decision_table
end

function leave_pheromones(ants::Vector{Ant})
    for ant in ants
        sum_distance = 0
        for path in ant.used_paths
            sum_distance += path.weight
        end

        for path in ant.used_paths
            path.pheromones += path.weight/sum_distance
        end
    end
end

function leave_pheromones_colony(path::UndirectedPath)
    path.pheromones += 1
end

function Δτ(ant, path)
    """
    Calculating the Δτ 
    """
    if path in ant.used_paths
        return 1/path.weight
    else
        return 0
    end
end

function update_decision_table_colony(graph::Graph, decision, decision_table, ant::Ant)
    """
    Updates the decision table after changes.
    """
    α = 1
    β = 5
    ρ = 0.5

    for point in graph.points
        sum_decisions = 0
        
        for path in point.connections
            path.pheromones = ρ*path.pheromones + Δτ(ant, path)
            sum_decisions += (path.pheromones^α)*((1/path.weight)^β)
        end
        
        index = NaN
        for (i, path) in enumerate(point.connections)
            println("Pheromones:\t", path.pheromones)
            decision_table[point.id][i] = (path.pheromones*((1/path.weight)^β))/sum_decisions
            if decision == path
                println("\nAnt at\t", ant.current_point, "\nArrived using path:\t", decision, "\nWith decision value:\t", decision_table[point.id][i], "\n")
                
            end
        end
        
    end
    return decision_table
end

function update_decision_table(graph::Graph, decision_table, ants::Vector{Ant})
    """
    Updates the decision table after changes.
    """
    α = 1
    β = 5
    ρ = 0.5
    for ant in ants
        for point in graph.points
            sum_decisions = 0
            
            for path in point.connections
                path.pheromones = ρ*path.pheromones + Δτ(ant, path)
                sum_decisions += (path.pheromones^α)*((1/path.weight)^β)
            end
            
            for (i, path) in enumerate(point.connections)
                
                println("Pheromones:\t", path.pheromones)
                decision_table[point.id][i] = (path.pheromones*((1/path.weight)^β))/sum_decisions
                println("Decision table at\t", point.id, "\t", decision_table[point.id][i])
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

function traveling_sales(graph::Graph, starting_point_id::Int, finish_point_id::Int, type::String="default")
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
                ant_move_to(decision, graph.points[decision.connection.second], ant)
                leave_pheromones_colony(decision)
            end

            decision_table = update_decision_table_colony(graph, decision, decision_table, ant)
        end
    end
    best_ant(ants)
end

function ant_system(graph::Graph, max_iter::Int=200)
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
                ant_move_to(decision, graph.points[decision.connection.second], ant)
            end
            leave_pheromones(decision)
            
            decision_table = update_decision_table(graph, decision_table, ant)
        end
    end
end

function ant_colony_system(graph::Graph, max_iter::Int=200)
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
                ant_move_to(decision, graph.points[decision.connection.second], ant)
            end
            leave_pheromones(decision)
            
            decision_table = update_decision_table(graph, decision_table, ant)
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

function visualize_graph(graph::Graph)
    # TODO
end

function main()
    # graph = data_init()
    graph = generate_map(x, y)
    traveling_sales(graph, 1, 3)


end

main()



