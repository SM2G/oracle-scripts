-- Rem -- --------------------------------------------------
-- Rem -- Script Name: Object Real Size
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows size information regarding a specific table.
-- Rem -- Usage: @com_tablesize <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

Set autot           off
Set verify          off
Set linesize 		220
Set autotrace 		off
Set serveroutput	 on
Set pagesize       1000

PROMPT [0;33m
PROMPT "************************"
PROMPT "*** Object Real Size ***"
PROMPT "************************"
PROMPT

define rs_tblname = &1

DECLARE
    linecounter	VARCHAR2(9);   -- NUMBER;
    tablesize	VARCHAR2(14);
    numro		VARCHAR2(9);   -- NUMBER;
    CURSOR c_tab	IS SELECT *
            FROM dba_tables
            WHERE owner||'.'||table_name LIKE (UPPER('&rs_tblname')||'%')
            AND owner NOT IN ('SYS','SYSTEM','DBSNMP')
            AND IOT_NAME IS NULL;
    r_tab		c_tab%rowtype;
BEGIN
-- Preparation
DBMS_OUTPUT.put_line('Table                                                                Line     Table     Average       ');
DBMS_OUTPUT.put_line('Name                                                                Count     Size (Mb) Line Size (Kb)');
DBMS_OUTPUT.put_line('------------------------------------------------------------ ------------ ------------- --------------');
OPEN c_tab;
--- --- --- --- --- Go !
LOOP
    FETCH c_tab INTO r_tab;
    EXECUTE IMMEDIATE 'SELECT count(*) FROM '||r_tab.owner||'.'||r_tab.table_name
        INTO linecounter;
    -- DBMS_OUTPUT.put_line('linecounter OK');
    EXECUTE IMMEDIATE 'SELECT NUM_ROWS
            FROM dba_tables
            WHERE owner||''.''||table_name='''||r_tab.owner||'.'||r_tab.table_name||'''
            AND IOT_NAME IS NULL'
        INTO numro;
    -- DBMS_OUTPUT.put_line('Numro OK');
    EXECUTE IMMEDIATE 'SELECT ROUND(SUM(bytes)/1024/1024,2)
            FROM dba_segments
            GROUP BY segment_name, OWNER
            HAVING owner||''.''||SEGMENT_NAME ='''||r_tab.owner||'.'||r_tab.table_name||''''
        INTO tablesize;
    -- Final Display
    DBMS_OUTPUT.put_line(
        RPAD(r_tab.owner||'.'||r_tab.table_name,61,' ')
        ||LPAD(linecounter,12,' ')
        ||LPAD(TO_CHAR(ROUND(tablesize,2),'9G999G999D00'),14,' ')
        ||LPAD(TO_CHAR(ROUND(tablesize*1024/(linecounter+1),2),'9G999G999D00'),15,' '));
    EXIT WHEN c_tab%NOTFOUND;
END LOOP;
CLOSE c_tab;
END;
/

PROMPT [0;00m
