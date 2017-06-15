-- Rem -- --------------------------------------------------
-- Rem -- Script Name: rep_whosthere
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows current connexions.
-- Rem -- Usage: @rep_whosthere
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     180
Set pages        300

-- Original script by SS64.com

Col killparams    for A10     head "KILLPARAMS"       justify left
Col wt_spidproc   for A10     head "SPID"             justify left
Col wt_clientpid  for A13     head "Client|PID"       justify left
Col wt_Status     for A1      head "S|t|a|t|u|s"      justify left
Col wt_hostcomp   for A40     head "User@Host"        justify left
Col wt_logusr     for A25     head "Login"            justify left
Col wt_command    for A20     head "Running Command"  justify left
Col wt_prgm       for A20     head "Program"          justify left
Col wt_logon      for A11     head "Logon|Time"       justify left

PROMPT [0;33m
PROMPT "*******************"
PROMPT "*** Whos There? ***"
PROMPT "*******************"

SELECT    s.SID||','||s.SERIAL#                   AS killparams
    ,    p.spid                                   AS wt_spidproc
    ,    s.process                                AS wt_clientpid
    ,    SUBSTR(STATUS,1,1)                       AS wt_Status
    ,    TO_CHAR(s.LOGON_TIME,'DD/MM-HH24:MI')    AS wt_logon
    ,   SUBSTR(s.osuser,INSTR(s.osuser,'\')+1)||'@'||SUBSTR(s.machine,INSTR(s.machine,'\')+1) AS wt_hostcomp
        -- '@'||RPAD(,20,' ')
    ,   NVL(s.username,'---')                                        AS wt_logusr
    ,   RPAD(decode(s.command,
                1,'Create table',        2,'Insert',
                3,'Select',              6,'Update',
                7,'Delete',              9,'Create index',
                10,'Drop index',         11,'Alter index',
                12,'Drop table',         13,'Create seq',
                14,'Alter sequence',     15,'Alter table',
                16,'Drop sequ.',         17,'Grant',
                19,'Create syn.' ,       20,'Drop synonym',
                21,'Create view',        22,'Drop view',
                23,'Validate index',     24,'Create procedure',
                25,'Alter procedure',    26,'Lock table',
                42,'Alter session',      44,'Commit',
                45,'Rollback' ,          46,'Savepoint',
                47,'PL/SQL Exec',        48,'Set Transaction',
                60,'Alter trigger',      62,'Analyze Table',
                63,'Analyze index',      71,'Create Snapshot Log',
                72,'Alter Snapshot Log', 73,'Drop Snapshot Log',
                74,'Create Snapshot',    75,'Alter Snapshot',
                76,'drop Snapshot',      85,'Truncate table',
                0,'No command',
                '? : '||s.command),20,' ') AS wt_command
    ,    substr(s.program,instr(s.program,']',-1)+1 ,
        decode(instr(s.program,'.',-1) - instr(s.program,']',-1)-1,-1,20,instr(s.program,'.',-1) - instr(s.program,']',-1)-1)) AS wt_prgm
FROM v$session s,
     v$process p
WHERE (s.type  <> 'BACKGROUND')
  and (s.paddr = p.addr)
  -- and (s.program is not null)
ORDER BY s.osuser, s.program, wt_logon;

PROMPT [0m
