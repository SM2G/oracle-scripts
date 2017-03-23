-- Rem -- --------------------------------------------------
-- Rem -- Script Name: SCP Splitter
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Splits all DB Files for parallel SCP
-- Rem -- Usage: @com_tbssize <NUMBER_OF_THREADS>
-- Rem -- --------------------------------------------------

SET linesize    170
SET pages         0
SET heading      ON 
SET pagesize   2000
SET serveroutput on

PROMPT [0;33m
PROMPT    "********************" 
PROMPT    "*** SCP Splitter ***" 
PROMPT    "********************" 
Col spt_filegroup        for         999          head "Filegroup"            justify left
Col spt_filename         for A100                 head "File Name"            justify left
Col spt_filesize         for 999G999G990D00       head "File Size(Mb)"        justify right

-- Rem -- Sizing tips
-- Rem -- SIZE                      Human Eqv
-- Rem -- ------------------------- ---------
-- Rem -- size                      Bytes
-- Rem -- size/1024                 KiloBytes
-- Rem -- size/1024/1024            MegaBytes
-- Rem -- size/1024/1024/1024       GigaBytes
-- Rem -- size/1024/1024/1024/1024  TeraBytes

define nb_filegroups = &1

Select (Round(MOD(rownum, &nb_filegroups)))+1 AS spt_filegroup, datafiles_table.*
FROM
   (Select NAME AS spt_filename, BYTES/1024/1024 AS spt_filesize FROM v$datafile 
   UNION
   Select lgf.MEMBER, log.BYTES/1024/1024 FROM V$LOGFILE lgf, v$log log WHERE lgf.GROUP# = log.GROUP# 
   UNION 
   Select NAME, (block_size * file_size_blks)/1024/1024 AS spt_filesize FROM V$CONTROLFILE 
   UNION
   Select NAME, BYTES/1024/1024 FROM v$tempfile Order by spt_filesize) datafiles_table
Order by spt_filegroup;

PROMPT [0;00m

