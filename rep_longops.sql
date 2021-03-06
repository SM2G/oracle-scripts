-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows information about the long running queries.
-- Rem -- Usage: @rep_longops
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     170
Set pages        100

col lo_killparams   for A10         head "KILLPARAMS"     justify left
col lo_username     for A30         head "Username"       justify left
col lo_sqlid        for A13         head "Sql Id"         justify center
col lo_opname       for A40         head "Op Name"        justify center WRAPPED
col lo_sofar        for 999G999G999 head "Sofar"          justify right
col lo_totwrk       for 999G999G999 head "Total Work"     justify right
col lo_percent      for 999         head "Pct"            justify right
col lo_timremain    for 999G999G999 head "Secs remaining" justify right
col lo_timremainv2  for A20         head "Time remaining"

PROMPT "***************"
PROMPT "*** LongOps ***"
PROMPT "***************"
PROMPT

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
