-- =============================================================================
--  Function      : BLOB_TO_HEX
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.1
--  Creation date : 19.08.2019
--  Modifications : 02.10.2019
-- =============================================================================
--  Description   : Converts BLOB binary data into hexadecimal representation.
--                : Each byte is represented by two hexadecimal (HEX) digits.
--                : Resulting HEX returned as CLOB string.
--                : 
--                : This function is a bypass for Oracle RAWTOHEX, which doesn't
--                : support conversion of BLOB value which resulting HEX exceeds
--                : 32767 bytes limit of VARCHAR2 data type.
-- =============================================================================
--  Parameters    : > p_blob_val:
--                : Any non-null BLOB hexadecimal value to convert into HEX.
-- =============================================================================

CREATE OR REPLACE FUNCTION BLOB_TO_HEX (p_blob_val IN BLOB)
RETURN CLOB
IS
    v_hex_code   CLOB;
    v_blob_len   INTEGER;
    v_currpos    INTEGER := 1;
    v_hex_buffer VARCHAR2(32000);
    v_chunk_size SIMPLE_INTEGER := 16000;
BEGIN
    v_blob_len := DBMS_LOB.GETLENGTH(p_blob_val);

    WHILE v_currpos <= v_blob_len
    LOOP
        v_hex_buffer := RAWTOHEX(DBMS_LOB.SUBSTR(lob_loc => p_blob_val,
                                                 amount  => v_chunk_size,
                                                 offset  => v_currpos));
        v_hex_code := v_hex_code || v_hex_buffer;

        v_currpos := v_currpos + v_chunk_size;
    END LOOP;

    RETURN v_hex_code;
END BLOB_TO_HEX;
/