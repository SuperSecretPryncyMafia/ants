# Calculations and analysis

### The map
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

**Filling the ___decision table___**

*Assuming that ant always chooses path with highest probability*


|     |Point1|Point2|
|---- |------|------|
|Path1| 0.96 | 0.03 |
|Path2| 0.03 | 0.96 |





