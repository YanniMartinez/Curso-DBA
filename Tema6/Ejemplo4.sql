select segment_name, segment_type, tablespace_name, extent_id,
bytes, blocks
from dba_extents
where segment_type = 'TABLE'
and owner='JORGE'
order by segment_name;