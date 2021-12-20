# Ants Systems

## 1. Introduction

**The Ant systems** - the family of biological-inspired agent-based algorithms created for solving complex optimization problems with nature inspired decision making.

The agents(ants) always seek for the most optimal way of solving the problem with chance of choosing other paths as the experiment. With this approach we are obtaining the globally optimal solution for the given problem. As the ant algorithms are randomly initialized and operates on the probabilistic aproach there is no gurantee that the solution obtained is indeed the most optimal for the given problem. 

Path preferention regulation done by weighing them accordingly to the usage.
By increasing the pheromone level everytime an ant crosses the path, the path becomes more atractive for the next ant that will haveto choose path at this point.

At this point there are two main approaches to the procedure of depositing the pheromones on the path. The first being **the ant colony** aproach when every ant deposits the pheromones when finishes the tour. The second is **the ant system** aproach when the deposition procedure starts after all of the ants from the given iteration has completed the tour.

## 2. Example of the algorithm:

### Calculations and analysis

### The map example
```
1 p11 2 p21 3
O-----O-----O
 \   / \   /
   -     -
  p12   p22
```
Points are connected with paths. 
Paths p11 and p12 are connections between point nr 1 and point nr 2.
Paths p21 and p22 are connections between point nr 2 and point nr 3.

Point1:
- distance to 2 with path 11 is equal 1
- distance to 2 with path 12 is equal 2

Point2:
- distance to 3 with path 21 is equal 1
- distance to 3 with path 22 is equal 2

Every path has initial pheromone value $\tau_0$ = 1

$\eta_{i,j}$ = 1 / $d_{i,j}$

**Constatns**:

$\alpha$ = 1;
$\beta$  = 5;
$\rho$   = 0.5

**The $\eta$ values for given paths:**

$\eta_{1,1}$ = 1

$\eta_{1,2}$ = 1/2

$\eta_{2,1}$ = 1

$\eta_{2,2}$ = 1/2


**Calculating the values of $\Delta\tau_{i,j}$**

*$\Delta\tau_{i,j}$ is equal to the cumulative sum of inverse of the distance when ant k has crossed it.*

$\Delta\tau_{1,1}$ = 1

$\Delta\tau_{1,2}$ = 0.5

$\Delta\tau_{2,1}$ = 1

$\Delta\tau_{2,2}$ = 0.5

**Calculating the values of $\tau_{i,j}$ for the first iteration**

$\tau_{i,j}(n+1) = (1-\rho)*\tau_{i,j}(n) + \Delta\tau_{i,j}$

$\tau_{1,1}(1) = (1-\rho)*\tau_{1,1}(0) + \Delta\tau_{1,1} = (1 - 0.5) * 1 + 1 = 1.5 $

$\tau_{1,2}(1) = 0.5 * 1 + 0 = 0.5 $

$\tau_{2,1}(1) = 0.5 * 1 + 1 = 1.5 $

$\tau_{2,2}(1) = 0.5 $

**Calculating probabilities**

$p_{i,j}(n) = {\tau_{i,j}(n)^\alpha * \eta_{i,j} \over \Sigma { } \tau_{i,j}(n)^\alpha * \eta_{i,j}} $

$p_{1,1}(1) = {\tau_{1,1}(1)^\alpha * \eta_{1,1} \over \Sigma { } \tau_{1,1}(1)^\alpha * \eta_{1,1}} = {1.5 \over 1.5 + 0.25} = 0.857 $

$p_{1,2}(1) = 1 - p_{1,1}(1)$

$p_{2,1}(1) = p_{1,1}(1) $

$p_{2,2}(1) = p_{1,2}(1) $

$p_{1,1}(2) = {1.75 \over 1.75 + 0.125} = 0.923$

$p_{1,2}(2) = 0.077 $

$p_{1,1}(3) = {1.875 \over 1.875 + 0.0625} = 0.968$

$p_{1,2}(3) = 0.032 $

$p_{1,1}(4) = {1.9375 \over 1.9375 + 0.03125} = 0.984$

$p_{1,2}(4) = 0.016 $

**Filling the ___decision table___**

*Assuming that ant always chooses path with highest probability*


| Iteraction | Path11| Path12| Path21| Path22|
| ---------- | ----- | ----- | ----- | ----- |
|      1     | 0.857 | 0.143 | 0.857 | 0.143 |
|      2     | 0.923 | 0.077 | 0.923 | 0.077 |
|      3     | 0.968 | 0.032 | 0.968 | 0.032 |
|      4     | 0.984 | 0.016 | 0.984 | 0.016 |

## 3. Implementation

The main function.
The examplary implementation of the ant system aproach.
Initialization of graph, running the ant system implementation and visualization of the results.

```julia
function main()
	graph = generate_map(x, y)
	used_paths = ant_system(graph, 1, 200)
	visualize_graph(graph, used_paths)
end
```

Starting with the initialization of the graph which contains ten points and connections from every point to every point.

```julia
function generate_map(x_coordinates, y_coordinates)
	"""
	Generator of graphs based on given points coordinates
	"""
	points = Vector{Point}()
	paths = Vector{UndirectedPath}()
	len_x = length(x_coordinates)
	
	if len_x == length(y_coordinates)
		for i in 1:len_x
			append!(points, [Point(i, 0, [
                x_coordinates[i], 
                y_coordinates[i]
            ])])
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
						path = UndirectedPath(
                            path_id, 
                            Pair(points[i].id, points[j].id),
                             sqrt(
                                abs(x_coordinates[i]-x_coordinates[j])^2 + 
                                abs(y_coordinates[i]-y_coordinates[j])^2
                                ),
                            0.0001 
                            )
						append!(paths, [path])
						path_id +=1
					end
				end
			end
		end
		for point in points
			for path in paths
				if  path.connection.first == point.id  ||
                    path.connection.second == point.id
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

```

After creating the graph program proceeds with the implemented system.
Depending on the goal there are two functions inplementing the algorithm.

The first: **The shortest path**

```julia

function shortest_path(
    graph::Graph, 
    starting_point_id::Int, 
    finish_point_id::Int, 
    type::String="default"
    )

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
				decision_table = update_decision_table(
                    graph, 
                    decision_table, 
                    ant
                )
			end
		else
			println("Sales Ant is starts at destination, distance 0.\nIf you want ant to travel through all points then use ant_system()")
		end
	end
	best_ant(ants)
end
```

The second: **The traveling sales-ant**

```julia

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

```

As this two implementations varies only in the details and not in the main solutions this paper will dercribe the traveling sales-ant problem which implements the ant system.

### Starting from the initialization phase of the program:

```julia
number_of_points = length(graph.points)
println(number_of_points)
decision_table = init_decision_table(graph)
ants = Vector{Ant}()
```
Initialization of decision table provides 2d dictionary with id of points and id of path as keys with starting decision value equal to $0.1$. 

```julia
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
```

### The loop

Interating over the range 1 to max_iter( by default equal to 200 ).

```julia
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
```

Initaialization of new group of ants for every iteration.
Number of ants in the group in equal to the number of points(cities) on the graph.
Every ant starts in the random city with this city set in the current_point, visited_cities and the starting_point. Also, ant is initialized with zero tour length(did not traveled anywere yet) and empty used_paths vector.

```julia
function init_ants(graph::Graph, number_of_ants::Int)
	"""
	Ant vector initialization with starting point of every ant choosen as random
	"""
	ants = []
	for i in 1:number_of_ants
		starting_point = graph.points[rand(1:number_of_ants)]
		append!(ants, [Ant(
            starting_point, 
            [starting_point], 
            [], 
            0, 
            starting_point
        )])
	end
	return ants
end
```

For every ant we check the progress of travel. Then we chceck the posiible paths which will not lead to already visited cities and make decision using the rulette wheel. Higher the pheromone level of the path, higher chance that the ant will choose to walk it.

After a whole turn( while loop closes ) we chceck the path which leads from current point of the ant to the starting point( which is our final destination) and force the ant to cross it.

When all of the ants will finish the tours we update the decision table acordingly to the decisions taken by the ants.Deposition of the pheromones and evaporation takes place before the update.

```julia
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
```


