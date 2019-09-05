CREATE OR REPLACE FUNCTION BLOB_TO_HEX (p_blob_val IN BLOB)
RETURN CLOB
IS
    v_hex_code   CLOB;
    v_hex_buffer VARCHAR2(32000);
    v_blob_len   PLS_INTEGER;
    v_chunk_size INTEGER := 16000;
    v_currpos    SIMPLE_INTEGER := 1;
BEGIN
    /*
    *   Title: Converts BLOB binary data into hexadecimal (HEX) representation
    *   Author: Andriy Oseledko
    *   Date: 19.08.2019
    *   Code version: 1.0
    */
    v_blob_len := DBMS_LOB.GETLENGTH(p_blob_val);

    LOOP
        v_hex_buffer := RAWTOHEX(DBMS_LOB.SUBSTR(lob_loc => p_blob_val,
                                                 amount  => v_chunk_size,
                                                 offset  => v_currpos));
        v_hex_code := v_hex_code || v_hex_buffer;

        v_currpos := v_currpos + v_chunk_size;
        EXIT WHEN v_currpos > v_blob_len;
    END LOOP;

    RETURN v_hex_code;
END BLOB_TO_HEX;
/