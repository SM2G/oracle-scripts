-- Rem -- --------------------------------------------------
-- Rem -- Script Name: Report Long Ops
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows information about the long running queries.
-- Rem -- Usage: @rep_longops
-- Rem -- --------------------------------------------------


SET linesize     170
SET pages        100
Col lo_killparams   for A10         head "KILLPARAMS"     justify left
Col lo_username     for A30         head "Username"       justify left
Col lo_sqlid        for A13         head "Sql Id"         justify center
Col lo_opname       for A40         head "Op Name"        justify center WRAPPED
Col lo_sofar        for 999G999G999 head "Sofar"          justify right
Col lo_totwrk       for 999G999G999 head "Total Work"     justify right
Col lo_percent      for 999         head "Pct"            justify right
Col lo_timremain    for 999G999G999 head "Secs remaining" justify right
Col lo_timremainv2 for A20 head "Time remaining"
PROMPT [0;33m
PROMPT "***************"
PROMPT "*** LongOps ***"
PROMPT "***************"


--VAR rl_username VARCHAR2(30);
--ACCEPT rl_username PROMPT 'Enter Username: '

SELECT SID||','||SERIAL#              AS lo_killparams
   ,  USERNAME                        AS lo_username
   ,  SQL_ID                          AS lo_sqlid
   ,  OPNAME                          AS lo_opname
   ,  sofar                           AS lo_sofar
   ,  totalwork                       AS lo_totwrk
   ,  ROUND((sofar*100/totalwork),0)  AS lo_percent
-- just secs --   ,  TIME_REMAINING                  AS lo_timremain
   ,  TRUNC(TIME_REMAINING/60)||' mins '
      ||MOD(TIME_REMAINING,60)||' secs' AS lo_timremainv2
FROM V$SESSION_LONGOPS
WHERE sofar - totalwork <> 0
ORDER BY lo_killparams, lo_percent
/
--AND USERNAME LIKE UPPER(('%&rl_username%'))
PROMPT [0;00m
