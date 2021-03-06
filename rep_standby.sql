-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows information about the standby lag time.
-- Rem -- Usage: @rep_standby
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     170
Set pages        100
Set echo         off

col sby_lag      for 999G999G999   head "Logfiles remaining"  justify left
col sby_remains  for 999G999G999   head "Remains"             justify left

PROMPT "***************"
PROMPT "*** Standby ***"
PROMPT "***************"
PROMPT

SELECT count(*) AS sby_lag FROM V$ARCHIVED_LOG WHERE APPLIED = 'NO';

SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, (BLOCKS - BLOCK#) AS sby_remains FROM V$MANAGED_STANDBY;
