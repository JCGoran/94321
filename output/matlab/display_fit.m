%
% DISPLAY-FIT
%
%
% Michele Giugliano and Corrado Cali', 2006, EPFL - Lausanne.
%
%--------------------------------------------------------------------------

global Np myfaxis myout;
global E_best p_best;

%--------------------------------------------------------------------------
myout2    = myout;              % Data analysed from the simulations..
myout2(1) = myout2(2);          % Data analysed from the simulations..

myout2 = out;

%--------------------------------------------------------------------------
G0  = p_best(1);        % Gain/Attenuation - careful on the normalization!
p   = sort(p_best(2:end));      % Poles..
num = G0;                % The accumulation begins.. (for the numerator)
den = 1;                 % The accumulation begins.. (for the numerator)
for ii = 1:Np                                   % Let's accumulate,
    num = num * abs(p(ii));                % (normalization factor)..
    %den = den .* (sqrt(-1).*myfaxis + p(ii)); % terms like (s+s_i).
    den = den .* (sqrt(-1).*faxis + p(ii)); % terms like (s+s_i).
end
func = num ./ den;                              % Definition
func2 = abs(func);                              % Just the magnitude.. 
%--------------------------------------------------------------------------

%func2     = 20.*log10(func2);
%myout2    = 20.*log10(myout2);
q         = p(find(p<=100));        % Let's take the 'good' ones only..
%--------------------------------------------------------------------------
figure(21); clf; hold on;
III = [1:2:20, 21:10:length(faxis)];
P1 = plot(faxis(III),myout2(III),'ks');
P2 = plot(faxis,func2, 'r');

cmd = 'legend(''Data'', ''Fit''';
for jj = 1:length(q)
 XX = q(jj); YY = min(find(faxis > XX));
 QQQ = plot(XX,func2(YY),'o'); set(QQQ, 'MarkerEdgeColor', [0 0 1], 'MarkerFaceColor', [0 0 1]);
 set(QQQ, 'MarkerSize', 10)
 cmd = sprintf('%s, ''{\\pi_%d = %.2f Hz}''',cmd, jj, q(jj));
end
 cmd = sprintf('%s, ''Location'', ''SouthWest'');',cmd);
 
set([P1 P2], 'LineWidth', 2);
xlabel('Frequency [Hz]', 'FontName', 'Arial', 'FontSize', 40);
ylabel('Gain', 'FontName', 'Arial', 'FontSize', 40);

TTT = title([pfname, ' - Fitting with ',num2str(length(q)),' poles; fit error : ',num2str(E_best)]);
set(TTT, 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', 'Arial', 'FontSize', 20, 'Box', 'on');
set(gca, 'XScale', 'log', 'YScale', 'log', 'XLim', [1 200]);
eval(cmd);

LABS = {};
LL = get(gca, 'XTick');
for iii=1:length(LL), LABS{iii} = num2str(LL(iii)); end
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', LABS)

LABS = {};
LL = get(gca, 'YTick');
for iii=1:length(LL), LABS{iii} = num2str(LL(iii)); end
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', LABS)
hold off

print(gcf, '-depsc2', '-zbuffer', sprintf('%s.eps',pfname))
print(gcf, '-dpng', '-zbuffer', sprintf('%s.png',pfname))

