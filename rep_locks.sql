-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows informations about database locks.
-- Rem -- Usage: @rep_locks
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     180
Set echo         off

-- Source http://oratips-ddf.blogspot.com/2008/05/let-my-data-go.html

col lck_Holder       for A10  head "Holder|KILLPARAMS"  justify left
col lck_holdername   for A20  head "Holder|Name"        justify left
col lck_Waiter       for A10  head "Waiter|KILLPARAMS"  justify left
col lck_waitername   for A20  head "Waiter|Name"        justify left
col lck_objname      for A50  head "Object Name"        justify left
col lck_ClientPID    for A10  head "Client|PID"         justify left
col lck_LockType     for A20  head "Lock Type"          justify left

PROMPT [0;33m
PROMPT    "*******************"
PROMPT    "*** Lock Report ***"
PROMPT    "*******************"
PROMPT

with blocked as (
 select sid blocked, serial#, username, blocking_session
 from v$session
 where blocking_session is not null
),
blocking as (
 select sid blocking, serial# bl_serial#, username bl_username
 from v$session
),
obj_info as (
 select l.session_id, o.owner||'.'||o.object_name objname, l.object_id,
 decode(l.locked_mode,
        1, 'No Lock',
        2, 'Row Share',
        3, 'Row Exclusive',
        4, 'Shared Table',
        5, 'Shared Row Exclusive',
        6, 'Exclusive') locked_mode
 from v$locked_object l, dba_objects o
 where o.object_id = l.object_id
)
SELECT    blocking||','||bl_serial#   AS lck_Holder
    ,     bl_username                 AS lck_holdername
    ,    blocked||','||serial#        AS lck_Waiter
    ,     username                    AS lck_Waitername
    ,    objname                      AS lck_objname
    ,     locked_mode                 AS lck_LockType
from blocked, blocking, obj_info
where blocking = blocking_session
and session_id = blocking_session;

/* SELECT  o.owner||'.'||o.object_name AS lck_objname
            ,    sw.process                     AS lck_ClientPID
            ,    sh.username ||
                '('         ||
                sh.sid         ||
                ')'                         AS lck_Holder
            ,    sw.username ||
                '('         ||
                sw.sid         ||
                ')'                         AS lck_Waiter
            ,    DECODE (
                   lh.lmode,
                   1, 'NULL',
                   2, 'row share',
                   3, 'row exclusive',
                   4, 'share',
                   5, 'share row exclusive',
                   6, 'exclusive'
                )                             AS lck_LockType
FROM all_objects o, v$session sw, v$lock lw, v$session sh, v$lock lh
WHERE lh.id1 = o.object_id
AND    lh.id1 = lw.id1
AND sh.sid = lh.sid
AND sw.sid = lw.sid
AND sh.lockwait IS NULL
AND sw.lockwait IS NOT NULL
AND lh.type = 'TM'
AND lw.type = 'TM'
/ */

PROMPT [0;00m
