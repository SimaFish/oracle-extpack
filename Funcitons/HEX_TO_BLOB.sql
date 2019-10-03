-- =============================================================================
--  Function      : HEX_TO_BLOB
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.1
--  Creation date : 18.08.2019
--  Last modified : 02.10.2019
--  Language      : Oracle PL/SQL, SQL
-- =============================================================================
--  Description   : Converts CLOB containing hexadecimal representation (HEX)
--                : of binary data into BLOB value.
--                : 
--                : This function is a bypass for Oracle HEXTORAW, which doesn't
--                : support CLOB data directly, and conversion of HEX values
--                : longer than 32767 bytes.
-- =============================================================================
--  Parameters    : > p_hex_code:
--                : Any valid hexadecimal value to convert into binary data.
-- =============================================================================

CREATE OR REPLACE FUNCTION HEX_TO_BLOB (p_hex_code IN CLOB)
RETURN BLOB
IS
    v_blob_val    BLOB;
    v_raw_buffer  RAW(32000);
    v_currpos     SIMPLE_INTEGER := 1;
    v_hexcode_len SIMPLE_INTEGER := 0;
    v_chunk_size  SIMPLE_INTEGER := 32000;
    v_hex_code    CLOB := p_hex_code;
BEGIN
    -- Left padding with '0' the HEX code if it has unpaired length
    v_hex_code := CASE MOD(DBMS_LOB.GETLENGTH(p_hex_code), 2)
                     WHEN 0 THEN p_hex_code
                     ELSE '0' || p_hex_code
                  END;

    DBMS_LOB.CREATETEMPORARY(lob_loc => v_blob_val,
                             cache   => FALSE,
                             dur     => DBMS_LOB.CALL);

    v_hexcode_len := DBMS_LOB.GETLENGTH(v_hex_code);

    WHILE v_currpos <= v_hexcode_len
    LOOP
        v_raw_buffer := HEXTORAW(DBMS_LOB.SUBSTR(lob_loc => v_hex_code,
                                                 amount  => v_chunk_size,
                                                 offset  => v_currpos));
        DBMS_LOB.WRITEAPPEND(v_blob_val,
                             UTL_RAW.LENGTH(v_raw_buffer),
                             v_raw_buffer);

        v_currpos := v_currpos + v_chunk_size;
    END LOOP;

    RETURN v_blob_val;
END HEX_TO_BLOB;
/

ALTER FUNCTION HEX_TO_BLOB
    COMPILE PLSQL_CODE_TYPE = NATIVE
    PLSQL_OPTIMIZE_LEVEL = 3
    REUSE SETTINGS;
/