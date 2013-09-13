%---------------------------------------------------------------------------
% Filter Demo version 1.00 (08-Nov-2004)
%---------------------------------------------------------------------------
%  : Created by Milind Borkar 
%       Undergraduate Research Project (Summer 2002 - Fall 2002)
%       Completed under the advisement of Dr. James McClellan
%
%  : FIR filters added by Milan Doshi
%       Graduate Research Project (Summer 2005 - Spring 2006)
%
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%
% If there is any other bug that you found while running the program or 
% questions, please let me know by sending email to: 
%
%   Professor James McClellan (james.mcclellan@ece.gatech.edu)

%===========================================================================
% Revision Summary
%===========================================================================
% Milan Doshi, G Krudysz 8-Mar-2006 (ver. 1.47)
%       Release for Spring 2006
%       Added FIR filters (Milan)
%       Added context menus (Milan)
%       Symbolic phase, code restructuring, HTML mods, rewrote coeff_dlg (Greg)
%---------------------------------------------------------------------------
% G Krudysz 15-Jul-2005 (ver. 1.25)
%       Spfirst release for Fall 2005
%       Added SPTcheck.m
%       Added x-Normalized and y-dB control option, added unit texts
%       Rewrote user.m; re-structured code for readability/efficiency
%---------------------------------------------------------------------------
% G Krudysz 22-Nov-2004 (ver. 1.10)
%       Fixed scaling issues, figure is saved in "pixel" units, then
%       rescaled in "norm" units, see "Re-center and normalalize figure"
%---------------------------------------------------------------------------
% G Krudysz 07-Nov-2004 (ver. 1.00)
%       Replaced installcheck.m for version 7.0
%---------------------------------------------------------------------------
% G Krudysz 20-Apr-2003 (ver. 0.90)
%       Made compatible with Matlab R12 (6.0)
%       Added export to workspace, opens coeff_dlg
%---------------------------------------------------------------------------
% G Krudysz 27-Mar-2003 (ver. 0.89) 
%       Added default plot, deleted "plot" button
%       Rewrote code for line objects/props
%       Reorganized menus
%---------------------------------------------------------------------------
% G Krudysz 07-Mar-2003 (ver. 0.81)
%       Added Version check, pathcheck
%       Added hand over line capability
%       Added 'Set Line Width' menu, checks
%       fixed figure properties, warnings 
%---------------------------------------------------------------------------
%===========================================================================
% Known Issues
%==========================================================================
%=
% Took out "Barcilon-temes" FIR filter - needs additional work (Greg)
% Resize problems in MATLAB 7.0.x

% bugs present in the GUI
% 
% 1. Bug related to bandpass back and forth
% 2. Gaussian window implementation
% 3. Barcelion-temes window implementation
% 4. old value of passband freq not stored and updated in fpass1
% 5. go to bandpass change the parameters and go back to buttlow parameters get reintialized
% 6. so coming back from buttlow to FIR menu...has reinitialized parameters rather than the old paramters
% 7. this happens between IIR filters also..hence a person to see the high pass and lowpass for same cut off frequency 
%    would have to change all the parameters in order to visualize it...
% 8. MOST IMP change at line 260,349
% 
% 
% 
% problem faced was in the setappdata and getappdata---wherein 
% one obtained handles to the current callback figure and set it to a name called datastructure....
% hence all the previously saved handles for imp_res and total_res as well as the oldpass1 and oldpass2...
% hence those were delted from fpss1 and fpass2 calback functions..hopefully they didnt create a probelm for the 
% rest of teh code...
% 
% 
% 
% 3 Dec. 2005
% either i can keep the default values when one comes back from the previous stage or i can change the values
% so...to decide what to do....
% one main problem being faced is that when u go in the filterdesign menu for the first time
% and give an illegal value it cant recognize that...
% 
% 
% order 2 hanning, bartlett and hamming window problems....in magnitude response...
% in case of impulse response able to get the output...
% 
% 
% problems for different windows
% A. magnitude response
%     1. rectangular--no problem till now
%     2. bartlett-- order 1...since 2-len bartlett window  would give a zero output
%                   order 2..throughout flat response...since only one point is available after windowing
%                   order 3...higher cutoff freq...no change in mag response....
%     3. hanning--  order 1..not possible 
%                   order 2..same response as bartlett with order 2
%                   order 3..same behavior as bartlett with order 3 
%     4. hamming--  order 1..same behavior as bartlett with order 3
%                   order 2..mag response not at all satisfactory....considering the filter type.
%     5. blackmann--order 1..same behavior as bartlett with order 3
%                   order 2..same behavior as bartlett with order 2
%                   order 3..same behavior as bartlett with order 3
% 
% changes made today
% changed the limits for the windowed and unwindowed impulse response
% changed the markersize in pole zero callback
% changed the limits in pole and zero
% 
% 
% ----
% Jan 7
% Phase response in terms of pi yet to change..
% 
% -----
% In the help section..do i have to change the revised version date as well as the version