function [t, I, varargout] = read_sdt(fileName)
% load a Becker & Hickl sdt file into matlab. 
%
% Simple Usage:
% [t, I] = read_sdt('filename.sdt');
%   where t is a time vector and I is a decay curve
%
% Advanced Usage:
% [t, I, meas_info] = read_sdt('filename.sdt');
%   this form also returns a structure meas_info which contains
%   lots of information about the measurement settings. For details
%   of all parameters see the file SPC_data_file_structure.h in the
%   B&H program directory.
%

if (nargin ~= 1)
     dir = 'c:\Data\';
     dir = '~/Desktop/';
    [fname, fpath]= uigetfile('*.sdt','Select TCSPC Data File', dir);
    fname = fullfile(fpath,fname);

else
  fname = fileName;
end
  
  
%fp = fopen(fname, 'rb');
fp=fopen(fname,'rb', 'ieee-le');
if(fp<0)
    error(sprintf('could not open file %s',fname));
end


head.revision = fread(fp,1,'short');
head.info_offs = fread(fp,1,'long');
head.info_length = fread(fp,1,'short');
head.setup_offs = fread(fp,1,'long');
head.setup_length = fread(fp,1,'short');
head.data_block_offs = fread(fp,1,'long');
head.no_of_data_blocks = fread(fp,1,'short');
head.data_block_length = fread(fp,1,'long');
head.meas_desc_block_offs = fread(fp,1,'long');
head.no_of_meas_desc_blocks = fread(fp,1,'short');
head.meas_desc_block_length = fread(fp,1,'short');
head.header_valid = fread(fp,1,'ushort');
head.reserved1 = fread(fp,1,'ulong');
head.reserved2 = fread(fp,1,'ushort');
head.chksum = fread(fp,1,'ushort');

% check header
if(head.header_valid ~= 21845)
fclose(fp);
error('invalid file header');
end

%% file info
fseek(fp, head.info_offs, 'bof');
file_info = fread(fp, head.info_length, 'char=>char');
file_info = file_info';

%% data block header
fseek(fp, head.data_block_offs, 'bof');
data(1).block_no = fread(fp, 1, 'short');
data(1).data_offs = fread(fp, 1, 'long');
data(1).next_block_offs = fread(fp, 1, 'long');
data(1).block_type = fread(fp, 1, 'ushort=>ushort');
data(1).meas_desc_block_no = fread(fp, 1, 'short');
data(1).lblock_no = fread(fp, 1, 'ulong');
data(1).block_length = fread(fp, 1, 'ulong');

% figure out type of block data (bits 4-7)
foo_block_type = bitshift(bitand(data(1).block_type, bin2dec('11110000')),-4);
if(foo_block_type == 0)
data(1).meas_type = 'decay curve';
end

%% data block
fseek(fp, head.data_block_offs+4 , 'bof');
I = fread(fp, head.data_block_length/4,'uint32'); 

%% measurement info - determine dt
fseek(fp, head.meas_desc_block_offs, 'bof');
meas_info.time=fread(fp, 9, 'char=>char')'; 
meas_info.date=fread(fp, 11, 'char=>char')'; 
meas_info.mod_ser_no=fread(fp, 16, 'char=>char')'; 
meas_info.meas_mode = fread(fp,1,'short');
meas_info.cfd = fread(fp,4,'float');
meas_info.syn_zc = fread(fp, 1, 'float');
meas_info.syn_fd = fread(fp, 1, 'short');
meas_info.syn_hf = fread(fp, 1, 'float');
meas_info.tac_r = fread(fp, 1, 'float');
meas_info.tac_g = fread(fp, 1, 'short');
meas_info.tac_of = fread(fp, 1, 'float');
meas_info.tac_ll = fread(fp, 1, 'float');
meas_info.tac_lh = fread(fp, 1, 'float');
meas_info.adc_re = fread(fp, 1, 'short=>short');
meas_info.eal_de = fread(fp, 1, 'short');
meas_info.ncx = fread(fp, 1, 'short');
meas_info.ncy = fread(fp, 1, 'short');
meas_info.page = fread(fp, 1, 'ushort');
meas_info.col_t = fread(fp, 1, 'float');
meas_info.rep_t = fread(fp, 1, 'float');
meas_info.stopt = fread(fp, 1, 'short');
meas_info.overfl = fread(fp, 1, 'char');
meas_info.use_motor = fread(fp, 1, 'short');
meas_info.steps = fread(fp, 1, 'ushort');
meas_info.offset = fread(fp, 1, 'float');
meas_info.dither = fread(fp, 1, 'short');
meas_info.incr = fread(fp, 1, 'short');
meas_info.mem_bank = fread(fp, 1, 'short');
meas_info.mod_type = fread(fp, 16, 'char=>char');
meas_info.syn_th = fread(fp, 1, 'float');
meas_info.dead_time_comp = fread(fp, 1, 'short');
meas_info.polarity = fread(fp, 3, 'short');
meas_info.linediv = fread(fp, 1, 'short');
meas_info.accumulate = fread(fp, 1, 'short');
meas_info.flbck = fread(fp, 2, 'int');
meas_info.bord = fread(fp, 2, 'int');
meas_info.pix_time = fread(fp, 1, 'float');
meas_info.pix_clk = fread(fp, 1, 'short');
meas_info.trigger = fread(fp, 1, 'short');
meas_info.scan = fread(fp, 4, 'int');
meas_info.fifo_typ = fread(fp, 1, 'short');
meas_info.exp_div = fread(fp, 1, 'int');
meas_info.mod_type_code = fread(fp, 1, 'ushort');
meas_info.mod_fpga_ver = fread(fp, 1, 'ushort');
meas_info.overflow_corr_factor = fread(fp, 1, 'float');
meas_info.adc_zoom = fread(fp, 1, 'int');
meas_info.cycles = fread(fp, 1, 'int');
%meas_info.MeasStopInfo = fread(fp, 2*2+14*4, 'char=>char');
meas_info.stop_info.status = fread(fp, 1, 'ushort');
meas_info.stop_info.flags= fread(fp, 1, 'ushort=>ushort');
meas_info.stop_info.stop_time = fread(fp, 1, 'float');
meas_info.stop_info.cur_step = fread(fp, 1, 'int');
meas_info.stop_info.cur_cycle = fread(fp, 1, 'int');
meas_info.stop_info.cur_page = fread(fp, 1, 'int');
meas_info.stop_info.min_sync_rate = fread(fp, 1, 'float');
meas_info.stop_info.min_cfd_rate = fread(fp, 1, 'float');
meas_info.stop_info.min_tac_rate = fread(fp, 1, 'float');
meas_info.stop_info.min_adc_rate = fread(fp, 1, 'float');
meas_info.stop_info.max_sync_rate = fread(fp, 1, 'float');
meas_info.stop_info.max_cfd_rate = fread(fp, 1, 'float');
meas_info.stop_info.max_tac_rate = fread(fp, 1, 'float');
meas_info.stop_info.max_adc_rate = fread(fp, 1, 'float');
meas_info.stop_info.reserved1 = fread(fp, 1, 'int');
meas_info.stop_info.reserved2 = fread(fp, 1, 'float');

meas_info.chan = fread(fp, 1, 'ushort'); %%% start of MeasFCSInfo fields
meas_info.fcs_decay_calc = fread(fp, 1, 'ushort=>ushort');
meas_info.mt_resol = fread(fp, 1, 'uint');

fclose(fp);

t=linspace(0, meas_info.tac_r, meas_info.adc_re)';

if(nargout == 3)
varargout(1)={meas_info};
end