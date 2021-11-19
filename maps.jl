include("graph.jl")

point1 = Point(1, 1)
point2 = Point(2, 1)
point3 = Point(3, 1)
point4 = Point(4, 1)
point5 = Point(5, 1)
point6 = Point(6, 1)
point7 = Point(7, 1)
point8 = Point(8, 1)
point9 = Point(9, 1)

path1 = UndirectedPath(Pair(point1.id, point2.id), 0, 0)

path2 = UndirectedPath(Pair(point2.id, point3.id), 0, 2)
path3 = UndirectedPath(Pair(point2.id, point4.id), 0, 1)
path4 = UndirectedPath(Pair(point3.id, point5.id), 0, 1)
path5 = UndirectedPath(Pair(point4.id, point5.id), 0, 2)

path6 = UndirectedPath(Pair(point5.id, point6.id), 0, 2)
path7 = UndirectedPath(Pair(point5.id, point7.id), 0, 1)
path8 = UndirectedPath(Pair(point6.id, point8.id), 0, 1)
path9 = UndirectedPath(Pair(point7.id, point8.id), 0, 1)

path10 = UndirectedPath(Pair(point8.id, point9.id), 0, 0)
graph = Graph([], [])

points = [point1, point2, point3, point4, point5, point6, point7, point8, point9]
paths = [path1, path2, path3, path4, path5, path6, path7, path8, path9, path10]

graph.paths = paths
graph.points = points