select segment_name, tablespace_name, bytes, blocks, extents
from dba_segments
where segment_type = 'TABLE'
and owner='JORGE'
order by segment_name;