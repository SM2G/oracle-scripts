-- Rem -- --------------------------------------------------
-- Rem -- Script Name: Com_Schemarefresh
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Gather statistics on all tables for a scecific schema.
-- Rem -- Usage: @com_schemarefresh <OWNER>
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     165
Set heading       on
Set pagesize     200

col ds_tablename   FOR A30 head "Table|Name" justify left
col ds_comments    FOR A90 head "Comments"   justify center

PROMPT ^[[0;33m
PROMPT "**********************"
PROMPT "*** Schema refresh ***"
PROMPT "**********************"
PROMPT

SELECT 'EXEC DBMS_STATS.GATHER_TABLE_STATS('''||owner||''', '''||TABLE_NAME||''' , NULL, 1, FALSE, ''FOR ALL INDEXED COLUMNS'', NULL, ''DEFAULT'', FALSE);'
FROM dba_tables
WHERE owner LIKE UPPER('%&1%')
ORDER BY owner, TABLE_NAME;


PROMPT ^[[0;00m
