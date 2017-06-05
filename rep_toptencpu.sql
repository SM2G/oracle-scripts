-- Rem -- --------------------------------------------------
-- Rem -- Script Name: Top Ten CPU
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Top 10 CPU sessions.
-- Rem -- Usage: @rep_toptencpu.sql
-- Rem -- --------------------------------------------------

SET linesize	160
COL rank	for 9999	head "Rank"			justify right
COL sid 	for 99999	head "SID"			justify right
COL prgm 	for A50 	head "Program"		justify left
COL cpumins for 99999	head "CPU|minutes"	justify right

PROMPT [0;33m
PROMPT "***************************"
PROMPT "*** Top 10 CPU Sessions ***"
PROMPT "***************************"

SELECT rownum as rank, a.*
from (
    SELECT v.sid, program as prgm, v.value / (100 * 60) CPUMins
    FROM v$statname s , v$sesstat v, v$session sess
   WHERE s.name = 'CPU used by this session'
     and sess.sid = v.sid
     and v.statistic#=s.statistic#
     and v.value>0
   ORDER BY v.value DESC) a
where rownum <= 10;

PROMPT [0;00m
