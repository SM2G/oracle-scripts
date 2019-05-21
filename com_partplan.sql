-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows partition information regarding a specific table.
-- Rem -- Usage: @com_partplan <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

Set autot            off
Set autotrace        off
Set pagesize        1000
Set verify           off
Set linesize         220
Set serveroutput      on

col part_sql  for A60
col part_plan for A100
col part_comp for A15

PROMPT "****************************"
PROMPT "*** Table Partition Plan ***"
PROMPT "****************************"
PROMPT

define rs_tblname = &1

SELECT  'PARTITION '||PARTITION_NAME||' VALUES LESS THAN (' AS part_sql
    , HIGH_VALUE
    , ')) '||DECODE(COMPRESSION, 'ENABLED','COMPRESS','DISABLED','NOCOMPRESS')||', ' AS part_comp
FROM dba_tab_partitions
WHERE table_owner||'.'||table_name = (UPPER('&rs_tblname'))
Order by PARTITION_POSITION;
