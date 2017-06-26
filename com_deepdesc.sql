-- Rem -- --------------------------------------------------
-- Rem -- Platform:  Oracle DB
-- Rem -- Desctiption: Shows detailed informations on a specific table.
-- Rem -- Usage: @com_compress <OWNER>.<TABLE_NAME>
-- Rem -- --------------------------------------------------

Set autot      off
Set linesize   165
Set pages      100
Set verify     off

col dpdsc_colnam     for A30          head "Column|Name"   justify left
col dpdsc_datatype   for A33          head "Datatype"      justify left
col dpdsc_nullable   for A8           head "Nullable"      justify center
col dpdsc_NUM_ROWS   for 999G999G990  head "NUM_ROWS"      justify right
col dpdsc_colnumdist for 999G999G990  head "Distinct"      justify right
col dpdsc_avgcollen  for 999G999G990  head "Avg Col Len"   justify right
col dpdsc_numnulls   for 999G999G990  head "Num Nulls"     justify right
col dpdsc_dnsty      for 9D000000     head "Density"       justify right

define tbl_name=&1

PROMPT "****************"
PROMPT "*** Deepdesc ***"
PROMPT "****************"
PROMPT

SELECT  dtc.column_name                AS dpdsc_colnam
  , dtc.DATA_TYPE                      AS dpdsc_datatype
  , DECODE(NULLABLE,'Y',NULL,'N','NN') AS dpdsc_nullable
  , dtb.NUM_ROWS                       AS dpdsc_NUM_ROWS
  , dtc.num_distinct                   AS dpdsc_colnumdist
  , dtc.NUM_NULLS                      AS dpdsc_numnulls
  , dtc.AVG_COL_LEN                    AS dpdsc_avgcollen
  , ROUND(dtc.density,7)               AS dpdsc_dnsty
FROM  dba_tables dtb JOIN dba_tab_cols dtc
ON ( dtb.table_name  = dtc.table_name
    AND dtb.owner    = dtc.owner)
WHERE dtb.owner||'.'||dtc.table_name = upper('&tbl_name')
/
