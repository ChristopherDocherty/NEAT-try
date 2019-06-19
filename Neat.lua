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
  species.meanF = 0
  species.propTOkill = 0
  species.numTOkill = 0
  species.staleness = 0
  species.example = {}
  species.elite = {}

  return species

end


function makeGen()

  local gen = {}

  gen.number = genNum
  gen.species = {}
  gen.maxFitness = 0
  gen.totalF = 0
  gen.eliteNum = 0

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

--Also calculates total fitness
function genRank()

  local forSort = {}
  local totalF = gen.totalF

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

  for i = 1,#forSort do

    forSort.globalRank[i] = i
    --Still pretty sure this works
    totalF = totalF + forSort.fitness
  end

end

--Make species rank also sum so it is quicker
--May need to change this function based on whether i parameter pass or not
function speciesRank(species)

  local forSort = {}
  local sum = 0


  for i = 1, #species.genomes do

    table.insert(forSort,species.genome[i])
    sum = sum + species.genome[i].fitness
  end

  table.sort(forSort, function(a,b)
    return(a.fitness > b.fitness)

  end
  )

  --For elitism purposes
  if #forSort >= 5 then

    table.insert(species.elite, forSort[1])

  end

  for i = 1,#forSort do

    forSort.speciesRank[i] = i

  end

  --For adjusted fitness
  species.meanF = sum / #species.genomes


end


--For making new generation

function offspringAssign()

  local species = gen.species
  local forPropor = 0
--not keeping track of generation explcitly just store seperately in file part
    for i = 1,#species do

      forPropor = forPropor + species[i].meanF

    end

    for i = 1,#species do

      species[i].propTOkill = meanf / forPropor

    end


end

--Want to check this after
--Should just globally assign to species - my intention anyway
function SUS()

  local i = 1
  local a = 0
  local r = math.random() * (1 / population)
  local wantChildNum = population - gen.eliteNum
  --TO make sure required number of children is found
  local overallChildNum = 0
  local speciesChildNum = 0


--need to adjust for elitism DONE
  while  overallChildNum <= wantChildNum do

    --Accumulative probablity
    a = a + gen.species[i].propTOkill

    --Resetting to take from top each time
    speciesChildNum = 0
    while r <= a do

      r = r +(1 / childNum)
      speciesChildNum = speciesChildNum +1


      --Count of parents overall
      overallChildNum = overallChildNum + 1
    end

    --Saving number of children for each species
    gen.species[i].numTOkill = speciesChildNum

    i = i + 1


  end



end

function createPop()

  local children = {}
  local parents = {}


  for i = 1,#gen.species do
    --Elitism
    if species[i].elite ~= nil then
      table.insert(children,gen.species[i].elite)
      table.remove(gen.species[i].elite)
      gen.eliteNum = gen.eliteNum +1
    end

  end


  --Making babies

  --Needed number of elite for this function
   SUS()

   killWeaklings()
   --meaning sort and remove bottom so many

   childtemp = Breed()

   --use table.move() to combine children and childtemp

   stale()
   --save one genome in examples but remove all the rest
   blankSpecies()



   speciate()


end













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

--Probably inefficient method
  for i =1,#gen.species do
    --Species ranking and summation of
    speciesRank(gen.species[i])
  end


  offspringAssign()
  createPopandSpeciate()

  genNum = genNum +1

end
