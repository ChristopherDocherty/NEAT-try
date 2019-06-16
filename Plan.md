Have to split project up into sections I can do in a wunner

Part 1:

Constants required


  -Population = 150


  -Mutation
    -Mutate chance = 0.25
    -Mutate weights = 0.8
      -Perturbed = 0.9
      -Random reset = 0.1
    -Add node = 0.03
    -Add link = 0.05
    `-Mutate enable = 0.4
    -Mutate disable = 0.2`


  -Recombination
    -Inherit Disable = 0.75
    `-Interspecies = 0.01`


  -Speciation
    -c1 (Excess) = 1
    -c2 (disjoint) = 1
    -c3 (Weights) = 0.4
    -deltaT = 3
    -Max stale = 15





Part 2:

Make data structures required

  nodes
  genes
  genomes
  species
  generation




Part 3:

Neat Algorithm

-Divide into species
    -

  -Evaluate fitness
    -Build Net
    -Run simulation
    -Use fitness function

  -Rank genomes in species

  -Calculate adjusted fitness (f') and sum for species

  -Assign offspring in proportion to sum of f' in species

  -Kill assigned number of weakest individuals

  -Recombine to replace these individuals

  -Mutate offspring

  -Mutate 25% of rest of population
    -Will be in species structures already
    -Enforce elitism on any best species member for species with 5 or more members

  -Increment generation

  -Repeat



Part 4

Simulation design



Part 5

Fitness function design
