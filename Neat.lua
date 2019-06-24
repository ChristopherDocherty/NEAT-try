--[[Program containing Neat by itself without details of the fitness function or the
necessary data ot actually runthe algorithm
]]

--Constants
population =150
genNum = 1
nodeNum = 0
innovation = 0
stepSize = 0.01 --From NEAT paper
propForDeath = 0.5

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
inno.count = 0

--Unless i can think of some otehr information I have to store thendelete this later
--can define nodes implicitly in innovation structure
--Store the connection I/O that the node disrupts in here



function makeNode(genome,gene)
--Check if node already exists by looking at I/O

  local found = false
  local nodeID = 0

  local i = 1

  while found = false & i <= #inno.data do


    if gene.I == inno.data[i].input & gene.O = inno.data[i].output then
      found = true
      nodeID = i
    end

    i = i + 1
  end

  if found == false then
    local temp = {}
    temp.input = gene.I
    temp.output = gene.O
    table.insert(inno.data,temp)--IMPORTANT for format of data in table
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
  gene.innovation = 0
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
  species.maxF = 0
  species.propTOkill = 0
  species.numTOkill = 0
  species.staleness = 0
  species.example = {}
  species.elite = {}

  return species

end


function makeGen()

  genNum = genNum + 1
  local gen = {}

  gen.number = genNum
  gen.species = {}
  gen.maxFitness = 0
  gen.totalF = 0
  gen.eliteNum = 0


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

      if I == geneList.I & O = geneList.O then --Pretty sure this works
        found = true
      end

      i = i + 1

    end

    if found == false then
      unique = true
    end
  end

  return {I,O}

end

--For getting the innovation of genes
function getInno(I,O)


  local found = false

  local i = 1

  while found = false & i <= #inno.data do

    if gene.I == inno.data[i].input & gene.O = inno.data[i].output then
      found = true
    end

    i = i + 1
  end

  if found == false then
    inno.count = inno.count + 1
    return inno.count
  else
    return i
  end

end





--Mutate functions

function addLink(genome) --Need to determine if already existing

  local linkGene = makeGene()
  --enabled by default

  linkGene.I, linkGene.O = randomNodes(genome)
  linkGene.weight = math.random()*4 -2 --following sethbling [-2,2] range here
  linkGene.innovation = getInno(linkGene.I,linkGene.O)

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
  addGene1.innovation = getInno(addGene1.I ,addGene1.O)


  addGene2.I = newNode
  addGene2.O = disruptGene.O
  addGene2.weight = disruptGene.weight
  addGene2.innovation = getInno(addGene2.I,addGene2.O)

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

    table.insert(forSort,species.genomes[i])
    sum = sum + species.genomes[i].fitness
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

--Definetly passes its value?
    forSort.speciesRank[i] = i

  end

  --For adjusted fitness
  species.meanF = sum / #species.genomes
  --for max f
  if forSort[1].fitness > species.maxF then
    species.maxF = forSort[1].fitness
  else
    species.staleness = species.staleness + 1
  end

end


--For making new generation

function offspringAssign()

  local forPropor = 0
--not keeping track of generation explcitly just store seperately in file part
    for i = 1,#gen.species do

      forPropor = forPropor + gen.species[i].meanF

    end

    for i = 1,#species do

      gen.species[i].propTOkill = meanf / forPropor

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

function killWeaklings()


  --iterate over every species
  for i = 1,#gen.species do

    table.sort(gen.species[i].genomes, function(a,b)
      return(a.speciesRank < b.speciesRank)
    end
    )
    tempGenomeCount = #gen.species[i].genomes

    --Removes worst so many
    for j = 1, tempGenomeCount* propForDeath do
      table.remove(gen.species.[i].genomes)
    end

  end

end

--Going to leave out case where g1 fitness is same as g2
function recommbine(g1,g2)

  local equal = false
  local child = makeGenome()

  if math.random() <= 0.75 then

--Ensuring fittest is always g1
    if g1.fitness < g2.fitness then
      local tempg = g2
      g2 = g1
      g1 = tempg
    elseif g1.fitness == g2.fitness then
      equal = true
    end

--copy innovatoins so they can be accessed by their index number
    local innovations2 = {}
	   for i=1,#g2.genes do
		     local gene = g2.genes[i]
		     innovations2[gene.innovation] = gene
	   end


--actually giving genes
    for i = 1,#g1.genes do
      local gene1 = g1.genes[i]
      local gene2 = innovations2[gene1.innovation]

      if gene2 ~= nil and math.random(2) == 1 then
        table.insert(child.genes,gene2)
      else
        table.insert(child.genes,gene1)
      end

      return child

    end

  else
    --If not from recombination just copy fitter individual
    child.genes = g1.genes
    child.nodeNum = g1.nodeNum

    return child
  end
end






--Need to return children from recombination
function breed()

  local species = gen.species
  local bred = {}

  for i = 1,#species do

    for i = 1,species[i].numTOkill do

      local genomeCnt = #species[i].genomes

      g1 = species[i].genomes[math.random(genomeCnt)]
      g2 = species[i].genomes[math.random(genomeCnt)]

      local child = recombine(g1,g2)

      child = mutate(child)

      table.insert(bred,child)

    end

  end


  return bred

end


function createPop()

  local childtemp = {}



  for i = 1,#gen.species do
    --Elitism
    if species[i].elite ~= nil then
      table.insert(childtemp,gen.species[i].elite)
      table.remove(gen.species[i].elite)
      gen.eliteNum = gen.eliteNum +1
    end

  end


  --Making babies

  --Needed number of elite for this function
   SUS()

   killWeaklings()
   --meaning sort and remove bottom so many

   children = breed()

   --Adding the elite members into the children
   for i = 1,#childtemp do
     table.insert(children,childtemp[i])
   end


   local nextGenSpecies = {}


   for i = 1,#gen.species do
    if gen.species[i].staleness < staleLim then

      gen.species[i].example = gen.species[i].genomes[math.random(1,#gen.species[i].genomes)]
      table.insert(nextGenSpecies,gen.species[i])

    end
   --save one genome in examples but remove all the rest


   return children, nextGenSpecies

end

--for disjoint not considering equal case
--Strategy here is to make a table where there is only an i'th entry if
--the i'th gene is disjoint
function sameSpecies(genome1,species)

  --May be wrong to have this [1], also kind of redunandat to have best member and example...
  local genome2 = species.example[1]

  --Actually counting disjoint and excess
  dNum, avWdif = constantGet(genome1,genome2)

 --following paper for size of N
  if #genome1.genes < 20 and #genome2.genes < 20 then
    N = 1
  else
    if #genome1.genes > #genome2.genes then
      N = #genome1.genes
    else
      N = #genome2.genes
    end
  end

  local delta = c1 * dNum/N + c3 * avWdif

  if delta < deltaT then
    return true
  else
    return false
  end

end





--Will almost certainly have to look this one over...
function constantGet(genome1,genome2)


  local i1 = {}
  for i = 1,#genome1.genes do
    local gene = genome1.gene[i]
    local temptable = {}
    --For disjoint
    temptable.inno = true
    --for weight
    temptable.geneNum = i
    table.insert(i1,temptable)
  end

  local i2 = {}
  for i = 1,#genome2.genes do
    local gene = genome2.gene[i]
    local temptable = {}
    --For disjoint
    temptable.inno = true
    --for weight
    temptable.geneNum = i
      table.insert(i2,temptable)
  end


  local disjointNum = 0
  local totalWdif = 0
  local countW = 0

  for i = 1,#genome1.genes do
    local gene = genome1.gene[i]
    local num = gene.innovation
    if  i2[num].inno then

      countW = countW + 1
      --Looks nasty but is just finding the right gene for difference in genome2
      local wdif = math.abs((gene.weight - genome2.gene[i2[num].geneNum].weight))
      totalWdif = totalWdif + wdif
    else
      disjointNum = disjointNum +1
    end
  end

  for i = 1,#genome2.genes do
    local gene = genome2.gene[i]
    local num = gene.innovation
    if  i1[num].inno then

      countW = countW + 1
      --Looks nasty but is just finding the right gene for difference in genome2
      local wdif = math.abs((gene.weight - genome2.gene[i2[num].geneNum].weight))
      totalWdif = totalWdif + wdif
    else
      disjointNum = disjointNum +1
    end
  end

local avWdif = totalWdif / countW



return disjointNum,avWdif



end




function speciate(children,table)


  if table = true then
    for i = 1,#children do

      local child = children[i]
      local found = false
      local count = 1
      while count <= #gen.species & found == false do

        found = sameSpecies(child,gen.species[count])

      end

      if found = true then
        table.insert(child,gen.species[count])
      else
        local newSpecies = makeSpecies()
        table.insert(newSpecies.genomes,child)
        --If i want to change example have to alter here
        table.insert(newSpecies.example,child)
        table.insert(gen.species,newSpecies)
      end


    end
  else


    local found = false
    local count = 1
    while count <= #gen.species & found == false do

      found = sameSpecies(children,gen.species[count])

    end

    if found = true then
      table.insert(children,gen.species[count])
    else
      local newSpecies = makeSpecies()
      table.insert(newSpecies,children)
      table.insert(gen.species,newSpecies)
    end

  end

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
  --Performing speciation for only one genome
  speciate(genome,false)

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


  children, nextGenSpecies = createPop()


  gen = makeGen()
  for i = 1,#nextGenSpecies do
    table.insert(gen.species,nextGenSpecies[i])
  end


  speciate(children,true)




end
