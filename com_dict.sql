-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Simple lazy script for dictionary table searching.
-- Rem -- Usage: @com_dict <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

Set autot     off
Set verify    off
Set linesize  165
Set heading    on
Set pagesize  200

col ds_tablename FOR A30 head "Table|Name" justify left
col ds_comments  FOR A90 head "Comments"   justify center

PROMPT [0;33m
PROMPT "*************************"
PROMPT "*** Dictionary Search ***"
PROMPT "*************************"
PROMPT

SELECT TABLE_NAME AS ds_tablename, COMMENTS AS ds_comments
FROM dictionary
WHERE TABLE_NAME LIKE UPPER('%&1%')
ORDER BY TABLE_NAME;

PROMPT [0;00m
