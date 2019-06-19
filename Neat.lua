--[[Program containing Neat by itself without details of the fitness function or the
necessary data ot actually runthe algorithm
]]

--Constants
population =150
genNum = 1
nodeNum = 0
innovation = 0
stepSize = 0.01 --From NEAT paper

--Mutation Constants
mChance = 0.25
mWeight = 0.8
mPerturb = 0.9
mAddLink = 0.05
mAddNode = 0.03
mEnable = 0.4
mDisable = 0.2

--Recombination Constants
rDisable = 0.75
rInter = 0.01

--Speciation Constants
c1 = 1
c2 = 1
c3 = 0.4
deltaT = 3
staleLim = 15

--Terminals of neural net
inputs = 0
outputs = 0



--Data structures

inno = {}
inno.data = {}
--Unless i can think of some otehr information I have to store thendelete this later
--can define nodes implicitly in innovation structure
--Store the connection I/O that the node disrupts in here


function makeNode(genome,gene)
--Check if node already exists by looking at I/O

  local found = false
  local nodeID = 0

  local i = 1

  while found = false & i <= #inno.data do


    if {gene.I,gene.O} = inno.data[i]
      found = true
      nodeID = i
    end

    i = i + 1
  end

  if found = false then
    table.insert(inno.data,{gene.I,gene.O})--IMPORTANT for format of data in table
    nodeID = #inno.data
  end

  return nodeID

--[[on creation, nodes have a unique I/O identifier, so if that is stored on
creation (i.e. in this function) then identical nodes can identified]]
  --Use for loop to search inno structure
  --All connectoin genes aer uniquely identified by I/O as innovation depends on it entirely
end





function makeGene()

  local gene = {}

  gene.I = 0
  gene.O = 0
  gene.weight = 0
  gene.enable = true
  --[[gene.innovation = 1
can add this back in if I want to keep track from some reaosn
but there is no need given innovation number is implicitly defined
]]

  return gene

end


function makeGenome()

  local genome = {}

  genome.genes = {}
  genome.speciesRank = 0
  genome.globalRank = 0
  genome.fitness = 0
  genome.nodeNum = 0

  return genome

end


function makeSpecies()

  local species

  species.genomes = {}
  species.sumADJFit = 0
  species.numTOkill = 0
  species.staleness = 0
  species.example = {}

  return species

end


function makeGen()

  local gen = {}

  gen.number = genNum
  gen.species = {}
  gen.maxFitness = 0

  genNum = genNum + 1

  return gen

end

--Add to functions

function addToSpecies(genome)

end

--Meta mutate functions

--Not going to enforce feed forward network in this case
--BUt can if that turns out to be easier during the NN stage
function distanceFromI()



end

function removeOutputs (inno)

  for i = 1,outputs do

    table.remove(inno,i)
  end


end

function cauchyStep()

  local rng = (math.random() - 0.5) / 5

  perturb = 1 / (math.pi * stepSize * (1 + (rng / stepSize)^2)

  return perturb

end


function randomNodes(genome)
  --Always want 2 nodes out
  --This function needs to get a unique (for the genome) pair of nodes
  --If wanting a feed forward network the need distanceFromI funciton


  local geneList = genome.genes
  local innoCopy = inno.data
  --Get rid of outputs for RNG
  for i = 1,outputs do
    table.remove(inno,i)
  end

  --Finding if unique and regenerateing if not
  local unique = false
  while unique = false do

    local found = false

    --giving random values
    I = innoCopy[math.random(1,#inno_copy)]
    O = inno.data[math.random(inputs+1,#inno.data)]

    --Search for gene
    local i = 1
    while found = false & i < #genome.genes do

      if I = geneList.I & O = geneList.O then --Pretty sure this works
        found = true
      end

      i = i + 1

    end

    if found = false then
      unique = true
    end
  end

  return {I,O}

end




--Mutate functions

function addLink(genome) --Need to determine if already existing

  local linkGene = makeGene()
  --enabled by default

  linkGene.I, linkGene.O = randomNodes(genome)
  linkgene.weight = math.random()*4 -2 --following sethbling [-2,2] range here

  table.insert(genome.genes,linkGene)--check if this will stay global
end


function addNode(genome)

  local addGene1 = makeGene()
  local addGene2 = makeGene()

  selected = math.random(1,#genome.genes)
  disruptGene = genome.gene(selected)

  newNode = makeNode(genome, disruptGene)

  addGene1.I = disruptGene.I
  addGene1.O = newNode
  addGene1.weight = 1


  addGene2.I = newNode
  addGene2.O = disruptGene.O
  addGene2.weight = disruptGene.weight

  table.insert(genome.genes,addGene1)
  table.insert(genome.genes,addGene2)
  genome.gene(selected).enable = false

end






function alterWeight(genome)

  local gene = genome.genes


  if rand <= mPerturb then

    for i = 1,#genome.genes do

      gene[i].weight =gene.[i].weight + cauchyStep()

    end

  else

    gene[i].weight =  math.random()*4 -2

end

--[[Implementation choice of whether multiple different types of mutatoin can
or not. Here I have chosen only one kind of mutation because I don't know which
is correct]]
function mutate(genome)

 local rng = math.random()

 if rng < mWeight then

   alterWeight(genome)

 elseif rng < mWeight + mAddNode then

   addNode(genome)

 elseif  rng < mWeight + mAddNode + mAddLink then

   addLink(genome)
 end

end

--Ranking functions

function genRank()

  local forSort = {}

  for i = 1,#gen.species do

    local tempSpecies = gen.species[i]

    for j = 1,#species.genomes do

      table.insert(forSort,species.genomes[j])

    end
  end

table.sort(forSort, function (a,b)
  return(a.fitness > b.fitness)

  end
  )

  for i = 1,#global do

    forSort.globalRank[i] = i

  end

end


function speciesRank(species)

  local forSort = {}

  for i = 1, #species.genomes do

    table.insert(forSort,species.genome[i])

  end

  table.sort(forSort, function(a,b)
    return(a.fitness > b.fitness)

  end
  )

  for i = 1,#global do

    forSort.speciesRank[i] = i

  end



end


--Miscellaneous





--Initialisation

gen = makeGen()

--[[
Find number of inputs and outpus and put here

]]

--Speciate on the fly
for i = 1,population do

  local genome = makeGenome()

  genome = addlink(genome)
  addToSpecies(genome)

end


while true do

  fitnessEval()
  genRank()
  speciesRank()

  adjustF()
  offspringAssign()
  createPop()

  speciate()

  genNum = genNum +1

end
