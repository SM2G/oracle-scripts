-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Top 10 CPU sessions.
-- Rem -- Usage: @rep_toptencpu
-- Rem -- --------------------------------------------------

Set autot     off
Set verify    off
Set linesize  160

col rank    for 9999  head "Rank"        justify right
col sid     for 99999 head "SID"         justify right
col prgm    for A50   head "Program"     justify left
col cpumins for 99999 head "CPU|minutes" justify right

PROMPT "***************************"
PROMPT "*** Top 10 CPU Sessions ***"
PROMPT "***************************"
PROMPT

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
