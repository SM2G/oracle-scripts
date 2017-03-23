-- Rem -- --------------------------------------------------
-- Rem -- Script Name: Report Standby
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows information about the standby lag time.
-- Rem -- Usage: @rep_standby
-- Rem -- --------------------------------------------------

SET linesize     170
SET pages        100
SET echo         off
Col sby_lag      for 999G999G999   head "Logfiles remaining"  justify left
Col sby_remains  for 999G999G999   head "Remains"             justify left

PROMPT [0;33m
PROMPT "***************"
PROMPT "*** Standby ***"
PROMPT "***************"

SELECT count(*) AS sby_lag FROM V$ARCHIVED_LOG WHERE APPLIED = 'NO';

SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, (BLOCKS - BLOCK#) AS sby_remains FROM V$MANAGED_STANDBY;

PROMPT [0;00m
