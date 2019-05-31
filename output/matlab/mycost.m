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

global Np         % Hypothesis choice for the number of 'poles', which are 
global myfaxis    % solutions of the characteristic polynomial of a I/O
global myout      % relationship or eigenvalues of the system.

% Np      : number of transmission 'poles' of the system, 
% visible at high-frequency..
% myfaxis : frequency axis, to speed up the function evaluations..
% myout   : evaluation of the function across all the frequencies.

G0 = pars(1);            % Gain/Attenuation - careful on the normalization!
num = G0;                % The accumulation begins.. (for the numerator)
den = 1;                 % The accumulation begins.. (for the numerator)

for ii = 1:Np                                   % Let's accumulate,
    num = num * abs(pars(ii+1));                % (normalization factor)..
    den = den .* (sqrt(-1).*myfaxis + pars(ii+1)); % each term like (s + s_i).
end
func = num ./ den;                              % Definition
func2 = abs(func);                              % Just the magnitude.. 
% hold on
% plot(abs(den))

for kk = 1:length(myout)                        % The cost is a measure
    err(kk) = (myout(kk) - func2(kk)).^2;       % of the error and here
end                                             % we chose the m.s.e.
out = 1000000.*sqrt(sum(err))/length(myout);    % (arbitrarily scaled)

%
%