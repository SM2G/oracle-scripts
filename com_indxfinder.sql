-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows detailled index information for a specific table.
-- Rem -- Usage: @com_indxfinder <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

-- Original Script by Burleson
-- http://www.dba-oracle.com/concepts/indexes_for_table_query.htm -- (The original query being incorrect.)

Set autot        off
Set linesize     200
Set pagesize     100
Set serveroutput  on
Set verify       off

col if_tblname   for A61            head "    Owner.TableName"      justify center
col if_colindn   for A30            head "Index|Name"               justify left
col if_blocks    for 9G999G999G999  head "Blocks"                   justify right
col if_clusfac   for 9G999G999G999  head "Clustering|Factor"        justify right
col if_numrows   for 9G999G999G999  head "Num Rows"                 justify right
col if_distkeys  for A10            head "Distinct|Keys"            justify left
col if_colindc   for A60            head "Column Name and Position" justify left

PROMPT "***************************"
PROMPT "*** Index Finder Report ***"
PROMPT "***************************"

define if_indsearch = &1

DECLARE
expression dba_ind_expressions.COLUMN_EXPRESSION%TYPE;
position   dba_ind_expressions.COLUMN_POSITION%TYPE;
BEGIN
DBMS_OUTPUT.Put_Line('Index');
DBMS_OUTPUT.Put_Line('Name                           Func Column Name and Position');
DBMS_OUTPUT.Put_Line('------------------------------ ---- ------------------------------------------------------------');
For src IN (SELECT dic.index_name AS index_name
            , dic.COLUMN_NAME     AS column_name
            , dic.COLUMN_POSITION AS column_position
            FROM dba_ind_columns dic
            WHERE dic.table_owner||'.'||dic.table_name = UPPER('&if_indsearch')
            ORDER BY dic.table_owner, dic.table_name, dic.index_name, dic.column_position)
LOOP
    IF src.column_name LIKE 'SYS!_NC%' ESCAPE '!' THEN
        Select COLUMN_EXPRESSION, COLUMN_POSITION INTO expression, position
        FROM dba_ind_expressions
        WHERE index_name = src.index_name
        AND COLUMN_POSITION = src.column_position
        AND TABLE_OWNER||'.'||TABLE_NAME = UPPER('&if_indsearch');
        DBMS_OUTPUT.Put_line(RPAD(src.index_name,30)||' Func '||LPAD(expression,LENGTH(expression) + position * 2-2,' '));
    ELSE
        DBMS_OUTPUT.Put_line(RPAD(src.index_name,30)||'      '||LPAD(src.column_name,LENGTH(src.column_name) + src.column_position * 2-2,' '));
    END IF;
END LOOP;
END;
/


VAR    whatever NUMBER;
ACCEPT whatever PROMPT 'Press Y for clustering report:'

SELECT  dic.index_name                                                                AS if_colindn
    ,   ds.BLOCKS                                                                     AS if_blocks
    ,   di.CLUSTERING_FACTOR                                                          AS if_clusfac
    ,   dt.NUM_ROWS                                                                   AS if_numrows
    ,   LPAD(dic.COLUMN_NAME,LENGTH(dic.COLUMN_NAME) + dic.COLUMN_POSITION * 2-2,' ') AS if_colindc
FROM dba_ind_columns dic
    JOIN dba_tab_cols dtc
    ON (dic.TABLE_OWNER = dtc.OWNER
    AND dic.TABLE_NAME  = dtc.TABLE_NAME
    AND dic.COLUMN_NAME = dtc.COLUMN_NAME)
    JOIN dba_indexes di
    ON (dic.TABLE_OWNER = di.TABLE_OWNER
    AND dic.TABLE_NAME  = di.TABLE_NAME
    AND dic.INDEX_NAME  = di.INDEX_NAME)
    JOIN dba_segments ds
    ON (dic.TABLE_OWNER = ds.OWNER
    AND dic.TABLE_NAME  = ds.SEGMENT_NAME)
    JOIN dba_tables dt
    ON (dic.TABLE_OWNER    = dt.OWNER
    AND dic.TABLE_NAME  = dt.TABLE_NAME)
WHERE dic.table_owner||'.'||dic.table_name = UPPER('&if_indsearch')
AND UPPER('&whatever') = 'Y'
ORDER BY dic.table_owner, dic.table_name, dic.index_name, dic.column_position;


-- CLUSTERING_FACTOR: This is one of the most important index statistics
-- because it indicates how well sequenced the index columns are to the table rows.
-- If clustering_factor is low (about the same as the number of dba_segments.blocks
-- in the table segment) then the index key is in the same order as the table rows
-- and index range scans will be very efficient, with minimal disk I/O.
-- As clustering_factor increases (up to dba_tables.num_rows),
-- the index key is increasingly out of sequence with the table rows.
-- Oracle�s cost-based SQL optimizer relies heavily upon clustering_factor
-- to decide whether to use the index to access the table.
-- Blocks < Clustering_factor < NUM_ROWS
