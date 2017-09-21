-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows immediate compression gain for a table.
-- Rem -- Usage: @com_compress <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

Set autot        off
Set linesize     200
Set pagesize     100
Set serveroutput  on
Set verify       off

PROMPT "********************************"
PROMPT "*** Table Compression Report ***"
PROMPT "********************************"

define comp_tblsearch = &1

DECLARE
comp_tblsearch VARCHAR2(70);
comp_tblcheck  NUMBER := 0;
pct            NUMBER := 0.000099;
blkcnt         NUMBER := 0;
blkcntc        NUMBER;
comp_initsize  NUMBER;
comp_compsize  NUMBER;
begin
SELECT count(1) INTO comp_tblcheck
FROM dba_tables where table_name = 'TEMP_COMPRESS_FOR_TEST';
IF comp_tblcheck = 0
THEN
    EXECUTE IMMEDIATE 'create table TEMP_COMPRESS_FOR_TEST pctfree 0 as select * from &comp_tblsearch where rownum < 1';
    while ((pct < 100) and (blkcnt < 1000))
    loop
        EXECUTE IMMEDIATE 'truncate table TEMP_COMPRESS_FOR_TEST';
        EXECUTE IMMEDIATE 'insert into TEMP_COMPRESS_FOR_TEST (select * from &comp_tblsearch sample block ('|| pct ||',10))';
        EXECUTE IMMEDIATE 'select count(distinct(dbms_rowid.rowid_block_number(rowid))) from TEMP_COMPRESS_FOR_TEST' INTO blkcnt;
        pct := pct * 10;
    end loop;
    EXECUTE IMMEDIATE 'alter table TEMP_COMPRESS_FOR_TEST move compress ';
    EXECUTE IMMEDIATE 'select count(distinct(dbms_rowid.rowid_block_number(rowid))) from TEMP_COMPRESS_FOR_TEST' into blkcntc;
    EXECUTE IMMEDIATE 'drop table TEMP_COMPRESS_FOR_TEST';
    SELECT bytes INTO comp_initsize
        FROM dba_segments
        WHERE owner||'.'||SEGMENT_NAME = UPPER('&comp_tblsearch');
    SELECT comp_initsize/ROUND(blkcnt/blkcntc,3) INTO comp_compsize FROM dual;

    DBMS_OUTPUT.Put_line('Table &comp_tblsearch compression ratio: '||ROUND(blkcnt/blkcntc,3));
    DBMS_OUTPUT.Put_line('Size before compression (Mb): '||ROUND(comp_initsize/1024/1024,3));
    DBMS_OUTPUT.Put_line('Size after compression (Mb): '||ROUND(comp_compsize/1024/1024,3));
ELSE
    DBMS_OUTPUT.Put_line('Table TEMP_COMPRESS_FOR_TEST found! Aborting...');
END IF;
end;
/
