function out = mycost(pars)
%
% Cost function for the ANNEAL nonlinear optimization (anneal.m).
% out = mycost(pars)
%
%   Copyright 2006 Michele Giugliano, PhD
%   $Revision: 1.00 $  $Date: 2006/12/12 19:35:29 $

%
% All what follows is problem-dependent..
%

%
% This is computing the magnitude of a complex rational polynomial function
% by accumulation and multiplications (e.g. F(s) = G * (s + so) * (s + s1):
% F = G, F = F * (s + so), F = F * (s + s1),...
%

global faxis    % solutions of the characteristic polynomial of a I/O
global TFmag      % relationship or eigenvalues of the system.
global freqs2fit; 

Np = length(pars) - 1; % Hypothesis choice for the number of 'poles', which are 

% Np      : number of transmission 'poles' of the system, 
% visible at high-frequency..
% faxis : frequency axis, to speed up the function evaluations..
% TFmag   : evaluation of the function across all the frequencies.

ffaxis = [freqs2fit];
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
G0  = pars(1);                % Gain/Attenuation - careful on the normalization!
p   = sort(pars(2:end));      % Poles are sorted for illustration purpouses only..
num = G0;                       % The accumulation begins.. (for the numerator)
den = 1;                        % The accumulation begins.. (for the numerator)

for ii = 1:Np                        % Let's accumulate,
    num = num * abs(p(ii));     % (normalization factor)..
    den = den .* (sqrt(-1).*ffaxis + p(ii)); % terms like (s + p_i) 
end

func = abs(num ./ den);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%for kk = 1:length(TFmag),                       % The cost is a measure
%%for kk =[(fix(0.5*length(TFmag))):length(TFmag)],  
%    err(kk) = (TFmag(kk) - func(kk)).^2;       % of the error and here
%end                                             % we chose the m.s.e.

%out = 1000000.*sqrt(norm(TFmag(2:end) - func(2:end)))/length(TFmag);    % (arbitrarily scaled)

%out = 1000000.*sqrt(sum(err))/length(TFmag);    % (arbitrarily scaled)

tmp = 0;
for kn=1:length(freqs2fit),
    tmq = find(faxis <= freqs2fit(kn));    
    tmq = tmq(end);
    tmp = tmp + (TFmag(tmq) - func(kn)).^2;
end

out = 10000.*sqrt(tmp)/length(freqs2fit);    
