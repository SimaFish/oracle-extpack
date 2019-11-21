--DROP TABLE csv_test;

-- Create table to store test csv string
CREATE TABLE csv_test (col1 CLOB);

-- Generate required amount of test values separated by a specified delimiter
DECLARE
    v_clob_val CLOB;
    v_testval_cnt PLS_INTEGER := 5000;
    v_delimiter VARCHAR2(32767) := ',';
    v_test_value VARCHAR2(32767) := 'TestVal';
BEGIN
    WITH csv_dataset AS (
    SELECT v_test_value || LEVEL test_val,
           LEVEL ord_num
      FROM DUAL
    CONNECT BY LEVEL <= v_testval_cnt)

    SELECT RTRIM(DBMS_XMLGEN.CONVERT(XMLAGG(XMLELEMENT(e, test_val, v_delimiter).EXTRACT('//text()')
                 ORDER BY ord_num).GetClobVal(), 1), v_delimiter) csv_string
      INTO v_clob_val
      FROM csv_dataset;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE csv_test';

    INSERT INTO csv_test (col1)
         VALUES (v_clob_val);
END;

-- Example 1 (single separator)
SELECT column_value AS VALUE
  FROM TABLE(STRING_SPLIT('Str1,Str2,Str3,Str4,Str5,Str6,Str7', ','));

-- Example 2 (separator expression)
SELECT column_value AS VALUE
  FROM TABLE(STRING_SPLIT('__Str1__,__Str2_,__Str3___,___Str4_,__Str5_', '_,_'));

-- Example 3 (trim `_` symbol from the left-hand side)
SELECT column_value AS VALUE
  FROM TABLE(STRING_SPLIT('__Str1__,__Str2_,__Str3___,___Str4_,__Str5_', '_,_', 1, '_'));

-- Example 4 (trim `_` symbol from the right-hand side)
SELECT column_value AS VALUE
  FROM TABLE(STRING_SPLIT('__Str1__,__Str2_,__Str3___,___Str4_,__Str5_', '_,_', 2, '_'));

-- Example 5 (trim `_` symbol from both sides)
SELECT column_value AS VALUE
  FROM TABLE(STRING_SPLIT('____Str1,Str2_,__Str3__,Str4,Str5__,___Str6,Str7__,_Str8,__Str9,_Str10__', ',', 3, '_'));

--DROP TABLE test_table;

-- Example 6 (results table for extremely large result sets)
CREATE TABLE test_table AS
SELECT column_value AS VALUE
  FROM TABLE(SELECT STRING_SPLIT(col1, ',') FROM csv_test);