include("graph.jl")

using Random
using Distributions
using Plots


const x = [3 2 12 7 9  3 16 11 9 2]
const y = [1 4 2 4.5 9  1.5 11 8 10 7]

mutable struct Ant
	current_point::Point
	visited_points::Vector{Point}
	used_paths::Vector{UndirectedPath}
	tour_length::Float64
end

Ant( c, v, u ) = Ant( c, v, u, 0 )

function data_init()
	"""
	Initialization of graph for the traveling sales ant
	"""
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

		for i in 1:len_x
			for j in 1:len_x
				if points[i] != points[j]
					path = UndirectedPath(Pair(points[i].id, points[j].id), sqrt(abs(x_coordinates[i]-x_coordinates[j])^2 + abs(y_coordinates[i]-y_coordinates[j])^2), 0.0001 )
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
	# LEGACY UNUSED #
	k = 20
	d = 2
	PR(paths, k, d)
end

function PR(paths, k, d)
	# LEGACY UNUSED #
	return ((paths[1].ants_crossed + k)^d) / (((paths[1].ants_crossed + k)^d) + ((paths[2].ants_crossed + k)^d))  
end

function rulette_choose_lower(paths, decision_table, k, d, point)
	# LEGACY UNUSED #
	
	println(decision_table[point.id])
	upper_bound = maximum(decision_table[point.id])
	println("Decision table at key point.id:	", decision_table[point.id])
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
	# LEGACY UNUSED #
	println(decision_table[point.id])
	upper_bound = maximum(decision_table[point.id])
	println("Decision table at key point.id:	", decision_table[point.id])
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
	# println("Decision table at key point.id:	", point.id, "\t", decision_table[point.id])
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

function rulette_choose(decision_table, graph::Graph, ant::Ant)

	# Creating dick with paths as a keys
	avaliable_paths = Dict()
	# search for point with this ID
	current_point = point_at(graph, ant.current_point.id)
	# for every point id in decision table
	for (i,x) in enumerate(decision_table[ant.current_point.id])
		# if i in the bounds
		if i < length(graph.points)
			potential_path = current_point.connections[i]
			# x_city is the poitn which is on the other end of the path in question
			x_city = point_at(graph, potential_path.connection.second)
			# if city was not visited yet
			if x_city ∉ ant.visited_points
				# we take value of decision table for this path and save
				avaliable_paths[potential_path] = x
			end
		end
	end
	if length(values(avaliable_paths)) > 0
		upper_bound = maximum(values(avaliable_paths))
		scalled = []
		for i in values(avaliable_paths)
			new_value = i/upper_bound
			if !isempty(scalled)
				summed = sum(scalled)
			else
				summed = 0
			end
			append!(scalled, [summed + new_value])
		end
		upper_bound = maximum(scalled)
		decision = rand(Uniform(0, 1))*upper_bound
		for (i, choice) in enumerate(scalled)
			if choice >= decision
				return collect(keys(avaliable_paths))[i]
			end
		end
	end
	return NaN
end

function rulette_choose(decision_table, graph::Graph, ant::Ant, exclude::Point)
	avaliable_paths = Dict()
	current_point = point_at(graph, ant.current_point.id)
	for (i,x) in enumerate(decision_table[ant.current_point.id])
		if i < length(graph.points)
			x_city = point_at(graph, ant.current_point.connections[i].connection.second)
			potential_path = current_point.connections[i]
			#if x_city != exclude
				if x_city ∉ ant.visited_points
					avaliable_paths[potential_path] = x
				end
			#end
		end
	end
	upper_bound = maximum(values(avaliable_paths))
	scalled = []
	for i in values(avaliable_paths)
		new_value = i/upper_bound
		if !isempty(scalled)
			summed = sum(scalled)
		else
			summed = 0
		end
		append!(scalled, [summed + new_value])
	end
	upper_bound = maximum(scalled)
	decision = rand(Uniform(0, 1))*upper_bound
	for (i, choice) in enumerate(scalled)
		if choice >= decision
			return collect(keys(avaliable_paths))[i]
		end
	end
end

# function init_ants(graph::Graph, number_of_ants::Int)
#	 ants = []
#	 for i in 1:number_of_ants
#		 append!(ants, Ant(graph.points[rand(1, number_of_ants)], [], []))
#	 end
#	 return ants
# end

function init_ants(graph::Graph, number_of_ants::Int)
	"""
	Ant vector initialization with starting point of every ant choosen as random
	"""
	ants = []
	starting_points = []
	for i in 1:number_of_ants
		starting_point = graph.points[rand(1:number_of_ants)]
		append!(starting_points, [starting_point])
		append!(ants, [Ant(starting_point, [], [])])
	end
	return ants, starting_points
end

function init_ants(starting_point::Point, number_of_ants::Int)
	# init ants when all are starting from the same place
	ants = []
	for i in 1:number_of_ants
		append!(ants, [Ant(starting_point, [], [])])
	end
	return ants
end

function init_pheromones(graph::Graph, amount_of_pheromone::Float16)
	# initialization of pheromons disposition UNUSED
	for path in graph.paths
		path.pheromones = amount_of_pheromone
	end
end

function show_ants(ants::Vector{Ant})
	# UNUSED #
	for ant in ants
		println(ant)
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
	println("The best ant: ", best_ant_len, "\t", ants[best_ant_index], "\nPath:\n")
	[println(x) for x in ants[best_ant_index].used_paths]
	return ants[best_ant_index].used_paths
end

function init_decision_table(graph::Graph)
	β = 5
	decision_table = Dict()
	for point in graph.points
		# find_all_connections(graph, point)
		decision_table[point.id] = []

		for path in point.connections
			append!(decision_table[point.id], 0.1)
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

#function update_decision_table(graph::Graph, decision_table, ants::Vector{Any})
#	"""
#	Updates the decision table after changes.
#	"""
#	α = 1
#	β = 5
#	ρ = 0.5
#	for ant in ants
#		for point in graph.points
#			sum_decisions = 0
#			
#			for path in point.connections
#				path.pheromones = ρ*path.pheromones + Δτ(ant, path)
#				sum_decisions += (path.pheromones^α)*((1/path.weight)^β)
#			end
#			
#			for (i, path) in enumerate(point.connections)
#				
#				# println("Pheromones:\t", path.pheromones)
#				decision_table[point.id][i] = (path.pheromones*((1/path.weight)^β))/sum_decisions
#				# println("Decision table at\t", point.id, "\t", decision_table[point.id][i])
#			end
#		end
#	end
#	return decision_table
#end

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
		for (i, path) in enumerate(point.connections)
			decision_table[point.id][i] = (path.pheromones*((1/path.weight)^β))/sum_decisions
		end
	end

	return decision_table
end

function ant_move_to(path::UndirectedPath, point::Point, ant::Ant)
	"""
	Transports the ant to the next point with choosen path and updates ant memory.
	path - UndirectedPath - Choosen path
	point - Point - Next point
	ant - Ant - Ant that made the decision 
	"""
	if point ∉ ant.visited_points
		append!(ant.used_paths, [path])
		ant.current_point = point
		append!(ant.visited_points, [point])
		path.number_of_ants_crossed += 1
		#leave_pheromones_colony(path)
	else
		println("something wrong I can feel it")
		# println(ant.visited_points, "\n", point, "\n")
		return -1
	end
end

function traveling_sales(graph::Graph, starting_point_id::Int, finish_point_id::Int, type::String="default")
	# Initialization
	starting_point = point_at(graph, starting_point_id)
	finish_point = point_at(graph, finish_point_id)

	number_of_points = length(graph.points)
	ants = init_ants(starting_point, number_of_points)
	decision_table = init_decision_table(graph)
	
	for ant in ants
		if finish_point != starting_point
			while ant.current_point != finish_point
				# Check if point has a crossroad
				paths = ant.current_point.connections
				if length(paths) > 1
					decision = rulette_choose(decision_table, ant)
					ant_move_to(decision, graph.points[decision.connection.second], ant)
					leave_pheromones_colony(decision)
				end
				decision_table = update_decision_table_colony(graph, decision_table, ant)
			end
		else
			println("Sales Ant is starts at destination, distance 0.\nIf you want ant to travel through all points then use ant_system()")
		end
	end
	best_ant(ants)
end

function ant_system(graph::Graph, start_destination_id::Int, max_iter::Int=200)
	# Initialization
	starting_point = point_at(graph, start_destination_id)

	number_of_points = length(graph.points)
	println(number_of_points)
	decision_table = init_decision_table(graph)
	ants = Vector{Ant}()
	for i in 1:max_iter
		ants, starting_points = init_ants(graph, number_of_points)
		for (j, ant) in enumerate(ants)
			while length(ant.visited_points) < number_of_points-1
				# Check if point has a crossroad
				decision = rulette_choose(decision_table, graph, ant, starting_points[j])
				if decision == NaN 
					break
				end
				if ant_move_to(decision, graph.points[decision.connection.second], ant) == -1
					println("errrrr")
				end
			end
			decision = rulette_choose(decision_table, graph, ant)
			ant_move_to(decision, graph.points[decision.connection.second], ant)
		end
		#leave_pheromones(ants)
		decision_table = update_decision_table(graph, decision_table, ants)
	end
	
	# best_path()  -- TODO

	[println(decision_table[x],"\t", x) for x in keys(decision_table)]

	return best_ant(ants)
end

function ant_colony_system(graph::Graph, start_destination_id::Int, max_iter::Int=200)
	# Initialization
	starting_point = point_at(graph, start_destination_id)

	number_of_points = length(graph.points)
	println(number_of_points)
	decision_table = init_decision_table(graph)
	ants = Vector{Ant}()
	for i in 1:max_iter
		ants, starting_points = init_ants(graph, number_of_points)
		for (j, ant) in enumerate(ants)
			while length(ant.visited_points) < number_of_points
				# Check if point has a crossroad
				println("Problem here")
				if length(find_all_paths_with_point(graph, ant.current_point)) > 1
					decision = rulette_choose(decision_table, graph, ant, starting_points[j])
					ant_move_to(decision, graph.points[decision.connection.second], ant)
					
					# println(decision)
				else
					break
				end
			end
			#decision = rulette_choose(decision_table, graph, ant)
			decision::UndirectedPath=starting_points[j].connections[1]
			for x in ant.current_point.connections
				if x.connection.second == starting_points[j]
					decision = x
					break
				end
			end
			# decision = [x for x in ant.current_point.connections if x.connection.second == starting_points[j]]
			#println(length(decision))

			
			
			if ant.current_point == starting_points[j]
				ant_move_to(decision, graph.points[decision.connection.second], ant)
				decision_table = update_decision_table_colony(graph, decision_table, ant)
			end
		end
	end
	best_ant(ants)
	# best_path()  -- TODO

	[println(decision_table[x],"\t", x) for x in keys(decision_table)]

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

function visualize_graph(graph::Graph, used_paths)
	points_coords_x = [point.coordinates[1] for point in graph.points]
	points_coords_y = [point.coordinates[2] for point in graph.points]

	plot(legend=false)

	for index in 2:length(graph.points)
		first_point = graph.points[index]
		for jndex in 1:index-1
			second_point = graph.points[jndex]
			x = [first_point.coordinates[1], second_point.coordinates[1]]
			y = [first_point.coordinates[2], second_point.coordinates[2]]
			path_weight = 0

			plot!(x, y, lw=path_weight*1)
		end
		for path in used_paths
			plot!(
				[point_at(graph, path.connection.first).coordinates[1], point_at(graph, path.connection.second).coordinates[1]], 
				[point_at(graph, path.connection.first).coordinates[2], point_at(graph, path.connection.second).coordinates[2]], 
				lw=3
			)   

		end
	end
	scatter!(points_coords_x, points_coords_y)
end

function main()
	# graph = data_init()
	graph = generate_map(x, y)
	#traveling_sales(graph, 1, 3)
	used_paths = ant_system(graph, 1, 200)
	visualize_graph(graph, used_paths)

end

main()



