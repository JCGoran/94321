function [TFmag TFphase faxis] = loadme
%
%
%--------------------------------------------------------------------------
[filename, pathname, filterindex] = uigetfile('*', 'PREsynaptic membrane potential..');
if (filename == 0),  return; end;
fullfname = sprintf('%s%s', pathname, filename);
pre  = load(fullfname);
cwd = pwd;
cd(pathname);
[filename, pathname, filterindex] = uigetfile('*', 'POSTsynaptic membrane potential..');
cd(cwd);
if (filename == 0),  return; end;
post = load(sprintf('%s%s', pathname, filename));
%--------------------------------------------------------------------------
Lpre  = length(pre);    Lpost = length(post);
if (Lpre ~= Lpost),     f = warndlg('Lengths of waveforms do not coincide', 'Error!'); 
 return; 
end;
%--------------------------------------------------------------------------
name          = 'Fourier Domain Preprocessing';
prompt        = 'Enter the Sampling Rate [kHz]';
numlines      = 1;
defaultanswer = {'10'};
answer        = inputdlg(prompt,name,numlines,defaultanswer);
dt            = 1./str2num(answer{1}); % ms --> 10kHz
time          = 0:dt:((Lpre * dt) - dt);
%--------------------------------------------------------------------------
pre(1)  = pre(2);
post(1) = post(2);
figure(1);  
subplot(2,1,1); plot(time(2:end)./1000., 1000*pre(2:end), 'k');
ylabel('pre [mV]', 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'FontName', 'Arial', 'FontSize', 15, 'Box', 'on', 'XTickLabel', '');
%title('Data loaded');
set(gca, 'FontName', 'Arial', 'FontSize', 15, 'Box', 'on');
subplot(2,1,2); plot(time(2:end)./1000., 1000*post(2:end), 'r');
ylabel('post [mV]', 'FontName', 'Arial', 'FontSize', 20);
xlabel('time [s]', 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'FontName', 'Arial', 'FontSize', 15);

rev = questdlg('Do you want to reverse pre <--> post ?', 'Reverse', 'Yes', 'No', 'Yes');
if (strcmp(rev, 'Yes')), tmp = post;, post = pre; pre = tmp; end;
%--------------------------------------------------------------------------

TFmag   = [];       TFphase = [];       faxis   = [];
[TFmag TFphase faxis] = tfpreprocessing(0., 0., pre, post, time);   
      


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function [TFmag, TFphase, faxis] = tfpreprocessing(Tdiscard, Tdiscardsup, in, out, t)
%
% PREPROCESSING
% [TFmag, TFphase, faxis] = tfpreprocessing(Tdiscard, Tdiscardsup, in, out, t)
%
% Returns the magnitude and the phase of the complex transfer function
% in the frequency domain, between the input 'in' and the output 'out'
%
% Tdiscard    : [ms] how much initial interval to discard
% Tdiscardsup : [ms] how much final interval to discard
% in          : input waveform
% out         : output waveform
% t           : [ms] time axis
%
% Michele Giugliano and Corrado Cali', 2006, EPFL - Lausanne.
%
%--------------------------------------------------------------------------
dt = (t(21) - t(20)) * 1e-3; % sampling interval in [s]..
ind_cut     = max(find(t <= Tdiscard));
ind_cut_sup = max(find(t <= (t(end)-Tdiscardsup)));
i_input     = in(ind_cut:ind_cut_sup);
o_output    = out(ind_cut:ind_cut_sup);
clear in;   % frees some memory..
clear out;  % frees some memory..
%clear t;    % frees some memory..
%--------------------------------------------------------------------------
i_input  = i_input    - mean(i_input);  % remove the DC offset..
o_output = o_output   - mean(o_output); % remove the DC offset..

Tstart   = t(ind_cut) * 1e-3;        % [s]
Tfinal   = t(ind_cut_sup) * 1e-3;    % [s]
time     = Tstart:dt:Tfinal';        % New time axis column..
N        = length(i_input);          % Total number of samples..
%h       = hamming(N);               % symmetric Hamming window (FFT)
h = 1.;
i_input = i_input.*h;               % windowing the input..
o_output= o_output.*h;              % windowing the output..
clear time;                         % frees some memory..
clear Tstart;                       % frees some memory..
clear Tfinal;                       % frees some memory..
%--------------------------------------------------------------------------
NN      = 2^nextpow2(N);            % Next power of 2, for the FFT..
omega   = 1./(NN*dt);               % Frequency sampling interval (Hz)
faxis   = omega*(0:NN-1)';          % Frequency axis column..
Yin     = fft(i_input);             % Evaluating the FFT of the input
Yout    = fft(o_output);            % Evaluating the FFT of the output
Yin(1)  = nan;                      % Remove again the DC component..
Yout(1) = nan;                      % Remove again the DC component..
M       = NN / 2;                   % The FFT has a symmetry, you know..
faxis   = faxis(1:(M+1));           % Construct the frequency axis..
%--------------------------------------------------------------------------
Mag_in  = abs(Yin(1:(M+1)));        % Evaluate the magnitude of the in
Mag_out = abs(Yout(1:(M+1)));       % Evaluate the magnitude of the out
%--------------------------------------------------------------------------
Phase_in  = angle(Yin(1:(M+1)));    % Evaluate the phase of the in [rad]
Phase_out = angle(Yout(1:(M+1)));   % Evaluate the phase of the out [rad]
Phase_in  = Phase_in * (360./(2*pi)); % Convert it to degrees
Phase_out = Phase_out* (360./(2*pi)); % Convert it to degrees
%--------------------------------------------------------------------------
TFmag     = Mag_out ./ Mag_in;      % By definition of trasfer funtion..
TFphase   = unwrap(mod(Phase_out-Phase_in, 360) - 360); % 



