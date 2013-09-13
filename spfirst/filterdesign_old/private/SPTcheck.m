function SPTcheck()
%SPTCHECK Check for Signal Processing Toolbox installation.
%   This check determines whether or not SPT has been installed,
%   if it is not found, then an error message is displayed.

% Greg Krudysz, 15-Jul-2005

A = ver;

% Look for SPT installation
error_inst = 1;
for k = 1:length(A)
    if strcmp(A(k).Name,'Signal Processing Toolbox')
        error_inst = 0;
    end
end

% Look for SPT path
error_path = 1;
if 1
    P = path;
    str = fullfile('toolbox','signal','signal');
    match = findstr(P,str);
    if ~isempty(match)
        error_path = 0;
    end
end

if error_inst
    msg = ['This program requires Signal Processing Toolbox (SPT) to be ', ...
            'installed on your machine.  Please either re-install SPT  ', ...
            'and/or make sure that SPT has been added to the MATLAB''s path. '];
    error(msg);
elseif error_path
    msg = ['This program requires Signal Processing Toolbox (SPT) to be ', ...
           'on MATLAB path, please make sure that SPT has been added to the MATLAB''s path. '];
    error(msg);
end


%end function
%eof: SPTcheck.m
