function varargout = filterdesign(varargin)
% FILTERDESIGN Application M-file for filterdesign.fig
%    FIG = FILTERDESIGN launch filterdesign GUI.
%    FILTERDESIGN('callback_name', ...) invoke the named callback.
% --------------------------------------------------------------------
if nargin == 0  % LAUNCH GUI
    Ver = 'Filter Design 1.50';

    %---  Check the installation, the Matlab Version, and the Screen Size ---%
    errCmd = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
    cmdCheck1 = 'installcheck;';
    cmdCheck2 = 'MATLABVER = versioncheck(6.0);';
    cmdCheck3 = 'screensizecheck([800 600]);';
    cmdCheck4 = ['adjustpath(''' mfilename ''');'];
    cmdCheck5 = 'SPTcheck;';
    eval(cmdCheck1,errCmd);       % Simple installation check
    eval(cmdCheck2,errCmd);       % Check Matlab Version
    eval(cmdCheck3,errCmd);       % Check Screen Size
   % eval(cmdCheck4,errCmd);       % Adjust path if necessary
%    eval(cmdCheck5,errCmd);       % Check for Signal Proc. Toolbox

    fig = openfig(mfilename,'reuse');
    configresize(fig);            % Change all 'units'/'font units' to normalized
    % Re-center and normalalize figure
    % Assume that all figure objects are in "pixels" units
    op = get(fig,'pos');
    ss = get(0,'ScreenSize');
    set(fig,'pos',[(ss(3)-op(3))/2 (ss(4)-op(4))/2 op(3) op(4)]);
    set(findobj(fig,'units','pixels'),'units','norm');

    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'),'menubar','none');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);

    handles.old_Fsamp = get(handles.Fsamp,'String');        % storing old Fsamp value
    handles.old_Order = get(handles.Order,'String');        % storing old Order value
    handles.b = 0;                                          % storing old 'b' coefficients
    handles.a = 0;                                          % storing old 'a' coefficients
    handles.old_Rp = get(handles.Rpass,'String');           % storing old Rpass value
    handles.old_Rs = get(handles.Rstop,'String');           % storing old Rpass value
    handles.LineWidth = get(0,'defaultLineLineWidth');      % storing default Line Width   
    handles.fontname = get(handles.Plot1,'fontname');       
    handles.KaiserR = '';                                   % Rpass or Rstop indicator for Kaiser plotting
    
    % Suppress warnings:
    warning off MATLAB:nearlySingularMatrix;
    warning off MATLAB:divideByZero;
    warning('off','MATLAB:logofzero'); % does not work, need a substitute
    % --------------------------------------------------------------------
    % INITIALIZE GUI - Set Default Plot to Butterworth LPF
    % --------------------------------------------------------------------
    % Specify default filter type
    set(handles.Filter,'value',8);          % plot FIR filter
    set(handles.WindowsMenu,'value',4);     % plot Hamming window
       
    % Fix figure properties:
    set(fig,'WindowButtonMotionFcn',[mfilename ' WindowButtonMotion'], ...
        'Resize','default','Name',Ver,'DoubleBuffer','on');
    set(handles.Plot1,'nextplot','replacechildren','box','on','UIContextMenu',[]);
    set(get(handles.Plot1,'Xlabel'),'Units','normalized','position',[0.5 -0.1],'string','Frequency (Hz)');
    set(get(handles.Plot1,'Ylabel'),'Units','normalized','position',[-0.1 0.5],'string','Magnitude');   

    % Set Line properties
    handles.Line1a = line('parent',handles.Plot1,'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line1a');
    handles.Line1b = line('parent',handles.Plot1,'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line1b');
    handles.Line3  = line('parent',handles.Plot1,'EraseMode','Xor','ButtonDownFcn',[ mfilename  ' LineDragStart'],'Color','r','tag','Line3');

    handles.Line2  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line2','vis','off');
    handles.Line4a = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line4a','vis','off');
    handles.Line4b = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line4b','vis','off');
    handles.Line5a = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line5a','vis','off');
    handles.Line5b = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line5b','vis','off');
    handles.Line6  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'EraseMode','Xor','ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line6','vis','off');

    handles.LineCirc = line('parent',handles.Plot1,'xdata',cos(0:0.01:2*pi),'ydata',sin(0:0.01:2*pi),'linestyle',':','vis','off','color','b');
    handles.HorzLine = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle',':','color','b');
    handles.VertLine = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle',':','color','b');
    handles.PoleLine = line('parent',handles.Plot1,'xdata',0,'ydata',0,'vis','off','marker','x','markersize',12,'color','b');
    handles.WindowLine = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle',':');
    
    handles.LineMain  = line('parent',handles.Plot1,'Color','b');
	handles.LineGreen = line('parent',handles.Plot1,'Color','g');

    handles.TextPole = text('parent',handles.Plot1,'vis','off');

    [handles.LineStem1,handles.LineStem2] = stemdata(1,1,handles.Plot1);
    set([handles.LineStem1,handles.LineStem2,handles.WindowsMenu,handles.Windows, ...
        handles.AlphaTag,handles.alpha,handles.FilterMenu,handles.FiltType],'vis','off');
    set(handles.LineStem2,'markerfacecolor',[0 0 1]);
    
    % Run above specified filter
    Filter_Callback(handles.Filter,[],handles);
    handles = guidata(handles.figure1);
    % --------------------------------------------------------------------
    set(fig,'units','pixels');
    setappdata(fig,'Datastructure',handles);
    guidata(fig, handles);
    if nargout > 0
        varargout{1} = fig;
    end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end

end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
function handles = Filter_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
SetMenu(handles.Filter,handles);
if get(handles.Filter,'Value') < 8
    handles = PlotButton_Callback(handles.Filter, eventdata, handles, varargin);
    guidata(handles.figure1,handles);
end
% --------------------------------------------------------------------
function varargout = Fsamp_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%% CHECKING FOR ILLEGAL VALUES %%%%%%%%%%%%%%%%%%%%

%handles=getappdata(gcbf,'Datastructure');
filt_num=get(handles.Filter,'Value'); %%selecting which one of the filters is selected
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR','FIR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};    % get all values

%%This is for the FIR filter design menu
fir_num = get(handles.FilterMenu,'Value'); %%selecting which one of the filters is selected
names = {'LP','HP','BP','BR'};    % should appear in same order as pull down menu
fir_name = names{fir_num};    % get all values

if isempty(str2num(get(handles.Fsamp,'string')))
    errordlg('Fsamp cannot be empty!!')
    set(handles.Fsamp,'String',handles.old_Fsamp)
end

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale] = user(handles);
error = 1;                                                % variable to check for error

switch filt_name
    case {'ButterLP','ButterHP','KaiserLP'},
        if fs>2*max([f1,f2]),
            error = 0;
        else
            set(handles.Fsamp,'String',handles.old_Fsamp);
        end
    case {'ButterBP','ButterBR','KaiserBP','KaiserBR'}
        if fs > 2*max([f1,f2,f3,f4]),
            error = 0;
        else
            set(handles.Fsamp,'String',handles.old_Fsamp);
        end
    case 'FIR'
        switch fir_name
            case {'LP','HP'}
                if fs > 2*f1,
                    error = 0;
                else
                    set(handles.Fsamp,'String',handles.old_Fsamp);
                end
            case {'BP','BR'}
                if fs>2*max([f1,f3]),
                    error = 0;
                else
                    set(handles.Fsamp,'String',handles.old_Fsamp);
                end
        end
end

if error == 0,
    if (get(handles.Filter,'Value')<8)
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        handles = PlotGraph(handles);
    end
    handles.old_Fsamp=num2str(fs);                          % store new value
else
    if (get(handles.Filter,'Value')<8)
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        handles = PlotGraph(handles);
    end
    errordlg('Fsamp should be greater than twice the maximum frequency in filter constraints','ERROR');
end

guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Fpass1_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%% CHECKING FOR ILLEGAL VALUES %%%%%%%%%%%%%%%%%%%%

% handles=getappdata(gcbf,'Datastructure');   %%change to be done or not
filt_num=get(handles.Filter,'Value');
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR','FIR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};  % get all values

Line1aXData=get(handles.Line1a,'XData');                  % find line data
Line4aXData=get(handles.Line4a,'XData');                  % find line data

if isempty(str2num(get(handles.Fpass1,'string')))
    errordlg('Fpass1 cannot be empty!!')
    set(handles.Fpass1,'String',num2str(Line1aXData(2)))
end

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale] = user(handles);


error=1;                                                % variable to check for error

fir_num=get(handles.FilterMenu,'Value');

switch filt_name
    case {'ButterLP','KaiserLP'},
        if f1>0 & f1<f2,
            error = 0;                % no error
        else
            set(handles.Fpass1,'String',num2str(Line1aXData(2)));
            errordlg('0 < Fpass < Fstop');
        end
    case 'ButterHP',
        if f1>f2 & f1<fs/2
            error = 0;
        else
            set(handles.Fpass1,'String',num2str(Line1aXData(1)));
            errordlg('Fstop < Fpass < Fsamp/2');
        end
    case {'ButterBP','KaiserBP'}
        if f1<f3 & f1>f2,
            error = 0;
        else
            set(handles.Fpass1,'String',num2str(Line1aXData(1)));
            errordlg('Fstop1 < Fpass1 < Fpass2');
        end
    case {'ButterBR','KaiserBR'}
        if f1<f2 & f1>0,
            error = 0;
        else
            set(handles.Fpass1,'String',num2str(Line4aXData(2)));
            errordlg('0 < Fpass1 < Fstop1');
        end
    case {'FIR'}
        %         handles.Line1aXData=get(handles.Line1a,'xdata');
        switch fir_num
            case {1,2}
                if (f1>0 & f1<fs/2)
                    error=0;
                    handles.oldfpass1=get(handles.Fpass1,'string');
                else
                    errordlg('0<Fcutoff<Fsamp/2');
                    set(handles.Fpass1,'String',handles.oldfpass1);
                end
            case {3,4}
                if (f1>0 & f1<f3)
                    error=0;
                    handles.oldfpass1=get(handles.Fpass1,'string');
                else
                    errordlg('0<Fcutoff1 < Fcutoff2');
                    set(handles.Fpass1,'String',handles.oldfpass1);
                end
        end
end

if error == 0
    if (get(handles.Filter,'Value')<8)
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        handles = PlotGraph(handles);
    end
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Fpass2_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%% CHECKING FOR ILLEGAL VALUES %%%%%%%%%%%%%%%%%%%%

% handles=getappdata(gcbf,'Datastructure');
filt_num=get(handles.Filter,'Value');
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR','FIR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};  % get all values

Line1aXData=get(handles.Line1a,'XData');                  % find line data
Line5aXData=get(handles.Line5a,'XData');                  % find line data
Line3XData=get(handles.Line3,'XData');

if isempty(str2num(get(handles.Fpass2,'string')))
    errordlg('Fpass2 cannot be empty!!');
    set(handles.Fpass2,'String',num2str(Line1aXData(2)));
end

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale] = user(handles);
error=1;                                                % variable to check for error

fir_num=get(handles.FilterMenu,'Value');

switch filt_name
    case {'ButterBP','KaiserBP'}
        if f3>f1 & f3<f4,
            error=0;
        else
            set(handles.Fpass2,'String',num2str(Line1aXData(2)));
            errordlg('Fpass1 < Fpass2 < Fstop2');
        end
    case {'ButterBR','KaiserBR'}
        if f3>f4 & f3<fs/2,
            error=0;
        else
            set(handles.Fpass2,'String',num2str(Line5aXData(1)));
            errordlg('Fstop2 < Fpass2 < Fsamp/2');
        end
    case {'FIR'}
        switch fir_num
            case {3,4}
                if (f3>f1 & f3<fs/2)
                    error=0;
                    handles.oldfpass2=get(handles.Fpass2,'string');
                else
                    errordlg('Fcutoff1 < Fcutoff2<Fsamp/2');
                    set(handles.Fpass2,'String',handles.oldfpass2);
                end
            otherwise
        end
end

if error==0
    if (get(handles.Filter,'Value')<8)
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        handles = PlotGraph(handles);
    end
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Fstop1_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%% CHECKING FOR ILLEGAL VALUES %%%%%%%%%%%%%%%%%%%%

handles=getappdata(gcbf,'Datastructure');
filt_num=get(handles.Filter,'Value');
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};  % get all values

Line2XData=get(handles.Line2,'XData');                  % find line2 data
Line3XData=get(handles.Line3,'XData');                  % find line3 data
Line6XData=get(handles.Line6,'XData');                  % find line data

if isempty(str2num(get(handles.Fstop1,'string')))
    errordlg('Fstop1 cannot be empty!!');
    set(handles.Fstop1,'String',num2str(Line3XData(1)));
end

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale] = user(handles);
error=1;                                                % variable to check for error

switch filt_name
    case {'ButterLP','KaiserLP'},
        if f2<fs/2 & f2>f1,
            error=0;
        else
            set(handles.Fstop1,'String',num2str(Line3XData(1)));
            errordlg('Fpass < Fstop < Fsamp/2');
        end
    case 'ButterHP',
        if f2>0 & f2<f1,
            error=0;
        else
            set(handles.Fstop1,'String',num2str(Line2XData(2)));
            errordlg('0 < Fstop < Fpass');
        end
    case {'ButterBP','KaiserBP'}
        if f2>0 & f2<f1,
            error=0;
        else
            set(handles.Fstop1,'String',num2str(Line2XData(2)));
            errordlg('0 < Fstop1 < Fpass1');
        end
    case {'ButterBR','KaiserBR'}
        if f2>f1 & f2<f4,
            error=0;
        else
            set(handles.Fstop1,'String',num2str(Line6XData(1)));
            errordlg('Fpass1 < Fstop1 < Fstop2');
        end
end

if error==0,
    handles = PlotButton_Callback(h, eventdata, handles, varargin);
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Fstop2_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%% CHECKING FOR ILLEGAL VALUES %%%%%%%%%%%%%%%%%%%%

handles=getappdata(gcbf,'Datastructure');
filt_num=get(handles.Filter,'Value');
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};  % get all values

Line2XData=get(handles.Line2,'XData');                  % find line2 data
Line3XData=get(handles.Line3,'XData');                  % find line3 data
Line6XData=get(handles.Line6,'XData');                  % find line data

if isempty(str2num(get(handles.Fstop2,'string')))
    errordlg('Fstop2 cannot be empty!!');
    set(handles.Fstop2,'String',num2str(Line3XData(1)));
end

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale] = user(handles);

error=1;                                                % variable to check for error

switch filt_name
    case {'ButterBP','KaiserBP'}
        if f4>f3 & f4<fs/2,
            error=0;
        else
            set(handles.Fstop2,'String',num2str(Line3XData(1)));
            errordlg('Fpass2 < Fstop2 < Fsamp/2');
        end
    case {'ButterBR','KaiserBR'}
        if f4>f2 & f4<f3,
            error=0;
        else
            set(handles.Fstop2,'String',num2str(Line6XData(2)));
            errordlg('Fstop1 < Fstop2 < Fpass2');
        end
end

if error==0,
    handles = PlotButton_Callback(h, eventdata, handles, varargin);
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Rpass_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
Rp = str2num(get(handles.Rpass,'String'));              % obtain current Rpass value

if isempty(str2num(get(handles.Rpass,'string')))
    errordlg('Rpass cannot be empty!!');
    set(handles.Rpass,'String',num2str(handles.old_Rp));
end

if strcmp(get(handles.menu_y_scale,'checked'),'on') %mag in dB
    if Rp < 0 & Rp > 20*log10(0.5)                 % check for constraints
        handles.old_Rp = Rp;
        handles.KaiserR = 'Rpass';
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        set(handles.Rpass,'String',num2str(handles.old_Rp));
        errordlg('-6 dB < Rpass < 0 dB');
    end
else
    if Rp < 0.5 & Rp > 0                                    % check for constraints
        handles.old_Rp = Rp;
        handles.KaiserR = 'Rpass';
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        set(handles.Rpass,'String',num2str(handles.old_Rp));
        errordlg('0 < Rpass < 0.5');
    end
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Rstop_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
Rs = str2num(get(handles.Rstop,'String'));

if isempty(str2num(get(handles.Rstop,'string')))
    errordlg('Rstop cannot be empty!!');
    set(handles.Rstop,'String',num2str(handles.old_Rs));
end

if strcmp(get(handles.menu_y_scale,'checked'),'on') %mag in dB
    if Rs < -6 & Rs > -60                                    % check for constraints
        handles.old_Rs = Rs;
        handles.KaiserR = 'Rstop';
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        set(handles.Rstop,'String',num2str(handles.old_Rs));
        errordlg('-60 dB < Rstop < -6 dB');
    end
else
    if Rs < 0.5 & Rs > 0                                    % check for constraints
        handles.old_Rs=Rs;
        handles.KaiserR = 'Rstop';
        handles = PlotButton_Callback(h, eventdata, handles, varargin);
    else
        set(handles.Rstop,'String',num2str(handles.old_Rs));
        errordlg('0 < Rstop < 0.5');
    end
end

guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = Order_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
filt_num=get(handles.Filter,'Value');
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR','FIR'};   % should appear in same order as pull down menu
filt_name=names{filt_num};

%%This is for the order of FIR filters
fir_num=get(handles.FilterMenu,'Value'); %%selecting which one of the filters is selected
names={'LP','HP','BP','BR'};    % should appear in same order as pull down menu
fir_name=names{fir_num};    % get all values

if isempty(str2num(get(handles.Order,'string')))
    errordlg('Order cannot be empty!!');
    set(handles.Order,'String',num2str(handles.old_Order));
end
ord=str2num(get(handles.Order,'String'));


error = 1;                  % error variable

if ord <= 0,
    switch filt_name
        case {'ButterBP','KaiserBP'}                       % for BPF, need to check whether order is even
            if mod(handles.old_Order,2)~=0
                set(handles.Order,'String',num2str(str2num(handles.old_Order)+1));
            else
                set(handles.Order,'String',handles.old_Order);
            end
        otherwise                                           % all other filters
            set(handles.Order,'String',handles.old_Order);
    end
    handles = PlotButton_Callback(h, eventdata, handles, varargin);
    errordlg('Order must be positive');
else
    switch filt_name
        case {'ButterLP','ButterHP','KaiserLP','KaiserBP'}
            if mod(ord,1)==0,       % order is an integer
                error=0;
                handles = PlotButton_Callback(h, eventdata, handles, varargin);
            else
                set(handles.Order,'String',num2str(ceil(ord)));
                handles = PlotButton_Callback(h, eventdata, handles, varargin);
                errordlg('Order must be an Integer');
            end
        case {'ButterBP','ButterBR'}
            if mod(ord,2)==0,       % order is an even integer
                error=0;
                handles = PlotButton_Callback(h, eventdata, handles, varargin);
            else
                new_ord=ceil(ord);                          % use ceiling function to remove fractional part
                if mod(new_ord,2)~=0,
                    new_ord=new_ord+1;
                end
                set(handles.Order,'String',num2str(ceil(new_ord)));
                handles = PlotButton_Callback(h, eventdata, handles, varargin);
                errordlg('Order must be an even Integer');
            end
        case 'KaiserBR'
            if mod(ord,2)==1,       % order is an odd integer
                error=0;
                handles = PlotButton_Callback(h, eventdata, handles, varargin);
            else
                new_ord=ceil(ord);                          % use ceiling function to remove fractional part
                if mod(new_ord,2)~=1,
                    new_ord=new_ord+1;
                end
                set(handles.Order,'String',num2str(ceil(new_ord)));
                handles = PlotButton_Callback(h, eventdata, handles, varargin);
                errordlg('Order must be an Odd Integer');
            end
        case 'FIR'
            handles = PlotGraph(handles);
    end
end

ord = str2num(get(handles.Order,'String'));
handles.old_Order = num2str(ord);            % store new value
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function handles = PlotButton_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% generates the plot
filt_num = get(handles.Filter,'Value');
names = {'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR','FIR'};  % should appear in same order as pull down menu
filt_name = names{filt_num};

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,W1,W2,W3,W4] = user(handles); % get user values

if order_type == 1                          % if auto order
    Wc1 = (W1+W2)/2;                        % use mean of passband edge and stopband edge for first critical frequency
    Wc2 = (W3+W4)/2;                        % use mean of passband edge and stopband edge for second critical frequency
    switch filt_name
        case 'ButterLP'                        % if lowpass
            N = ceil(log10(((1/Rs)^2-1)/((1/(1-Rp))^2-1))/(2*log10(tan(W2*pi/2)/tan(W1*pi/2))));    % formula for order estimation (pg 455 in DTSP)
            [B,A] = butterworth(N,W1,Rp);
            [h,w] = freekz(B,A,512);                   % determine frequency response
            max_h = max(abs(h));
            h = h/max_h;
%%%            [handles.b,handles.a] = invfreqz(h,w,N,N);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.Order,'String',num2str(N));
            set(handles.PlotTitle, 'String', ['Butterworth Lowpass Filter of Order ' num2str(N)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % x/yscale can be either 1 or 2
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f2 fs/2]*(2-xscale) + [W2 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line3,'xdata', xdata2,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
            set([handles.Line2,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'ButterHP'                % if highpass

            [theta,omega]=hp_mapping(W1*pi);
            theta_p=(1-W1);
            theta_s=theta(floor(W2*pi*100+1))/pi;
            N = ceil(log10(((1/Rs)^2-1)/((1/(1-Rp))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));    % formula for order estimation (pg 455 in DTSP) modified for HPF
            [b,a]=butterworth(N,theta_p,Rp);
            %[b,a]=butterworth(N,W1,Rp);
            alpha=-cos((theta_p+W1)*pi/2)/cos((theta_p-W1)*pi/2);
            %alpha=-cos((W1+W1)*pi/2)/cos((W1-W1)*pi/2);
            flip_b=fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a=fliplr(a);						% they need to be flipped around for computation
            roots_b=roots(flip_b);
            roots_a=roots(flip_a);
            for i=1:length(roots_b),
                roots_B(i)=-(roots_b(i)+alpha)/(roots_b(i)*alpha+1);		%mapping
                roots_A(i)=-(roots_a(i)+alpha)/(roots_a(i)*alpha+1);		%mapping
            end
            flip_B=poly(roots_B);
            flip_A=poly(roots_A);
            A=fliplr(flip_A);
            B=fliplr(flip_B);
            %             handles.a=A;
            %             handles.b=B;
            [h,w]=freekz(B,A,512);                   % determine frequency response
            max_h=max(abs(h));
            h=h/max_h;
%%            [handles.b,handles.a] = invfreqz(h,w,N,N);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.Order,'String',num2str(N));
            set(handles.PlotTitle, 'String', ['Butterworth Highpass Filter of Order ' num2str(N)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [f1 fs/2]*(2-xscale) + [W1 1]*(xscale-1);
            xdata2 = [0 f2]*(2-xscale) + [0 W2]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line2],'visible','on');
            set([handles.Line3,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'ButterBP'               % if bandpass
            theta_p=W3-W1;          %   added

            [theta,omega]=bp_mapping(W1*pi,W3*pi);          % obtain the maping between theta and omega
            theta_s1=theta(floor(W2*pi*100+1))/pi;          % obtain particular theta values that map to particular stop band frequencies
            theta_s2=theta(floor(W4*pi*100+1))/pi;
            theta_s=min([theta_s1 theta_s2]);               % smaller value of theta should be used as stop band frequency for original filter

            %             if abs(W1-W2)>abs(W3-W4)
            %                 theta_s=theta_p+2*(W4-W3);
            %             else
            %                 theta_s=theta_p+2*(W1-W2);
            %             end

            N = ceil(log10(((1/Rs)^2-1)/((1/(1-Rp))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));          %   added
            [b,a]=butterworth(N,theta_p,Rp);        % find butterworth filter coefficients
            alpha=cos((W3+W1)*pi/2)/cos((W3-W1)*pi/2);  % find constants
            k=cot((W3-W1)*pi/2)*tan(theta_p*pi/2);
            flip_b=fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a=fliplr(a);						% they need to be flipped around for computation
            roots_b=roots(flip_b);
            roots_a=roots(flip_a);
            C1=2*alpha*k/(k+1);					% constants for mapping
            C2=(k-1)/(k+1);
            for i=1:length(roots_b),			% calculations from old Oppenheim & Schafer pg 434
                ba=1+roots_b(i)*C2;
                aa=1+roots_a(i)*C2;
                bb=-(C1+roots_b(i)*C1);
                ab=-(C1+roots_a(i)*C1);
                bc=roots_b(i)+C2;
                ac=roots_a(i)+C2;
                roots_B(2*i)=(-bb+sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_B(2*i-1)=(-bb-sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_A(2*i)=(-ab+sqrt(ab^2-4*aa*ac))/(2*aa);
                roots_A(2*i-1)=(-ab-sqrt(ab^2-4*aa*ac))/(2*aa);
            end
            flip_B=poly(roots_B);
            flip_A=poly(roots_A);
            A=fliplr(flip_A);
            B=fliplr(flip_B);
            %             handles.a=A;
            %             handles.b=B;
            [h,w]=freekz(B,A,512);                   % determine frequency response
            max_h=max(abs(h));
            h=h/max_h;
%%            [handles.b,handles.a] = invfreqz(h,w,2*N,2*N);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.Order,'String',num2str(2*N));
            set(handles.PlotTitle, 'String', ['Butterworth Bandpass Filter of Order ' num2str(2*N)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [f1 f3]*(2-xscale) + [W1 W3]*(xscale-1);
            xdata2 = [0 f2]*(2-xscale) + [0 W2]*(xscale-1);
            xdata3 = [f4 fs/2]*(2-xscale) + [W4 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);
            set(handles.Line3,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','on');
            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
       
        case 'ButterBR'
            
            theta_p=(W3-W1);          %   added

            [theta,omega]=br_mapping(W1*pi,W3*pi);          % obtain the maping between theta and omega
            theta_s1=theta(floor(W2*pi*100+1))/pi;          % obtain particular theta values that map to particular stop band frequencies
            theta_s2=theta(floor(W4*pi*100+1))/pi;
            theta_s=min([theta_s1 theta_s2]);               % smaller value of theta should be used as stop band frequency for original filter

            N = ceil(log10(((1/Rs)^2-1)/((1/(1-Rp))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));          %   added
            [b,a]=butterworth(N,theta_p,Rp);        % find butterworth filter coefficients
            alpha=cos((W3+W1)*pi/2)/cos((W3-W1)*pi/2);  % find constants
            k=tan((W3-W1)*pi/2)*tan(theta_p*pi/2);
            flip_b=fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a=fliplr(a);						% they need to be flipped around for computation
            roots_b=roots(flip_b);
            roots_a=roots(flip_a);
            C1=2*alpha/(k+1);					% constants for mapping
            C2=(1-k)/(k+1);
            for i=1:length(roots_b),			% calculations from old Oppenheim & Schafer pg 434
                ba=1-roots_b(i)*C2;
                aa=1-roots_a(i)*C2;
                bb=roots_b(i)*C1-C1;
                ab=roots_a(i)*C1-C1;
                bc=C2-roots_b(i);
                ac=C2-roots_a(i);
                roots_B(2*i)=(-bb+sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_B(2*i-1)=(-bb-sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_A(2*i)=(-ab+sqrt(ab^2-4*aa*ac))/(2*aa);
                roots_A(2*i-1)=(-ab-sqrt(ab^2-4*aa*ac))/(2*aa);
            end
            flip_B=poly(roots_B);
            flip_A=poly(roots_A);
            A=fliplr(flip_A);
            B=fliplr(flip_B);
            [h,w]=freekz(B,A,512);                   % determine frequency response
            max_h=max(abs(h));
            h=h/max_h;
            %h=1-abs(h);                         % invert to get band reject
%%            [handles.b,handles.a] = invfreqz(h,w,2*N,2*N);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.Order,'String',num2str(2*N));
            set(handles.PlotTitle, 'String', ['Butterworth Bandreject Filter of Order ' num2str(2*N)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f3 fs/2]*(2-xscale) + [W3 1]*(xscale-1);
            xdata3 = [f2 f4]*(2-xscale) + [W2 W4]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line4a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line4b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line5a,'xdata', xdata2,'ydata',ydata1);
            set(handles.Line5b,'xdata', xdata2,'ydata',ydata2);
            set(handles.Line6,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','on');
            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','off');

        case 'KaiserLP'                   % if window
            % for formulae, refer to pg 474 in Oppenheim & Schafer book

            if strcmp('Rpass',handles.KaiserR)
                delta = Rp;
            elseif strcmp('Rstop',handles.KaiserR)
                delta = Rs;
            else
                delta = min(Rs,Rp);
            end

            % fix to max delta such that Kaiser evaluates
            A=-20*log10(delta);
            if A < 8
                delta = 0.398;
                A=-20*log10(delta);
            end

            M=ceil((A-8)/(2.285*abs(W1-W2)*pi));
            alpha=M/2;
            if A>50
                beta=0.1102*(A-8.7);
            elseif A<21
                beta=0;
            else
                beta=0.5842*(A-21)^.4 + 0.07886*(A-21);
            end
            for n=0:M,
                x(n+1)=besseli(0,beta*(1-((n-alpha)/alpha)^2)^.5)/besseli(0,beta);
                if n~=alpha,
                    s(n+1)=sin(Wc1*pi*(n-alpha))/(pi*(n-alpha));
                else
                    s(n+1)=Wc1;
                end
            end
            f=s.*x;

            handles.b=f;
            handles.a=1;
            h=fft(f,1024);                       % determine frequency response (512pt FFT)
            h=h(1:512);                         % need only half due to symmetry
            w=(0:511)/512*pi;
%%            [handles.b,handles.a] = invfreqz(h,w,M+1,1);          % save coefficients
            set(handles.Order,'String',num2str(M+1));
            set(handles.PlotTitle, 'String', ['Lowpass Kaiser Window Filter of Order ' num2str(M+1)]);

            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % see L870 for definition of delta
            Rp = delta;
            Rs = delta;

            % update Rpass/Rstop
            if (yscale - 1) % mag in dB
                set(handles.Rpass,'String',20*log10(1-delta));
                set(handles.Rstop,'String',-A);
            else
                set([handles.Rpass,handles.Rstop],'String',delta);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f2 fs/2]*(2-xscale) + [W2 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line3,'xdata', xdata2,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
            set([handles.Line2,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'KaiserBP'                   % if window
            % for formulae, refer to pg 474 in Oppenheim & Schafer book

            if strcmp('Rpass',handles.KaiserR)
                delta = Rp;
            elseif strcmp('Rstop',handles.KaiserR)
                delta = Rs;
            else
                delta = min(Rs,Rp);
            end

            % fix to max delta such that Kaiser evaluates
            A=-20*log10(delta);
            if A < 8
                delta = 0.398;
                A=-20*log10(delta);
            end

            A=-20*log10(delta);
            M=ceil((A-8)/(2.285*min([abs(W1-W2),abs(W3-W4)])*pi));
            alpha=M/2;
            if A>50
                beta=0.1102*(A-8.7);
            elseif A<21
                beta=0;
            else
                beta=0.5842*(A-21)^.4 + 0.07886*(A-21);
            end
            for n=0:M,
                x(n+1)=besseli(0,beta*(1-((n-alpha)/alpha)^2)^.5)/besseli(0,beta);
                if n~=alpha,
                    s(n+1)=-sin(Wc1*pi*(n-alpha))/(pi*(n-alpha))+sin(Wc2*pi*(n-alpha))/(pi*(n-alpha));   % formula on pg 482 in Oppenheim/Schafer book
                else
                    s(n+1)=-Wc1+Wc2;
                end
            end
            f=s.*x;
            handles.b=f;
            handles.a=1;
            h=fft(f,1024);      % determine frequency response (512pt FFT)
            h=h(1:512);         % need only half due to symmetry
            w=(0:511)/512*pi;
%%            [handles.b,handles.a] = invfreqz(h,w,M+1,1);          % save coefficients
            set(handles.Order,'String',num2str(M+1));
            set(handles.PlotTitle, 'String', ['Bandpass Kaiser Window Filter of Order ' num2str(M+1)]);

            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %minimum = min(Rp,Rs);
            Rp = delta;
            Rs = delta;

            % update Rpass/Rstop
            if (yscale - 1) % mag in dB
                set(handles.Rpass,'String',20*log10(1-delta));
                set(handles.Rstop,'String',-A);
            else
                set([handles.Rpass,handles.Rstop],'String',delta);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            xdata1 = [f1 f3]*(2-xscale) + [W1 W3]*(xscale-1);
            xdata2 = [0 f2]*(2-xscale) + [0 W2]*(xscale-1);
            xdata3 = [f4 fs/2]*(2-xscale) + [W4 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);
            set(handles.Line3,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','on');
            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'KaiserBR'                   % if KaiserBR
            % for formulae, refer to pg 474 in Oppenheim & Schafer book

            if strcmp('Rpass',handles.KaiserR)
                delta = Rp;
            elseif strcmp('Rstop',handles.KaiserR)
                delta = Rs;
            else
                delta = min(Rs,Rp);
            end

            A=-20*log10(delta);
            M=ceil((A-8)/(2.285*min([abs(W1-W2),abs(W3-W4)])*pi));
            if mod(M,2)~=0                  % make sure M is even (order is odd)
                M=M+1;
            end
            alpha=M/2;
            if A>50
                beta=0.1102*(A-8.7);
            elseif A<21
                beta=0;
            else
                beta=0.5842*(A-21)^.4 + 0.07886*(A-21);
            end
            for n=0:M,
                x(n+1)=besseli(0,beta*(1-((n-alpha)/alpha)^2)^.5)/besseli(0,beta);
                if n~=alpha,
                    s(n+1)=sin(Wc1*pi*(n-alpha))/(pi*(n-alpha))-sin(Wc2*pi*(n-alpha))/(pi*(n-alpha))+sin(pi*(n-alpha))/(pi*(n-alpha));   % formula on pg 482 in Oppenheim/Schafer book
                else
                    s(n+1)=Wc1-Wc2+1;
                end
            end
            f=s.*x;
            handles.b=f;
            handles.a=1;
            h=fft(f,1024);  % determine frequency response (512pt FFT)
            h=h(1:512);     % need only half due to symmetry
            w=(0:511)/512*pi;
%%            [handles.b,handles.a] = invfreqz(h,w,M+1,1);          % save coefficients
            set(handles.Order,'String',num2str(M+1));
            set(handles.PlotTitle, 'String', ['Bandreject Kaiser Window Filter of Order ' num2str(M+1)]);

            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %minimum=min(Rp,Rs);
            Rp=delta;
            Rs=delta;

            % update Rpass/Rstop
            if (yscale - 1) % mag in dB
                set(handles.Rpass,'String',20*log10(1-delta));
                set(handles.Rstop,'String',-A);
            else
                set([handles.Rpass,handles.Rstop],'String',delta);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f3 fs/2]*(2-xscale) + [W3 1]*(xscale-1);
            xdata3 = [f2 f4]*(2-xscale) + [W2 W4]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line4a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line4b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line5a,'xdata', xdata2,'ydata',ydata1);
            set(handles.Line5b,'xdata', xdata2,'ydata',ydata2);
            set(handles.Line6,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','on');
            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','off');
    end
else                                % if order is MANUALLY set
    Wc1 = (W1+W2)/2;                        % use mean of passband edge and stopband edge for first critical frequency
    Wc2 = (W3+W4)/2;                        % use mean of passband edge and stopband edge for second critical frequency
    switch filt_name
        case 'ButterLP'
            [B,A] = butterworth(ord,W1,Rp);
            [h,w]=freekz(B,A,512);                   % determine frequency response
            max_h=max(abs(h));
            h=h/max_h;
%%            [handles.b,handles.a] = invfreqz(h,w,ord,ord);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.PlotTitle, 'String', ['Butterworth Lowpass Filter of Order ' num2str(ord)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f2 fs/2]*(2-xscale) + [W2 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line3,'xdata', xdata2,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
            set([handles.Line2,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'ButterHP'

            theta_p=(1-W1);
            [b,a]=butterworth(ord,theta_p,Rp);
            alpha=-cos((theta_p+W1)*pi/2)/cos((theta_p-W1)*pi/2);
            %             [b,a]=butterworth(ord,W1,Rp);
            %             alpha=-cos((W1+W1)*pi/2)/cos((W1-W1)*pi/2);
            flip_b=fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a=fliplr(a);						% they need to be flipped around for computation
            roots_b=roots(flip_b);
            roots_a=roots(flip_a);
            for i=1:length(roots_b),
                roots_B(i)=-(roots_b(i)+alpha)/(roots_b(i)*alpha+1);		%mapping
                roots_A(i)=-(roots_a(i)+alpha)/(roots_a(i)*alpha+1);		%mapping
            end
            flip_B=poly(roots_B);
            flip_A=poly(roots_A);
            A=fliplr(flip_A);
            B=fliplr(flip_B);
            max_h=max(abs(h));
            h=h/max_h;
%%            [handles.b,handles.a] = invfreqz(h,w,ord,ord);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.PlotTitle, 'String', ['Butterworth Highpass Filter of Order ' num2str(ord)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            xdata1 = [f1 fs/2]*(2-xscale) + [W1 1]*(xscale-1);
            xdata2 = [0 f2]*(2-xscale) + [0 W2]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line2],'visible','on');
            set([handles.Line3,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'ButterBP'

            theta_p=W3-W1;          %   added
            [b,a]=butterworth(ord/2,theta_p,Rp);        % find butterworth filter coefficients
            alpha=cos((W3+W1)*pi/2)/cos((W3-W1)*pi/2);  % find constants
            k=cot((W3-W1)*pi/2)*tan(theta_p*pi/2);

            %             [b,a]=butterworth(ord/2,W1,Rp);
            %             alpha=cos((W3+W1)*pi/2)/cos((W3-W1)*pi/2);
            %             k=cot((W3-W1)*pi/2)*tan(W1*pi/2);
            flip_b=fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a=fliplr(a);						% they need to be flipped around for computation
            roots_b=roots(flip_b);
            roots_a=roots(flip_a);
            C1=2*alpha*k/(k+1);					% constants for mapping
            C2=(k-1)/(k+1);
            for i=1:length(roots_b),			% calculations from old Oppenheim & Schafer pg 434
                ba=1+roots_b(i)*C2;
                aa=1+roots_a(i)*C2;
                bb=-(C1+roots_b(i)*C1);
                ab=-(C1+roots_a(i)*C1);
                bc=roots_b(i)+C2;
                ac=roots_a(i)+C2;
                roots_B(2*i)=(-bb+sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_B(2*i-1)=(-bb-sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_A(2*i)=(-ab+sqrt(ab^2-4*aa*ac))/(2*aa);
                roots_A(2*i-1)=(-ab-sqrt(ab^2-4*aa*ac))/(2*aa);
            end
            flip_B=poly(roots_B);
            flip_A=poly(roots_A);
            A=fliplr(flip_A);
            B=fliplr(flip_B);
            [h,w]=freekz(B,A,512);                   % determine frequency response
            max_h=max(abs(h));
            h=h/max_h;
%%            [handles.b,handles.a] = invfreqz(h,w,ord,ord);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.PlotTitle, 'String', ['Butterworth Bandpass Filter of Order ' num2str(ord)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [f1 f3]*(2-xscale) + [W1 W3]*(xscale-1);
            xdata2 = [0 f2]*(2-xscale) + [0 W2]*(xscale-1);
            xdata3 = [f4 fs/2]*(2-xscale) + [W4 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);
            set(handles.Line3,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','on');
            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'ButterBR'

            theta_p=(W3-W1);          %   added

            %             [theta,omega]=br_mapping(W1*pi,W3*pi);          % obtain the maping between theta and omega
            %             theta_s1=theta(floor(W2*pi*100+1))/pi;          % obtain particular theta values that map to particular stop band frequencies
            %             theta_s2=theta(floor(W4*pi*100+1))/pi;
            %             theta_s=min([theta_s1 theta_s2]);               % smaller value of theta should be used as stop band frequency for original filter
            %
            %             N = ceil(log10(((1/Rs)^2-1)/((1/(1-Rp))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));          %   added
            [b,a]=butterworth(ord/2,theta_p,Rp);        % find butterworth filter coefficients
            alpha=cos((W3+W1)*pi/2)/cos((W3-W1)*pi/2);  % find constants
            k=tan((W3-W1)*pi/2)*tan(theta_p*pi/2);
            flip_b=fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a=fliplr(a);						% they need to be flipped around for computation
            roots_b=roots(flip_b);
            roots_a=roots(flip_a);
            C1=2*alpha/(k+1);					% constants for mapping
            C2=(1-k)/(k+1);
            for i=1:length(roots_b),			% calculations from old Oppenheim & Schafer pg 434
                ba=1-roots_b(i)*C2;
                aa=1-roots_a(i)*C2;
                bb=roots_b(i)*C1-C1;
                ab=roots_a(i)*C1-C1;
                bc=C2-roots_b(i);
                ac=C2-roots_a(i);
                roots_B(2*i)=(-bb+sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_B(2*i-1)=(-bb-sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_A(2*i)=(-ab+sqrt(ab^2-4*aa*ac))/(2*aa);
                roots_A(2*i-1)=(-ab-sqrt(ab^2-4*aa*ac))/(2*aa);
            end
            flip_B=poly(roots_B);
            flip_A=poly(roots_A);
            A=fliplr(flip_A);
            B=fliplr(flip_B);
            [h,w]=freekz(B,A,512);                   % determine frequency response
            max_h=max(abs(h));
            h=h/max_h;
            %h=1-abs(h);                         % invert to get band reject
%%            [handles.b,handles.a] = invfreqz(h,w,ord,ord);          % save coefficients
            handles.b = B/A(1)/max_h;
            handles.a = A/A(1);
            set(handles.PlotTitle, 'String', ['Butterworth Bandreject Filter of Order ' num2str(ord)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f3 fs/2]*(2-xscale) + [W3 1]*(xscale-1);
            xdata3 = [f2 f4]*(2-xscale) + [W2 W4]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line4a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line4b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line5a,'xdata', xdata2,'ydata',ydata1);
            set(handles.Line5b,'xdata', xdata2,'ydata',ydata2);
            set(handles.Line6,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','on');
            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','off');

        case 'KaiserLP'
            % for formulae, refer to pg 474 in Oppenheim & Schafer book

            if strcmp('Rpass',handles.KaiserR)
                delta = Rp;
            elseif strcmp('Rstop',handles.KaiserR)
                delta = Rs;
            else
                delta = min(Rs,Rp);
            end

            A=-20*log10(delta);
            M=ord-1;
            alpha=M/2;
            if A>50
                beta=0.1102*(A-8.7);
            elseif A<21
                beta=0;
            else
                beta=0.5842*(A-21)^.4 + 0.07886*(A-21);
            end
            for n = 0:M
                x(n+1) = besseli(0,beta*(1-((n-alpha)/alpha)^2)^.5)/besseli(0,beta);
                if n ~= alpha,
                    s(n+1) = sin(Wc1*pi*(n-alpha))/(pi*(n-alpha));
                else
                    s(n+1) = Wc1;
                end
            end
            f = s.*x;
            handles.b = f;
            handles.a = 1;
            h = fft(f,1024);                       % determine frequency response (512pt FFT)
            h = h(1:512);                         % need only half due to symmetry
            w = (0:511)/512*pi;
%%            [handles.b,handles.a] = invfreqz(h,w,ord,1);          % save coefficients
            set(handles.PlotTitle, 'String', ['Lowpass Kaiser Window Filter of Order ' num2str(ord)]);

            %%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%
            set(handles.Rpass,'String',delta);
            set(handles.Rstop,'String',delta);
            Rp = delta;
            Rs = delta;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f2 fs/2]*(2-xscale) + [W2 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line3,'xdata', xdata2,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
            set([handles.Line2,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'KaiserBP'                   % if window
            % for formulae, refer to pg 474 in Oppenheim & Schafer book
            if strcmp('Rpass',handles.KaiserR)
                delta = Rp;
            elseif strcmp('Rstop',handles.KaiserR)
                delta = Rs;
            else
                delta = min(Rs,Rp);
            end

            A=-20*log10(delta);
            M=ord-1;
            alpha=M/2;
            if A>50
                beta=0.1102*(A-8.7);
            elseif A<21
                beta=0;
            else
                beta=0.5842*(A-21)^.4 + 0.07886*(A-21);
            end
            for n=0:M,
                x(n+1)=besseli(0,beta*(1-((n-alpha)/alpha)^2)^.5)/besseli(0,beta);
                if n~=alpha,
                    s(n+1)=-sin(Wc1*pi*(n-alpha))/(pi*(n-alpha))+sin(Wc2*pi*(n-alpha))/(pi*(n-alpha));   % formula on pg 482 in Oppenheim/Schafer book
                else
                    s(n+1)=-Wc1+Wc2;
                end
            end
            f=s.*x;
            handles.b=f;
            handles.a=1;
            h=fft(f,1024);                       % determine frequency response (512pt FFT)
            h=h(1:512);                         % need only half due to symmetry
            w=(0:511)/512*pi;
%%            [handles.b,handles.a] = invfreqz(h,w,M+1,1);          % save coefficients
            set(handles.Order,'String',num2str(M+1));
            set(handles.PlotTitle, 'String', ['Bandpass Kaiser Window Filter of Order ' num2str(M+1)]);

            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%
            set(handles.Rpass,'String',delta);
            set(handles.Rstop,'String',delta);
            Rp=delta;
            Rs=delta;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            xdata1 = [f1 f3]*(2-xscale) + [W1 W3]*(xscale-1);
            xdata2 = [0 f2]*(2-xscale) + [0 W2]*(xscale-1);
            xdata3 = [f4 fs/2]*(2-xscale) + [W4 1]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);
            set(handles.Line3,'xdata', xdata3,'ydata',ydata3);

            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','on');
            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');

        case 'KaiserBR'                   % if KaiserBR
            % for formulae, refer to pg 474 in Oppenheim & Schafer book

            if strcmp('Rpass',handles.KaiserR)
                delta = Rp;
            elseif strcmp('Rstop',handles.KaiserR)
                delta = Rs;
            else
                delta = min(Rs,Rp);
            end

            A = -20*log10(delta);
            M = ord-1;
            alpha = M/2;
            if A > 50
                beta = 0.1102*(A-8.7);
            elseif A < 21
                beta = 0;
            else
                beta=0.5842*(A-21)^.4 + 0.07886*(A-21);
            end
            for n=0:M,
                x(n+1) = besseli(0,beta*(1-((n-alpha)/alpha)^2)^.5)/besseli(0,beta);
                if n~=alpha,
                    s(n+1) = sin(Wc1*pi*(n-alpha))/(pi*(n-alpha))-sin(Wc2*pi*(n-alpha))/(pi*(n-alpha))+sin(pi*(n-alpha))/(pi*(n-alpha));   % formula on pg 482 in Oppenheim/Schafer book
                else
                    s(n+1) = Wc1-Wc2+1;
                end
            end
            f = s.*x;
            handles.b = f;
            handles.a = 1;
            h = fft(f,1024);                       % determine frequency response (512pt FFT)
            h = h(1:512);                         % need only half due to symmetry
            w = (0:511)/512*pi;
%%            [handles.b,handles.a] = invfreqz(h,w,M+1,1);          % save coefficients
            set(handles.Order,'String',num2str(M+1));
            set(handles.PlotTitle, 'String', ['Bandpass Kaiser Window Filter of Order ' num2str(M+1)]);

            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            set(handles.Rpass,'String',delta);
            set(handles.Rstop,'String',delta);
            Rp=delta;
            Rs=delta;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% initializing ideal filter lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            xdata1 = [0 f1]*(2-xscale) + [0 W1]*(xscale-1);
            xdata2 = [f3 fs/2]*(2-xscale) + [W3 1]*(xscale-1);
            xdata3 = [f2 f4]*(2-xscale) + [W2 W4]*(xscale-1);
            ydata1 = [1+Rp,1+Rp]*(2-yscale) + [20*log10(1+Rp) 20*log10(1+Rp)]*(yscale-1);
            ydata2 = [1-Rp 1-Rp]*(2-yscale) + [20*log10(1-Rp) 20*log10(1-Rp)]*(yscale-1);
            ydata3 = [Rs Rs]*(2-yscale) + [20*log10(Rs) 20*log10(Rs)]*(yscale-1);

            set(handles.Line4a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line4b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line5a,'xdata',xdata2,'ydata',ydata1);
            set(handles.Line5b,'xdata',xdata2,'ydata',ydata2);
            set(handles.Line6 ,'xdata',xdata3,'ydata',ydata3);

            set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','on');
            set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','off');
    end
end

if xscale==1 & yscale==1,           % frequency in Hz, linear amplitude

    set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',abs(h),'marker','none','linestyle','-' )
    set(handles.LineGreen,'xdata',[0,fs/2],'ydata',[0,0])
    set(handles.Plot1, 'Ylim', [-.1 1.2],'Xlim',[0 fs/2]);
    set(get(handles.Plot1,'Xlabel'),'string','Frequency (Hz)');
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude');

elseif xscale==2 & yscale==1,       % frequency normalized, linear amplitude

    set(handles.LineMain,'xdata',w/pi,'ydata',abs(h),'marker','none','linestyle','-' )
    set(handles.LineGreen,'xdata',[0 1],'ydata',[0,0])
    set(handles.Plot1, 'Ylim', [-.1 1.2],'Xlim',[0 1]);
    set(get(handles.Plot1,'Xlabel'),'string','Frequency (Normalized)');
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude');

elseif xscale==1 & yscale==2,       % frequency in Hz, dB amplitude

    idx_zero = find (abs(h) == 0 );
    if ~isempty(idx_zero)
        h(idx_zero) = sqrt(-1)*1e-15;
    end
    set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',20*log10(abs(h)),'marker','none','linestyle','-' )
    set(handles.LineGreen,'xdata',[],'ydata',[])
    set(handles.Plot1, 'Ylim', [-80 10],'Xlim',[0 fs/2]);
    set(get(handles.Plot1,'Xlabel'),'string','Frequency (Hz)');
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude (dB)');

else                                % frequency normalized, dB amplitude

    idx_zero = find (abs(h) == 0 );
    if ~isempty(idx_zero)
        h(idx_zero) = sqrt(-1)*1e-15;
    end
    set(handles.LineMain,'xdata',w/pi,'ydata',20*log10(abs(h)),'marker','none','linestyle','-' )
    set(handles.LineGreen,'xdata',[],'ydata',[])
    set(handles.Plot1, 'Ylim', [-80 10],'Xlim',[0 1]);
    set(get(handles.Plot1,'Xlabel'),'string','Frequency (Normalized)');
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude (dB)');
end
% --------------------------------------------------------------------
function varargout = SetOrder_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% sets the menu options depending on whether auto or manual setting of
% the filter order is selected

auto = get(handles.SetOrder, 'Value');
if auto == 1
    set(handles.Order,'Enable','off');
else
    set(handles.Order,'Enable','on');
end
% --------------------------------------------------------------------
function SetMenu(h,handles)
% --------------------------------------------------------------------
filt_num = get(handles.Filter,'Value');

names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR','FIR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};
fs = str2num(get(handles.Fsamp,'String'));
ord = str2num(get(handles.Order,'String'));
order_type = get(handles.SetOrder,'Value');

[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,w1,w2,w3,w4] = user(handles);

if (get(handles.Filter,'Value')<8)
    set(handles.Plot1,'UIContextMenu','');
    set([handles.WindowsMenu, handles.Windows,handles.FilterMenu, handles.FiltType],'vis','off');  %Enables Windows and Filter Type menus
    set([handles.Fstop1, handles.Fpass2, handles.Fstop2, handles.Rpass, handles.Rstop, handles.Fstop1Tag, handles.unitsFstop1], 'visible' ,'on');
    set([handles.Fpass2Tag, handles.unitsFpass2, handles.Fstop2Tag, handles.unitsFstop2, handles.unitsRstop, handles.unitsRpass, handles.RpassTag, handles.RstopTag],'vis','on');
    set(handles.Fpass1Tag, 'String', 'Fpass1');
    set(handles.SetOrder, 'vis','on');
    set(handles.Order,'Enable','off');
    set([handles.menu_x_scale,handles.menu_y_scale],'vis','on','checked','off');
    set(handles.LineMain,'vis','on');
    %         set(handles.VariousResp,'selected','off');
    set([handles.LineCirc,handles.HorzLine,handles.VertLine,handles.PoleLine...
        handles.LineStem1,handles.LineStem2,handles.WindowPlot,handles.TextPole...
        handles.AlphaTag,handles.alpha],'vis','off');
    set(handles.Rstop,'string',num2str(Rs),'vis','on');
    set(handles.RstopTag,'string','Rs','vis','on');
    set(handles.figure1,'WindowButtonMotionFcn','filterdesign WindowButtonMotion');
else
    set(handles.Plot1,'UIContextMenu',handles.VariousResp);
    set(handles.figure1,'WindowButtonMotionFcn','');
end

switch filt_name
    case 'ButterLP',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag,handles.unitsFpass2,handles.unitsFstop2],'Vis','off');
        set(handles.Fpass1Tag,'String','Fpass');
        set(handles.Fstop1Tag,'String','Fstop');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1,'String', num2str(4/16) );   % set default values
            set(handles.Fstop1,'String', num2str(6/16) );
        else
            set(handles.Fpass1, 'String', num2str(ceil(2*fs/16)));      % set default values
            set(handles.Fstop1, 'String', num2str(ceil(3*fs/16)));
        end
    case 'ButterHP',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag,handles.unitsFpass2,handles.unitsFstop2],'Visible','off');
        set(handles.Fpass1Tag,'String','Fstop');
        set(handles.Fstop1Tag,'String','Fpass');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(6/16));
            set(handles.Fstop1, 'String', num2str(4/16));
        else
            set(handles.Fpass1, 'String', num2str(ceil(3*fs/16)) );  % set default values
            set(handles.Fstop1, 'String', num2str(ceil(2*fs/16)) );
        end
    case 'ButterBP',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'Visible','on');
        set(handles.Fpass1Tag,'String','Fpass1');
        set(handles.Fstop1Tag,'String','Fstop1');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(6/16));      % set default values
            set(handles.Fstop1, 'String', num2str(4/16));
            set(handles.Fpass2, 'String', num2str(10/16));
            set(handles.Fstop2, 'String', num2str(14/16));
        else
            set(handles.Fpass1, 'String', num2str(ceil(3*fs/16)));      % set default values
            set(handles.Fstop1, 'String', num2str(ceil(2*fs/16)));
            set(handles.Fpass2, 'String', num2str(ceil(5*fs/16)));
            set(handles.Fstop2, 'String', num2str(ceil(7*fs/16)));
            % update unit texts
            set([handles.unitsFpass2,handles.unitsFstop2],'Vis','on');
        end

        if order_type==2 & mod(ord,2)~=0,   % if BPF in 'set order' mode and order is not even
            set(handles.Order,'String',num2str(ord+1));
        end

    case 'ButterBR',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'Visible','on');
        set(handles.Fpass1Tag,'String','Fpass1');
        set(handles.Fstop1Tag,'String','Fstop1');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(4/16));      % set default values
            set(handles.Fstop1, 'String', num2str(6/16));
            set(handles.Fpass2, 'String', num2str(14/16));
            set(handles.Fstop2, 'String', num2str(10/16));
        else
            set(handles.Fpass1, 'String', num2str(ceil(2*fs/16)));      % set default values
            set(handles.Fstop1, 'String', num2str(ceil(3*fs/16)));
            set(handles.Fpass2, 'String', num2str(ceil(7*fs/16)));
            set(handles.Fstop2, 'String', num2str(ceil(5*fs/16)));
            % update unit texts
            set([handles.unitsFpass2,handles.unitsFstop2],'Vis','on');
        end

        if order_type==2 & mod(ord,2)~=0,   % if BRF in 'set order' mode and order is not even
            set(handles.Order,'String',num2str(ord+1));
        end
    case 'KaiserLP',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag,handles.unitsFpass2,handles.unitsFstop2],'Visible','off');
        set(handles.Fpass1Tag,'String','Fpass');
        set(handles.Fstop1Tag,'String','Fstop');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(4/16) );      % set default values
            set(handles.Fstop1, 'String', num2str(6/16) );
        else
            set(handles.Fpass1, 'String', num2str(ceil(2*fs/16)) );      % set default values
            set(handles.Fstop1, 'String', num2str(ceil(3*fs/16)) );
        end
    case 'KaiserBP',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'Visible','on');
        set(handles.Fpass1Tag,'String','Fpass1');
        set(handles.Fstop1Tag,'String','Fstop1');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(6/16));      % set default values
            set(handles.Fstop1, 'String', num2str(4/16));
            set(handles.Fpass2, 'String', num2str(10/16));
            set(handles.Fstop2, 'String', num2str(14/16));
        else
            set(handles.Fpass1, 'String', num2str(ceil(3*fs/16)));
            set(handles.Fstop1, 'String', num2str(ceil(2*fs/16)));
            set(handles.Fpass2, 'String', num2str(ceil(5*fs/16)));
            set(handles.Fstop2, 'String', num2str(ceil(7*fs/16)));
            % update unit texts
            set([handles.unitsFpass2,handles.unitsFstop2],'Vis','on');
        end
    case 'KaiserBR',
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'Visible','on');
        set(handles.Fpass1Tag,'String','Fpass1');
        set(handles.Fstop1Tag,'String','Fstop1');
        set(handles.SetOrder, 'Enable','on');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(4/16));      % set default values
            set(handles.Fstop1, 'String', num2str(6/16));
            set(handles.Fpass2, 'String', num2str(14/16));
            set(handles.Fstop2, 'String', num2str(10/16));
        else
            set(handles.Fpass1, 'String', num2str(ceil(2*fs/16)));      % set default values
            set(handles.Fstop1, 'String', num2str(ceil(3*fs/16)));
            set(handles.Fpass2, 'String', num2str(ceil(7*fs/16)));
            set(handles.Fstop2, 'String', num2str(ceil(5*fs/16)));
            % update unit texts
            set([handles.unitsFpass2,handles.unitsFstop2],'Vis','on');
        end

        if order_type==2 & mod(ord,2)~=1,   % if KaiserBR in 'set order' mode and order is not even
            set(handles.Order,'String',num2str(ord+1));
        end
    case 'FIR'
        set([handles.WindowsMenu, handles.Windows,handles.FilterMenu, handles.FiltType],'visible','on','en','on');  %Enables Windows and Filter Type menus
        set([handles.Fstop1, handles.Fpass2, handles.Fstop2, handles.Rpass, handles.Rstop, handles.Fstop1Tag, handles.unitsFstop1], 'visible' ,'off');
        set([handles.Fpass2Tag, handles.unitsFpass2, handles.Fstop2Tag, handles.unitsFstop2, handles.unitsRstop, handles.unitsRpass, handles.RpassTag, handles.RstopTag],'vis','off');
        set(handles.Fpass1Tag, 'String', 'Fcutoff');
        set(handles.Order,'Enable','On');
        set([handles.alpha, handles.AlphaTag,handles.SetOrder],'vis','off')

        % [order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,w1,w2,w3,w4] = user(handles);
        set(handles.Order,'string','20');
        SetFIRMenu(handles);
        handles = PlotGraph(handles);
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function WindowButtonMotion()
% --------------------------------------------------------------------
hax = findobj(gcbf,'type','axes');
%-----------------------------------
% Determine if cursor is over Plot
old_units = get(hax,'units');
set(hax,'units','pixels');
[mouse_x,mouse_y,fig_size] = mousepos;
ax = get(hax,'position');
% Cursor over object axes flag
over_axes_flg = any( (mouse_x > ax(1)) & (mouse_x < ax(1)+ax(3)) &  ...
    (mouse_y > ax(2)) & (mouse_y < ax(2)+ax(4)) );

set(hax,'units',old_units);
%-----------------------------------
if over_axes_flg
    %%%%%
    % Find obj handles for red_lines (if they exist)
    Lines = findobj(gcbf,'type','line');

    if ~isempty(Lines)
        nLines = length(Lines);
        n = 1;
        for i = 1:nLines
            if ( get(Lines(i),'color') == [1 0 0] ) % if line is red
                Lines_red(n,:) = Lines(i);
                n = n+1;
            end
        end
        nredLines = length(Lines_red);
        if ~isempty(Lines_red)
            %%%%%
            current_pt = get(hax,'CurrentPoint');
            xpt = current_pt(1,1);
            ypt = current_pt(1,2);
            % specify handle tolerance whithin 1% of y-axis limits
            axis_ylim = get(hax,'Ylim');
            toll = diff(axis_ylim)*0.01;

            % Red Line object extend and over object flag
            for ii = 1:nredLines
                Lines_red_Xdata(ii,:) = get(Lines_red(ii),'Xdata');
                Lines_red_Ydata(ii,:) = get(Lines_red(ii),'Ydata');
                over_obj_flg(ii) = (xpt >= Lines_red_Xdata(ii,1)) & (xpt <= Lines_red_Xdata(ii,2)) & ...
                    ( abs(ypt - Lines_red_Ydata(ii,1)) < toll );
            end

            if any(over_obj_flg);
                setptr(gcbf,'hand');
            else
                setptr(gcbf,'arrow');
            end
        else
            setptr(gcbf,'arrow');
        end
    end
end
% --------------------------------------------------------------------
function LineDragStart()
% --------------------------------------------------------------------
handles = getappdata(gcbf,'Datastructure');
setptr(gcbf,'closedhand');
CurrentPoint = get(gca, 'CurrentPoint');
setappdata(gcbf, 'CurrentXY', CurrentPoint(1,1:2) );
set(gcbf,'WindowButtonUpFcn',[ mfilename ' LineDragStop']);
set(gcbf,'WindowButtonMotionFcn',[ mfilename ' MoveLine']);
% --------------------------------------------------------------------
function LineDragStop()
% --------------------------------------------------------------------
handles = getappdata(gcbf,'Datastructure');
rmappdata(gcbf,'CurrentXY');
set(gcbf,'WindowButtonMotionFcn','');
set(gcbf,'WindowButtonUpFcn','');
setptr(gcbf,'arrow');
Line1aXData = get(handles.Line1a,'XData');      % find xdata for both lines
Line1bXData = get(handles.Line1b,'XData');      % find xdata for both lines
Line4aXData = get(handles.Line4a,'XData');      % find xdata for both lines
Line4bXData = get(handles.Line4b,'XData');      % find xdata for both lines
Line5aXData = get(handles.Line5a,'XData');      % find xdata for both lines
Line5bXData = get(handles.Line5b,'XData');      % find xdata for both lines
Line2XData  = get(handles.Line2,'XData');
Line3XData  = get(handles.Line3,'XData');
Line6XData  = get(handles.Line6,'XData');
Line1aYData = get(handles.Line1a,'YData');      % find ydata for both lines
Line1bYData = get(handles.Line1b,'YData');      % find ydata for both lines
Line4aYData = get(handles.Line4a,'YData');      % find xdata for both lines
Line4bYData = get(handles.Line4b,'YData');      % find xdata for both lines
Line5aYData = get(handles.Line5a,'YData');      % find xdata for both lines
Line5bYData = get(handles.Line5b,'YData');      % find xdata for both lines
Line2YData  = get(handles.Line2,'YData');
Line3YData  = get(handles.Line3,'YData');
Line6YData  = get(handles.Line6,'YData');                     

filt_num=get(handles.Filter,'Value');           % determine type of filter
names={'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR'};    % should appear in same order as pull down menu
filt_name=names{filt_num};

yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; % 1-Mag, 2-Mag (dB)
xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm
fs = str2num(get(handles.Fsamp,'String'));

switch filt_name,
    case 'ButterLP'                                                     % LPF
        set(handles.Fpass1,'String',num2str(Line1aXData(2)));
        set(handles.Fstop1,'String',num2str(Line3XData(1)));

        set(handles.Rstop,'String',num2str(Line3YData(1)));
        if yscale==1        % if yscale is linear
            set(handles.Rpass,'String',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'String',num2str(20*log10(1-y1)));
            %set(handles.Rstop,'String',num2str(10^(Line3YData(1)/20)));
        end
    case 'ButterHP'                                                      % HPF
        set(handles.Fpass1,'String',num2str(Line1aXData(1)));
        set(handles.Fstop1,'String',num2str(Line2XData(2)));

        set(handles.Rstop,'String',num2str(Line2YData(1)));
        if yscale == 1        % if yscale is linear
            set(handles.Rpass,'String',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'String',num2str(20*log10(1-y1)));
        end
    case {'ButterBP','KaiserBP'}                                          % BPF
        set(handles.Fpass1,'String',num2str(Line1aXData(1)));
        set(handles.Fstop1,'String',num2str(Line2XData(2)));
        set(handles.Fpass2,'String',num2str(Line1aXData(2)));
        set(handles.Fstop2,'String',num2str(Line3XData(1)));

        set(handles.Rstop,'String',num2str(Line2YData(1)));
        if yscale == 1        % if yscale is linear
            set(handles.Rpass,'String',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'String',num2str(20*log10(1-y1)));
        end
    case {'ButterBR','KaiserBR'}                                           % BRF
        set(handles.Fpass1,'String',num2str(Line4aXData(2)));
        set(handles.Fstop1,'String',num2str(Line6XData(1)));
        set(handles.Fpass2,'String',num2str(Line5aXData(1)));
        set(handles.Fstop2,'String',num2str(Line6XData(2)));

        set(handles.Rstop,'String',num2str(Line6YData(1)));
        if yscale == 1      % if yscale is linear
            set(handles.Rpass,'String',num2str((abs(Line4aYData(1)-Line4bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line4aYData(1)/20)-1);
            set(handles.Rpass,'String',num2str(20*log10(1-y1)));
        end
    case 'KaiserLP'                                                      % Kaiser
        set(handles.Fpass1,'String',num2str(Line1aXData(2)));
        set(handles.Fstop1,'String',num2str(Line3XData(1)));

        set(handles.Rstop,'String',num2str(Line3YData(1)));
        if yscale == 1        % if yscale is linear
            set(handles.Rpass,'String',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'String',num2str(20*log10(1-y1)));
        end
end

handles = PlotButton_Callback(gcbo,[],guidata(gcbo));
set(gcbf,'WindowButtonMotionFcn',[ mfilename ' WindowButtonMotion']);
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function MoveLine()
% --------------------------------------------------------------------
handles = getappdata(gcbf,'Datastructure');
OldXY = getappdata(gcbf, 'CurrentXY');       % get old coordinates
CurrentPoint = get(gca, 'CurrentPoint');     % get current coordinates
CurrentXY = CurrentPoint(1,1:2);
DistanceMoved = CurrentXY - OldXY;           % find distance moved
Line1aXData = get(handles.Line1a,'XData');   % find xdata for both lines
Line1bXData = get(handles.Line1b,'XData');   % find xdata for both lines
Line4aXData = get(handles.Line4a,'XData');   % find xdata for both lines
Line4bXData = get(handles.Line4b,'XData');   % find xdata for both lines
Line5aXData = get(handles.Line5a,'XData');   % find xdata for both lines
Line5bXData = get(handles.Line5b,'XData');   % find xdata for both lines
Line2XData = get(handles.Line2,'XData');
Line3XData = get(handles.Line3,'XData');
Line6XData = get(handles.Line6,'XData');
line = get(gco,'Tag');                       % determine which line is moved

filt_num=get(handles.Filter,'Value');        % determine type of filter
names = {'ButterLP','ButterHP','ButterBP','ButterBR','KaiserLP','KaiserBP','KaiserBR'};    % should appear in same order as pull down menu
filt_name = names{filt_num};

yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; %yscale linear or dB: 1-Mag, 2-Mag (dB)
xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm
switch line
    case 'Line1a'
        switch filt_name
            case 'ButterLP'             % LPF
                NewData=get(handles.Line1a,'XData');  % get data to manipulate

                if yscale == 1            % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5 % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                    % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)  % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end

                if Line1aXData(2) <= Line3XData(1)   % check for constraints
                    NewData(2) = NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2) = NewData(2)-10;
                else
                    NewData(2) = NewData(2)-.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1    % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB=get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end
            case 'ButterHP'              % HPF
                NewData=get(handles.Line1a,'XData');                 % get data to manipulate
                if yscale == 1                % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                    % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if Line1aXData(1)>=Line2XData(2)   % check for constraints
                    NewData(1)=NewData(1)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(1) = NewData(1)+10;
                else
                    NewData(1) = NewData(1)+.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1    % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end
            case 'ButterBP'              % BPF
                NewData=get(handles.Line1a,'XData');                 % get data to manipulate
                if yscale==1                % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                        % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1a is moved
                    if Line1aXData(1)>=Line2XData(2)   % check for constraints
                        NewData(1)=NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1)=NewData(1)+10;
                    else
                        NewData(1)=NewData(1)+.01;
                    end
                else                                                    % if right point on Line1a is moved
                    if Line1aXData(2)<=Line3XData(1)   % check for constraints
                        NewData(2)=NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2)=NewData(2)-10;
                    else
                        NewData(2)=NewData(2)-.01;
                    end
                end
                set(handles.Line1a,'XData',NewData);
                if yscale==1    % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end
            case 'KaiserLP'              % Kaiser
                NewData=get(handles.Line1a,'XData');                 % get data to manipulate
                if yscale == 1                % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                        % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if Line1aXData(2)<=Line3XData(1)   % check for constraints
                    NewData(2)=NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2)=NewData(2)-10;
                else
                    NewData(2)=NewData(2)-.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale==1    % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB=get(handles.Line1a,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end

                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale == 1
                    set(handles.Line3,'YData', abs(1-get(handles.Line1a,'YData')));
                else
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=abs(1-lin);
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line3,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            case 'KaiserBP'              % KaiserBP
                NewData=get(handles.Line1a,'XData');                 % get data to manipulate
                if yscale==1                % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                        % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1a is moved
                    if Line1aXData(1)>=Line2XData(2)   % check for constraints
                        NewData(1)=NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1)=NewData(1)+10;
                    else
                        NewData(1)=NewData(1)+.01;
                    end
                else                                                    % if right point on Line1a is moved
                    if Line1aXData(2)<=Line3XData(1)   % check for constraints
                        NewData(2)=NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2)=NewData(2)-10;
                    else
                        NewData(2)=NewData(2)-.01;
                    end
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1    % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB=get(handles.Line1a,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end

                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale==1
                    set(handles.Line3,'YData', abs(1-get(handles.Line1a,'YData')));
                    set(handles.Line2,'YData', abs(1-get(handles.Line1a,'YData')));
                else
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=abs(1-lin);
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line3,'YData', dB);
                    set(handles.Line2,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

    case 'Line1b'
        switch filt_name
            case 'ButterLP'              % LPF
                NewData=get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale==1                % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else                        % dB
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                if Line1bXData(2)<=Line3XData(1)                    % make sure lines do not cross
                    NewData(2)=NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2)=NewData(2)-10;
                else
                    NewData(2)=NewData(2)-.01;
                end
                set(handles.Line1b,'XData',NewData);
                if yscale==1    % linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end

            case 'ButterHP'              % HPF
                NewData=get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale==1            % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else                    % dB
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if Line1bXData(1)>=Line2XData(2)                    % make sure lines dont cross
                    NewData(1)=NewData(1)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(1)=NewData(1)+10;
                else
                    NewData(1)=NewData(1)+.01;
                end
                set(handles.Line1b,'XData',NewData);
                if yscale==1    % linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end
            case 'ButterBP'              % BPF
                NewData=get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale==1                % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else                        % dB
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1b is moved
                    if Line1bXData(1)>=Line2XData(2)                    % make sure lines dont cross
                        NewData(1)=NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1)=NewData(1)+10;
                    else
                        NewData(1)=NewData(1)+.01;
                    end
                else                                                    % if right point on Line1b is moved
                    if Line1bXData(2)<=Line3XData(1)                    % make sure lines dont cross
                        NewData(2)=NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2)=NewData(2)-10;
                    else
                        NewData(2)=NewData(2)-.01;
                    end
                end
                set(handles.Line1b,'XData',NewData);
                if yscale==1    % linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end
            case 'KaiserLP'              % KaiserLP
                NewData=get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale==1                % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if Line1bXData(2)<=Line3XData(1)                    % make sure lines dont cross
                    NewData(2)=NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2)=NewData(2)-10;
                else
                    NewData(2)=NewData(2)-.01;
                end
                set(handles.Line1b,'XData',NewData);
                if yscale == 1    % linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end

                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale==1
                    set(handles.Line3,'YData', abs(1-get(handles.Line1b,'YData')));
                else
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=abs(1-lin);
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line3,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            case 'KaiserBP'              % KaiserBP
                NewData=get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale==1                % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1b is moved
                    if Line1bXData(1)>=Line2XData(2)                    % make sure lines dont cross
                        NewData(1)=NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1)=NewData(1)+10;
                    else
                        NewData(1)=NewData(1)+.01;
                    end
                else                                                    % if right point on Line1b is moved
                    if Line1bXData(2)<=Line3XData(1)                    % make sure lines dont cross
                        NewData(2)=NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2)=NewData(2)-10;
                    else
                        NewData(2)=NewData(2)-.01;
                    end
                end
                set(handles.Line1b,'XData',NewData);
                if yscale==1    % linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end

                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale==1
                    set(handles.Line3,'YData', abs(1-get(handles.Line1b,'YData')));
                    set(handles.Line2,'YData', abs(1-get(handles.Line1b,'YData')));
                else
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin=abs(1-lin);
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line3,'YData', dB);
                    set(handles.Line2,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    case 'Line2'
        NewData=get(handles.Line2,'XData');
        if yscale==1                % linear
            if (get(handles.Line2,'YData')+DistanceMoved(2))>0 & (get(handles.Line2,'YData')+DistanceMoved(2))<.5
                set(handles.Line2,'YData', get(handles.Line2,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line2,'YData')+DistanceMoved(2))>-80 & (get(handles.Line2,'YData')+DistanceMoved(2))<20*log10(.5)
                set(handles.Line2,'YData', get(handles.Line2,'YData')+DistanceMoved(2));
            end
        end
        if Line1aXData(1)>=Line2XData(2)
            NewData(2)=NewData(2)+DistanceMoved(1);
        elseif xscale == 1
            NewData(2)=NewData(2)-10;
        else
            NewData(2)=NewData(2)-.01;
        end
        set(handles.Line2,'XData',NewData);
        if strcmp(filt_name,'ButterBP')                        % BPF case
            set(handles.Line3,'YData', get(handles.Line2,'YData'));
            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(filt_name,'KaiserBP')                    % KaiserBP case
            if yscale==1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line2,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line2,'YData'));
                set(handles.Line3,'YData', get(handles.Line2,'YData'));
            else
                dB=get(handles.Line2,'YData');
                lin=10^(dB(1)/20);
                lin1=1+lin;
                lin2=1-lin;
                dB1=[20*log10(lin1),20*log10(lin1)];
                dB2=[20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
                set(handles.Line3,'YData', dB);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

    case 'Line3'
        NewData=get(handles.Line3,'XData');
        if yscale==1                % linear
            if (get(handles.Line3,'YData')+DistanceMoved(2))>0 & (get(handles.Line3,'YData')+DistanceMoved(2))<.5
                set(handles.Line3,'YData', get(handles.Line3,'YData')+DistanceMoved(2));
            end
        else
            if (get(handles.Line3,'YData')+DistanceMoved(2))>-80 & (get(handles.Line3,'YData')+DistanceMoved(2))<20*log10(.5)
                set(handles.Line3,'YData', get(handles.Line3,'YData')+DistanceMoved(2));
            end
        end
        if Line1aXData(2)<=Line3XData(1)
            NewData(1)=NewData(1)+DistanceMoved(1);
        elseif xscale == 1
            NewData(1) = NewData(1)+10;
        else
            NewData(1) = NewData(1)+.01;
        end
        set(handles.Line3,'XData',NewData);
        if strcmp(filt_name,'ButterBP')                        % BPF case
            set(handles.Line2,'YData', get(handles.Line3,'YData'));

            %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(filt_name,'KaiserLP')                    % KaiserLP case
            if yscale == 1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line3,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line3,'YData'));
            else
                dB = get(handles.Line3,'YData');
                lin = 10^(dB(1)/20);
                lin1 = 1+lin;
                lin2 = 1-lin;
                dB1 = [20*log10(lin1),20*log10(lin1)];
                dB2 = [20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
            end
        elseif strcmp(filt_name,'KaiserBP')                    % KaiserBP case
            if yscale == 1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line3,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line3,'YData'));
                set(handles.Line2,'YData', get(handles.Line3,'YData'));
            else
                dB = get(handles.Line3,'YData');
                lin = 10^(dB(1)/20);
                lin1 = 1+lin;
                lin2 = 1-lin;
                dB1 = [20*log10(lin1),20*log10(lin1)];
                dB2 = [20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
                set(handles.Line2,'YData', dB);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

    case 'Line4a'
        NewData=get(handles.Line4a,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line4a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line4a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line4a,'YData', get(handles.Line4a,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line4a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line4a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line4a,'YData', get(handles.Line4a,'YData')+DistanceMoved(2));
            end
        end
        if Line4aXData(2)<=Line6XData(1)   % check for constraints
            NewData(2) = NewData(2)+DistanceMoved(1);
        elseif xscale == 1
            NewData(2)=NewData(2)-10;
        else
            NewData(2)=NewData(2)-.01;
        end
        set(handles.Line4a,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line4b,'XData', get(handles.Line4a,'XData'),'YData', 2-get(handles.Line4a,'YData'));    % makes passband lines move together
            set(handles.Line5a,'YData', get(handles.Line4a,'YData'));
            set(handles.Line5b,'YData', 2-get(handles.Line4a,'YData'));
        else            % dB
            dB = get(handles.Line4a,'YData');
            set(handles.Line5a,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line4b,'XData', get(handles.Line4a,'XData'),'YData', dB);
            set(handles.Line5b,'YData', dB);
        end
        switch filt_name
            case 'KaiserBR'
                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line4a,'YData')));
                else
                    dB = get(handles.Line4a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    case 'Line4b'
        NewData = get(handles.Line4b,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line4b,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line4b,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line4b,'YData', get(handles.Line4b,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line4b,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line4b,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line4b,'YData', get(handles.Line4b,'YData')+DistanceMoved(2));
            end
        end
        if Line4bXData(2)<=Line6XData(1)   % check for constraints
            NewData(2)=NewData(2)+DistanceMoved(1);
        elseif xscale == 1
            NewData(2)=NewData(2)-10;
        else
            NewData(2)=NewData(2)-.01;
        end
        set(handles.Line4b,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line4a,'XData', get(handles.Line4b,'XData'),'YData', 2-get(handles.Line4b,'YData'));    % makes passband lines move together
            set(handles.Line5a,'YData', get(handles.Line4b,'YData'));
            set(handles.Line5b,'YData', 2-get(handles.Line4b,'YData'));
        else            % dB
            dB = get(handles.Line4b,'YData');
            set(handles.Line5a,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line4a,'XData', get(handles.Line4b,'XData'),'YData', dB);
            set(handles.Line5b,'YData', dB);
        end
        switch filt_name
            case 'KaiserBR'
                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line4b,'YData')));
                else
                    dB = get(handles.Line4b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

    case 'Line5a'
        NewData = get(handles.Line5a,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line5a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line5a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line5a,'YData', get(handles.Line5a,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line5a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line5a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line5a,'YData', get(handles.Line5a,'YData')+DistanceMoved(2));
            end
        end
        if Line5aXData(1) >= Line6XData(2)   % check for constraints
            NewData(1)=NewData(1)+DistanceMoved(1);
        elseif xscale == 1
            NewData(1) = NewData(1)+10;
        else
            NewData(1) = NewData(1)+.01;
        end
        set(handles.Line5a,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line5b,'XData', get(handles.Line5a,'XData'),'YData', 2-get(handles.Line5a,'YData'));    % makes passband lines move together
            set(handles.Line4a,'YData', get(handles.Line5a,'YData'));
            set(handles.Line4b,'YData', 2-get(handles.Line5a,'YData'));
        else            % dB
            dB = get(handles.Line5a,'YData');
            set(handles.Line4a,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line5b,'XData', get(handles.Line5a,'XData'),'YData', dB);
            set(handles.Line4b,'YData', dB);
        end

        switch filt_name
            case 'KaiserBR'
                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line5a,'YData')));
                else
                    dB = get(handles.Line5a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

    case 'Line5b'
        NewData = get(handles.Line5b,'XData'); % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line5b,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line5b,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line5b,'YData', get(handles.Line5b,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line5b,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line5b,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line5b,'YData', get(handles.Line5b,'YData')+DistanceMoved(2));
            end
        end

        if Line5bXData(1) >= Line6XData(2)   % check for constraints
            NewData(1) = NewData(1)+DistanceMoved(1);
        elseif xscale == 1
            NewData(1) = NewData(1)+10;
        else
            NewData(1) = NewData(1)+.01;
        end
        set(handles.Line5b,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line5a,'XData', get(handles.Line5b,'XData'),'YData', 2-get(handles.Line5b,'YData'));    % makes passband lines move together
            set(handles.Line4a,'YData', 2-get(handles.Line5b,'YData'));
            set(handles.Line4b,'YData', get(handles.Line5b,'YData'));
        else            % dB
            dB = get(handles.Line5b,'YData');
            set(handles.Line4b,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line5a,'XData', get(handles.Line5b,'XData'),'YData', dB);
            set(handles.Line4a,'YData', dB);
        end

        switch filt_name
            case 'KaiserBR'
                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line5b,'YData')));
                else
                    dB = get(handles.Line5b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end

    case 'Line6'
        NewData = get(handles.Line6,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line6,'YData')+DistanceMoved(2))<0.5 & (get(handles.Line6,'YData')+DistanceMoved(2))>0       % make sure stopband error <= 0.5
                set(handles.Line6,'YData', get(handles.Line6,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line6,'YData')+DistanceMoved(2))<20*log10(0.5) & (get(handles.Line6,'YData')+DistanceMoved(2))>-80       % make sure stopband error <= 0.5
                set(handles.Line6,'YData', get(handles.Line6,'YData')+DistanceMoved(2));
            end
        end
        if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line6 is moved
            if Line6XData(1) >= Line4aXData(2)                    % make sure lines dont cross
                NewData(1) = NewData(1)+DistanceMoved(1);
            elseif xscale == 1
                NewData(1) = NewData(1)+10;
            else
                NewData(1) = NewData(1)+.01;
            end
        else                                                    % if right point on Line1b is moved
            if Line6XData(2) <= Line5aXData(1)                    % make sure lines dont cross
                NewData(2) = NewData(2)+DistanceMoved(1);
            elseif xscale == 1
                NewData(2) = NewData(2)-10;
            else
                NewData(2) = NewData(2)-.01;
            end
        end
        set(handles.Line6,'XData',NewData);

        switch filt_name
            case 'KaiserBR'
                %%%%%%%%%%%%%%%%%%%%%% delete this if you dont want lines moving together in Kaiser %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if yscale == 1
                    set(handles.Line4a,'YData', 1+get(handles.Line6,'YData'));
                    set(handles.Line4b,'YData', 1-get(handles.Line6,'YData'));
                    set(handles.Line5a,'YData', 1+get(handles.Line6,'YData'));
                    set(handles.Line5b,'YData', 1-get(handles.Line6,'YData'));
                else
                    dB = get(handles.Line6,'YData');
                    lin = 10^(dB(1)/20);
                    %lin=abs(1-lin);
                    dB1 = [20*log10(1+lin),20*log10(1+lin)];
                    dB2 = [20*log10(1-lin),20*log10(1-lin)];
                    set(handles.Line4a,'YData', dB1);
                    set(handles.Line4b,'YData', dB2);
                    set(handles.Line5a,'YData', dB1);
                    set(handles.Line5b,'YData', dB2);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %         if yscale==1    % linear
        %             set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
        %         else            % dB
        %             dB=get(handles.Line1b,'YData');
        %             lin=10^(dB(1)/20);
        %             lin=2-lin;
        %             dB=[20*log10(lin),20*log10(lin)];
        %             set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
        %         end

end
setappdata(gcbf, 'CurrentXY', CurrentXY);
% --------------------------------------------------------------------
% --------------------------- M E N U --------------------------------
% --------------------------------------------------------------------
function varargout = menu_export_to_workspace_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%Call for "Export > To Workspace"
cdhandles = fd_coeffdlg(handles);

if cdhandles.export
    num_name = cdhandles.num;
    den_name = cdhandles.den;
    clear handles_coeffDLG.num;

    assignin('base',num_name,handles.b );
    assignin('base',den_name,handles.a );

    disp(['"' num_name '"' ' and ' '"' den_name '"' ' have been added to workspace'])
end
% --------------------------------------------------------------------
function varargout = menu_export_to_file_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%Call for "Export > To File"
[fname, pname] = uiputfile('*.mat','Choose File to Save Filter Coefficients');

if pname ~= 0
    a = handles.a;
    b = handles.b;
    save ([pname,fname], 'a','b');
end
% --------------------------------------------------------------------
function varargout = menu_exit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
delete(handles.figure1);    %Call for "Exit"
% --------------------------------------------------------------------
function varargout = menu_set_line_width_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
newLineWidth = linewidthdlg(get(handles.Line1a,'linewidth'));
set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3,handles.Line4a,handles.Line4b, ...
    handles.Line5a,handles.Line5b,handles.Line6,handles.LineMain,handles.LineGreen,...
    handles.PoleLine,handles.LineStem1,handles.LineStem2],'linewidth',newLineWidth);
setappdata(gcbf,'DataStructure',handles);
% --------------------------------------------------------------------
function varargout = menu_x_scale_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
if strcmp(get(h,'checked'),'off')
    [order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,W1,W2,W3,W4] = user(handles);
    % Normalize frequencies
    set(handles.Fpass1,'string',num2str(W1));
    set(handles.Fstop1,'String',num2str(W2));
    set(handles.Fpass2,'String',num2str(W3));
    set(handles.Fstop2,'String',num2str(W4));
    % update units
    set([handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'vis','off');

    set(h,'checked','on');
    if get(handles.Filter,'Value')<8
        handles = PlotButton_Callback(gcbo,[],guidata(gcbo));
    else
        handles = PlotGraph(handles);
    end
else
    [order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,W1,W2,W3,W4] = user(handles);
    % Normalize frequencies
    set(handles.Fpass1,'string',num2str(f1));
    set(handles.Fstop1,'String',num2str(f2));
    set(handles.Fpass2,'String',num2str(f3));
    set(handles.Fstop2,'String',num2str(f4));
    % update units
    filt_num = get(handles.Filter,'Value');
    fir_num = get(handles.FilterMenu,'Value');
    switch filt_num
        case {1,2,5}
            set([handles.unitsFpass1,handles.unitsFstop1],'vis','on');
        case {3,4,6,7}
            set([handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'vis','on');
        case {8}
            switch fir_num
                case {1,2}
                    set([handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'vis','off');
                    set(handles.unitsFpass1,'vis','on');
                case {3,4}
                    set([handles.unitsFstop1,handles.unitsFstop2],'vis','off');
                    set([handles.unitsFpass1,handles.unitsFpass2],'vis','on');
                otherwise
            end
    end

    set(h,'checked','off');
    if get(handles.Filter,'Value')<8
        handles = PlotButton_Callback(gcbo,[],guidata(gcbo));
    else
        handles = PlotGraph(handles);
    end   
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = menu_y_scale_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% y scale (magnitude in dB) button in menu
if strcmp(get(h,'checked'),'off') % in dB
    [order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,W1,W2,W3,W4,Rp_dB,Rs_dB] = user(handles);
    handles.old_Rp = Rp_dB;
    handles.old_Rs = Rs_dB;
    set(handles.Rpass,'String',num2str(Rp_dB));
    set(handles.Rstop,'String',num2str(Rs_dB));
    % update units (dB)
    filt_num=get(handles.Filter,'Value');

    if filt_num<8
        set([handles.unitsRpass,handles.unitsRstop],'vis','on');
    else
        set([handles.unitsRpass,handles.unitsRstop],'vis','off');
    end
    set(handles.menu_y_scale,'checked','on');

    if filt_num<8
        handles = PlotButton_Callback(gcbo,[],guidata(gcbo));   %newfilter('PlotButton_Callback',gcbo,[],guidata(gcbo))
    else
        handles = PlotGraph(handles);
    end
else
    [order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,W1,W2,W3,W4,Rp_dB,Rs_dB] = user(handles);
    handles.old_Rp = Rp;
    handles.old_Rs = Rs;
    set(handles.Rpass,'String',num2str(Rp));
    set(handles.Rstop,'String',num2str(Rs));
    % update units
    set([handles.unitsRpass,handles.unitsRstop],'vis','off');

    set(handles.menu_y_scale,'checked','off');
    filt_num=get(handles.Filter,'Value');
    if filt_num<8
        handles = PlotButton_Callback(gcbo,[],guidata(gcbo));
    else
        handles=PlotGraph(handles);
    end  
end
guidata(handles.figure1,handles);
% --------------------------------------------------------------------
function varargout = menu_grid_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
axes(handles.Plot1);
if strcmp(get(h,'checked'),'on')
    grid off;
    set(gcbo,'Checked','off');
else
    grid on;
    set(gcbo,'Checked','on');
end
% --------------------------------------------------------------------
function varargout = menu_zoom_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% zoom button in menu
axes(handles.Plot1);
if strcmp(get(h,'checked'),'on')
    set(handles.zoomText,'visible','off');
    zoom off;
    set(gcbo,'Checked','off');
else
    set(handles.zoomText,'visible','on');
    zoom on;
    set(gcbo,'Checked','on');
end
% --------------------------------------------------------------------
function varargout = menu_help_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
MATLABVER = versioncheck(6);
hBar = waitbar(0.25,'Opening internet browser...','color',get(handles.figure1,'color'));
DefPath = which(mfilename);
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
URL = [ DefPath(1:end-length(mfilename)-2) , 'help/','index.html'];
if MATLABVER >= 6
    STAT = web(URL,'-browser');
else
    STAT = web(URL);
end
waitbar(1);
close(hBar);
switch STAT
    case {1,2}
        s = {'Either your internet browser could not be launched or' , ...
            'it was unable to load the help page.  Please use your' , ...
            'browser to read the file:' , ...
            ' ', '     index.html', ' ', ...
            'which is located in the filter help directory.'};
        errordlg(s,'Error launching browser.');
end
% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function Plot1_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate Plot1
function Plot1_ButtonDownFcn(hObject, eventdata, handles)
function Rpass_ButtonDownFcn(hObject, eventdata, handles)
function FilterMenu_CreateFcn(hObject, eventdata, handles)
function WindowsMenu_CreateFcn(hObject, eventdata, handles)
%====================================================================
function SetFIRMenu(handles)
%====================================================================
f1 = num2str(get(handles.Fpass1,'string'));
f3 = num2str(get(handles.Fpass2,'string'));
fs = str2num(get(handles.Fsamp,'string'));
fir_num = get(handles.FilterMenu,'Value'); %%selecting which one of the filters is selected
names = {'LP','HP','BP','BR'};    % should appear in same order as pull down menu
fir_name = names{fir_num};    % get all values

switch fir_name
    case 'LP'
        set(handles.Fpass1Tag,'String','Fcutoff');
        set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFpass2],'vis','off');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1,'String', num2str(4/16) );   % set default values
            set(handles.unitsFpass1,'vis','off');
        else
            set(handles.Fpass1, 'String', num2str(ceil(2*fs/16)));      % set default values
            set(handles.unitsFpass1,'vis','on');
        end

    case 'HP'
        set(handles.Fpass1Tag,'String','Fcutoff');
        set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFpass2],'vis','off');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1,'String', num2str(4/16) );   % set default values
            set(handles.unitsFpass1,'vis','off');
        else
            set(handles.Fpass1, 'String', num2str(ceil(3*fs/16)));     % set default values
            set(handles.unitsFpass1,'vis','on');
        end
    case 'BP'
        set(handles.Fpass1Tag,'String','Fcutoff1');
        set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFpass2],'vis','on');
        set(handles.Fpass2Tag,'String','Fcutoff2');

        %         handles.Line1aXData=get(handles.Line1a,'XData');     % find line data
        %         handles.Line3XData=get(handles.Line3,'XData');

        if strcmp(get(handles.menu_x_scale,'checked'),'on')     % normalized freq
            set(handles.Fpass1, 'String', num2str(4/16));       % set default values
            set(handles.Fpass2, 'String', num2str(8/16));
            set([handles.unitsFpass1,handles.unitsFpass2],'vis','on');

        else
            set(handles.Fpass1, 'String',num2str(ceil(2*fs/16)));      % set default values
            set(handles.Fpass2, 'String',num2str(ceil(3*fs/16)));
            set([handles.unitsFpass1,handles.unitsFpass2],'Vis','on');
        end
    case 'BR'
        set(handles.Fpass1Tag,'String','Fcutoff1');
        set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFpass2],'vis','on');
        set(handles.Fpass2Tag,'String','Fcutoff2');

        if strcmp(get(handles.menu_x_scale,'checked'),'on') % normalized freq
            set(handles.Fpass1, 'String', num2str(4/16));      % set default values
            set(handles.Fpass2, 'String', num2str(8/16));
            set([handles.unitsFpass1,handles.unitsFpass2],'vis','on');

        else
            set(handles.Fpass1, 'String',num2str(ceil(2*fs/16)) );      % set default values
            set(handles.Fpass2, 'String',num2str(ceil(3*fs/16)) );
            set([handles.unitsFpass1,handles.unitsFpass2],'Vis','on');
        end
end
%====================================================================
% --- Executes on selection change in WindowsMenu.
%====================================================================
function WindowsMenu_Callback(hObject, eventdata, handles)
handles = PlotGraph(handles);
guidata(handles.figure1,handles);
%====================================================================
function FilterMenu_Callback(hObject, eventdata, handles)
%====================================================================
SetFIRMenu(handles);
handles = PlotGraph(handles);
guidata(handles.figure1,handles);
%====================================================================
%Plots the FIR filter design graph
%====================================================================
function handles = PlotGraph(handles)
%====================================================================
% WINDOWS MENU
win_num = get(handles.WindowsMenu,'Value'); %%selecting which one of the filters is selected
names = {'Rect','Bart','Hann','Hamm','Black','Gauss','DolphCheby','Lanc'};    % ('BarcTemes') should appear in same order as pull down menu
win_name = names{win_num};    % get all values
N = str2num(get(handles.Order,'String'));

len = N+1;
[order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,w1,w2,w3,w4] = user(handles);

% FILTER MENU
fir_num = get(handles.FilterMenu,'Value');  %selecting which one of the filters is selected
names = {'LP','HP','BP','BR'};              % should appear in same order as pull down menu
fir_name = names{fir_num};                  % get all values

switch fir_name
    case 'LP'
        wc = w1*pi;
        handles.imp_res = [];
        for n = 0:len-1
            if n == N/2
                handles.imp_res(n+1) = wc/pi;
            else
                handles.imp_res(n+1) = (sin(wc*(n-N/2)))./(pi*(n-N/2));
            end
        end
        set(handles.PlotTitle, 'String',['Lowpass Filter of Order ' num2str(get(handles.Order,'String'))]);
    case'HP'
        wc=w1*pi;
        handles.imp_res = [];
        if mod(N,2)~=0
            errordlg('Order must be even');
            set(handles.Order,'String',num2str(N+1));
            len = N+2;
            N   = N+1;
        end
        for n = 0:len-1
            if n == N/2
                handles.imp_res(n+1) = 1-(wc/pi);
            else
                handles.imp_res(n+1) = ((sin(pi*(n-N/2)))-(sin(wc*(n-N/2))))./(pi*(n-N/2));
            end
        end
        set(handles.PlotTitle,'String',['Highpass Filter of Order ' num2str(get(handles.Order,'String'))]);
    case 'BP'
        w1 = w1*pi;
        w3 = w3*pi;
        handles.imp_res = [];
        for n = 0:len-1
            if n == N/2
                handles.imp_res(n+1) = (w3/pi)-(w1/pi);
            else
                handles.imp_res(n+1) = ((sin(w3*(n-N/2)))-(sin(w1*(n-N/2))))./(pi*(n-N/2));
            end
        end
        set(handles.PlotTitle, 'String',['Bandpass Filter of Order ' num2str(get(handles.Order,'String'))]);
    case 'BR'
        w1 = w1*pi;
        w3 = w3*pi;
        handles.imp_res = [];
        if mod(N,2) ~= 0
            errordlg('Order must be even');
            set(handles.Order,'String',num2str(N+1));
            len = N+2;
            N   = N+1;
        end
        for n = 0:len-1
            if n == N/2
                handles.imp_res(n+1) = 1-(w3/pi)+(w1/pi);
            else
                handles.imp_res(n+1) = (sin(w1*(n-N/2))+sin(pi*(n-N/2))-sin(w3*(n-N/2)))./(pi*(n-N/2));
            end
        end
end

switch win_name
    case 'Rect'
        handles.winfun = [];
        handles.winfun = ones(1,len);
    case 'Bart'
        handles.winfun = [];
        if rem(len,2) == 0
            for k = 0:(len/2)-1
                handles.winfun(k+1)=(2*k/(len-1));
            end
            for k = (len/2):(len-1)
                handles.winfun(k+1)=(2*(len-k-1))/(len-1);
            end
        else
            for k = 0:(len-1)/2
                handles.winfun(k+1)=(2*k/(len-1));
            end
            for k = ((len-1)/2):(len-1)
                handles.winfun(k+1)=2-(2*k)/(len-1);
            end
        end
    case 'Hann'
        handles.winfun = [];
        k = 0:len-1;
        handles.winfun(k+1) = 0.5-0.5*cos(2*pi*k/(len-1));
    case 'Hamm'
        handles.winfun = [];
        k = 0:len-1;
        handles.winfun(k+1) = 0.54-0.46*cos(2*pi*k/(len-1));
    case 'Black'
        handles.winfun = [];
        k = 0:len-1;
        handles.winfun(k+1) = 0.42-(0.5*cos(2*k*pi/(len-1)))+(0.08*cos(4*pi*k/(len-1)));
    case 'Gauss'
        handles.winfun = [];
        k = 0:len-1;
        set([handles.alpha, handles.AlphaTag],'vis','on');
        alpha = str2num(get(handles.alpha,'String'));
        handles.winfun(k+1) = exp(-.5*(((alpha*(k-(len-1)/2))/((len-1)/2)).^2));
    case 'DolphCheby'
        handles.winfun = [];
        k = 0:len-1;
        alpha = 3.0;
        beta = cosh((acosh(10^alpha)/(len-1)));
        num = cos(len*acos((beta*cos(pi*k/(len-1)))));
        den = cosh(len*acosh(beta));
        win = ((-1).^k).*num./den;
        win = abs(ifft(win));
        win = win/max(win);
        handles.winfun=win;
    case 'BarcTemes'
        handles.winfun = [];
        k = 0:len-1;
        alpha = 3.0;
        C = acosh(10^alpha);
        beta = cosh(C/(len-1));
        A = sinh(C);
        B = cosh(C);

        y = len*acos(beta*cos(pi*k/(len-1)));
        num = (A.*cos(y)) + (B*(y.*sin(y)/C));
        den = (C+A*B)*((y/C).^2 +1);
        
        win = ((-1).^k).*num./den;
        win = abs(ifft(win));
        win = win/max(win);
        handles.winfun = win;
    case 'Lanc'
        handles.winfun = [];
        for k = 0:len-1
            if k == N/2;
                handles.winfun(k+1) = 1;
            else
                handles.winfun(k+1) = (sin((k-(N)/2)*pi/len))/((k-N/2)*pi/len);
            end
        end
end

if win_num == 6
    set([handles.alpha, handles.AlphaTag],'vis','on');
else
    set([handles.alpha, handles.AlphaTag],'vis','off');
end

%Find the total response
handles.total_res = (handles.imp_res).*(handles.winfun);

%Assigns the designed filter coefficients to b(num) and a(den)
handles.b = handles.total_res;
handles.a = 1;
set([handles.Line1a, handles.Line1b, handles.Line3, handles.Line4a,...
    handles.Line4b, handles.Line5a, handles.Line5b, handles.Line6,...
    handles.Line2],'vis','off');
[h w] = freekz(handles.total_res,1,512);

handles.h = h;
handles.w = w;
% h = h/max(abs(h));

if strcmp(get(handles.VariousResp,'selected'),'on')
    if strcmp(get(handles.ImpResp,'vis'),'off')
        ImpResp_Callback([],[],handles);
    elseif strcmp(get(handles.PhaseResp,'vis'),'off')
        PhaseResp_Callback([],[],handles);
    elseif strcmp(get(handles.PoleZero,'vis'),'off')
        PoleZero_Callback([],[],handles);
    else strcmp(get(handles.MagResp,'vis'),'off')
        MagResp_Callback([],[],handles);
    end
else

    yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; % 1-Mag, 2-Mag (dB)
    xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm

    if xscale==1 & yscale==1,           % frequency in Hz, linear amplitude

        set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',abs(h) )
        set(handles.LineGreen,'xdata',[0,fs/2],'ydata',[0,0],'color','g')
        set(handles.Plot1, 'Ylim', [-.1 1.2],'Xlim',[0 fs/2]);
        set(get(handles.Plot1,'Xlabel'),'string','Frequency (Hz)');
        set(get(handles.Plot1,'Ylabel'),'string','Magnitude');

    elseif xscale==2 & yscale==1,       % frequency normalized, linear amplitude

        set(handles.LineMain,'xdata',w/pi,'ydata',abs(h) )
        set(handles.LineGreen,'xdata',[0 1],'ydata',[0,0],'color','g')
        set(handles.Plot1, 'Ylim', [-.1 1.2],'Xlim',[0 1]);
        set(get(handles.Plot1,'Xlabel'),'string','Frequency (Normalized)');
        set(get(handles.Plot1,'Ylabel'),'string','Magnitude');

    elseif xscale==1 & yscale==2,       % frequency in Hz, dB amplitude

        idx_zero = find (abs(h) == 0 );
        if ~isempty(idx_zero)
            h(idx_zero) = sqrt(-1)*1e-15;
        end
        set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',20*log10(abs(h)) )
        set(handles.LineGreen,'xdata',[],'ydata',[],'color','g')
        set(handles.Plot1, 'Ylim', [-80 10],'Xlim',[0 fs/2]);
        set(get(handles.Plot1,'Xlabel'),'string','Frequency (Hz)');
        set(get(handles.Plot1,'Ylabel'),'string','Magnitude (dB)');

    else                                % frequency normalized, dB amplitude

        idx_zero = find (abs(h) == 0 );
        if ~isempty(idx_zero)
            h(idx_zero) = sqrt(-1)*1e-15;
        end
        set(handles.LineMain,'xdata',w/pi,'ydata',20*log10(abs(h)) )
        set(handles.LineGreen,'xdata',[],'ydata',[],'color','g')
        set(handles.Plot1, 'Ylim', [-80 10],'Xlim',[0 1]);
        set(get(handles.Plot1,'Xlabel'),'string','Frequency (Normalized)');
        set(get(handles.Plot1,'Ylabel'),'string','Magnitude (dB)');
    end
end

if strcmp(get(handles.ImpResp,'vis'),'off')
    if get(handles.WindowPlot,'value') == 0
        WindowPlot_Callback([],[],handles)
    end
end

guidata(handles.figure1,handles);
%====================================================================
function VariousResp_Callback(hObject, eventdata, handles)
%====================================================================
set(handles.menu_y_scale,'vis','off');
set(handles.VariousResp,'selected','on');
%====================================================================
function ImpResp_Callback(hObject, eventdata, handles)
%====================================================================
set([handles.ImpResp,handles.LineCirc,handles.HorzLine,...
    handles.VertLine,handles.PoleLine,handles.menu_x_scale,handles.menu_y_scale...
    handles.LineMain,handles.TextPole],'vis','off');
set(handles.WindowPlot,'vis','on');
set([handles.PhaseResp,handles.MagResp,handles.PoleZero],'vis','on');
N = str2num(get(handles.Order,'String'));

win_num = get(handles.WindowsMenu,'Value'); %%selecting which one of the filters is selected
names = {'Rect','Bart','Hann','Hamm','Black','Gauss','DolphCheby','Lanc'};    % ('BarcTemes') should appear in same order as pull down menu
win_name = names{win_num};    % get all values

if win_num == 6
    set([handles.alpha, handles.AlphaTag],'vis','on')
else
    set([handles.alpha, handles.AlphaTag],'vis','off')
end

%%Plot the rectangular window
yda1 = [0:0.01:max(handles.winfun*max(handles.imp_res))];
xda(1:length(yda1))=0;
yda2 = [0 max(handles.winfun*max(handles.imp_res))];
xda1 = [N N];

lim = max(max(handles.imp_res),min(abs(handles.imp_res)));

if get(handles.WindowsMenu,'value') == 1
    set(handles.VertLine,'vis','on','xdata',xda,'ydata',yda1,'color',[0 0 0]);
    set(handles.HorzLine,'vis','on','xdata',xda1,'ydata',yda2,'color',[0 0 0]);
else
    set([handles.VertLine,handles.HorzLine],'vis','off','color','b');
end

stemdata((0:N),handles.total_res,handles.Plot1,handles.LineStem1,handles.LineStem2);
set(handles.Plot1,'Ylim',[-(1.5*lim) 1.5*lim],'Xlim',[-1 N+1]);

%%plot the windowed/unwindowed response acc. to toggle button selection
if get(handles.WindowPlot,'value') == 0
    set(handles.WindowPlot,'string','Windowed');
else
    set(handles.WindowPlot,'string','Unwindowed');
end

%takes 200 samples of window and plots the shape of window with finite
%length..add windows accordingly....
winlen = 200;
switch win_name
    case 'Rect'
        set(handles.WindowLine,'xdata',[0 N],'ydata',[max(handles.imp_res) max(handles.imp_res)],'vis','on');
    case 'Bart'
        set(handles.WindowLine,'xdata',[0 N/2 N],'ydata',[0 max(handles.imp_res) 0],'vis','on');
    case 'Hann'
        set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*0.5*(1-cos(2*pi*((0:winlen)/winlen))),'vis','on');
    case 'Hamm'
        set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*(0.54-(0.46*cos(2*pi*(0:winlen)/winlen))),'vis','on');
    case 'Black'
        set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*(0.42-(0.5*cos(2*(0:winlen)*pi/winlen))+(0.08*cos(4*pi*(0:winlen)/winlen))),'vis','on');
    case 'Gauss'
        alpha = str2num(get(handles.alpha,'String'));
        k = 0:winlen;
        set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*(exp(-.5*(((alpha*(k-winlen/2))/(winlen/2)).^2))),'vis','on');
    case 'DolphCheby'
        alpha = 3.0;
        beta = cosh((acosh(10^alpha)/winlen));
        num = cos(winlen*acos((beta*cos(pi*(0:winlen-1)/winlen))));
        den = cosh(winlen*acosh(beta));
        win = ((-1).^(0:winlen-1)).*num./den;
        win = abs(ifft(win));
        win = win/max(win);
        win(1) = win(200);
        set(handles.WindowLine,'xdata',(0:N/winlen:N-N/winlen),'ydata',max(handles.imp_res)*win,'vis','on');
    case 'BarcTemes'
        k = 0:winlen-1;
        alpha = 3.5;
        C = acosh(10^alpha);
        beta = cosh(C/winlen);
        A = sinh(C);
        B = cosh(C);

        y = winlen*acos(beta*cos(pi*k/winlen));
        num = (A.*cos(y)) + (B*(y.*sin(y)/C));
        den = (C+A*B)*((y/C).^2 +1);

        win = ((-1).^k).*num./den;
        win = abs(ifft(win));
        win = win/max(win);
        set(handles.WindowLine,'xdata',(0:N/winlen:N-N/winlen),'ydata',max(handles.imp_res)*win,'vis','on');
    case 'Lanc'
        len=winlen;
        n=len-1;
        for k=0:len
            if(k==n/2);
                win(k+1)=1;
            else
               win(k+1)=(sin((k-n/2)*pi/len))/((k-n/2)*pi/len);
            end
        end
       
        set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*win,'vis','on');
end
% set(handles.WindowLine,'xdata',(0:N),'ydata',[(handles.winfun)*max(handles.imp_res)],'vis','on')

set(handles.LineGreen,'xdata',[-1 N+1],'ydata',[0 0],'vis','on');
set([handles.LineStem1,handles.LineStem2],'vis','on');
% set(handles.Plot1,'Ylim',[-0.1+min(handles.total_res) 0.1+max(handles.total_res)],'Xlim',[-1 N+1]);
set(get(handles.Plot1,'Xlabel'),'string','Samples');
set(get(handles.Plot1,'Ylabel'),'string','Magnitude','pos',[-0.1 0.5 0]);
set(handles.PlotTitle,'string','Impulse Response of the Filter');
guidata(handles.figure1,handles);
%====================================================================
function PhaseResp_Callback(hObject, eventdata, handles)
%====================================================================
fs = str2num(get(handles.Fsamp,'String'));
set([handles.LineCirc,handles.HorzLine,handles.VertLine,handles.PoleLine,handles.TextPole], 'vis','off');

win_num=get(handles.WindowsMenu,'Value');

if win_num == 6
    set([handles.alpha, handles.AlphaTag],'vis','on')
else
    set([handles.alpha, handles.AlphaTag],'vis','off')
end

set([handles.LineStem1,handles.LineStem2,handles.PhaseResp,handles.menu_y_scale],'vis','off');
set([handles.menu_x_scale,handles.ImpResp,handles.MagResp,handles.PoleZero],'vis','on');
set(handles.LineMain,'vis','on','marker','none','linestyle','-');

[h w] = freekz(handles.total_res,1,512);
ang = unwrap(angle(h));

if(strcmp(get(handles.menu_x_scale,'checked'),'off'));
    set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',ang);
    set(handles.Plot1,'Xlim',[0 fs/2]);
else
    set(handles.LineMain,'xdata',w/pi,'ydata',ang);
    set(handles.Plot1,'Xlim',[0 1]);
end

% Account for sampling error when determining YLim
if mod(min(ang/pi),pi/2) < 0.05*pi
    Ylim_min = (mod(abs(min(ang/pi)),pi/2)-pi/2) + min(ang/pi);
else
    Ylim_min = min(ang/pi);
end
Ylim_max = max(ang/pi);

%---------
% determine new yticks (symbolic multiples of pi/2)
handles.old_font = get(handles.Plot1,'fontname');
set(handles.Plot1,'fontname','symbol')
if length([round(Ylim_min):Ylim_max]) < 5
    ytick = [round(Ylim_min):0.5:Ylim_max];
else
    ytick = [round(Ylim_min):Ylim_max];
end

for k = 1:length(ytick)
    if ytick(k) == 0
        ytickL{k} = '0';
    elseif ytick(k) == 1
        ytickL{k} = 'p ';
    elseif ytick(k) == -1
        ytickL{k} = '-p ';
    else
        ytickL{k} = sprintf('%s%s',num2str(ytick(k)),'p ');
    end
end
%---------
set(handles.Plot1,'Ylim',[Ylim_min*pi Ylim_max*pi],'ytick',pi*ytick,'yticklabel',char(ytickL'))
set(handles.LineGreen,'xdata',[],'ydata',[]);
set(get(handles.Plot1,'Xlabel'),'string','Frequency','fontname',handles.fontname);
set(get(handles.Plot1,'Ylabel'),'string','Unwraped Phase','fontname',handles.fontname,'pos',[-0.13 0.5 0]);
set(handles.PlotTitle,'string',['Phase Response of Filter of order ' num2str(get(handles.Order,'String'))],...
    'fontname',handles.fontname);
set([handles.WindowPlot,handles.WindowLine],'vis','off');
%====================================================================
function MagResp_Callback(hObject, eventdata, handles)
%====================================================================
set(handles.Plot1,'fontname',handles.fontname,'YTickMode','auto','YTickLabelMode','auto');
set(handles.VariousResp,'selected','off');
set(handles.WindowPlot,'vis','off');
set(handles.LineMain,'vis','on','marker','none','linestyle','-');
% set(handles.LineStem,'vis','off');
set([handles.ImpResp,handles.PhaseResp,handles.menu_y_scale,handles.menu_x_scale],'vis','on');
set([handles.MagResp,handles.LineStem1,handles.LineStem2],'vis','off');
handles = PlotGraph(handles);
set(handles.PoleZero,'vis','on');
set([handles.LineCirc,handles.HorzLine,handles.VertLine,handles.PoleLine,handles.TextPole,handles.WindowPlot,handles.WindowLine],'vis','off');
guidata(handles.figure1,handles);

%%drawing the pole-zero plot...draw circle using sin and cos...
%find the roots of fliplr(b);
%separate the real and imaginary parts and plot them..
%plot the xdata as real and y data as imaginary..
%for FIR filters a=1,b=fliplr(b) no of poles=no of zeros and poles at z=0;
% =====================================================================
function PoleZero_Callback(hObject, eventdata, handles)
% =====================================================================
set(handles.PoleZero,'vis','off');
set([handles.ImpResp,handles.MagResp,handles.LineMain,handles.PhaseResp,...
    handles.LineCirc,handles.PoleLine],'vis','on');
set([handles.menu_x_scale,handles.menu_y_scale,handles.LineStem1, ...
    handles.LineStem2,handles.WindowPlot,handles.WindowLine],'vis','off');

win_num=get(handles.WindowsMenu,'Value');
if win_num == 6
    set([handles.alpha, handles.AlphaTag],'vis','on')
else
    set([handles.alpha, handles.AlphaTag],'vis','off')
end

b=fliplr(handles.total_res);
roots_b=roots(b);

ind=find((abs(roots_b)>1.0e+06 | abs(roots_b)<1.0e-06));
roots_b(ind) = [];

if ~isempty(find(roots_b==0))
    net_poles=length(roots_b)-length(find(roots_b==0));
    roots_b(find(roots_b==0))=[];
else
    net_poles=length(roots_b);
end
real_b = real(roots_b);
img_b = imag(roots_b);

max_no=ceil(max(max(abs(real_b),abs(img_b)))); %find max no out of real and img part...
%and ceil it to keep the unit circle
%in middle of the plot
xda = -(1.1*max_no):0.01:1.1*max_no;
yda(1:length(xda)) = 0;

set(handles.LineMain,'xdata',real_b,'ydata',img_b,'marker','o','LineStyle','none','MarkerSize',7);
set(handles.TextPole,'vis','on','position',[0.08 0.1 0],'string',num2str(net_poles));
set(handles.HorzLine,'xdata',xda,'ydata',yda,'vis','on');
set(handles.VertLine,'xdata',yda,'ydata',xda,'vis','on');
set(handles.LineGreen,'xdata',[],'ydata',[]);
set(handles.Plot1,'fontname',handles.fontname,'YTickMode','auto','YTickLabelMode','auto','XLim',[-(1.1*max_no) 1.1*max_no],'YLim',[-(1.1*max_no) 1.1*max_no]);

set(get(handles.Plot1,'Xlabel'),'string','Real');
set(get(handles.Plot1,'Ylabel'),'string','Imaginary','pos',[-0.1 0.5 0]);
set(handles.PlotTitle,'string',['Pole-Zero Plot of Filter of order ' num2str(get(handles.Order,'String'))]);

%=========================================================================
function WindowPlot_Callback(hObject, eventdata, handles)
%=========================================================================
set([handles.LineCirc,handles.HorzLine,handles.VertLine,handles.PoleLine],'vis','off');
N=str2num(get(handles.Order,'String'));
set(handles.LineMain,'vis','off');
set(handles.LineGreen,'xdata',[-1 N+1],'ydata',[0 0],'vis','on');
set([handles.menu_x_scale,handles.menu_y_scale],'vis','off');
set(get(handles.Plot1,'Xlabel'),'string','Samples');
set(get(handles.Plot1,'Ylabel'),'string','Magnitude','pos',[-0.1 0.5 0]);

yda1 = 0:0.01:max(handles.winfun*max(handles.imp_res));
xda(1:length(yda1)) = 0;
yda2 = [0 max(handles.winfun*max(handles.imp_res))];
xda1 = [N N];

lim = max(max(handles.imp_res),min(abs(handles.imp_res)));
set([handles.LineStem1,handles.LineStem2],'vis','on');

if(get(handles.WindowsMenu,'value')==1)
    set(handles.VertLine,'vis','on','xdata',xda,'ydata',yda1,'color',[0 0 0]);
    set(handles.HorzLine,'vis','on','xdata',xda1,'ydata',yda2,'color',[0 0 0]);
else
    set(handles.VertLine,'vis','off','color','b');
end

if get(handles.WindowPlot,'value') == 0
    set(handles.WindowPlot,'string','Windowed');
    stemdata((0:N),handles.total_res,handles.Plot1,handles.LineStem1,handles.LineStem2);
    set(handles.PlotTitle,'string','Windowed Impulse Response');
    set(handles.Plot1,'Xlim',[-1 N+1],'Ylim',[-(1.5*lim) 1.5*lim] );
else
    set(handles.WindowPlot,'string','Unwindowed');
    stemdata((0:N),handles.imp_res,handles.Plot1,handles.LineStem1,handles.LineStem2);
    set(handles.PlotTitle,'string','Unwindowed Impulse Response');
    set(handles.Plot1,'Xlim',[-1 N+1],'Ylim',[-(1.5*lim) 1.5*lim] );
end

win_num=get(handles.WindowsMenu,'Value');
if win_num == 6
    set([handles.alpha, handles.AlphaTag],'vis','on')
else
    set([handles.alpha, handles.AlphaTag],'vis','off')
end
guidata(handles.figure1,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=========================================================================
function alpha_Callback(hObject, eventdata, handles)
%=========================================================================
if (isempty(str2num(get(handles.alpha,'String'))))
    errordlg('Alpha cannot be empty!!')
    set(handles.alpha,'String','2.5');
end
handles = PlotGraph(handles);
guidata(handles.figure1,handles);
%=========================================================================
function alpha_CreateFcn(hObject, eventdata, handles)
%=========================================================================
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end