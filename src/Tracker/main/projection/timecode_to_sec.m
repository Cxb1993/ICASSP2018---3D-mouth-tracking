% FUNCTION T = TIMECODE_TO_SEC( TIMECODE, [ FRAME_RATE = 25 ] )

function t = timecode_to_sec( timecode, frame_rate )

if nargin < 1
  error( 'timecode_to_sec needs at least one parameter.' );
end

if nargin < 2
  frame_rate = 25;
end

[hour, rest] = strtok( timecode, ':' );
hour = str2num( hour );
[minute, rest] = strtok( rest, ':' );
minute = str2num( minute );
[second, rest] = strtok( rest, ':.');
second = str2num( second );
[frame, rest] = strtok( rest, ':.' );
frame = str2num( frame );

t = hour * 3600 + minute * 60 + second + frame / frame_rate;

