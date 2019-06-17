--[[Program containing Neat by itself without details of the fitness function or the
necessary data ot actually runthe algorithm
]]

--Constants
population =150

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


--Data structures

function makeGene()

  local gene = {}

  gene.I = 0
  gene.O = 0
  gene.weight = 0
  gene.enable = 1
  gene.innovation = 1 --Might need change

  return gene

end


function makeGenome()

  local genome = {}

  genome.genes = {}
  genome.speciesRank = 0
  genome.globalRank = 0
  genome.fitness = 0

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

  gen.number = 0
  gen.species = {}
  gen.maxFitness = 0

  return gen

end


--
