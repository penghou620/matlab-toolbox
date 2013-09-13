function [order_type,fs,f1,f2,f3,f4,Rp,Rs,ord,yscale,xscale,W1,W2,W3,W4,Rp_dB,Rs_dB] = user(handles);
% Repetative code 

yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; % 1-Mag, 2-Mag (dB)
xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm
order_type = get(handles.SetOrder,'Value');
fs = str2num(get(handles.Fsamp,'String'));

if (xscale - 1)
    % passband and stopband values are in normalized units
    W1 = str2num(get(handles.Fpass1,'String'));
    W2 = str2num(get(handles.Fstop1,'String'));
    W3 = str2num(get(handles.Fpass2,'String'));
    W4 = str2num(get(handles.Fstop2,'String'));
    
    % convert to frequencies in Hz
    f1 = W1*fs/2;
    f2 = W2*fs/2;
    f3 = W3*fs/2;
    f4 = W4*fs/2; 
else
    % passband and stopband values are in Hz units
    f1 = str2num(get(handles.Fpass1,'String'));
    f2 = str2num(get(handles.Fstop1,'String'));
    f3 = str2num(get(handles.Fpass2,'String'));
    f4 = str2num(get(handles.Fstop2,'String'));
    
    % convert to normalized frequencies
    W1=f1/fs*2;                                 
    W2=f2/fs*2;
    W3=f3/fs*2;
    W4=f4/fs*2;
end

if (yscale - 1)
    % magnitude is in dB 
    Rp_dB = str2num(get(handles.Rpass,'String'));
    Rs_dB = str2num(get(handles.Rstop,'String'));
    
    Rp = abs(10^(Rp_dB/20)-1);
    Rs = 10^(Rs_dB/20);
else
    % magnitude is linear
    Rp = str2num(get(handles.Rpass,'String'));
    Rs = str2num(get(handles.Rstop,'String'));
    
    Rp_dB = 20*log10(1-Rp);
    Rs_dB = 20*log10(Rs);
end
ord = str2num(get(handles.Order,'String'));