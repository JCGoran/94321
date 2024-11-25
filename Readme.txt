"Readme" file related to the NEURON package employed for the paper

Inferring connection proximity in networks of electrically coupled
cells by subthreshold frequency response analysis

Corrado Cali'(1,2), Thomas K. Berger (1), Michele Pignatelli
(1,3), Alan Carleton (3), Henry Markram (1) and Michele Giugliano (1)

1 Laboratory of Neural Microcircuitry, Brain Mind Institute, Ecole
Polytechnique Federale de Lausanne (EPFL) 1015, Switzerland

2 Department of Electronics, Polytechnic of Turin, 10129 Turin, Italy

3 Flavour Perception Group, Brain Mind Institute, Ecole Polytechnique
Federale de Lausanne (EPFL) 1015, Switzerland

Corresponding author: Michele Giugliano, mgiugliano@gmail.com,
	http://www.giugliano.info

---------------------------------------------------------------------
---------------------------------------------------------------------

This package is running with the NEURON simulation program written by
  Michael Hines and available on internet at:
  http://www.neuro.duke.edu/neuron/home.html


It contains mechanisms (.mod files) and programs (.hoc files) needed
to simulate the biophysical model, modified from the standard
Hodgkin-Huxley model, as described in a contribution in press on the
Journal of Computational Neuroscience.


Electrical synapses are common in many brain structures such as the
inferior olive, the subcoeruleus nucleus and the neocortex, between
neurons and between glial cells. In the cortex, interneurons have been
shown to be electrically coupled and proposed to participate in large,
continuous cortical syncytia, as opposed to smaller spatial domains of
electrically coupled cells. However, to explore the significance of
these findings it is imperative to map the electrical synaptic
microcircuits, in analogy with in vitro studies on monosynaptic and
disynaptic chemical coupling. Since walking from cell to cell
over large distances with a glass pipette is challenging,
microinjection of (fluorescent) dyes diffusing through gap-junctions
remains so far the only method available to decipher such
microcircuits even though technical limitations exist.

Based on circuit theory, we have derived analytical descriptions of
the AC electrical coupling in networks of isopotential cells. We have
then proposed an operative electrophysiological protocol to
distinguish between direct electrical connections and connections
involving one or more intermediate cells. This method allows inferring
the number of intermediate cells, generalizing the conventional
coupling coefficient, which provides limited information.

We provide here some analysis and simulation scripts that used to test
our method through computer simulations, in vitro recordings,
theoretical and numerical methods.

Key words: Gap-Junctions; Electrical Coupling; Networks; ZAP current;
Impedance.

List of files and directories and short description:

runme.hoc [FILE] : the main control, definition, start-stop routine to
launch the simulation!

mechanisms [DIR]

This directory contains hh2.mod (by A. Destexhe), Isin.mod and
Izap.mod (both by M. Giugliano & C. Cali').

These are the mechanisms the user needs to compile (by mknrndll.exe,
under Windows), to extend the repertoire of point-process available in
NEURON, to perform ZAP-current and sinusoidal current
stimulations. Refer to manuscript as well as to the header/comments of
the *.mod files for further implementation details.

mylibs     [DIR]

This directory contains several *.hoc file, to make the definition,
run and output control of the simulation more user friendly (i.e. here
"user-friendly" means easy for us, and hopefully for other beginners
of NEURON like us).

gap.hoc : template for a non-rectifying resistive gap junction (by
M. Migliore)

graphs.hoc : support functions for graphical display (by A. Destexhe
and/or Z. Mainen ?)

Izap_proc.hoc : Zap current injection (user-function) procedure [it
refers, instantiate and use Izap.mod]

filemanagement.hoc : convenient (for us) encapsulation of all the
commands to prepare for data on output file..  write_on_disk.hoc :
convenient (for us) encapsulation of all the commands to prepare for
data on output file..

nsinglecompneuron.hoc : definition of the neuronal morphology,
geometry and biophysics, to be later simulated..

ncellsgj.hoc : linking by electrical coupling (i.e. gap junctions)
each cell defined by the above procedure..

output     [DIR]

This directory contains the raw (binary) data from each simulation run
(i.e. the files chirp_0v_gj.x, chirp_1v_gj.x, chirp_2v_gj.x...), but
also the MATLAB scripts (matlab/) needed to perform Fourier analysis,
to estimate the transfer functions, and to fit a canonical of rational
complex function with zeros and poles.

This directory contains "plotme.m" a very simple script in MATLAB to
quickly display the raw data produced by the simulation and look at
the traces..


---------------------------------------------------------------------
---------------------------------------------------------------------

MATLAB: performing Fourier analysis and identifying a canonical model

---------------------------------------------------------------------
---------------------------------------------------------------------

The subdirectory "output/matlab" contains all the necessary code to
perform a two-steps analysis of the data produced by the simulations..

First one has to preprocess the data by calling the procedure
'preproc.m' and then invoke 'go_and_fit.m' to launch the optimzation.


Description of the scripts and functions available:

anneal.m --> Multidimensional constrained nonlinear minimization,
		      based on the Metropolis algorithm, known as the
		      Simulated Annealing Optimization.  This function
		      assumes the user created a matlab procedure to
		      evaluate the "cost function" and it needs to
		      have access to such a procedure to call it at
		      each descent/random step.


mycost.m : Cost function (see above).

tfpreprocessing.m --> preprocessing core function , based on standard
		      Fourier analysis techniques. It accepts from the
		      user some parameters to specify which input and
		      output waveforms need to be examined, the time
		      axis as well as how many samples at the
		      beginning and at the end of those waveforms
		      should be discarded from the analysis. The
		      function returns magnitude and phase of the
		      transfer function, in the frequency domain
		      computed by means of FFT algorithms.

See the file SSPICE_readme.txt for information about SSPICE in this work.

Changelog
---------
2024-11: Updated hoc files to use Random123
