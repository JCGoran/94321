%
% GO-AND-FIT STAGE
%
%
% Michele Giugliano and Corrado Cali', 2006, EPFL - Lausanne.
%
%--------------------------------------------------------------------------
clear all; close all; clc;

disp('Analysis and identification on the preprocessed (simulation) data..');
disp('Dec 2006 - Michele Giugliano, Brain Mind Institute, EPFL, Lausanne');
disp(' ');
disp('This script will look for results.mat in the current directory');
disp('It further assumes that the subdir <matlab> is also there..');


addpath matlab;

global Np myfaxis myout E_best p_best;

if (~exist('results.mat', 'file')),
 disp('results.mat could not be found - Run <preproc.m> first!');  return; 
end;

load('results.mat');
N = size(outputs,2);

for i=1:N,
 for j=(i+1):N,
  
  inname  = outputs{i,j,1};
  outname = outputs{i,j,2};
  TFmag   = outputs{i,j,3};
  TFphase = outputs{i,j,4};
  INVERSION=outputs{i,j,5};
  
  if (INVERSION),   disp(sprintf('Analysing T(%d - %d)',j,i));
  else              disp(sprintf('Analysing T(%d - %d)',i,j));
  end
  
  guess = abs(i-j);
  kkk   = 0;
  Np = N+2;
  G0 = TFmag(2);
  cmd2 = 'p_best = [G0 ';
  for h=1:Np,
   if (kkk<guess), RRR = 5 + kkk * 40. /guess; else RRR = 10000; end; kkk = kkk + 1;
   cmd = sprintf('p%d = %f;',h,RRR);   eval(cmd);
   cmd2= sprintf('%s p%d',cmd2, h);
  end
  cmd2= sprintf('%s];',cmd2);     eval(cmd2); 

  posinit = max(find(faxis<=20));   % was 15
  posfin  = max(find(faxis<=100)); % was 100
  out     = TFmag;
  myfaxis = faxis(posinit:posfin);
  myout   = out(posinit:posfin);
  
  fprintf('Type CTRL-C to break the annealing, call "display_fit" to print the fitting\nPress any key to start the annealing:')
  pause
 
  dp_max = 10 * ones(1,Np+1); %dp_max(1) = 0.1;
  p_min = zeros(1,Np+1); 
  p_max = 10000 * ones(1,Np+1); p_max(1) = 5;
  [E_best p_best] = anneal(@mycost,p_best,dp_max,p_min,p_max,10000);  
  disp('..done!');
  again = str2num(input('Again ? (Y>0/N=0)', 's'));
  while (again > 0), 
   [E_best p_best] = anneal(@mycost,p_best,again*dp_max,p_min,p_max,10000);  
   again = str2num(input('Again ? (Y>0/N=0)', 's'));
  end;
  
  if (INVERSION),   pfname = sprintf('T%d%d',j,i);
  else              pfname = sprintf('T%d%d',i,j);  
  end
  display_fit;
  
  end
end

