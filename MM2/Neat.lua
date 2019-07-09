--Constants
population = 300
genNum = 0
stepSize = 1
propForDeath = 0.5
TimeoutConstant = 20--For genomes that are stuck
eliteTOkeep = 7

--Mutation Constants
mChance = 0.25
mWeight = 0.8
mPerturb = 0.9
mAddLink = 0.3
mAddNode = 0.03

--Recombination Constants
rDisable = 0.75
rInter = 0.01

--Speciation Constants
c1 = 1
c2 = 1
c3 = 0.4
deltaT = 3
staleLim = 15


Filename = "MetalManBoss.state"
ButtonNames = {
		"A",
		"B",
		"Left",
		"Right",
}

boxLength = 16

screen = {}
--MAY NEED OT CHANGE TO MATCH WITH GAME
screen.L = 16
screen.R = 239
screen.T = 24
screen.B = 183

horizBoxes = math.ceil(math.abs(screen.R - screen.L )/ boxlength)
vertBoxes = math.ceil(math.abs(screen.B - screen.T )/ boxlength)

inputNum = horizBoxes * vertBoxes
outputNum = #ButtonNames



function getSprites()

	megaman = {}
	megaman.threshold = 25
	megaman.position = {}
	megaman.hurt = false
	local megamanx = memory.readbyte(0x0460)
	table.insert(megaman.position,megamanx)
	local megamany = memory.readbyte(0x04A0)
	table.insert(megaman.position,megamany)


	metalman = {}
	metalman.threshold = 25
	metalman.position = {}
	metalman.hurt = true
	local metalmanx = memory.readbyte(0x0461)
	table.insert(metalman,metlamanx)
	local metalmany = memory.readbyte(0x04A1)
	table.insert(metalman,metlamany)

	metalblades = {}
	metalblades.threshold = 15
	metalblades.position = {}
	metalblades.hurt = true
	local metalblade1x = memory.readbyte(0x047D)
	table.insert(metalblades.position,metalblade1x)
	local metalblade1y = memory.readbyte(0x04BD)
	table.insert(metalblades.position,metalblade1y)
	local metalblade2x = memory.readbyte(0x047C)
	table.insert(metalblades.position,metalblade2x)
	local metalblade2y = memory.readbyte(0x04BC)
	table.insert(metalblades.position,metalblade2y)
	local metalblade3x = memory.readbyte(0x047B)
	table.insert(metalblades.position,metalblade3x)
	local metalblade3y = memory.readbyte(0x04BB)
	table.insert(metalblades.position,metalblade3y)

end


function getNearInputBoxes(sprite,inputs)

	local threshold = sprite[1].threshold
	local hurt = sprtie[1].hurt

	for i = 1,(#sprite[1].position/2) do

		local x = sprite[1].position[2*i-1]
		local y = sprite[1].position[2*i]


		local dist = 0
		local metaBoxlength = 0
		while dist < threshold do
			dist = dist + boxLength
			metaBoxlength = metaBoxlength + 1
		end

		local centreBox = {}
		centreBox.metaX = math.floor((x-screen.L)/boxLength)
		centreBox.metaY = math.floor((y-screen.T)/boxLength)


		local boxNum = horizBoxes*centreBox.metaY + centreBox.metaX
		if hurt = true and inputs[boxNum] ~= 1 then
			inputs[boxNum] = -1
		elseif inputs[boxNum] ~= -1 then
			inputs[boxNum] = 1
		end


		--Simple version where just a square around the sprite is changed
		for j = -metaBoxLength,metaBoxLength do
			for k = -metaBoxLength,metaBoxLength do
				local otherBoxNum = boxNum + j + k*vertBoxes
				if otherBoxNum > 0 and otherBoxNum <= inputNum then
					if hurt = true and inputs[otherboxNum] ~= 1 then
						inputs[otherBoxNum] = -1
					elseif inputs[boxNum] ~= -1 then
						inputs[otherBoxNum] = 1
					end
				end
			end
		end
	end
	return inputs
end

function getInputs()

	local inputs = {}
	for i = 1,inputNum do
		inputs[i] = 0
	end

	inputs = getNearInputBoxes(megaman,inputs)
	inputs = getNearInputBoxes(metalman,inputs)
	inputs = getNearInputBoxes(metalbades,inputs)
end


--Data structures

---have to store I/O's in here
inno = {}
inno.genes = {}
--for genes use .I and .O
inno.nodes = {}
--for ndoes use .input and .output

--[[
I can't create an equivalent node for any I/O node so I make one of their
attributes a negative number (obviously invalid). This allows me to put them
in the table (so i can correctly choose random nodes) without potentially
matching a new ndoe to it
]]

--^^ is necessary for checking if new innovation occurs
--Store the connection I/O that the node disrupts in here



function makeNode(genome,gene)
--Check if node already exists by looking at I/O

  local found = false
  local nodeID = 0

  local i = 1
  while found == false and i <= #inno.nodes do
    if gene.I == inno.nodes[i].input and gene.O == inno.nodes[i].output then
      found = true
      nodeID = i
    end
    i = i + 1
  end

  if found == false then
    local tempTable = {}
    tempTable.input = gene.I
    tempTable.output = gene.O

    table.insert(inno.nodes,tempTable)
    nodeID = #inno.nodes
  end


  return nodeID
	--[[on creation, nodes have a unique I/O identifier, so if that is stored on
creation (i.e. in this function) then identical nodes can identified]]
end





function makeGene()

  local gene = {}

  gene.I = 0
  gene.O = 0
  gene.weight = 0
  gene.enable = true
  gene.innovation = 0

  return gene

end


function makeGenome()

  local genome = {}

  genome.genes = {}
  genome.speciesRank = 0
  genome.globalRank = 0
  genome.fitness = 0
	--By making .nodes a hash table, nodes are uniform across all genomes
	--Changing from before to have output nodes stored first
  genome.nodes = {}
	--This can be used to create a list table from the .nodes hash table
	genome.mostNode = inputNum + outputNum
	--[[This will hold the list table created from .nodes with node index and
	value contained within]]
	genome.network = {}

  return genome

end



function copyGene(gene1)

	local gene2 ={}

	gene2.I = gene1.I
	gene2.O = gene1.O
	gene2.weight = gene1.weight
	gene2.enable = gene1.enable
	gene2.innovation = gene1.innovation

	return gene2

end

function copyGenome(genome1)

	local genome2 = {}

	genome2.genes = genome1.genes
  genome2.speciesRank = genome1.speciesRank
  genome2.globalRank = genome1.globalRank
  genome2.fitness = genome1.fitness
  genome2.nodes = genome1.nodes
	genome2.mostNode = genome1.mostNode
	genome2.network = genome1.network

	return genome2

end

function makeSpecies()


  local species = {}

  species.genomes = {}
  species.meanF = 0
  species.maxF = 0
  species.proptobreed = 0
  species.numTObreed = 0
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
  gen.eliteNum = 0
  --Added for keeping track fo what has been tested in main loop
  gen.currentGenome = 1
  gen.currentSpecies = 1
  gen.frame = 0


  return gen

end


function gaussStep()

  local rng = (math.random() - 0.5) * 7

  perturb = 1/(stepSize * math.sqrt(2 * math.pi)) * math.exp(-(rng^(2)/(2*stepSize^(2))))
  return perturb

end


function randomNodes(genome)
  --Always want 2 nodes out
  --This function needs to get a unique (for the genome) pair of nodes
 	local geneList = genome.genes

  --Finding if unique and regenerateing if not
  local unique = false
  while unique == false do

		--Have to ensure the chosen node is present in genome
		local present = false
		while present == false do
    	--Initialisation for loop
    	O = outputNum +1
    	while O > outputNum and O <= (inputNum + outputNum) do
				O = math.random(1,outputNum)
    	end
			I = math.random(outputNum+1,#inno.nodes)

			if genome.nodes[O] ~= nil and genome.nodes[I] ~= nil then
				present = true
			end

		end


    local found = false
    local i = 1
    while found == false and i < #genome.genes do
      if I == geneList.I and O == geneList.O then
        found = true
      end
      i = i + 1
    end

    if found == false then
      unique = true
    end
  end
  return I,O

end

--For getting the innovation of genes
function getInno(I,O)


  local found = false
  local i = 1

  while found == false and i <= #inno.genes do
    if I == inno.genes[i].I and O == inno.genes[i].O then
      found = true
    end
    i = i + 1
  end

--If not found then add to global list of innovations
  if found == false then
    local temp = {}
    temp.I = I
    temp.O = O
    table.insert(inno.genes,temp)
    return #inno.genes
  else
    return i
  end

end





--Mutate functions

function addLink(genome) --Need to determine if already existing

  local linkGene = makeGene()
  --enabled by default

  linkGene.I, linkGene.O = randomNodes(genome)
  linkGene.weight = math.random()*4 - 2 --following sethbling [-2,2] range here
  linkGene.innovation = getInno(linkGene.I,linkGene.O)

  table.insert(genome.genes,linkGene)--check if this will stay global
end


function addNode(genome)

	local addGene1 = makeGene()
  local addGene2 = makeGene()

	local selected = 1
	local enabled = false
	while enabled == false do
		selected = math.random(1,#genome.genes)
		enabled = genome.genes[selected].enable
	end

	disruptGene = genome.genes[selected]

	local actuallyNew = false
	local newNode = 0

	newNode = makeNode(genome,disruptGene)

	if genome.nodes[newNode] == nil then
		 genome.mostNode = genome.mostNode + 1
	end
	genome.nodes[newNode] = 0

  addGene1.I = disruptGene.I
  addGene1.O = newNode
  addGene1.weight = 1
  addGene1.innovation = getInno(addGene1.I,addGene1.O)

  addGene2.I = newNode
  addGene2.O = disruptGene.O
  addGene2.weight = disruptGene.weight
  addGene2.innovation = getInno(addGene2.I,addGene2.O)


  table.insert(genome.genes,addGene1)
  table.insert(genome.genes,addGene2)

  disruptGene.enable = false

end

function alterWeight(genome)

  local gene = genome.genes

	for i = 1,#genome.genes do
		local rand = math.random()

  	if rand <= mPerturb then
      gene[i].weight =gene[i].weight + gaussStep()
  	else
    	gene[i].weight =  math.random()*4 -2
  	end
	end

end

--[[In this 1000 population version, the probabilites add up to more
than one so I am allowing multiple different types of muation to occur]]

function mutate(genome)

 local rng = math.random()

 if rng < mWeight then
	 alterWeight(genome)
 end
 if  rng < mAddLink then
	 addLink(genome)
 end
 if rng < mAddNode then
   addNode(genome)
 end

return genome

end

--Ranking functions

--Also calculates total fitness
function genRank()

  local forSort = {}

  for i = 1,#gen.species do

    for j = 1,#gen.species[i].genomes do

      table.insert(forSort,gen.species[i].genomes[j])
    end
  end

	table.sort(forSort, function (a,b)
  	return(a.fitness > b.fitness)

  	end
  	)

		for i = 1,#forSort do
    	forSort[i].globalRank = i
		end
end


function speciesRank(species,speciesNum)

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

    forSort[i].speciesRank = i

  end

  --For adjusted fitness
  species.meanF = sum / #species.genomes
  --for max f
  if forSort[1].fitness > species.maxF then
    species.maxF = forSort[1].fitness
  else
    species.staleness = species.staleness + 1
  end


  --Saving good genomes
  if #species.genomes > 5 then
      saveGenome(forSort[1],gen.number,speciesNum,1)
  end
end


--For making new generation

function offspringAssign()

  local forPropor = 0
--not keeping track of generation explcitly just store seperately in file part
    for i = 1,#gen.species do

      forPropor = forPropor + gen.species[i].meanF
    end

    for i = 1,#gen.species do
      gen.species[i].proptobreed = gen.species[i].meanF / forPropor
    end


end

--Want to check this after
--Should just globally assign to species - my intention anyway
function SUS()

  local i = 1
  local a = 0
  local wantChildNum = population - gen.eliteNum
	gen.eliteNum = 0

  --TO make sure required number of children is found
  local overallChildNum = 0
  local speciesChildNum = 0
	local r = math.random() * (1 / wantChildNum)


--need to adjust for elitism DONE
  while  overallChildNum < wantChildNum do


    --Accumulative probablity
    a = a + gen.species[i].proptobreed
    --Resetting to take from top each time
    speciesChildNum = 0
    while r <= a do

      r = r +(1 / wantChildNum)
      speciesChildNum = speciesChildNum +1


      --Count of parents overall
      overallChildNum = overallChildNum + 1
    end

    --Saving number of children for each species
    gen.species[i].numTObreed = speciesChildNum

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
    for j = 1, tempGenomeCount * propForDeath do
      table.remove(gen.species[i].genomes)
    end

  end

end

--Going to leave out case where g1 fitness is same as g2
function recombine(g1,g2)

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

				local geneCopy = copyGene(gene2)
				local rng = math.random()
				if geneCopy.enable == false and rng < (1-rDisable) then
					geneCopy.enable = true
				end
        table.insert(child.genes,geneCopy)

      else

				local geneCopy = copyGene(gene1)
				local rng = math.random()
				if geneCopy.enable == false and rng < (1-rDisable) then
					geneCopy.enable = true
				end
        table.insert(child.genes,geneCopy)

      end
    end

		--[[Cannot inherit nodes from g2 as any genes with a node not
		present in g1 will not be copied]]

		child.nodes = g1.nodes
		child.mostNode = g1.mostNode

		return child

  	else
    	--If not from recombination just copy fitter individual
    	child.genes = g1.genes
			child.nodes = g1.nodes
			child.mostNode = g1.mostNode

    return child
  end
end





--Need to return children from recombination
function breed()

  local species = gen.species
  local bred = {}

  for i = 1,#species do
    for j = 1,species[i].numTObreed do

      local genomeCnt = #species[i].genomes

      g1 = species[i].genomes[math.random(1,genomeCnt)]
			g2 = species[i].genomes[math.random(1,genomeCnt)]


			local rng = math.random()
			if rng < rInter then
				local interNum = math.random(1,#species)
				local interGenomeCnt = #species[interNum].genomes
				g2 = species[interNum].genomes[math.random(1,interGenomeCnt)]
			end

      local child = recombine(g1,g2)

			child = mutate(child)
      table.insert(bred,child)
    end

  end
  return bred
end


function createPop()

	local children = {}
  local childtemp = {}

  for i = 1,#gen.species do
    --Elitism
		for j = 1,#gen.species[i].genomes do
			if gen.species[i].genomes[j].globalRank < eliteTOkeep then
				gen.species[i].genomes[j].fitness = 0
				table.insert(childtemp,gen.species[i].genomes[j])
	      gen.eliteNum = gen.eliteNum +1
			end
		end

		if #gen.species[i].genomes >= 5 then
			for j = 1,#gen.species[i].genomes do
				if gen.species[i].genomes[j].speciesRank == 1 then
					gen.species[i].genomes[j].fitness = 0
					copiedGenome = copyGenome(gen.species[i].genomes[j])
					table.insert(childtemp,copiedGenome)
		      gen.eliteNum = gen.eliteNum +1
				end
			end
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
			--Update example as per NEAT paper
			table.remove(gen.species[i].example)
			local rng = math.random(1,#gen.species[i].genomes)
			table.insert(gen.species[i].example,gen.species[i].genomes[rng])
			--Need to remove old genomes...
			local getLostNum = #gen.species[i].genomes
			for j = 1,getLostNum do
				table.remove(gen.species[i].genomes)
			end
      table.insert(nextGenSpecies,gen.species[i])
    end
 	end
   return children, nextGenSpecies
end

--for disjoint not considering equal case
--Strategy here is to make a table where there is only an i'th entry if
--the i'th gene is disjoint
function sameSpecies(genome1,species)

  --There is never an example...
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
	--EVEN when genome2 doesn't exist, dNum returns 2


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
    local gene = genome1.genes[i]
		i1[gene.innovation] = i
  end

  local i2 = {}
  for i = 1,#genome2.genes do
    local gene = genome2.genes[i]
		i2[gene.innovation] = i
  end


  local disjointNum = 0
  local totalWdif = 0
  local countW = 0
	local avWdif = 0

  for i = 1,#genome1.genes do
    local gene = genome1.genes[i]
    local num = gene.innovation
    if  i2[num] ~= nil then
      countW = countW + 1
      --Looks nasty but is just finding the right gene for difference in genome2
      local wdif = (gene.weight - genome2.genes[i2[num]].weight)
      totalWdif = totalWdif + math.abs(wdif)
    else
      disjointNum = disjointNum +1
    end
  end

  for i = 1,#genome2.genes do
    local gene = genome2.genes[i]
    local num = gene.innovation
    if i1[num] == nil then
			--No need for weight difference as first loop carries this out
      disjointNum = disjointNum +1
    end
  end


	if countW >0 then
		avWdif = totalWdif / countW
	end


	return disjointNum,avWdif
end



function speciate(children,TorNot)

  if TorNot == true then
    for i = 1,#children do

      local child = children[i]
      local found = false
      local count = 1
      while count <= #gen.species and found == false do

				found = sameSpecies(child,gen.species[count])
				if not 	found then
					count = count + 1
				end
      end
      if found == true then
        table.insert(gen.species[count].genomes,child)
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
    while count <= #gen.species and found == false do

			found = sameSpecies(children,gen.species[count])
			if not 	found then
				count = count + 1
			end
    end


    if found == true then
		  table.insert(gen.species[count].genomes,children)
    else
      local newSpecies = makeSpecies()
      table.insert(newSpecies.genomes,children)
			table.insert(newSpecies.example,children)
      table.insert(gen.species,newSpecies)
    end
  end
end

--File functions

function saveGenome(genome, generation, speciesNum, genomeNum)

  local filename = "genomes\\level-YL2-gen" .. tostring(generation) .. "-species-" .. tostring(speciesNum) .. "-genome-" .. tostring(genomeNum) .. ".gen"


        local file = io.open(filename, "w")
  file:write(genome.fitness .. "\n")
  file:write(generation .. "\n")
  file:write(speciesNum .. "\n")
  file:write(genome.globalRank .. "\n")
  file:write(#genome.genes .. "\n")

  for i = 1,#genome.genes do

    file:write(genome.genes[i].I .. " ")
    file:write(genome.genes[i].O .. " ")
    file:write(genome.genes[i].weight .. " ")
    if genome.genes[i].enable == true then
      file:write("1 ")
    else
      file:write("0 ")
    end
    file:write(genome.genes[i].innovation .. "\n")
  end

        file:close()

end


--For on exit
function saveGen()

  local filename = "generation\\Generation-" .. gen.number .. "-Save.gen"

        local file = io.open(filename, "w")
  file:write(gen.number .. "\n\n")

  file:write(#inno.genes .. "\n")
  for i = 1,#inno.genes do
    file:write(inno.genes[i].I .. " ")
    file:write(inno.genes[i].O .. "\n")
  end

  file:write("\n")

  file:write(#inno.nodes .."\n")
  for i = 1,#inno.nodes do
    file:write(inno.nodes[i].input .. " ")
    file:write(inno.nodes[i].output .. "\n")
  end

  file:write("\n")

  file:write(#gen.species .. "\n")
  for i = 1,#gen.species do
    file:write(i .. "\n")
    file:write(gen.species[i].staleness .. "\n")

		file:write(#gen.species[i].genomes .."\n")
		for j = 1,#gen.species[i].genomes do
    	local genome = gen.species[i].genomes[j]
			file:write(genome.mostNode .. "\n")

			local Counter = 0
			for k = 1,genome.mostNode do
				if genome.nodes[k] ~= nil then
					Counter = Counter + 1
				end
			end
			file:write(Counter .. "\n")

			for k = 1,genome.mostNode do
				if genome.nodes[k] ~= nil then
					file:write(k .. "\n")
				end
			end

			file:write(#genome.genes .. "\n")
    	for k = 1,#genome.genes do
      	file:write(genome.genes[k].I .. " ")
      	file:write(genome.genes[k].O .. " ")
      	file:write(genome.genes[k].weight .. " ")
      	if genome.genes[k].enable == true then
        	file:write("1 ")
      	else
        	file:write("0 ")
      	end
      	file:write(genome.genes[k].innovation .. "\n")
    	end
    	file:write("\n")
			end
  end
        file:close()
end


--Initialisation
function clearJoypad()
	controller = {}
	for b = 1,#ButtonNames do
		controller["P1 " .. ButtonNames[b]] = false
	end
	joypad.set(controller)
end

function initialiseRun()
	savestate.load(Filename);
	rightmost = 0
	gen.frame = 0
	timeout = TimeoutConstant
	clearJoypad()

	local species = gen.species[gen.currentSpecies]
	local genome = species.genomes[gen.currentGenome]

	--This is done so that no values from a previous run are carried over
	for i = 1,outputNum do
		genome.nodes[i] = 0
	end
	for i = (inputNum + 1),genome.mostNode do
		if genome.nodes[i] ~= nil then
			genome.nodes[i] = 0
		end
	end

	evaluateNetwork(genome)
end


function initialise()
	--[[
	As part of initialsiation I have to add the input and output nodes to
	inno.nodes if I or O is 0 then it is an I/O node, -1 indicate invalid
	]]

	for i = 1,outputNum do
		local temp = {}
		temp.input = -1
		temp.output = 0
		table.insert(inno.nodes,temp)
	end

	for i = 1,inputNum do
	  local temp = {}
	  temp.input = 0
	  temp.output = -1
	  table.insert(inno.nodes,temp)
	end

  --Will reset currents on 1
  gen = makeGen()
  --Speciate on the fly
  for i = 1,population do

    local genome = makeGenome()

		--If this is not done then random nodes does not work
		for i = 1, inputNum + outputNum do
			genome.nodes[i] = 0
		end

    addLink(genome)
    --Performing speciation for only one genome

    speciate(genome,false)

  end

  initialiseRun()

end


function nextGen()

	saveGen()
  genRank()

	local children = {}
	local nextGenSpecies = {}

  for i =1,#gen.species do
    --Species ranking and summation of
    --Also storing fittest idnividual's data
    speciesRank(gen.species[i],i)
  end

	offspringAssign()


  children, nextGenSpecies = createPop()

  gen = makeGen()

  for i = 1,#nextGenSpecies do
    table.insert(gen.species,nextGenSpecies[i])
  end


  speciate(children,true)

	--Have to ensure that dead species are removed!
	local index = 1
	local specCount = #gen.species
	while index < specCount do
		if #gen.species[index].genomes == 0 then
			table.remove(gen.species,index)
			index = 1
			specCount = #gen.species
		else
		index = index + 1
		end
	end
--JNDWJNDWJDJWNJDNJWDNJDNJDNJNJW
	for i = 1,#gen.species do
		if #gen.species[index].genomes == 0 then
			console.writeline("still no good :L")
		end
	end

end




--For neural net

function sigmoid(x)

  local result = 1/ (1+math.exp(-4.9*x))

	return result

end

--This function puts a list of nodes referenced in genes into genome.network
function getNetwork(genome)
	--Resetting the network
	genome.network = {}

	--Adding output nodes to network
	for i = 1,outputNum do
		local temptable = {}
		temptable.node = i
		temptable.inputGenes = {}
		for j = 1,#genome.genes do
			if genome.genes[j].O == i then
				table.insert(temptable.inputGenes,genome.genes[j])
			end
		end
		table.insert(genome.network,temptable)
	end

	--Adding hidden nodes to network
	for i = inputNum + outputNum + 1,genome.mostNode do
		if genome.nodes[i] ~= nil then
			local temptable = {}
			temptable.node = i
			temptable.inputGenes = {}
			for j = 1,#genome.genes do
				if genome.genes[j].O == i then
					table.insert(temptable.inputGenes,genome.genes[j])
				end
			end
			table.insert(genome.network,temptable)
		end
	end
end

function evaluateNetwork(genome)
--[[
So the plan is to store the i'th node's value in the i'th entry to
genome.nodes. This means I'll have to update only the inputs at first and
then everything else can be updated on its own in this function
]]

	local inputs = getInputs()

	for i = outputNum+1,inputNum+outputNum -1 do
			genome.nodes[i] = inputs[i-outputNum]
	end

	--Always-on node
	genome.nodes[inputNum+outputNum] = 1

	getNetwork(genome)

	network = genome.network

	--iterate over all non terminal nodes to get output values
	for i = outputNum+1,#network do
		local sum = 0
		for j = 1,#network[i].inputGenes do
			local inputGene = network[i].inputGenes[j]
			sum = sum + genome.nodes[inputGene.I] * inputGene.weight
		end
		genome.nodes[network[i].node] = sigmoid(sum)
	end

	--Calculate output values and set controllee accordingly
	for i = 1,outputNum do
		local sum = 0
		for j = 1,#network[i].inputGenes do
			local inputGene = network[i].inputGenes[j]
			sum = sum + genome.nodes[inputGene.I] * inputGene.weight
		end
		if sigmoid(sum) > 0.5 then
			controller["P1 " .. ButtonNames[i]] = true
		end
	end
end


--For main loop

function nextGenome()

  gen.currentGenome = gen.currentGenome + 1

	--Returning nil becasue i have removed all of the species
  if gen.currentGenome > #gen.species[gen.currentSpecies].genomes then
    gen.currentSpecies = gen.currentSpecies + 1
    gen.currentGenome = 1
  end
  if gen.currentSpecies > #gen.species then
    nextGen()
		gen.currentGenome = 1
    gen.currentSpecies = 1
  end
end

function fitnessMeasured()

  local s = gen.species[gen.currentSpecies]
  local g = s.genomes[gen.currentGenome]
	if gen.currentGenome > #gen.species[gen.currentSpecies].genomes then
		console.writeline(#gen.species[gen.currentSpecies].genomes .. " " .. gen.currentGenome)
	end
  return g.fitness ~= 0

end


--Start of actual code

--event.onexit(saveGen)

initialise()

while true do


	species = gen.species[gen.currentSpecies]
	genome = species.genomes[gen.currentGenome]


	if gen.frame%5 == 0 then
		clearJoypad()
		evaluateNetwork(genome)
	end

  joypad.set(controller)

  g

  timeout = timeout - 1


  --evaluate fitness
  local fitness = --HERERERE
  gui.drawText(0,0,"Fitness:" .. tostring(math.abs(fitness)))


		genome.fitness = fitness





		console.writeline("Gen " .. gen.number .. " species " .. gen.currentSpecies .. " genome " .. gen.currentGenome .. " fitness: " .. fitness)


    gen.currentSpecies = 1
		gen.currentGenome = 1
		while fitnessMeasured()  do
			nextGenome()
		end
		initialiseRun()
  end

  gen.frame = gen.frame + 1


	gui.drawText(210,100,tostring(controller["P1 " .. ButtonNames[1]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[2]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[3]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[4]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[5]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[6]]) .. "\n" ..
	tostring(controller["P1 " .. ButtonNames[7]]) .. "\n" ..
	tostring(controller["P1 " .. ButtonNames[8]]))



--All of this just to help me debug



	emu.frameadvance();
end
