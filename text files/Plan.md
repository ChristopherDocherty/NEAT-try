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


Because I have to enforce feed forward (it seems like the easiest way to
implement) I will now be storing the network as each input node with its
given outputs


in randomNodes() I am going to make a table where the index is the output node
and each entry is a table of input nodes. There will be no repeat inputs as
every time a link is added uniqueness is checked.

From this list I can then, in getMaxDistance(), work through all paths of the
tree the neural net makes and get distance.

So, how to work through all the paths?

Every time I will insert multiple list's {} of inputs and increase the distance
by 1, if I continue to do this until i get to an input node (i.e.
outputList[node] = nil) then I can compare with maxD (change if necessary),
remove that line from current table and reiterate.

NOt quite perfect, will have to remove a level from currentTable each time i've iterated over it and incremented depth



Going







So,

-check if any nodes left in the index of currentTable being accessed in this
cycle, if none then compare with maxD and remove from currentTable.
Will be nil if outputList for the node is nil
-If yes then add each nodes outputList entry to currentTable and increment
depth (and link count), also remove current layer from currentTable


need to test if table.remove() will do shifting if there are nil entries!!





So this will just be:

-finding what nodes go into which other nodes\
  -In networkI have list of genes in table for given node rather than outputs
-Sum up inputs with weights for earliest nodes\
  -Start with inputs
  -Calculate sum
    -Will have to store in something, use index trick again
  -Next nodes are taken from networkI
  -Repeat
  -Going to make a choice to store outputs in the next entries after inputs
  inside inno.data structure
    --Therefore just need to use output to determine button press



-Use sigmoid function to determine the output\
-Continue along until outputs\
-Give outputs
  -saved in controller table which I will understand better once I have inputs\
  for this thing


IMPORTANT: table funcitons don't really work if there are entries left out
(insert does still but not shifting of elements)





### Part 5

Simulation design
-Copy SethBling
  -Just took enough of the code to get the inputs and output names

### Part 6

Now I need to decide how I am going execute this in the loop.

  -In initialisation have to clearJoypad DONE!


  -Each genome must be tested
    -Every frame check for timeout
    -Every frame evaluate fitness and display using gui.drawText()

    -Only find outputs every 5th frame

    -Once timeout occurs
      -save fitness to genome
      -iterate through genomes (and species if need be) and stop when a\
      genome has no fitness assigned (This will be fine through newGeneration
      as children only retain genes from parents NOT fitness)


    -Have a variable called speciesDone which is turned true in above function
      -when true do
      -rankSpecies
      -Save top 5 of species into file
        -Put genNum and speciesNum into file
      -speciesDone = false



  -Create onexit that saves current pool











### Part 7
File Storage for solutions

Can get file storage working nicely with lua+ instead of Nlua


Store individual genomes in seperate folder to generations so they can be
treated differently

use \\ in specifying directory

genome:

generation
species
global rank
number of genes
  geneList

DONE!


On exit need to save generation

for generation need to save everything required to continue code i.e.
everything kept in newGen()



  -gen.number
  -Save innovation data

  -#gen.species
  -Save species by saving all genomes after each species info

  -species1
    -staleness
    -example
    -genome list
      -genome1
      -genome2
  -species2
    -staleness
    -example
    -genome list
      -genome1
      -genome2

DONE!

### Part 8

now I need to make a list of function in order of execution so that I can more
effectively debug
