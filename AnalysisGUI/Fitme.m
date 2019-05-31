function varargout = Fitme(varargin)
% FITME M-file for Fitme.fig
%      FITME, by itself, creates a new FITME or raises the existing
%      singleton*.
%
%      H = FITME returns the handle to a new FITME or the handle to
%      the existing singleton*.
%
%      FITME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITME.M with the given input arguments.
%
%      FITME('Property','Value',...) creates a new FITME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Fitme_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Fitme_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Fitme

% Last Modified by GUIDE v2.5 13-Aug-2007 11:58:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Fitme_OpeningFcn, ...
                   'gui_OutputFcn',  @Fitme_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Fitme is made visible.
function Fitme_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Fitme (see VARARGIN)

global faxis TFmag TFphase;
global p_best E_best;
global freqs2fit;
addpath ./matlab;
freqs2fit = [5 10 50 150 250 350 400 450 500 550];
if (isempty(p_best)), p_best = [0.2 10 20 30 40 50 60]; 
else
 set(handles.param, 'String', num2str(p_best));
end;
axes(handles.axes1);
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', 'Arial', 'FontSize', 10);
set(gca, 'XScale', 'log', 'YScale', 'log', 'XLim', [1 550],'Box', 'on');
set(handles.displaycost, 'String', sprintf('cost: ???'));
set(handles.freqs2fit, 'String', num2str(freqs2fit));

% Choose default command line output for Fitme
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Fitme wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Fitme_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in update.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global p_best;
global faxis TFmag TFphase;
axes(handles.axes1);
displayfit(p_best, faxis, TFmag);
set(handles.displaycost, 'String', sprintf('cost: %.5f', mycost(p_best)))
XXLIM = str2num(get(handles.xxlim, 'String'));
set(handles.axes1, 'XLim', XXLIM);

% --- Executes on button press in fit.
function fit_Callback(hObject, eventdata, handles)
% hObject    handle to fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global p_best E_best;
global faxis TFmag TFphase;

dp_max    = 10. * ones(size(p_best));
dp_max(1) = 0.01;

p_min = zeros(size(p_best)); 
p_min(1) = 0.00001;

p_max    = 5000. * ones(size(p_best)); 
p_max(1) = 1.;

iter = str2num(get(handles.iterations, 'String'));
pref = str2num(get(handles.stepsize, 'String'));
set(handles.displaycost, 'ForegroundColor', [1 0 0]);
pause(0.1);
[E_best p_best] = anneal(@mycost, p_best, pref * dp_max, p_min, p_max, iter);  
set(handles.displaycost, 'ForegroundColor', [0 0 0]);
set(handles.param, 'String', num2str(p_best));
axes(handles.axes1);
displayfit(p_best, faxis, TFmag);
set(handles.displaycost, 'String', sprintf('cost: %.5f', mycost(p_best)))
XXLIM = str2num(get(handles.xxlim, 'String'));
set(handles.axes1, 'XLim', XXLIM);


function param_Callback(hObject, eventdata, handles)
% hObject    handle to param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of param as text
%        str2double(get(hObject,'String')) returns contents of param as a double
global faxis TFmag TFphase;
global p_best;
p_best = str2num(get(handles.param, 'String'));
axes(handles.axes1);
displayfit(p_best, faxis, TFmag);
set(handles.displaycost, 'String', sprintf('cost: %.5f', mycost(p_best)))
XXLIM = str2num(get(handles.xxlim, 'String'));
set(handles.axes1, 'XLim', XXLIM);

% --- Executes during object creation, after setting all properties.
function param_CreateFcn(hObject, eventdata, handles)
% hObject    handle to param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global faxis TFmag TFphase;
[TFmag TFphase faxis] = loadme;
%close(gcf);


% --- Executes on button press in reverse.
function reverse_Callback(hObject, eventdata, handles)
% hObject    handle to reverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function xxlim_Callback(hObject, eventdata, handles)
% hObject    handle to xxlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xxlim as text
%        str2double(get(hObject,'String')) returns contents of xxlim as a double
global p_best;
global faxis TFmag TFphase;
axes(handles.axes1);
displayfit(p_best, faxis, TFmag);
set(handles.displaycost, 'String', sprintf('cost: %.5f', mycost(p_best)))
XXLIM = str2num(get(handles.xxlim, 'String'));
set(handles.axes1, 'XLim', XXLIM);



% --- Executes during object creation, after setting all properties.
function xxlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xxlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function freqs2fit_Callback(hObject, eventdata, handles)
% hObject    handle to freqs2fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqs2fit as text
%        str2double(get(hObject,'String')) returns contents of freqs2fit as a double

global freqs2fit;
global p_best;
global faxis TFmag TFphase;

freqs2fit = str2num(get(handles.freqs2fit, 'String'));

axes(handles.axes1);
displayfit(p_best, faxis, TFmag);
set(handles.displaycost, 'String', sprintf('cost: %.5f', mycost(p_best)))
XXLIM = str2num(get(handles.xxlim, 'String'));
set(handles.axes1, 'XLim', XXLIM);


% --- Executes during object creation, after setting all properties.
function freqs2fit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqs2fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function iterations_Callback(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iterations as text
%        str2double(get(hObject,'String')) returns contents of iterations as a double


% --- Executes during object creation, after setting all properties.
function iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function stepsize_Callback(hObject, eventdata, handles)
% hObject    handle to stepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepsize as text
%        str2double(get(hObject,'String')) returns contents of stepsize as a double


% --- Executes during object creation, after setting all properties.
function stepsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in print.
function print_Callback(hObject, eventdata, handles)
% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global p_best;
global faxis TFmag TFphase;
figure(1);
displayfit_final(p_best, faxis, TFmag);
set(handles.displaycost, 'String', sprintf('cost: %.5f', mycost(p_best)))
XXLIM = str2num(get(handles.xxlim, 'String'));
set(handles.axes1, 'XLim', XXLIM);


