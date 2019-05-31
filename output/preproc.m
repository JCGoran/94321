%
% PREPROCESSING STAGE
%
%
% Michele Giugliano and Corrado Cali', 2006, EPFL - Lausanne.
%
%--------------------------------------------------------------------------
clear all; close all; clc;

disp('Preprocessing of raw (simulation) data..');
disp('Dec 2006 - Michele Giugliano, Brain Mind Institute, EPFL, Lausanne');
disp(' ');
disp('This script will look for *.x data files in the current directory');
disp('It further assumes that the subdir <matlab> is also there..');

addpath matlab;

Pv = dir('chirp_*v_gj.x');
N  = length(Pv);

if (N==0),
 disp('No voltage trace found!');  return; 
end;
if (~exist('stim_index.txt', 'file')), 
 disp('stim_index.txt could not be found');  return; 
end;
if (~exist('chirp_t_gj.x', 'file')),
 disp('chirp_t_gj.x could not be found');  return; 
end;
%--------------------------------------------------------------------------
stim = load('stim_index.txt')+1;
disp(sprintf('\nProcessing data from a simulation including %d cells..', N));
disp(sprintf(' Stimulus delivered to cell %d. \n\n', stim));

disp('Loading files..');

fp = fopen('chirp_t_gj.x');     T  = fread(fp, inf, 'double'); fclose(fp);
%fp = fopen('chirp_i_in_gj.x');  I  = fread(fp, inf, 'double'); fclose(fp);

figure(1); clf; hold on;

outputs = {};
for i=1:N,
    for j=(i+1):N,

     fp = fopen(Pv(i).name);     in  = fread(fp, inf, 'double'); fclose(fp);
     fp = fopen(Pv(j).name);     out = fread(fp, inf, 'double'); fclose(fp);        
     [TFmag TFphase faxis] = tfpreprocessing(200., 100., out, in, T);   

     i1 = min(find(faxis>50));
     i2 = min(find(faxis>100));
    
    if mean(diff(TFmag(i1:i2))) > 0,
         INVERSION = 1
         disp(sprintf('Preprocessing T(%d - %d)',j,i));    
         TFmag = abs(1./TFmag);
         TFphase = -TFphase;
     else
         INVERSION = 0; 
         disp(sprintf('Preprocessing T(%d - %d)',i,j));    
     end;
   
    %-------------
    Y = log(TFmag); %Y = (Y - min(Y))/(max(Y) - min(Y));
    plot(faxis, Y); set(gca, 'XScale', 'log', 'YScale', 'linear', 'XLim', [0 250]);
    drawnow;
    %pause
    clf;
    %-------------    
    clear in out;
     outputs{i,j,1} = Pv(i).name;
     outputs{i,j,2} = Pv(j).name;
     outputs{i,j,3} = TFmag;
     outputs{i,j,4} = TFphase;
     outputs{i,j,5} = INVERSION;    
    disp('..done!');
    end
end
save 'results.mat' outputs faxis -mat
