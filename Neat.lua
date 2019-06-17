--[[Program containing Neat by itself without details of the fitness function or the
necessary data ot actually runthe algorithm
]]

--Constants
population =150
genNum = 1
nodeNum = 0
innovation = 0

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
inno.noNodes = 0
--can define nodes implicitly in innovation structure
--Store the connection I/O that the node disrupts in here


function makeNode(genome,gene)
--Check if node already exists by looking at I/O

--[[on creation, nodes ahve a unique I/O identifier, so if that is stored on
creation (i.e. in this function) then identical nodes can identified]]
  --Use for loop to search inno structure


--All connectoin genes aer uniquely identified by I/O as innovation depends on it entirely
  if someVar = false then

    inno.noNodes = inno,noNodes + 1
    local nodeID = inno.noNodes
    table.insert(inno.data,{gene.I,gene.O}) --IMPORTANT for format of data in table

  end

  return nodeID
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

function randomNodes(genome,type)
  --Always want 2 nodes out
  --This function needs to get a unique (for the genome) pair of nodes



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

  selected = random(1,#genome.genes)
  disruptGene = genome.gene(selected)

  newNode = makeNode(genome, disruptGene)

  addGene1.I = disruptGene.I
  addGene1.O = newNode
  addGene1.weight = 1


  addGene2.I = newNode
  addGene2.O = disruptGene.O
  addGene2.weight = disruptGene.weight

  genome.gene(selected).enable = false

end


function alterWeight()

end


function mutate()

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

  local genome = makeGenome

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
