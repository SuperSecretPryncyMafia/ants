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
point4 = Point(4, 1)
point5 = Point(5, 1)


path2 = UndirectedPath(Pair(point2.id, point3.id), 0)
path3 = UndirectedPath(Pair(point2.id, point4.id), 0)
path4 = UndirectedPath(Pair(point3.id, point5.id), 0)

graph = Graph([],[])

points = [point1, point2, point3, point4, point5]
paths = [ path2, path3, path4]

graph.paths = paths
graph.points = points

#dijiksta(3, 5, graph)

function choose_branch(point, paths)
    k = 20
    d = 2
    PR(paths, k, d)
end

function PR(paths, k, d)
    p =  ((paths[1].weight + k)^d) / (((paths[1].weight + k)^d) + ((paths[2].weight + k)^d))  
    
    
    return p
end

function ants(paths, n=10000)
    k = 20
    d = 2

    for i in 1:n*2
        probability_right = PR(paths, k, d)  
        
        decision = rand(Uniform(0.0, 1.0))

        if decision <= probability_right
            paths[1].weight += 1
        else
            paths[2].weight += 1
        end
    end
    
    println(paths[1])
    println(paths[2])
end

ants(paths)
ants(paths)
ants(paths)
ants(paths)
