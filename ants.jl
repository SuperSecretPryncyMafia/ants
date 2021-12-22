include("graph.jl")

using Random
using Distributions
using Plots


x = [0 3 6 7 15 10 16 5 8 1.5]
y = [1 2 1 4.5 -1 2.5 11 6 9 12]


mutable struct Ant
	current_point::Point
	visited_points::Vector{Point}
	used_paths::Vector{UndirectedPath}
	tour_length::Float64
    starting_point::Point
end

Ant( c, v, u, s) = Ant( c, v, u, 0, s)

function data_init()
	"""
	Initialization of graph for the traveling sales ant
	"""
	point1 = Point(1, 1)
	point2 = Point(2, 1)
	point3 = Point(3, 1)

	path1 = UndirectedPath(1,Pair(point1.id, point2.id), 2, 1.0)
	path2 = UndirectedPath(2,Pair(point1.id, point2.id), 1, 1.0)
	path3 = UndirectedPath(3,Pair(point2.id, point3.id), 2, 1.0)
	path4 = UndirectedPath(4,Pair(point2.id, point3.id), 1, 1.0)

	point1.connections = Vector{UndirectedPath}([path1, path2])
	point2.connections = Vector{UndirectedPath}([path3, path4])
	graph = Graph([], [])

	points = [point1, point2, point3]
	paths = [path1, path2, path3, path4] 

	graph.paths = paths
	graph.points = points

	return graph
end

function generate_map(x_coordinates, y_coordinates)
	"""
	Generator of graphs based on given points coordinates
	"""
	points = Vector{Point}()
	paths = Vector{UndirectedPath}()
	len_x = length(x_coordinates)
	
	if len_x == length(y_coordinates)
		for i in 1:len_x
			append!(points, [Point(i, 0, [x_coordinates[i], y_coordinates[i]])])
		end

		path_id = 1
		for i in 1:len_x
			for j in 1:len_x
				if points[i] != points[j]
					create = true
					for path in paths
						if  (path.connection.first == points[i].id || 
							path.connection.second == points[i].id) &&
							(path.connection.first == points[j].id || 
							path.connection.second == points[j].id)
							
							create = false
							break
						end
					end
					if create == true
						path = UndirectedPath(path_id, Pair(points[i].id, points[j].id), sqrt(abs(x_coordinates[i]-x_coordinates[j])^2 + abs(y_coordinates[i]-y_coordinates[j])^2), 0.0001 )
						append!(paths, [path])
						path_id +=1
					end
				end
			end
		end
		for point in points
			for path in paths
				if path.connection.first == point.id  || path.connection.second == point.id
					append!(point.connections, [path])
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

function ant_available_paths(ant::Ant)
	available_paths = Vector{UndirectedPath}()

	for path in ant.current_point.connections
		if path.connection.first == ant.current_point.id
			if path.connection.second in [point.id for point in ant.visited_points]
			else
				append!(available_paths, [path])
			end
		elseif path.connection.second == ant.current_point.id
			if path.connection.first in [point.id for point in ant.visited_points]
			else
				append!(available_paths, [path])
			end
		end
	end

    return available_paths
end

function roll_next_path(decision_table::Dict{Any, Any}, available_paths::Vector{UndirectedPath}, ant::Ant)
    top = 0
    order = zeros(length(available_paths))
    for (i, path) in enumerate(available_paths)
        if path.connection.first == ant.current_point.id 
            order[i] = decision_table[path.connection.first][path.id]
            top += order[i]
        else
            order[i] = decision_table[path.connection.first][path.id]
            top += order[i]
        end
    end

    roll = rand(Uniform(0, 1))*top
    for i in 1:length(order)
        if roll < order[i]
            return available_paths[i]
        else
            roll -= order[i]
        end
    end
end

function init_ants(graph::Graph, number_of_ants::Int)
	"""
	Ant vector initialization with starting point of every ant choosen as random
	"""
	ants = []
	for i in 1:number_of_ants
		starting_point = graph.points[rand(1:number_of_ants)]
		append!(ants, [Ant(starting_point, [starting_point], [], 0, starting_point)])
	end
	return ants
end

function init_ants(starting_point::Point, number_of_ants::Int)
	# init ants when all are starting from the same place
	ants = []
	for i in 1:number_of_ants
		append!(ants, [Ant(starting_point, [starting_point], [], starting_point)])
	end
	return ants
end

function init_pheromones(graph::Graph, amount_of_pheromone::Float16)
	# initialization of pheromons disposition UNUSED
	for path in graph.paths
		path.pheromones = amount_of_pheromone
	end
end

function best_ant(ants::Vector{Any})
	# Searching for the best ant. Used in the end of the program
	
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
	println("\nThe best ant: ", best_ant_len, "\t", ants[best_ant_index], "\nPath:\n")
	[println(x) for x in ants[best_ant_index].used_paths]
	[println(x.connection) for x in ants[best_ant_index].used_paths]
	return ants[best_ant_index].used_paths
end

function init_decision_table(graph::Graph)
	decision_table = Dict()
	for point in graph.points
		# find_all_connections(graph, point)
		decision_table[point.id] = Dict()

		for path in point.connections
			decision_table[point.id][path.id] = 0.1
		end
	end
	return decision_table
end

function leave_pheromones(ants::Vector{Any})
	# Here we need to calculate how much pheromone is being deposited on the full path of the ant
	# Shorter overall path means higher level of pheromones being spread. 
	for ant in ants
		sum_distance = 0.0
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
		return 1/ant.tour_length
	else
		return 0
	end
end

function update_decision_table_colony(graph::Graph, decision_table, ant::Ant)
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

		for (i, path) in enumerate(point.connections)
			# println("Pheromones:\t", path.pheromones)
			decision_table[point.id][i] = (path.pheromones*((1/path.weight)^β))/sum_decisions
			# if decision == path
			#	 println("\nAnt at\t", ant.current_point, "\nArrived using path:\t", decision, "\nWith decision value:\t", decision_table[point.id][i], "\n")
				
			# end
		end
		
	end
	return decision_table
end

function update_decision_table(graph::Graph, decision_table, ant::Ant)
	"""
	Updates the decision table after changes.
	"""
	α = 1
	β = 5
	ρ = 0.5

	for path in ant.used_paths
		ant.tour_length += path.weight
	end
	
	for path in graph.paths
		path.Δτ += Δτ(ant, path)
	end

	# Add partial Δτ's and evaporate
	for path in graph.paths
		path.pheromones = (1-ρ) * path.pheromones + path.Δτ
	end

	for point in graph.points
		sum_decisions = 0
		for path in point.connections
			sum_decisions += path.pheromones^α * (1/path.weight)^β #η^β
		end
		for path in point.connections
			decision_table[point.id][path.id] = (path.pheromones*((1/path.weight)^β))/sum_decisions
		end
	end

	return decision_table
end

function update_decision_table(graph::Graph, decision_table, ants::Vector{Any})
	"""
	Updates the decision table after changes.
	"""
	α = 1
	β = 5
	ρ = 0.5

	for ant in ants
		for path in ant.used_paths
			ant.tour_length += path.weight
		end
		
		for path in graph.paths
			path.Δτ += Δτ(ant, path)
		end
	end
	
	# Add partial Δτ's and evaporate
	for path in graph.paths
		path.pheromones = (1-ρ) * path.pheromones + path.Δτ
	end

	for point in graph.points
		sum_decisions = 0
		for path in point.connections
			sum_decisions += path.pheromones^α * (1/path.weight)^β #η^β
		end
		for path in point.connections
			decision_table[point.id][path.id] = (path.pheromones*((1/path.weight)^β))/sum_decisions
		end
	end

	return decision_table
end

function ant_move_to(graph::Graph, path::UndirectedPath, ant::Ant)
	"""
	Transports the ant to the next point with choosen path and updates ant memory.
	path - UndirectedPath - Choosen path
	point - Point - Next point
	ant - Ant - Ant that made the decision 
	"""
	if ant.current_point == point_at(graph, path.connection.first)
		append!(ant.used_paths, [path])
		ant.current_point = point_at(graph, path.connection.second)
		append!(ant.visited_points, [point_at(graph, path.connection.second)])
		path.number_of_ants_crossed += 1
	elseif ant.current_point == point_at(graph, path.connection.second)
		append!(ant.used_paths, [path])
		ant.current_point = point_at(graph, path.connection.first)
		append!(ant.visited_points, [point_at(graph, path.connection.first)])
		path.number_of_ants_crossed += 1
	end

end

function shortest_path(graph::Graph, starting_point_id::Int, finish_point_id::Int, type::String="default")
	# Initialization
	starting_point = point_at(graph, starting_point_id)
	finish_point = point_at(graph, finish_point_id)

	number_of_points = length(graph.points)
	ants = init_ants(starting_point, number_of_points)
	decision_table = init_decision_table(graph)
	
	for ant in ants
		if finish_point != starting_point
			while ant.current_point.id != finish_point_id
				# Check if point has a crossroad
				paths = ant.current_point.connections
				println(paths)
				if length(paths) > 1
					decision = roll_next_path(decision_table, paths, ant)
					ant_move_to(graph, decision, ant)
				end
				decision_table = update_decision_table(graph, decision_table, ant)
			end
		else
			println("Sales Ant is starts at destination, distance 0.\nIf you want ant to travel through all points then use ant_system()")
		end
	end
	best_ant(ants)
end

function ant_system(graph::Graph, start_destination_id::Int, max_iter::Int=200)
	# Initialization
	number_of_points = length(graph.points)
	println(number_of_points)
	decision_table = init_decision_table(graph)
	ants = Vector{Ant}()
	for i in 1:max_iter
		ants = init_ants(graph, number_of_points)
		for ant in ants
			while length(ant.visited_points) < number_of_points
				paths = ant_available_paths(ant)
				decision = roll_next_path(decision_table, paths, ant)
				if ant_move_to(graph, decision, ant) == -1
					println("errrrr")
				end
			end

			decision = find_path(ant.current_point, ant.starting_point)
			ant_move_to(graph, decision, ant)
		end
		decision_table = update_decision_table(graph, decision_table, ants)
		z = [sum([y.weight for y in x.used_paths ]) for x in ants]
		println(minimum(z))
	end

	[println(decision_table[x],"\t", x) for x in keys(decision_table)]

	return best_ant(ants)

end

function ant_colony_system(graph::Graph,max_iter::Int=200)
	number_of_points = length(graph.points)
	println(number_of_points)
	decision_table = init_decision_table(graph)
	ants = Vector{Ant}()
	for i in 1:max_iter
		ants = init_ants(graph, number_of_points)
		for ant in ants
			while length(ant.visited_points) < number_of_points
				paths = ant_available_paths(ant)
				decision = roll_next_path(decision_table, paths, ant)
				if ant_move_to(graph, decision, ant) == -1
					println("errrrr")
				end
			end
			decision = find_path(ant.current_point, ant.starting_point)
			ant_move_to(graph, decision, ant)
		end
		decision_table = update_decision_table(graph, decision_table, ants)
	end

	[println(decision_table[x],"\t", x) for x in keys(decision_table)]

	return best_ant(ants)
end

function visualize_graph(graph::Graph, used_paths)
	points_coords_x = [point.coordinates[1] for point in graph.points]
	points_coords_y = [point.coordinates[2] for point in graph.points]

	plot(legend=false, thickness_scaling = 0.6)

	for index in 2:length(graph.points)
		first_point = graph.points[index]
		for jndex in 1:index-1
			second_point = graph.points[jndex]
			x = [first_point.coordinates[1], second_point.coordinates[1]]
			y = [first_point.coordinates[2], second_point.coordinates[2]]
			path_weight = 1

			plot!(x, y, lw=path_weight*1, color="lightblue")
		end
		for path in used_paths
			plot!(
				[point_at(graph, path.connection.first).coordinates[1], point_at(graph, path.connection.second).coordinates[1]], 
				[point_at(graph, path.connection.first).coordinates[2], point_at(graph, path.connection.second).coordinates[2]], 
				lw=3,
				color="#73C6B6"
			)   
		end
	end
	scatter!(points_coords_x, points_coords_y, color="#73C6B6", series_annotations=text.(1:length(x), :bottom))
end

function main()
	# graph = data_init()
	graph = generate_map(x, y)
	# shortest_path(graph, 1, 3)
	used_paths = ant_system(graph, 1, 200)
	visualize_graph(graph, used_paths)

end

main()

