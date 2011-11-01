function [y, t, info, ind_over, ind_under] = wfm2read(filename, datapoints);
% function [y, t, info, ind_over, ind_under] = wfm2read(filename, datapoints);
%
% loads YT-waveform data from *.wfm file saved by Tektronix TDS5000B, TDS6000B,
% or TDS7000B Oscilloscopes into the variables y (y data) and t (time
% data). The structure "info" contains information about units and
% digitizing resolution of the y data. The matrices ind_over and ind_under 
% contain the indices of overranged data points outside the upper / lower
% limit of the TDS AD converter.
% 
% Reading of *.wfm files written by other than the above Oscilloscopes may
% result in errors, since the file format seems not to be downward compatible.
% Other projects exist for the older format, e.g. wfmread.m by Daniel Dolan.
% Everyone who wants to improve or extend this code is allowed to do that, 
% however, only by permission of the author in order to track and organize 
% changes.
% The code can be used in non-profit projects if the author is properly cited.
% 
% Author:
% Erik Benkler
% Physikalisch-Technische Bundesanstalt
% Section 4.53: Microoptics Measuring Technologies
% Bundesallee 100
% D-38116 Braunschweig
% Germany
% Erik.Benkler@ptb.de
%
% The implementation is based on Tektronix OpenChoice Solutions SDK-Article 001-1378-01 (April 2004): 
% "TDS5000, TDS6000, and TDS7000 Oscilloscope Reference File Format"
% available at: http://www.tek.com/Measurement/Solutions/openchoice/docs/articles/001137801.pdf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% current state of the project and change history:
% 
% Version 1.4, November 11, 2005:
% (a)   changed to read unit string until NULL string only.
%
% Version 1.3, October 31, 2005 (submitted to FileExchange):
% (a)   Added handling of overranged values. Added two output variables
%       ind_over and ind_under for this purpose.
%
% Version 1.2, July 07, 2005:
% (a)   Added optional second input parameter to limit the number of data
%       points to be read.
%
% Version 1.1, April 12, 2005:
% (a)   Removed the bug that the byte order verification (big-endian vs. little-endian)
%       was disregarded.
% (b)   close file at the end.
% (c)   Checked functionality with YT-waveform measured with TDS6804B scope.
%
% Version 1.0, December 20, 2004
%
% Already done:
% 1) All file fields listed in the SDK article are assigned to variables named like in the SDK article
% 2) Only reading of YT waveform is implemented. It is assumed that the waveform is
% a simple YT waveform. This is not checked and may result in errors when waveform is other than YT.
% 3) Optional WFM#002 format is implemented (footnote 6 in SDK article)
% 4)Checked functionality with YT-waveform measured with TDS5104B scope
%
% Yet to be done:
% 1) reading of XY-wavefroms, Fast Frames etc.
% 2) handle interpolated data
% 3) error checking, e.g. after each file operation, or checking if data is YT waveform should be improved
% 4) only some important header information is output at this stage
% 5) file checksum not yet implemented
% 6) how to handle old format wfm files? Downward compatibility...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% beginning of code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%checking of file name etc.
if nargin==0        
    filename='';
end

if isempty(filename)
    [fname,pname]=uigetfile({'*.wfm', 'Tektronix Waveform Files (*.wfm)';'*.*', 'All Files (*.*)'},'Choose Tektronix WFM file');
    filename=[pname fname];
end

[pname,fname,ext] = fileparts(filename);

if isempty(ext)
    filename=[filename,'.wfm'];
end

if exist(filename)~=2
   error('Invalid file name');
end

[fid,message]=fopen(filename);

if fid==-1
    error(message);
end

%read the waveform static file info 
byte_order_verification = dec2hex(fread(fid,1,'uint16'),4);
if byte_order_verification == '0F0F'
    byteorder='l'; % little-endian byte order
else 
    byteorder='b'; % big-endian byte order
end
versioning_number = char(fread(fid,8,'*char',byteorder)');
num_digits_in_byte_count = fread(fid,1,'*uint8',byteorder);
num_bytes_to_EOF = fread(fid,1,'*int32',byteorder);
num_bytes_per_point = fread(fid,1,'uint8',byteorder); %do not convert to same type, since required as double later
byte_offset_to_beginning_of_curve_buffer = fread(fid,1,'*uint32',byteorder);
horizontal_zoom_scale_factor = fread(fid,1,'*int32',byteorder);
horizontal_zoom_position = fread(fid,1,'*float32',byteorder);
vertical_zoom_scale_factor = fread(fid,1,'*double',byteorder);
vertical_zoom_position = fread(fid,1,'*float32',byteorder);
waveform_label = char(fread(fid,32,'*char',byteorder)');
N = fread(fid,1,'*uint32',byteorder);
size_of_waveform_header = fread(fid,1,'*uint16',byteorder);

%read waveform header
setType = fread(fid,4,'*int8',byteorder); 
wfmCnt = fread(fid,1,'*uint32',byteorder); 
fread(fid,24,'char',byteorder); %skip bytes 86 to 109 (not for use)
wfm_update_spec_count = fread(fid,1,'*uint32',byteorder); 
imp_dim_ref_count = fread(fid,1,'*uint32',byteorder); 
exp_dim_ref_count = fread(fid,1,'*uint32',byteorder); 
data_type = fread(fid,4,'*int8',byteorder);  
fread(fid,16,'char',byteorder); %skip bytes 126 to 141 (not for use)
curve_ref_count = fread(fid,1,'*uint32',byteorder);
num_req_fast_frames = fread(fid,1,'*uint32',byteorder);
num_acq_fast_frames = fread(fid,1,'*uint32',byteorder);
%There's a misprinting in the SDK article, the ":" at the beginning of version number string is missing.
%read optional entry in WFM#002 (and higher?) file format:
if sscanf(versioning_number,':WFM#%3d')>1 % see footnote 6 in SDK Article concerning TDS5000B scopes and version number 002
   summary_frame_type = fread(fid,1,'*uint16',byteorder);
end                                       
pixmap_display_format = fread(fid,4,'*int8',byteorder); 
pixmap_max_value = fread(fid,1,'uint64',byteorder); %storage in a uint64 variable does not work. Uses only double. Bug in Matlab?

%explicit dimension 1
ed1.dim_scale = fread(fid,1,'*double',byteorder);
ed1.dim_offset = fread(fid,1,'*double',byteorder);
ed1.dim_size = fread(fid,1,'*uint32',byteorder);
dummy=fread(fid,20,'*char',byteorder);
ed1.units = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
ed1.dim_extent_min = fread(fid,1,'*double',byteorder);
ed1.dim_extent_max = fread(fid,1,'*double',byteorder);
ed1.dim_resolution = fread(fid,1,'*double',byteorder);
ed1.dim_ref_point = fread(fid,1,'*double',byteorder);
ed1.format = fread(fid,4,'*int8',byteorder);
ed1.storage_type = fread(fid,4,'*int8',byteorder); 
ed1.n_value = fread(fid,1,'*int32',byteorder);
ed1.over_range = fread(fid,1,'*int32',byteorder);
ed1.under_range = fread(fid,1,'*int32',byteorder);
ed1.high_range = fread(fid,1,'*int32',byteorder);
ed1.low_range = fread(fid,1,'*int32',byteorder);
ed1.user_scale = fread(fid,1,'*double',byteorder);
ed1.user_units = char(fread(fid,20,'*char',byteorder)');
ed1.user_offset = fread(fid,1,'*double',byteorder);
ed1.point_density = fread(fid,1,'*uint32',byteorder);
ed1.href = fread(fid,1,'*double',byteorder);
ed1.trig_delay = fread(fid,1,'*double',byteorder);

%explicit dimension 2
ed2.dim_scale = fread(fid,1,'*double',byteorder);
ed2.dim_offset = fread(fid,1,'*double',byteorder);
ed2.dim_size = fread(fid,1,'*uint32',byteorder);
dummy=fread(fid,20,'*char',byteorder);
ed2.units = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
ed2.dim_extent_min = fread(fid,1,'*double',byteorder);
ed2.dim_extent_max = fread(fid,1,'*double',byteorder);
ed2.dim_resolution = fread(fid,1,'*double',byteorder);
ed2.dim_ref_point = fread(fid,1,'*double',byteorder);
ed2.format = fread(fid,4,'*int8',byteorder);
ed2.storage_type = fread(fid,4,'*int8',byteorder); 
ed2.n_value = fread(fid,1,'*int32',byteorder);
ed2.over_range = fread(fid,1,'*int32',byteorder);
ed2.under_range = fread(fid,1,'*int32',byteorder);
ed2.high_range = fread(fid,1,'*int32',byteorder);
ed2.low_range = fread(fid,1,'*int32',byteorder);
ed2.user_scale = fread(fid,1,'*double',byteorder);
ed2.user_units = char(fread(fid,20,'*char',byteorder)');
ed2.user_offset = fread(fid,1,'*double',byteorder);
ed2.point_density = fread(fid,1,'*uint32',byteorder);
ed2.href = fread(fid,1,'*double',byteorder);
ed2.trig_delay = fread(fid,1,'*double',byteorder);

%implicit dimension 1
id1.dim_scale = fread(fid,1,'*double',byteorder);
id1.dim_offset = fread(fid,1,'*double',byteorder);
id1.dim_size = fread(fid,1,'*uint32',byteorder);
id1.units = char(fread(fid,20,'*char',byteorder)');
id1.dim_extent_min = fread(fid,1,'*double',byteorder);
id1.dim_extent_max = fread(fid,1,'*double',byteorder);
id1.dim_resolution = fread(fid,1,'*double',byteorder);
id1.dim_ref_point = fread(fid,1,'*double',byteorder);
id1.spacing = fread(fid,1,'*uint32',byteorder);
id1.user_scale = fread(fid,1,'*double',byteorder);
id1.user_units = char(fread(fid,20,'*char',byteorder)');
id1.user_offset = fread(fid,1,'*double',byteorder);
id1.point_density = fread(fid,1,'*uint32',byteorder);
id1.href = fread(fid,1,'*double',byteorder);
id1.trig_delay = fread(fid,1,'*double',byteorder);

%implicit dimension 2
id2.dim_scale = fread(fid,1,'*double',byteorder);
id2.dim_offset = fread(fid,1,'*double',byteorder);
id2.dim_size = fread(fid,1,'*uint32',byteorder);
id2.units = char(fread(fid,20,'*char',byteorder)');
id2.dim_extent_min = fread(fid,1,'*double',byteorder);
id2.dim_extent_max = fread(fid,1,'*double',byteorder);
id2.dim_resolution = fread(fid,1,'*double',byteorder);
id2.dim_ref_point = fread(fid,1,'*double',byteorder);
id2.spacing = fread(fid,1,'*uint32',byteorder);
id2.user_scale = fread(fid,1,'*double',byteorder);
id2.user_units = char(fread(fid,20,'*char',byteorder)');
id2.user_offset = fread(fid,1,'*double',byteorder);
id2.point_density = fread(fid,1,'*uint32',byteorder);
id2.href = fread(fid,1,'*double',byteorder);
id2.trig_delay = fread(fid,1,'*double',byteorder);

%time base 1
tb1_real_point_spacing = fread(fid,1,'*uint32',byteorder);
tb1_sweep = fread(fid,4,'*int8',byteorder); 
tb1_type_of_base = fread(fid,4,'*int8',byteorder); 

%time base 2
tb2_real_point_spacing = fread(fid,1,'*uint32',byteorder);
tb2_sweep = fread(fid,4,'*int8',byteorder); 
tb2_type_of_base = fread(fid,4,'*int8',byteorder); 

%wfm update specicfication
real_point_offset = fread(fid,1,'*uint32',byteorder);
tt_offset = fread(fid,1,'*double',byteorder);
frac_sec = fread(fid,1,'*double',byteorder);
GMT_sec = fread(fid,1,'*int32',byteorder);

%wfm curve information
state_flags = fread(fid,1,'*int32',byteorder); 
%There's a misprinting in the SDK article here:
%The field type of "state_flags" is "long" (4 bytes) instead of "double" (8 bytes)
%The offset values starting from 820 ("end of curve buffer offset") are printed incorrectly, too.
type_of_checksum = fread(fid,4,'*int8',byteorder); 
checksum = fread(fid,1,'*int16',byteorder); 
precharge_start_offset = fread(fid,1,'*uint32',byteorder);
data_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
postcharge_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
postcharge_stop_offset = fread(fid,1,'*uint32',byteorder);
end_of_curve_buffer_offset = fread(fid,1,'*uint32',byteorder);

%In this first version of wfm2read I omit the implementation of fast frames and other complicated stuff and jump directly to the curve buffer
offset = double(byte_offset_to_beginning_of_curve_buffer+data_start_offset);

switch ed1.format(1)
    case 0 
        format='*int16';
    case 1 
        format='*int32';
    case 2 
        format='*uint32';
    case 3 
        format='*uint64';  %may not work properly. Bug in Matlab? Does not convert to uint64, but to double instead. 
    case 4 
        format='*float32';
    case 5 
        format='*float64';
    otherwise
        error(['invalid data format or error in file ' filename]);
end

%read the curve buffer portion which is displayed on the scope only 
%(i.e. drop precharge and postcharge points)
nop=(postcharge_start_offset-data_start_offset)/num_bytes_per_point; %number of data points
if nargin==2
    nop = min(nop, datapoints); % take only as many data points as set by optional input parameter, or all of them if datapoints is larger than number of data points in file 
end
fseek(fid, offset,'bof');
values=double(fread(fid,nop,format,byteorder));%read data values from curve buffer
%handling over- and underranged values
ind_over=find(values==ed1.over_range); %find indices of values that are larger than the AD measurement range (upper limit)
ind_under=find(values<=-ed1.over_range);%find indices of values that are larger than the AD measurement range (lower limit)
y = ed1.dim_offset + ed1.dim_scale *values;  %scale data values to obtain in correct units 
fclose(fid);
t = id1.dim_offset + id1.dim_scale * (1:nop)';

info.yunit = ed1.units;
info.tunit = id1.units;
info.yres = ed1.dim_resolution;
info.samplingrate = 1/id1.dim_scale;
info.nop = nop;

%print warning if there are wrong values because they are lying outside 
%the AD converter digitization window:
if length(ind_over)
   warning([int2str(length(ind_over)), ' over range value(s) in file ' filename]);
end
if length(ind_under)
   warning([int2str(length(ind_under)), ' under range value(s) in file ' filename]);
end
end
