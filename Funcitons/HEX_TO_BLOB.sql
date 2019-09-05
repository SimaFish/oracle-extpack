CREATE OR REPLACE FUNCTION HEX_TO_BLOB (p_hex_code IN CLOB)
RETURN BLOB
IS
    v_blob_val    BLOB;
    v_hexcode_len PLS_INTEGER;
    v_raw_buffer  RAW(32000);
    v_chunk_size  INTEGER := 32000;
    v_hex_code    CLOB := p_hex_code;
    v_currpos     SIMPLE_INTEGER := 1;
BEGIN
    /*
    *   Title: Converts CLOB containing hexadecimal representation (HEX) of binary data into BLOB value
    *   Author: Andriy Oseledko
    *   Date: 18.08.2019
    *   Code version: 1.0
    */
    --Left padding (with '0') the HEX code if it has unpaired length
    v_hex_code := CASE MOD(DBMS_LOB.GETLENGTH(p_hex_code), 2)
                     WHEN 0 THEN p_hex_code
                     ELSE '0' || p_hex_code
                  END;

    DBMS_LOB.CREATETEMPORARY(lob_loc => v_blob_val,
                             cache   => FALSE,
                             dur     => DBMS_LOB.CALL);

    DBMS_LOB.OPEN(lob_loc   => v_blob_val,
                  open_mode => DBMS_LOB.LOB_READWRITE);

    v_hexcode_len := DBMS_LOB.GETLENGTH(v_hex_code);

    LOOP
        v_raw_buffer := HEXTORAW(TO_CHAR(DBMS_LOB.SUBSTR(lob_loc => v_hex_code,
                                                         amount  => v_chunk_size,
                                                         offset  => v_currpos)));
        DBMS_LOB.WRITEAPPEND(v_blob_val,
                             UTL_RAW.LENGTH(v_raw_buffer),
                             v_raw_buffer);

        v_currpos := v_currpos + v_chunk_size;
        EXIT WHEN v_currpos > v_hexcode_len;
    END LOOP;

    RETURN v_blob_val;
END HEX_TO_BLOB;
/