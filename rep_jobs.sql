-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows informations about scheduled jobs.
-- Rem -- Usage: @rep_jobs
-- Rem -- --------------------------------------------------

Set autot        off
Set heading       on
Set verify       off
Set linesize     200
Set pages        100

col jb_num       for 99999   head "Job|Number"      justify right
col jb_loguser   for A20     head "Log|User"        justify left
col jb_lastdate  for A20     head "Last|Date"       justify center
col jb_interval  for A20     head "Interval"        justify left
col jb_nextdate  for A10     head "Next|Date"       justify center
col jb_fail      for 999G999 head "F|a|i|l|u|r|e|s" justify right
col jb_broken    for A1      head "B|r|o|k|e|n"     justify center
col jb_desc      for A70     head "What"            justify center

col jb_jobname       for A40     head "Job Name"         justify left
col jb_jobaction     for A40     head "Action"           justify center WRAPPED
col jb_enabled       for A1      head "E|n|a|b|l|e|d"    justify center
col jb_state         for A9      head "State"            justify right
col jb_runcount      for 999G999 head "Run|Count"        justify right
col jb_failcount     for 999G999 head "Fail|Count"       justify right
col jb_nextrundate   for A17     head "Next|Run"         justify left
col jb_lastrundurat  for A8      head "Last|Duration"    justify left
col jb_startdate     for A17     head "Start|Date"       justify left
col jb_repinterval   for A47     head "Repeat Interval"  justify left   WRAPPED
col jb_comments      for A40     head "Comments"         justify left   WRAPPED

PROMPT "*******************"
PROMPT "*** Jobs Report ***"
PROMPT "*******************"
PROMPT

SELECT  job          AS jb_num
    ,   log_user     AS jb_loguser
    ,   last_date    AS jb_lastdate
    ,   interval     AS jb_interval
    ,   next_date    AS jb_nextdate
    ,   failures     AS jb_fail
    ,   broken       AS jb_broken
    ,   what         AS jb_desc
FROM dba_jobs
ORDER BY job;

PROMPT -- Scheduler Jobs
PROMPT ------------------

SELECT OWNER||'.'||JOB_NAME       AS jb_jobname
    --,  SUBSTR(ENABLED,1,1)       AS jb_enabled
    --,  JOB_ACTION         AS jb_jobaction
    ,  STATE           AS jb_state
    ,  RUN_COUNT          AS jb_runcount
    ,  FAILURE_COUNT         AS jb_failcount
    --, TO_CHAR(START_DATE,'DD/MM/YY-HH24:MI:SS')  AS jb_startdate
    , TO_CHAR(NEXT_RUN_DATE,'DD/MM/YY-HH24:MI:SS') AS jb_nextrundate
    , SUBSTR(LAST_RUN_DURATION,12,8)     AS jb_lastrundurat
    , REPEAT_INTERVAL         AS jb_repinterval
    , COMMENTS          AS jb_comments
FROM dba_scheduler_jobs
ORDER BY jb_jobname;
