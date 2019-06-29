
--Saves a list of genes coming from each input
function getNetworkI(genome)

  local geneList = genome.genes


  --Going to save into networkI on genome

  --This prepares a list of all nodes with a list of all genes from sed node
  for i = 1,#geneList do
    local Inode = geneList[i].I
    --going to have to save current list of genes and then add new one
    if genome.networkI[Inode] ~= nil then
      local tempIlist = genome.networkI[Inode]
    else
      local tempIlist = {}
    end

    table.insert(tempIlist,geneList[i])

    --Remove and replace at position of output
    table.remove(genome.networkI,Inode)
    table.insert(genome.networkI,Inode,tempIlist)
  end


end

function sigmoid(x)

  local result = 1/ (1+e^(-4.9*x))
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


function EvaluateNetwork(genome,inputs)

  local currentLayer = {}
  currentLayer.nodes = {}
  local net = genome.networkI

  local outputSum = {}
  local outputCheckRef = {}

  --Initialising by adding the inputs that are firing into the current layer table
  local tempTable = {}
  for i = 1,inputNum do
    if net[i] ~= nil then
      table.insert(tempTable,i)
      --IMPORTANT need to add taking plus or minus - will be able to once input part done
      --After having done the above, the first neurons output will be recorded in outputSum. (outputCheckRef also updated)
    end
  end
  table.insert(currentLayer[1].nodes,tempTable)
--These inital inputs will be 1 if standable block, -1 if enemy and 0 if nothing









--Creating a condition that, while there is anything in current layer, will repeat
  while currentLayer[1].nodes ~= nil do

    --Temporary table to store next layer in
    local nextLayer = {}


    --iterate over all input nodes in this layer
    for i = 1,#currentLayer[1].nodes do

      --So inputNodeNumO is just the number of a node
      local inputNodeNum = currentLayer[1].nodes[i]

      --Making sure not a terminal node
      if #net[inputNodeNum] ~= 0 then
        --iterate over all output nodes for this node
        local genesI = net[inputNodeNum]
        for j = 1,#genesI do
          --add to their sum, index i is meaning the current input node
          outputSum[genesI[j].O] = outputSum[genesI[j].O] + sigmoid(outputSum[inputNodeNum]) * genesI.weight
          --IMPRTANT!!!! applying sigmoid here, should be okay but should still check
          --also add them to nextLayer if outputCheckRef = false
          if outputCheckRef[genesI[j].O] = false then
            outputCheckRef[genesI[j].O] = true
            table.insert(nextLayer,genesI[j].O)
          end
        end
      else

        if sigmoid(outputSum[inputNodeNum]) > 0.5 then
          --do inputNodeNume - #inputs to give an index for controller table
          --IMPORANT MUST FINISH HERE AFTER DON OUTPUTS
        end

      end
    end

    --Remove current layer
      table.remove(currentLayer[1].nodes)

    --Add new layer
    --TO make sure condition is broken when only output nodes are given
    if #nextLayer ~= 0
      table.insert(currentLayer[1].nodes,NextLayer)
    end




  end

end
