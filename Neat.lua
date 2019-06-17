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
