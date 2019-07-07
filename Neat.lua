--[[Program containing Neat by itself without details of the fitness function or the
necessary data ot actually runthe algorithm
]]
--1-1-113
--Constants
population = 300
genNum = 0
nodeNum = 0
innovation = 0
stepSize = 1 --From NEAT paper
propForDeath = 0.5
TimeoutConstant = 20--For genomes that are stuck

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
staleLim = 30


--Copied parts
BoxRadius = 6
InputSize = (BoxRadius*2+1)*(BoxRadius*2+1)



-- in this exact order, inno.nodes(inputNum) till (inputNum+outputNum)
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
--fir ndoes use .input and .output

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
	console.writeline("-1-")
  while found == false and i <= #inno.nodes do


    if gene.I == inno.nodes[i].input and gene.O == inno.nodes[i].output then
      found = true
      nodeID = i
    end

    i = i + 1
  end

  if found == false then
    local temp = {}
    temp.input = gene.I
    temp.output = gene.O
		console.writeline("-2-")
    table.insert(inno.nodes,temp)--IMPORTANT for format of data in table
    nodeID = #inno.nodes
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

  return gene

end


function makeGenome()

  local genome = {}

  genome.genes = {}
  genome.speciesRank = 0
  genome.globalRank = 0
  genome.fitness = 0
  genome.nodeNum = 0
  --Use this one for making the neural network
  genome.networkI = {}
  --Use this one for getting distance of node
  genome.networkO = {}

  return genome

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
  --gen.totalF = 0
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

--[[Have a feeling this may not be as computationally expensive as I thought so
I'm going to try and implement it]]
function getMaxDistance(node,genome)


  local outputList = genome.networkO

	--This is accounting for output node case which would otherwise return 0
	--on first run
	if  node > inputNum and node <= (inputNum + outputNum) then
		return 10000
	end

  --Dealing with case of input node
  if outputList[node] == nil then
    return 0
  end

--[[Need to completely overhaul this, the list of nodes needs to be added to
currenTable.nodes]]
  local currentTable = {}
	local tempTable = {}
	tempTable.nodes = {}
  tempTable.depth = 0
  --Initialisation
  table.insert(tempTable.nodes,outputList[node])
  tempTable.depth = 1
	table.insert(currentTable,tempTable)


  local maxD = 0


  --[[I know how many connections there are as each gene is a connection
  and that means that I can determine how many links to check]]
--Above not true so better condition required
-- Have to make list of all nodes not checked
  while #currentTable ~= 0 do

    if #currentTable[1].nodes == 0 then
      if currentTable[1].depth > maxD then
        maxD = currentTable[1].depth
      end
      table.remove(currentTable,1)
    else

      for i = 1,#currentTable[1].nodes do
        local nodeAdd = currentTable[1].nodes[i]

				local insertTable = {}
				insertTable.nodes = {}
				insertTable.depth = currentTable[1].depth +1
        table.insert(insertTable.nodes,outputList[nodeAdd])
        table.insert(currentTable,insertTable)

      end
      table.remove(currentTable,1)
    end
  end

  return maxD

end

function randomNodes(genome)
  --Always want 2 nodes out
  --This function needs to get a unique (for the genome) pair of nodes
  --Implementing feed forward network is a lot easier in here I think so I do it
  --[[the maximum distance is the most important part here, if this is enforced
  from the beginning then it makes sure that comparing maximum distance tells
  us whether the new connection will be recurrent or not. It does reduce the
  problem space but saves pruning]]

  local geneList = genome.genes

	genome.networkO = {}

  --Making networkO solely for getMaxDistance
  --This prepares a list of all nodes with a list of all input to sed node
  for i = 1,#geneList do
    local Onode = geneList[i].O
    --going to have to save current list of outputs and then add new one
		local tempOlist = {}


		--If there is no table inserted then this will suffice
    if genome.networkO[Onode] ~= nil then
  		tempOlist = genome.networkO[Onode]
    end
    table.insert(tempOlist,geneList[i].I)

    --Remove and replace at position of output
    genome.networkO[Onode] = nil

    genome.networkO[Onode] = tempOlist

  end






  --Finding if unique and regenerateing if not
  local unique = false
  while unique == false do


    local feedFor = false

    while feedFor == false do
      --giving random values

      --Need to use this loop so that an output node isn't chosen
      I = inputNum +1


      while I > inputNum and I <= (inputNum + outputNum) do
        I = math.random(1,#inno.nodes) --This assignment change the type of I to table
      end
      --This is okay becasue only first inputNum'th entries are input nodes
      O = math.random(inputNum+1,#inno.nodes)


      feedFor = getMaxDistance(I,genome) < getMaxDistance(O,genome)
    end



    --Search for gene, can probably imrpove in light of list but will come back
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
	console.writeline("--1--")
  while found == false and i <= #inno.genes do

    if I == inno.genes[i].I and O == inno.genes[i].O then
      found = true
    end

    i = i + 1
  end

	console.writeline("--2--")
--If not found then add to global list of innovations
  if found == false then
		console.writeline("--2--")
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

local selected = 0
	local enabled = false
	while enabled == false do
		selected = math.random(1,#genome.genes)
		enabled = genome.genes[selected].enable
	end

	disruptGene = genome.genes[selected]
console.writeline("---1---")
  newNode = makeNode(genome, disruptGene)

  addGene1.I = disruptGene.I
  addGene1.O = newNode
  addGene1.weight = 1
  addGene1.innovation = getInno(addGene1.I ,addGene1.O)

console.writeline("---2---")
  addGene2.I = newNode
  addGene2.O = disruptGene.O
  addGene2.weight = disruptGene.weight
  addGene2.innovation = getInno(addGene2.I,addGene2.O)

console.writeline("---3---")
  table.insert(genome.genes,addGene1)
  table.insert(genome.genes,addGene2)
  genome.genes[selected].enable = false
	console.writeline("---4---")
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
	 console.writeline("hello error?")
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
    	forSort[i].globalRank = i
		end




end


--Make species rank also sum so it is quicker
--May need to change this function based on whether i parameter pass or not
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

--Definetly passes its value?
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
        table.insert(child.genes,gene2)
      else
        table.insert(child.genes,gene1)
      end


    end
		return child

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

    for j = 1,species[i].numTObreed do

      local genomeCnt = #species[i].genomes

      g1 = species[i].genomes[math.random(1,genomeCnt)]
      g2 = species[i].genomes[math.random(1,genomeCnt)]

      local child = recombine(g1,g2)
				--[[if species[i].meanF > 500 then
				console.writeline(g1)
				console.writeline(g2)
				console.writeline(child)
			end
      child = mutate(child)
			if species[i].meanF > 500 then
				console.writeline(child)
			end]]


			child = mutate(child)
			console.writeline("i like lag")
      table.insert(bred,child)
    end

  end
	console.writeline("nae way")
  return bred

end


function createPop()

  local childtemp = {}
	local forElitisim = {}

  for i = 1,#gen.species do
    --Elitism
    if #gen.species[i].elite ~= 0 then
			gen.species[i].elite[1].fitness = 0
      table.insert(childtemp,gen.species[i].elite[1])
      table.remove(gen.species[i].elite)
      gen.eliteNum = gen.eliteNum +1
    end
		for j = 1,#gen.species[i].genomes do
			if gen.species[i].genomes[j].globalRank < 10 then
				gen.species[i].genomes[j].fitness = 0
				table.insert(childtemp,gen.species[i].genomes[j])
			end
		end
  end


  --Making babies
  --Needed number of elite for this function
   SUS()

   killWeaklings()
   --meaning sort and remove bottom so many

	 --WORKS TO HERE!!!!
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

--In this case the last entry of children is blank (or most probably the entry from elitism)
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
	evaluateNetwork(genome)
end


function initialise()
	--[[
	As part of initialsiation I have to add the input and output nodes to
	inno.nodes if I or O is 0 then it is an I/O node, -1 indicate invalid
	]]

	for i = 1,inputNum do
	  local temp = {}
	  temp.input = 0
	  temp.output = -1
	  table.insert(inno.nodes,temp)
	end

	for i = 1,outputNum do
	  local temp = {}
	  temp.input = -1
	  temp.output = 0
	  table.insert(inno.nodes, temp)
	end

  --Will start currents on 1
  gen = makeGen()

  --Speciate on the fly
  for i = 1,population do

    local genome = makeGenome()

    addLink(genome)
    --Performing speciation for only one genome

    speciate(genome,false)

  end

  clearJoypad()

  initialiseRun()

end


function nextGen()

  genRank()
--around here

	--Probably inefficient method
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

--Saves a list of genes coming from each input
function getNetworkI(genome)

  local geneList = genome.genes

	saveing = {}
	local tempIlist = {}
  --Going to save into networkI on genome

	--Have to reset the network so as to not carry on past uses
	genome.networkI = {}

  --This prepares a list of all nodes with a list of all genes from sed node
  for i = 1,#geneList do
		if geneList[i].enable == true then
			local Inode = geneList[i].I
    	--going to have to save current list of genes and then add new one
    	if genome.networkI[Inode] ~= nil then
      	tempIlist = genome.networkI[Inode]
    	end

    	table.insert(tempIlist,geneList[i])
    	--Remove and replace at position of output
    	genome.networkI[Inode] = nil
    	genome.networkI[Inode] = tempIlist

			table.insert(saveing,Inode)
		end
  end
end

function sigmoid(x)

  local result = 1/ (1+math.exp(-4.9*x))

	return result

end






--[[
So I don't have to worry about a node not having all its inputs so long as I
take all the outputs for a given distance at the same time and calculate them.
This is because I have enforced that the input's distance must be less than the
outputs distance so no node can be connected to by anything at the same distance or further away fromthe initial inputs.
]]


--[[
The structure of networkI is that the index represents the neuron and the
actual entry is a table of the output neurons
]]

--THIs FUNCITON ISN'T WORKING CORRECTLY!!!
function evaluateNetwork(genome)

  getNetworkI(genome)
--Confident this works as intended!!!!!!!!!!!
  local currentLayer = {}
	--[[not exactly sure if Im going to change this but currently it is
	working out that i have to index currentlayer twice to get to the gene.
	Not exactly a problem just looks bad :L]]
  local net = genome.networkI

--[[	for i = 1,#saveing do
		if gen.frame%10 == 0 then
			for j = 1,#net[saveing[i]] --do
		--		console.writeline(net[saveing[i]][j])
		--[[		console.writeline("gap")
			end
		end
	end
]]
  --Getting input values to start Evaluation
  local inputs = getInputs()
  --^This is an inputNum size table with the value {-1,0,1} fo reach node^

	--This is the "always on" node
	inputs[#inputs + 1] = 1


	--HASH TABLES
  local outputSum = {}
  local outputCheckRef = {}

  --Initialising by adding the inputs that are firing into the current layer table
  local tempTable = {}
  for i = 1,inputNum do
    if net[i] ~= nil then
      table.insert(tempTable,i)
      outputSum[i] =  inputs[i]
      outputCheckRef[i] = true
      --After having done the above, the first neurons output will be recorded in outputSum. (outputCheckRef also updated)
    end
  end
  table.insert(currentLayer,tempTable)
--These inital inputs will be 1 if standable block, -1 if enemy and 0 if nothing

--Creating a condition that, while there is anything in current layer, will repeat

  while #currentLayer ~= 0 do


    --Temporary table to store next layer in
    local nextLayer = {}

    --iterate over all input nodes in this layer
    for i = 1,#currentLayer do

			--ProbabLY NEED TO ADD ANOTHER FOR LOOP TO ITERATE over multiple nodes!!

			for k = 1,#currentLayer[i] do
      	--So inputNodeNum is just the number of a node
      	local inputNodeNum = currentLayer[i][k]


      	--Making sure not a terminal node
      	if net[inputNodeNum] ~= nil then
        	--iterate over all output nodes for this node
        	local genesI = net[inputNodeNum]

        	for j = 1,#genesI do
          --[[There may not necessarily be anything in outputsum yet so Have
					to make if statement]]
						if outputSum[genesI[j].O] == nil then
          		outputSum[genesI[j].O] = outputSum[inputNodeNum] * genesI[j].weight
						else
							outputSum[genesI[j].O] = outputSum[genesI[j].O] + outputSum[inputNodeNum] * genesI[j].weight
						end
          --also add them to nextLayer if outputCheckRef = false
					--This is currently successfully updating
          	if outputCheckRef[genesI[j].O] == false or 	outputCheckRef[genesI[j].O] == nil then
            	outputCheckRef[genesI[j].O] = true
            	table.insert(nextLayer,genesI[j].O)
          	end
        	end

					--[[this ensures all sum's are ran through the sigmoid function]]
					for j = 1,#genesI do
						--Think this is necessary so that sigmoid doesn;t make something out of 0 values
							if outputSum[genesI[j].O] ~= 0 then
								outputSum[genesI[j].O] = sigmoid(outputSum[genesI[j].O])
							end
					end
      	else
					--sigmoid already applied
        	if outputSum[inputNodeNum] > 0.5 then
          --do inputNodeNum - #inputs to give an index for controller table
					if ButtonNames[inputNodeNum-#inputs] == nil then
						console.writeline(inputNodeNum)
						saveGenome(genome,5000,5000,50000)
					end

		      	controller["P1 " .. ButtonNames[inputNodeNum-#inputs]] = true
        	end
      	end
    	end
		end
    --Remove current layer
      table.remove(currentLayer)

    --Add new layer
    --TO make sure condition is broken when only output nodes are given
		if #nextLayer ~= 0 then
      table.insert(currentLayer,nextLayer)
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

	--Error: unable to index s because all species have been destroyed
  local s = gen.species[gen.currentSpecies]
  local g = s.genomes[gen.currentGenome]

  return g.fitness ~= 0

end


--Start of actual code

--event.onexit(saveGen)

initialise()

counter = 0


while true  do


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


	gui.drawText(210,100,tostring(controller["P1 " .. ButtonNames[1]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[2]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[3]]) .. "\n" .. tostring(controller["P1 " .. ButtonNames[4]]) .. "\n" ..
	tostring(controller["P1 " .. ButtonNames[5]]) .. "\n" ..
	tostring(controller["P1 " .. ButtonNames[6]]) .. "\n" ..
	tostring(controller["P1 " .. ButtonNames[7]]) .. "\n" ..
	tostring(controller["P1 " .. ButtonNames[8]]))



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

	emu.frameadvance()




end
