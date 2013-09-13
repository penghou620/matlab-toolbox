function mypath = SPFirst
% Run this to update the MATLAB path to include the MATLAB demos.
%   Sinusoid Drill (sindrill)
%   Complex Number Drill (zdrill)
%   Phasor Races (phrace)
%   Fourier Series Demo (fseriesdemo)
%   Continuous to Discrete Sampling Demo (con2dis)
%   Continuous-Time Convolution Demo (cconvdemo)
%   Discrete-Time Convolution Demo (dconvdemo)
%   Continuous LTI Demo (cltidemo)
%   Discrete LTI Demo (dltidemo)
%   PEZ  Pole/Zero Plotter (pezdemo)
%   Music GUI (musicgui)
%   Beat Frequencies
%   Filter Design (filterdesign)
%   Strobe Demo (strobedemo)
% NOTE: this file must be on the MATLAB path

%===========================================================================
% Revision Summary
%===========================================================================
% Jim McClellan, 12-Feb-2010 (spfirst v1.53)
%   : fix computer-dependent file separator in spfirxt.m
%---------------------------------------------------------------------------
% Greg Krudysz, 02-June-2009 (spfirst v1.52)
%   : more general fix for stem('v6', ...) deprecation in con2dis,
%                     dconvdemo, dltidemo, fseriesdemo, and strobedemo
%---------------------------------------------------------------------------
% Greg Krudysz, 6-Mar-2009 (spfirst v1.49)
%   : fix stem('v6', ...) deprecation in dconvdemo,dltidemo
%---------------------------------------------------------------------------
% Jim McClellan, Greg Krudysz, 6-Mar-2008 (spfirst v1.48)
%   : Bug fixes in cltidemo, v2.52
%   : Added @spfirst_coord and bug fixes to filterdesign, v2.7
%---------------------------------------------------------------------------
% Jim McClellan, Greg Krudysz, 6-Mar-2008 (spfirst v1.47)
%   : Bug fixes in dltidemo, v2.5
%---------------------------------------------------------------------------
% Greg Krudysz, 4-Mar-2008 (spfirst v1.46)
%   : Removed SSN from nveloper.m, edited for warnings in woodwenv.m
%   : Fixed bug in Filterdesign
%---------------------------------------------------------------------------
% Greg Krudysz, 4-Dec-2007 (spfirst v1.44)
%   : Final release for Spring 2008 semester
%   : Updated Filterdesign & Pezdemo
%---------------------------------------------------------------------------
% Greg Krudysz, 26-Oct-2007 (spfirst v1.41)
%   : MATLAB R2007a update
%   : Updated Pezdemo, C/Dconvdemo
%---------------------------------------------------------------------------
% Greg Krudysz, 18-Jan-2007 (spfirst v1.40)
%   : Final release for Spring 2007 semester
%   : Updated Pezdemo and FilterDesign
%---------------------------------------------------------------------------
% Krudysz, 19-Mar-2006 (spfirst v1.36)
% Updated Pezdemo
%---------------------------------------------------------------------------
% Krudysz, 19-Mar-2006 (spfirst v1.35)
% Filterdesign update version 1.47 (from 1.3) (FIR filters addition)
% Fixed bugs in /updated  cltidemo and pezdemo
%---------------------------------------------------------------------------
% Krudysz, Velmurugan, 30-Dec-2005 (spfirst v1.26)
% Matlab 7.1 Update: 
%   : Addressed problems with axes() function in ML 7.1
%   : Renamed g/setuprop to g/setappdata, datestr, mode fcns
%   : Updated linewidthdlg.m
%---------------------------------------------------------------------------
% Greg Krudysz, 17-Dec-2004 (spfirst v1.25)
%   : Final release for Spring 2005 semester
%   : Added 'movietool' object for GUI recoring and playback
%     for con2dis,cltidemo,dltidemo,fseriesdemo,pezdemo
%---------------------------------------------------------------------------
%
%   fseriesdemo  v1.21
%   cconvdemo    v2.12
%   con2dis      v2.1
%   cltidemo     v2.52
%   dconvdemo    v3.1
%   dltidemo     v2.6
%   pezdemo      v2.84
%   filterdesign v2.71
%   strobedemo   v1.42

% if strcmp(computer,'PCWIN'),   Sep='\';
% elseif strcmp(computer,'MAC2'),  Sep=':';
% else,  Sep='/';
% end;
%----****----Use filesep instead

SP1_path = which('spfirst');
if(strcmp(SP1_path, ''))
    error('>> spfirst.m  must be in a directory already on your MATLAB path');
end

%% xx = findstr(SP1_path, Sep);
%% xx = xx(length(xx));	    % get last element of xx
%% SP1_path = SP1_path(1:xx-1);	% chop off dspfirst.m

SP_path = fileparts(SP1_path);

ALL_dirs = {'sindrill', 'zdrill', 'fseriesdemo', 'phasorraces',...
            'cltidemo', 'dltidemo', 'cconvdemo', 'dconvdemo',...
            'pezdemo', 'con2dis', 'musiclab', 'filterdesign', 'strobedemo' };
for kk = 1:length(ALL_dirs)
    if exist([SP_path, filesep, ALL_dirs{kk}],'dir')
        path(path,[SP_path, filesep, ALL_dirs{kk}]);
    end
end

mypath = path;
