# NEATendo

This repository holds Lua code for the emulator Bizhawk for the following games:

Mega Man II (NES) - Metal Man boss stage\
Super Mario World (SNES)

Running the Lua scripts in Bizhawk will run the NEAT algorithm to determine the
best play choices through simulation. The end result is an bot that can often
perform quite successfully in the above games.

The NEAT algorithm uses Genetic Programming to slowly build up a neural network,
in theory optimising both the architecture and weights of the neural network
simultaneously. In essence, for a defined fitness function (a formula that
measures performance and is chosen suitably for each particular problem or game)
the algorithm will simulate the results of a large number of different neural
networks and choose the fittest individuals for the next generation. These
fittest individuals are speciated (i.e. separated into groups of similar
individuals based on the similarity of their network architecture and weights)
and then are combined with other members of the same species to create the next
generation of networks. The better a species performs on average, the more
networks it will be able to reproduce and pass on to the next generation with
the worst species being culled if they are far outperformed by the other
species.



## Sources

For more details on the NEAT algorithm the original paper can be found here:
[Evolving Neural Networks through Augmenting Topologies](http://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf)\
O. Stanley, R. Miikkulainen


For further reading on Evolutionary Computing (which is helpful for
understanding the terminology used in the paper) I recommend this book:

[Introduction to Evolutionary Computing Second Edition](http://cslt.riit.tsinghua.edu.cn/mediawiki/images/e/e8/Introduction_to_Evolutionary_Computing.pdf)\
A.E. Eiben ,J.E. Smith

This coding project was heavily inspired by SethBling's [video](https://www.youtube.com/watch?v=qv6UVOQ0F44)



## Running the script

To run the script the [Bizhawk](http://tasvideos.org/BizHawk.html) emulator is
required. Once download you need to load the ROM file of the game you want
to run the script on and then open Tools->Lua Console and open a Lua file
from this repository. Running the file should output data about the generation
and the last genomes performance.

If you are training then I recommend you run the emulator on 400% speed (found
in Config->Speed/Skip) so the algorithm can run as fast as possible.
