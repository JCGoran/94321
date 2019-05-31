function model = displayfit_final(p_best, faxis, out)
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
III = [1:2:20, 21:10:length(faxis)];    % Downsampling of the model response
%III = 1:length(faxis);
P1  = plot(faxis(III), out(III), 'ks');  % data as black open squares
P2  = plot(faxis, func, 'r');            % model as a red continuous line
 
set(P1, 'Markersize', 5)
set([P1 P2], 'LineWidth', 2);
xlabel('{\omega / 2 \pi [Hz]}', 'FontName', 'Arial', 'FontSize', 25);
ylabel('Magnitude', 'FontName', 'Arial', 'FontSize', 25);

YLIM = get(gca, 'YLim');

%TTT = title([pfname, ' - Fitting with ',num2str(length(q)),' poles; fit error : ',num2str(E_best)]);
%set(TTT, 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', 'Arial', 'FontSize', 20, 'Box', 'on');
%set(gca, 'XScale', 'log', 'YScale', 'log', 'XLim', [1 150], 'YLim', [0.001 p_best(1)*1.4]);
set(gca, 'XScale', 'log', 'YScale', 'log', 'XLim', [1 500], 'YLim', [0.001 0.2+0.5]);

%------ (CUSTOM) LEGEND ---------------------------
cmd = 'legend(''{gap070809a2b : Z_{13}(j \omega)}'', ''Identification''';
for jj = 1:length(q),
 XX = q(jj); YY = min(find(faxis > XX));
 QQQ = plot(XX,func(YY),'d'); set(QQQ, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 1]);
 set(QQQ, 'MarkerSize', 18)
 cmd = sprintf('%s, ''{p_%d = %.2f Hz}''',cmd, jj, q(jj));
end
cmd = sprintf('%s, ''Location'', ''SouthWest'');',cmd);
eval(cmd);
%-------------------------------------------------------

LABS = {};
LL   = get(gca, 'XTick')
for iii=1:length(LL), LABS{iii} = num2str(LL(iii)); end
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', LABS)

LABS = {};
LL   = get(gca, 'YTick');
for iii=1:length(LL), LABS{iii} = num2str(LL(iii)); end
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', LABS)
hold off

 pfname = 'output';
 print(gcf, '-depsc2', '-loose', sprintf('%s.eps',pfname))
 print(gcf, '-dpng', '-loose', sprintf('%s.png',pfname))

