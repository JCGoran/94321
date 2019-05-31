The present text file contains some information about the "Symbolic
Spice" circuit analysis tools and explorations, carried out in the
context of the paper:

--------------------------------------------------------------------

"Inferring connection proximity in networks of electrically coupled
cells by subthreshold frequency response analysis"

Corrado Cali', Thomas K. Berger, Michele Pignatelli, Alan Carleton,
Henry Markram, and Michele Giugliano

Journal of Computational Neuroscience (in press)

Corresponding Author:
Dr. Michele Giugliano
EPFL SV BMI LNMC, Station 15, CH-1015 Lausanne (CH)
Phone: +41-76-569-0648, Fax: +41-21-693-5350, 
E: michele.giugliano@epfl.ch 
--------------------------------------------------------------------

In the studies performed by Giugliano and collaborators, it soon
became clear that the availability of a circuit simulation program for
linear ac *symbolic* analysis would have represented a crucial step
towards the numerical and theoretical confirmation of the method
proposed in the above paper.

In the last decades, a lot of software for linear and non-linear
circuit simulation and design was proposed.  Historically, SPICE is
the the most famous and it originated from the EECS Department of the
University of California at Berkeley. Electrical circuits are
described in an abstract textual description language and may contain
resistors, capacitors, inductors, mutual inductors, independent
voltage and current sources, four types of dependent sources, lossless
and lossy transmission lines, switches, uniform distributed RC lines,
as well as semiconductor devices such as diodes, BJTs, JFETs, MESFETs,
and MOSFETs.

(see http://bwrc.eecs.berkeley.edu/Classes/IcBook/SPICE/)

In the 90s, the groups of Prof. Gregory M. Wierzba and many others
published several papers on the automatic symbolic analysis and
approximation. SSPICE, Copyright 1991 by Michigan State University
Board of Trustees, is one such successful proposal. Accepting
input files in the same SPICE format, SSPICE performs a symbolic AC
analysis. Symbolic determinants are sorted with the additional option
of numeric evaluation. Although, SSPICE offers a many low and high
frequency symbolic transistor models as well as some linear ICs, only
linear networks composed of resistors and capacitors have been
implemented. Although SSPICE was born as a commercial product, a
functional demo version is available from
http://www.egr.msu.edu/~wierzba.

The task of Giugliano and collaborators was then to write a very
simple script to generate a "netlist" ASCII file, containing the
formal description of the network. Below we exemplify and fully
comment one of the many scripts employed. It is written in MATLAB as
it will also perform some 'analysis' of the results of
SSPICE. Nevertheless, rewriting it in any programming language or
scripting language is possible.

Lausanne, 16 Oct 2007 - Michele Giugliano, PhD

%
% ladder1D_nearest.m
%
% (c) 2007, Michele Giugliano, PhD - www.giugliano.info, mgiugliano@gmail.com
% Lausanne, Feb 21st 2007
%
%
% This script automagically generates a SSPICE compatible netlist, for the case of
% finite, 1-dimensional RC ladder network with nearest neighbor connectivity - as a
% model of a linear chain of electrically coupled neurons (see the sketch below; nodes are
% numbered accordingly).
%
%     1        2 ...
%    |--|--R--...
%    R  C
%    |  |
%    0 - ---------------ground
%
%
clear all;		% clear the memory
close all;		% close all open files, figures, etc.
clc;			% clear the MATLAB window

N   = 60;        % Number of RC-groups..	<--------- NETWORK SIZE !!!
stim_node = 10;  % Node where the external, probing, current is injected (see Cali' et al., 2008)..

fp  = fopen('L.cir', 'w');				% a file is created and it will contain the netlist
out = sprintf('LADDER NETWORK (%d)', N);  	% the netlist format is simple but one must conform to it.
fprintf(fp,'%s\n', out);				% netlist start with a comment

%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
node = 1;							% An iterative definition of all the 'nodes'..
for i=1:N,							%

 val = rand * (150. - 75.) + 75.;			% Random values are assigned to components of the circuit.
 out = sprintf('R%d %d 0 %fM', i, node, val);  
 fprintf(fp,'%s\n', out);

 eval(sprintf('G%d = %f;', i, 1./val));		% For later analysis, I make the actual value available to MATLAB

 val = rand * (300. - 50.) + 50.;
 out = sprintf('C%d %d 0 %fp', i, node, val);  
 fprintf(fp,'%s\n', out);

 eval(sprintf('C%d = %f;', i, val)); 		% For later analysis, I make the actual value available to MATLAB

 if (i<N)
  val = rand * (60. - 20.) + 20.;
  out = sprintf('Rg%d %d %d %fp', i, node, node+1, val);  fprintf(fp,'%s\n', out);

  eval(sprintf('GG%d = %f;', i, 1./val));		% For later analysis, I make the actual value available to MATLAB

 end
 node = node + 1;   
end % for
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
								% The definition of the netlist is complemented by other commands.
out = sprintf('Iin %d 0 AC 1', stim_node);  fprintf(fp,'%s\n', out);
out = sprintf('.AC DEC 500 5K .5MEG');  fprintf(fp,'%s\n', out);
out = sprintf('.OPTIONS LIMPTS=1500');  fprintf(fp,'%s\n', out);
out = sprintf('.PRINT AC V(2)');        fprintf(fp,'%s\n', out);
out = sprintf('.END');                  fprintf(fp,'%s\n', out);
fclose(fp);

%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% ANALYSIS AND VISUALIZATION, exploiting the Symbolic MATLAB TOOL

if (exist('L.DET', 'file')~=2),		% The output file produced by SSPICE does not exist!
 disp('Launch SSPICE now and then re-run this script..'); 
 return; 
end;

I = zeros(N, 1);
s = sym('s');
Y = sym('Y');


%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= SSPICE OUTPUT FILE PARSING
fp = fopen('L.DET', 'r');
fgetl(fp);	fgetl(fp);	fgetl(fp);	fgetl(fp);	fgetl(fp);
eval(fgetl(fp));
tmp = fgetl(fp);
while(tmp(1)=='Y')
 k   = strfind(tmp, 's');
 if (~isempty(k))
  tmq = sprintf('%ss*%s', tmp(1:k-2), tmp(k+1:end));
  k   = strfind(tmq, '=');
  tmq = sprintf('%svpa(%s, 5);', tmq(1:k), tmq(k+1:end));
 else
  k   = strfind(tmp, '=');
  tmq = sprintf('%svpa(%s, 5);', tmp(1:k), tmp(k+1:end)); 
 end
 eval(tmq);
 tmp = fgetl(fp);
end
fclose(fp);
%-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

V = inv(Y) * I;
[n,d] = numden(vpa(V,5));

match = 0;

disp(sprintf('STIMULATION ON CELL %d', stim_node));

for i=1:N,
 a = sym2poly(n(i));  a = a(1);
 b = sym2poly(d(i));  b = b(1);
 n(i) = n(i)/a;       d(i)  = d(i)/b;
 distance = length(sym2poly(d(i))) - length(sym2poly(n(i)));
 disp(sprintf('Recording on cell %d (distance is %d): estimated %d !', i, abs(stim_node-i), distance-1));
 if (abs(stim_node-i) == (distance-1)), match = match + 1; end
end
disp(sprintf('Success: %d %%', 100*match/N));

return;

figure(1); clf; hold on;
for i=1:N,
 f = [0.000001 0.0001 0.001 0.01 0.1 1 10 100 200 300 400 500 800 1000 1500];
 ss = double(sqrt(-1) * f);
 M = n(i)/d(i);
 AA = subs(M, 's', ss);
 loglog(f, abs(AA));
 set(gca, 'YScale', 'log', 'XScale', 'log')
 pause;
end
