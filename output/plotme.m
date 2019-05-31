

clear all; close all; clc;

Pv = dir('chirp_*v_gj.x');
N  = length(Pv);

stim = load('stim_index.txt')+1;

disp(sprintf('\n\n Plotting data from a simulation including %d cells..', N));
disp(sprintf(' Stimulus delivered to cell %d [red trace]. \n\n', stim));

if (N==0) return; end;

fp = fopen('chirp_t_gj.x');    
T  = fread(fp, inf, 'double');
fclose(fp);

dt = T(21) - T(20);
K  = find(abs(T-150.)<dt); K = K(1);

fp = fopen('chirp_i_in_gj.x');    
I  = fread(fp, inf, 'double');
fclose(fp);

figure(1); clf;
M = ceil(sqrt(5));
for i=1:N,
    subplot(M,M,i);
    fp = fopen(Pv(i).name);    
    X  = fread(fp, inf, 'double');
    fclose(fp);
    P = plot(T(K:end), X(K:end), 'k');
    if (i==stim), set(P, 'Color', [1 0 0]); end
    xlabel('time [ms]');     ylabel('Vm [mV]')
    set(gca, 'XGrid', 'on', 'YGrid', 'on');
end


