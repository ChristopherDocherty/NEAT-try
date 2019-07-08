--Constants
population = 150
genNum = 0
nodeNum = 0
innovation = 0
stepSize = 1 --From NEAT paper
propForDeath = 0.5
TimeoutConstant = 20--For genomes that are stuck
eliteTOkeep = 7

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
staleLim = 20


--Copied parts
BoxRadius = 6
InputSize = (BoxRadius*2+1)*(BoxRadius*2+1)

--correspond to these buttons
Filename = "YI2.state"
ButtonNames = {
		"A",
		"B",
		"X",
		"Y",
		"Up",
		"Down",
		"Left",
		"Right",
}

inputNum = InputSize+1
outputNum = #ButtonNames


function clearJoypad()
	controller = {}
	for b = 1,#ButtonNames do
		controller["P1 " .. ButtonNames[b]] = false
	end
	joypad.set(controller)
end

--Assigns globally
function getPositions()

		marioX = memory.read_s16_le(0x94)
		marioY = memory.read_s16_le(0x96)

		local layer1x = memory.read_s16_le(0x1A);
		local layer1y = memory.read_s16_le(0x1C);

		screenX = marioX-layer1x
		screenY = marioY-layer1y
end


function getTile(dx, dy)

		x = math.floor((marioX+dx+8)/16)
		y = math.floor((marioY+dy)/16)

		return memory.readbyte(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
end


function getSprites()

		local sprites = {}
		for slot=0,11 do
			local status = memory.readbyte(0x14C8+slot)
			if status ~= 0 then
				spritex = memory.readbyte(0xE4+slot) + memory.readbyte(0x14E0+slot)*256
				spritey = memory.readbyte(0xD8+slot) + memory.readbyte(0x14D4+slot)*256
				sprites[#sprites+1] = {["x"]=spritex, ["y"]=spritey}
			end
		end

		return sprites

end

function getExtendedSprites()

		local extended = {}
		for slot=0,11 do
			local number = memory.readbyte(0x170B+slot)
			if number ~= 0 then
				spritex = memory.readbyte(0x171F+slot) + memory.readbyte(0x1733+slot)*256
				spritey = memory.readbyte(0x1715+slot) + memory.readbyte(0x1729+slot)*256
				extended[#extended+1] = {["x"]=spritex, ["y"]=spritey}
			end
		end

		return extended
end


function getInputs()
	getPositions()

	sprites = getSprites()
	extended = getExtendedSprites()

	local inputs = {}

	for dy=-BoxRadius*16,BoxRadius*16,16 do
		for dx=-BoxRadius*16,BoxRadius*16,16 do
			inputs[#inputs+1] = 0

			tile = getTile(dx, dy)
			if tile == 1 and marioY+dy < 0x1B0 then
				inputs[#inputs] = 1
			end

			for i = 1,#sprites do
				distx = math.abs(sprites[i]["x"] - (marioX+dx))
				disty = math.abs(sprites[i]["y"] - (marioY+dy))
				if distx <= 8 and disty <= 8 then
					inputs[#inputs] = -1
				end
			end

			for i = 1,#extended do
				distx = math.abs(extended[i]["x"] - (marioX+dx))
				disty = math.abs(extended[i]["y"] - (marioY+dy))
				if distx < 8 and disty < 8 then
					inputs[#inputs] = -1
				end
			end
		end
	end

	return inputs
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
    for i = 1,5 do
      saveGenome(forSort[i],gen.number,speciesNum,i)
    end
  else
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
				local geneCopy = copyGene(gene2)
        table.insert(child.genes,geneCopy)
      else
				local geneCopy = copyGene(gene1)
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
			--Need to remove old genomes...
			local getLostNum = #gen.species[i].genomes
			for j = 1,getLostNum do
				table.remove(gen.species[i].genomes)
			end

      table.insert(nextGenSpecies,gen.species[i])

    end
   --save one genome in examples but remove all the rest

   return children, nextGenSpecies

 	end

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

  local filename = "Generation-" .. gen.number .. "-Save.gen"

        file = io.open(filename)
  file:write(gen.number .. "\n\n")

  file:write(#inno.genes .. "/n")
  for i = 1,#inno.genes do
    file:write(inno.genes[i].I .. " ")
    file:write(inno.genes[i].O .. "\n")
  end

  file:write("\n")

  file:write(#inno.nodes .."\n")
  for i = 1,#inno.nodes do
    file:write(inno.nodes[i] .. " ")
    fiel:write(inno.nodes[i] .. "\n")
  end

  file:write("\n")

  file:write(#gen.species)
  for i = 1,#gen.species do
    file:write(i .. "\n")
    file:write(gen.species[i].staleness)
    file:write(gen.species[i].example)

    local genomes = gen.species[i].genomes
    file:write(#genomes)
    for j = 1,#genomes do
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
    file:write("\n")
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
		end
		index = index + 1
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

  return g.fitness ~= 0

end


--Start of actual code

--event.onexit(saveGen)

initialise()

while true do


	species = gen.species[gen.currentSpecies]
	genome = species.genomes[gen.currentGenome]


	if gen.frame%5 == 0 then
		evaluateNetwork(genome)
	end

  joypad.set(controller)

  getPositions()
  if marioX > rightmost then
  		rightmost = marioX
  		timeout = TimeoutConstant
  end

  timeout = timeout - 1


  --evaluate fitness
  local fitness = rightmost - gen.frame / 2
  gui.drawText(0,0,"Fitness:" .. tostring(fitness))


  local timeoutBonus = gen.frame / 4
	if timeout + timeoutBonus <= 0 then
		 fitness = rightmost - gen.frame / 2
		if rightmost > 4816 then
			fitness = fitness + 1000
		end
    --to get rid of species with awful fitness
		if fitness == 0 then
			fitness = -1
		end
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

	local needThese = getInputs()

	local cells = {}
	local i = 1
	local cell = {}
	for dy=-BoxRadius,BoxRadius do
		for dx=-BoxRadius,BoxRadius do
			cell = {}
			cell.x = 50+5*dx
			cell.y = 70+5*dy
			cell.value = needThese[i] --HVYFEVBEB
			cells[i] = cell
			i = i + 1
		end
	end

	local biasCell = {}
	biasCell.x = 80
	biasCell.y = 110
	biasCell.value = 1
	cells[inputNum + 1] = biasCell





	gui.drawBox(50-BoxRadius*5-3,70-BoxRadius*5-	3,50+BoxRadius*5+2,70+BoxRadius*5+2,0xFF000000, 0x80808080)
	for n,cell in pairs(cells) do
		if n > inputNum or cell.value ~= 0 then
			local color = math.floor((cell.value+1)/2*256)
			if color > 255 then color = 255 end
			if color < 0 then color = 0 end
			local opacity = 0xFF000000
			if cell.value == 0 then
				opacity = 0x50000000
			end
			color = opacity + color*0x10000 + color*0x100 + color
			gui.drawBox(cell.x-2,cell.y-2,cell.x+2,cell.y+2,opacity,color)
		end
	end

	emu.frameadvance();
end
