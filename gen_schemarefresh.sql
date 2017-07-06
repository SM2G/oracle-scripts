-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Gather statistics on all tables for a scecific schema.
-- Rem -- Usage: @com_schemarefresh <OWNER>
-- Rem -- --------------------------------------------------

Set autot        off
Set heading       on
Set verify       off
Set linesize     165
Set pagesize     200

col ds_tablename   FOR A30 head "Table|Name" justify left
col ds_comments    FOR A90 head "Comments"   justify center

PROMPT "**********************"
PROMPT "*** Schema refresh ***"
PROMPT "**********************"
PROMPT

SELECT 'EXEC DBMS_STATS.GATHER_TABLE_STATS('''||owner||''', '''||TABLE_NAME||''' , NULL, 1, FALSE, ''FOR ALL INDEXED COLUMNS'', NULL, ''DEFAULT'', FALSE);'
FROM dba_tables
WHERE owner LIKE UPPER('%&1%')
ORDER BY owner, TABLE_NAME;
