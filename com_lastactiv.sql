-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows currently running SQL for a specified login.
-- Rem -- Usage: @com_lastactiv <USERNAME>
-- Rem -- --------------------------------------------------

Set autot        off
Set echo         off
Set heading       on
Set linesize     200
Set pagesize     500
Set verify       off

col killparams  for A10             head "KILLPARAMS"            justify left
col la_username for A20             head "Username"              justify left
col la_exectime for A15             head "Last Execution|Time"   justify left
col la_sqlid    for A13             head "SQL Id"                justify left
col la_rowspro  for 999G999G999G990 head "Rows|Processed"        justify right
col la_fetches  for     999G999G990 head "Fetches"               justify right
col la_execute  for 999G999G999G990 head "Executions"            justify right
col la_sqltext  for A50             head "SQL|Text"              justify left WRAPPED

PROMPT "*********************"
PROMPT "*** Last Activity ***"
PROMPT "*********************"
PROMPT

define la_username = &1

-- VAR la_username VARCHAR2(30);
-- ACCEPT la_username PROMPT 'Enter username to report for activity: '

SELECT a.SID||','||a.SERIAL#                           AS killparams
    , a.USERNAME                                       AS la_username
    , TO_CHAR(b.LAST_ACTIVE_TIME,'DD/MM HH24:MI:SS')   AS la_exectime
    , b.sql_id                                         AS la_sqlid
    , b.ROWS_PROCESSED                                 AS la_rowspro
    , b.FETCHES                                        AS la_fetches
    , b.EXECUTIONS                                     AS la_execute
    , b.sql_text                                       AS la_sqltext
FROM v$session a JOIN v$sqlarea b
ON (a.sql_address = b.address)
WHERE a.username LIKE UPPER('%&la_username%')
ORDER BY la_exectime, la_sqltext
/
