function model = displayfit(p_best, faxis, out)
% 
%   Routine to display fitting performances
%
%   Copyright 2007 Michele Giugliano, PhD
%   $Revision: 1.00 $  $Date: 2007/8/12 18:47:33 $
%
% p_best    : Go (gain), p1, p2, p3, .... (poles)
% faxis     : frequency axis [Hz]
% out       : data
% model     : model prediction
global freqs2fit;

pfname = '';

Np = length(p_best) - 1;    % number of poles..

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
G0  = p_best(1);                % Gain/Attenuation - careful on the normalization!
p   = sort(p_best(2:end));      % Poles are sorted for illustration purpouses only..
num = G0;                       % The accumulation begins.. (for the numerator)
den = 1;                        % The accumulation begins.. (for the numerator)

for ii = 1:Np                          % Let's accumulate,
    num = num * abs(p_best(1+ii));     % (normalization factor)..
    den = den .* (sqrt(-1).*faxis + p_best(1+ii)); % terms like (s + p_i)
end

func = abs(num ./ den);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%
% Now I plot and compare data and model predictions
% First I select which 'poles' are actually contributing, to be plotted.
%

q         = p(find(p<=800));        % Let's take the 'good' ones only..
%--------------------------------------------------------------------------
%figure(21); 
cla; hold on;
III = [1:2:20, 21:3:length(faxis)];    % Downsampling of the model response
%III = 1:length(faxis);
P1  = plot(faxis(III), out(III), 'ks');  % data as black open squares
P2  = plot(faxis, func, 'r');            % model as a red continuous line
 
set([P1 P2], 'LineWidth', 2);
xlabel('Frequency [Hz]', 'FontName', 'Arial', 'FontSize', 10);
ylabel('Gain', 'FontName', 'Arial', 'FontSize', 10);

%TTT = title([pfname, ' - Fitting with ',num2str(length(q)),' poles; fit error : ',num2str(E_best)]);
%set(TTT, 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', 'Arial', 'FontSize', 20, 'Box', 'on');
set(gca, 'XScale', 'log', 'YScale', 'log', 'XLim', [1 550]);

%------ (CUSTOM) LEGEND ---------------------------
cmd = 'legend(''Experiment'', ''Identification''';
for jj = 1:length(q),
 XX = q(jj); YY = min(find(faxis > XX));
 QQQ = plot(XX,func(YY),'d'); set(QQQ, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 1]);
 set(QQQ, 'MarkerSize', 18)
 cmd = sprintf('%s, ''{p_%d = %.2f Hz}''',cmd, jj, q(jj));
end
cmd = sprintf('%s, ''Location'', ''SouthWest'');',cmd);
eval(cmd);
%-------------------------------------------------------
YYLIM = get(gca, 'YLim');
for kn=1:length(freqs2fit),
 LL = line(freqs2fit(kn) * [1 1], YYLIM);
 set(LL, 'LineStyle', '-', 'Color', [1 0 0]);
end

% LABS = {};
% LL   = get(gca, 'XTick')
% for iii=1:length(LL), LABS{iii} = num2str(LL(iii)); end
% set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', LABS)
% 
% LABS = {};
% LL   = get(gca, 'YTick');
% for iii=1:length(LL), LABS{iii} = num2str(LL(iii)); end
% set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', LABS)
% hold off

% print(gcf, '-depsc2', '-zbuffer', sprintf('%s.eps',pfname))
% print(gcf, '-dpng', '-zbuffer', sprintf('%s.png',pfname))

