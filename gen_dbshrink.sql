-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Displays SQL queries to shrink a database.
-- Rem -- Usage: @gen_dbshrink
-- Rem -- --------------------------------------------------

Set autot        off
Set heading       on
Set linesize     200
Set pagesize    2000
Set verify       off

col dfsz_realsize    for 9G999G990D00    head "Real|Size"        justify right
col dfsz_shrinksiz   for 9G999G990D00    head "Shrinked|Size"    justify right
col dfsz_releasize   for 9G999G990D00    head "Released|Size"    justify right
col dfsz_cmd         for A110            head "Command"          justify center

col file_name        for a70                                    word_wrapped
col smallest         for 999G990 head "Smallest|Size|Poss."
col currsize         for 999G990 head "Current|Size"
col savings          for 999G990 head "Poss.|Savings"
col cmd              for A110    head "Command"                 word_wrapped

PROMPT    "******************"
PROMPT    "*** DBF Shrink ***"
PROMPT    "******************"
PROMPT

-- Tom Kyte's asktom.com solution.

break on report
compute sum of savings on report

column value new_val blksize
select value from v$parameter where name = 'db_block_size'
/

select file_name,
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) smallest,
       ceil( blocks*&&blksize/1024/1024) currsize,
       ceil( blocks*&&blksize/1024/1024) -
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) savings
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
order by file_name
/


select 'alter database datafile '''||file_name||''' resize ' ||
       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 )  || 'm;' cmd, TABLESPACE_NAME, AUTOEXTENSIBLE, ceil( blocks*&&blksize/1024/1024) - ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) savings
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
  and ceil( blocks*&&blksize/1024/1024) -
      ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) > 50
order by 2,1,4
/


-- Alternate Method
-- ----------------
-- sho parameter DB_BLOCK_SIZE
--
-- undefine DB_BLOCK_SIZE
--
-- compute sum of dfsz_releasize on report
-- break on report
-- SELECT     bytes/1024/1024                                                         AS dfsz_realsize
--     ,    ceil( (nvl(hwm,1)*&&DB_BLOCK_SIZE)/1024/1024 )                            AS dfsz_shrinksiz
--     ,    bytes/1024/1024-ceil((nvl(hwm,1)*&DB_BLOCK_SIZE)/1024/1024)               AS dfsz_releasize
--     ,    'ALTER DATABASE DATAFILE '|| ''''||file_name||'''' || ' RESIZE ' ||
--         ceil( (nvl(hwm,1)*&DB_BLOCK_SIZE)/1024/1024 ) || ' M;'                     AS dfsz_cmd
-- FROM    dba_data_files a
--     ,    ( select file_id, max(block_id+blocks-1) hwm
--         from dba_extents group by file_id ) b
-- WHERE    tablespace_name='&ts_name'
-- AND        a.file_id = b.file_id(+)
-- AND     ceil(blocks*&DB_BLOCK_SIZE/1024/1024)- ceil((nvl(hwm,1)* &DB_BLOCK_SIZE)/1024/1024 ) > 0;
