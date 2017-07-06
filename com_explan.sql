-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows explain plan for a specified Sql ID.
-- Rem -- Usage: @com_explan <SQL_ID>
-- Rem -- --------------------------------------------------

Set autot            off
Set heading           on
Set linesize         180
Set long      2000000000
Set pagesize        2000
Set verify           off

col plan_table_output FOR A150 head "-- Plan Table Ouput --" justify center

col fq_bindname     For A30 head "Bind Variable Name"      justify left
col fq_valstring    For A50 head "Value"                   justify left
col fq_datatype     For A10 head "Datatype"                justify left
col fq_captured     For A12 head "Was captured"            justify left
col fq_lastcapt     For A16 head "Last Captured"           justify left

PROMPT "**********************"
PROMPT "*** Execution Plan ***"
PROMPT "**********************"
PROMPT

SELECT plan_table_output
FROM table(dbms_xplan.display_cursor('&1',null,'OUTLINE'));

SELECT  lpad(' ',2*(level-1))||operation operation
   ,   options
   ,   object_name
   ,   position
FROM plan_table
START WITH id=0
AND
statement_id = '&1'
CONNECT BY prior id = parent_id
AND statement_id = '&1';

PROMPT
PROMPT -- Bind Variables
PROMPT -----------------

SELECT   NAME                                            AS fq_bindname
    ,    VALUE_STRING                                    AS fq_valstring
    ,    Decode(DATATYPE,1    ,'VARCHAR2'
                        ,2    ,'NUMBER'
                        ,DATATYPE)                       AS fq_datatype
    ,    TO_CHAR(LAST_CAPTURED,'DD/MM/YYYY HH24:MI')     AS fq_lastcapt
    ,    WAS_CAPTURED                                    AS fq_captured
FROM    v$sql_bind_capture
WHERE SQL_ID='&1'
ORDER BY POSITION asc;
