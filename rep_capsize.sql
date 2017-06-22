-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows detailled informations about database size.
-- Rem -- Usage: @rep_capsize
-- Rem -- --------------------------------------------------

Set autot        off
Set verify       off
Set linesize     200
Set pages          0
Set heading       on
Set pagesize    2000

PROMPT [0;33m
PROMPT    "****************************"
PROMPT    "*** Capacity Information ***"
PROMPT    "****************************"
PROMPT

Col rcs_dbdatafiles         for 9G999G990D00     head "Database|Datafiles|(Gb)"    justify right
Col rcs_ownerschema         for A30              head "Schema|Name"                justify left
Col rcs_schemasize          for 9G999G990D00     head "Schema|Size|(Mb)"           justify right
Col rcs_cstbs_tsname        for A30              head "Tablespace|Name"            justify left
Col rcs_Tbs_size            for 9G999G990D00     head "Tablespace|Size|(Mb)"       justify right
Col rcs_TSid                for     99999        head "Tablespace|Id"              justify right
Col rcs_fs                  for A50              head "File System"                justify left
Col rcs_cstbs_blocksize     for       999        head "Block Size|(Kb)"            justify right
Col rcs_fssiz               for 9G999G990D00     head "Full|Database|Size|(Gb)"    justify right
Col rcs_sizmo               for 9G999G990D00     head "Size"                       justify left
Col rcs_Pct_Used            for   9999999        head "Percent|used"               justify right
Col rcs_Pct_Free            for       999        head "F|r|e|e"                    justify right
Col rcs_tot_spc_alloc_Mo    for    9G999G990D00  head "Total|Allocated|Space|(Mb)" justify right
Col rcs_tot_spc_used_Mo     for 9G999G990D00     head "Total|Used|Space|(Mb)"      justify right
Col rcs_tot_spc_free_Mo     for 9G999G990D00     head "Total|Free|Space|(Mb)"      justify right
Col rcs_FileName            for A65              head "File|Name"                  justify left
Col rcs_fileid              for      9999        head "File|ID"                    justify left
Col rcs_cs_autoext          for A12              head "Autoextend"                 justify right
Col rcs_ts_name             for A30              head "Tablespace Name"            justify left

-- Rem -- Sizing tips
-- Rem -- SIZE                      Human Eqv
-- Rem -- ------------------------- ---------
-- Rem -- size                      Bytes
-- Rem -- size/1024                 KiloBytes
-- Rem -- size/1024/1024            MegaBytes
-- Rem -- size/1024/1024/1024       GigaBytes
-- Rem -- size/1024/1024/1024/1024  TeraBytes

PROMPT
PROMPT -- Total Database
PROMPT -----------------

SELECT ROUND(sum(bytes)/1024/1024/1024,2) AS rcs_dbdatafiles
FROM dba_data_files;

PROMPT
PROMPT -- Datafiles Info
PROMPT -----------------

-- break on report
-- compute sum of fssiz on report
SELECT     SUBSTR(file_name,1,instr(file_name,'/',-1)-1) AS rcs_fs,
        ROUND(sum(bytes/1024/1024/1024),2) AS rcs_fssiz
FROM    (SELECT file_name,bytes FROM dba_data_files
        union all
        SELECT member,bytes FROM v$log,v$logfile
        where v$log.group#=v$logfile.group#
        union all
        SELECT file_name,bytes FROM dba_temp_files)
group by substr(file_name,1,instr(file_name,'/',-1)-1);

PROMPT
PROMPT -- Schema Info
PROMPT --------------

SELECT owner AS rcs_ownerschema, ROUND(sum(bytes)/1024/1024,2) AS rcs_schemasize
FROM dba_segments group by owner order by 2 desc;

PROMPT
PROMPT -- Tablespaces
PROMPT --------------

SELECT ddf.tablespace_name              AS rcs_cstbs_tsname
    , AVG(dts.BLOCK_SIZE)/1024           AS rcs_cstbs_blocksize
    , ROUND(sum(ddf.bytes)/1024/1024,2)  AS rcs_Tbs_size
FROM dba_data_files ddf
JOIN dba_tablespaces dts
ON (ddf.TABLESPACE_NAME = dts.TABLESPACE_NAME)
GROUP BY ddf.tablespace_name
ORDER BY 3 desc;

PROMPT
PROMPT -- Data Tablespaces
PROMPT -------------------


SELECT  tsid          AS rcs_TSid,
        tsname         AS rcs_ts_name,
        rcs_pct_used   AS rcs_Pct_Used,
        --pct_free,
        rcs_tot_spc_alloc_Mo, rcs_tot_spc_used_Mo, rcs_tot_spc_free_Mo
FROM   (SELECT   "C"."TS#" tsid,
                 a.tsname,
                 round((1 - (b.tot_spc_free / a.tot_spc_alloc)) * 100)            AS rcs_pct_used,
                 --LPAD(round((b.tot_spc_free / a.tot_spc_alloc) * 100),3,' ')    AS rcs_pct_free,
                 round(a.tot_spc_alloc / 1024 / 1024,2)                           AS rcs_tot_spc_alloc_Mo,
                 round((a.tot_spc_alloc - b.tot_spc_free) / 1024 / 1024,2)        AS rcs_tot_spc_used_Mo,
                 round(b.tot_spc_free / 1024 / 1024,2)                            AS rcs_tot_spc_free_Mo
        FROM     (SELECT   tablespace_name tsname, SUM (BYTES) tot_spc_alloc
                  FROM     DBA_DATA_FILES
                  GROUP BY tablespace_name) a,
                 (SELECT   tablespace_name tsname, SUM (BYTES) tot_spc_free, MAX (BYTES) max_b2
                  FROM     DBA_FREE_SPACE
                  GROUP BY tablespace_name) b,
                 v$tablespace c
        WHERE    a.tsname = b.tsname(+)
                AND a.tsname = c.NAME
        ORDER BY "C"."TS#")
ORDER BY tsname;


-- Choose a specific tablespace
VAR TABLESPACEID NUMBER;
ACCEPT TABLESPACEID PROMPT 'Enter Tablespace ID:'

PROMPT
PROMPT -- List Datafiles for a specified tablespace
PROMPT --------------------------------------------

-- break on report
-- compute avg of pct_free on report
-- compute avg of pct_used on report

SELECT DISTINCT a.file_id                                                     AS rcs_fileid,
                SUBSTR (a.file_name, 1, 60)                                   AS rcs_FileName,
                NVL(round((1 - (b.tot_spc_free / a.BYTES)) * 100),0)          AS rcs_pct_used,
                --LPAD(NVL(round((b.tot_spc_free / a.BYTES) * 100),0),3,' ')  AS rcs_pct_free,
                round(a.BYTES/1024/1024,2)                                    AS rcs_tot_spc_alloc_Mo,
                NVL(round(tot_spc_free/1024/ 1024,2),000)                     AS rcs_tot_spc_free_Mo,
                AUTOEXTENSIBLE                                                AS rcs_cs_autoext
FROM            DBA_DATA_FILES a, (SELECT   file_id, tablespace_name tsname, SUM (BYTES) tot_spc_free, MAX (BYTES) max_b2
                                   FROM     DBA_FREE_SPACE
                                   GROUP BY file_id, tablespace_name) b
WHERE           a.file_id = b.file_id(+)
 AND a.tablespace_name = (SELECT NAME
            FROM   v$tablespace
            WHERE  ts# = &tablespaceid)
ORDER BY rcs_FileName;

PROMPT [0;00m
