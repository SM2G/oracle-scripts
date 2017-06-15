-- Rem -- --------------------------------------------------
-- Rem -- Script Name: Object usage
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows information regarding a specific object in the library cache.
-- Rem -- Usage: @com_objusage <OBJECT_OWNER>.<OBJECT_NAME>
-- Rem -- --------------------------------------------------

Set autot            off
Set verify           off
Set linesize         300
Set heading           ON
Set feedback          ON
Set pagesize        2000
Set long      2000000000

col obus_sqlid      for A13 head "Sql Id"            justify left
col obus_timestamps for A12 head "Timestamp"         justify left
col obus_objtype    for A10 head "Object|Type"       justify left
col obus_operation  for A12 head "Operation"         justify left
col obus_child      for 999 head "Child|Num"         justify right
col obus_accesspred for A50 head "Access|Predicates" justify left
col obus_filterpred for A50 head "Filter|Predicates" justify left

PROMPT [0;33m
PROMPT "********************"
PROMPT "*** Object Usage ***"
PROMPT "********************"
PROMPT

SELECT SQL_ID                                AS obus_sqlid
     , TO_CHAR(TIMESTAMP,'YYMMDD-HH24:MI')   AS obus_timestamps
	 , OBJECT_TYPE                           AS obus_objtype
     , OPERATION                             AS obus_operation
     , CHILD_NUMBER                          AS obus_child
     , ACCESS_PREDICATES                     AS obus_accesspred
     , FILTER_PREDICATES                     AS obus_filterpred
FROM    v$sql_plan
WHERE OBJECT_OWNER||'.'||OBJECT_NAME = UPPER('&1')
ORDER BY TRUNC(TIMESTAMP) asc, SQL_ID;

PROMPT [0;00m
