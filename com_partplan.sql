-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows partition information regarding a specific table.
-- Rem -- Usage: @com_partplan <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

Set autot            off
Set verify           off
Set linesize 		 220
Set autotrace 		 off
Set serveroutput	  on
Set pagesize        1000

PROMPT [0;33m
PROMPT "****************************"
PROMPT "*** Table Partition Plan ***"
PROMPT "****************************"
PROMPT

define rs_tblname = &1

Col PART_SQL for A60
Col PART_PLAN for A100
Col COMP for A15

SELECT  'PARTITION '||PARTITION_NAME||' VALUES LESS THAN (' AS PART_SQL
    , HIGH_VALUE
    , ')) '||DECODE(COMPRESSION, 'ENABLED','COMPRESS','DISABLED','NOCOMPRESS')||', ' AS COMP
FROM dba_tab_partitions
WHERE table_owner||'.'||table_name = (UPPER('&rs_tblname'))
Order by PARTITION_POSITION;

PROMPT [0;00m
