-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows report about UNDO usage.
-- Rem -- Usage: @rep_undo
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     200
Set pages          0
Set heading       on
Set pagesize    2000

col ru_hitratio for A4 head "Hit|  R|  a|  t|  i|  o" justify right

PROMPT --- Undo Status
PROMPT ---------------

SELECT tablespace_name
    , status
    , count(*) AS HOW_MANY
FROM dba_undo_extents
GROUP BY tablespace_name, status;


PROMPT --- Hit Ratio
PROMPT -------------

SELECT name
    , gets
    , waits
    , to_char(((gets-waits)*100)/gets,'999') AS ru_hitratio
FROM v$rollstat S, v$rollname R
WHERE S.usn = R.usn
ORDER BY R.name;


PROMPT --- Undo Optimal settings
PROMPT -------------------------

SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
       SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
       ROUND((d.undo_size / (to_number(f.value) *
       g.undo_block_per_sec))) "OPTIMAL UNDO RETENTION [Sec]"
  FROM (
       SELECT SUM(a.bytes) undo_size
          FROM v$datafile a,
               v$tablespace b,
               dba_tablespaces c
         WHERE c.contents = 'UNDO'
           AND c.status = 'ONLINE'
           AND b.name = c.tablespace_name
           AND a.ts# = b.ts#
       ) d,
       v$parameter e,
       v$parameter f,
       (
       SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
              undo_block_per_sec
         FROM v$undostat
       ) g
WHERE e.name = 'undo_retention'
  AND f.name = 'db_block_size'
/
