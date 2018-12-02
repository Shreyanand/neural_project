function [Data, NumPoints] = loaddata(filename);
% LOADDATA Load AG500 vendor binary data from the given file. Filetype can
%           be '.amp', for signal amplitude data, or '.pos' for calculated
%           positions. Expected is a binary file with 72 single values per
%           sample for 'amp'-files or with 84 single values per sample for
%           a 'pos'-file.
%	         Amp: Returns a 3D data matrix arranged NumPoints*6*12.
%                (6 transmitter coils and 12 sensors/channels)
%           Pos: Returns a 3D data matrix arranged NumPoints*7*12
%                Organisation of second dimension:
%                x, y, z, phi, theta, rms, extra
%
%           [Data, NumPoints] = loaddata('DataFileName');
%
%           As a convenience-feature, the function can also load
%           TAPADM result files (*.mat)

%---------------------------------------------------------------------
% Copyright � 2005 by Andreas Zierdt (Anderas.Zierdt@phonetik.uni-muenchen.de)
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA
%---------------------------------------------------------------------

NUMBER_OF_CHANNELS   = 12;
AMP_RECORD_SIZE      = NUMBER_OF_CHANNELS * 6;
NUMBER_OF_DIMENSIONS = 3+2+2; % cartesian sensor position + spatial orientation angles + extra
POS_RECORD_SIZE      = NUMBER_OF_CHANNELS * NUMBER_OF_DIMENSIONS;

if (nargin ~= 1),
	error('Syntaxerror: Wrong number of arguments. Try LoadData(FileName).')
end

if (~isempty(strfind(filename, '.amp')))  % AG500 amplitude data
   [rawdata, count] = readbinary(filename);
	[Data, NumPoints] = reshapedata(rawdata, count, AMP_RECORD_SIZE);
   Data = reshape(Data, [NumPoints 6 NUMBER_OF_CHANNELS]);
elseif (~isempty(strfind(filename, '.pos'))) % AG500 position data
   [rawdata, count] = readbinary(filename);
	[Data, NumPoints] = reshapedata(rawdata, count, POS_RECORD_SIZE);
   Data = reshape(Data, [NumPoints NUMBER_OF_DIMENSIONS NUMBER_OF_CHANNELS]);
elseif (~isempty(strfind(filename, '.mat'))) % MATLAB position data
	PData = load(filename);
	fn = fieldnames(PData);
	if (~isempty(strmatch('data', fn, 'exact')))
		Data = double(PData.data);
	else
		Data = PData.Result;
	end
else
   error('Unsupported file type.');
end

%------------- subfunctions -----------
function [rawdata, count] = readbinary(filename)
   [fid, msg] = fopen(filename, 'r', 'ieee-le');    % open file for binary read access with Intel byte-order
   if fid == -1,
      error([msg ' Filename: ' filename]);
   end
   [rawdata, count] = fread(fid, inf, 'single');	% read single-precision AG500 data into double-precision numeric array
   fclose(fid);

function [Data, NumPoints] = reshapedata(rawdata, count, recsize)
 	if mod(count, recsize) ~= 0
		error('Read %d values, which is not a multiple of record size (%d).', count, recsize)
	end
	NumPoints = count / recsize;
	Data = (reshape(rawdata, [recsize NumPoints]))';
