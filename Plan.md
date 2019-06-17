# Plan
#### Have to split project up into sections I can do in a wunner

### Part 1:

Constants required


  -Population = 150


  -Mutation
    -Mutate chance = 0.25\
    -Mutate weights = 0.8\
      -Perturbed = 0.9\
      -Random reset = 0.1\
    -Add node = 0.03\
    -Add link = 0.05\
    `-Mutate enable = 0.4\
    -Mutate disable = 0.2`


  -Recombination\
    -Inherit Disable = 0.75\
    `-Interspecies = 0.01`\


  -Speciation\
    -c1 (Excess) = 1\
    -c2 (disjoint) = 1\
    -c3 (Weights) = 0.4\
    -deltaT = 3\
    -Max stale = 15





### Part 2:

Make data structures required

  nodes\
  genes\

  genomes\
    -speciesRank
    -globalRank
    -fitness

  species\
    -numTOkill
    -highestFitness
    -staleness
    -exampleGenome

  generation
    -No
    -maxFitness




### Part 3:

Neat Algorithm

  -Create initial generation

  -Create initial genomes\
    -BlankGenome
    -AddLink


In while loop till


  -Evaluate fitness\
    -Build Net\
    -Run simulation\
    -Use fitness function

  -Rank genomes
    -use `table.sort`
    -Do intraspecies for algorithm
      -Increment Staleness or update HighestFitness
    -Do globally for interest
      -Store maxFitness for generation along with corresponding genome

  -Calculate adjusted fitness (f') and sum for species
    -Simple
    -When calculating increment stale counter if not improved

  -Assign offspring in proportion to sum of f' in species
    -Determine number of offspring by (population - #species(members > 5))
    -Use stochastic universal sampling (SUS) pg 98 EC book
    -Assign globally number to be replaced in species data structure


Going to interpret the replacement scheme as get rid of all but best if more than 5 members

  -Creating new population
    -For elitism purposes, make a temporary table for any such individuals
    -Create children and save in temporary table
      -First kill off bottom half
        -kill function
      -Random selection of mutation method (0.75 Recombination 0.25 mutate if not one then the other)
        -Recombine function
          -
        -Mutate offspring\
          -AddNode function\
          -AddLink function\
          -AlterWeights function
    -Kill all of current population
      -Randomly assign a member to be representative of this species
      -Kill function
    -Replace with temporary child and elite tables

  -Divide into species\
    -Calculate delta\
    -Add to species when delta< deltaT\
    -Will be order in some way meaningful or not
    -New species otherwise\

  -Increment generation

end of loop



In code have:

  Initialisation
  While... do
    Fitness Evaluation
    Ranking
    Population Creation
    Speciate
  end

Each a separate function


### Part 4

Neural net design


### Part 5

Simulation design
-Copy SethBling


### Part 6

Fitness function design


### Part 7
File Storage for solutions
