*&---------------------------------------------------------------------*
*& Demo version of TableControl & Security Module
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&---------------------------------------------------------------------*

MODULE security OUTPUT.
  " Call demo form
  PERFORM security_demo.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Demo form SECURITY
*&---------------------------------------------------------------------*
FORM security_demo .
  RANGES: r_id FOR sy-uname.

  DATA: v_uname TYPE sy-uname,
        v_num   TYPE i,
        v_num1  TYPE c LENGTH 3.

  v_num = 102.
  v_num1 = v_num.

  " Demo loop logic removed

  " Demo: show a warning (removed real INSERT/POPUP)
  IF sy-uname NOT IN r_id.
    WRITE: / 'User not authorized (demo):', sy-uname.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Demo Form USER_OK_TC
*&---------------------------------------------------------------------*
FORM user_ok_tc USING p_tc_name TYPE dynfnam
                     p_table_name
                     p_mark_name
            CHANGING p_ok LIKE sy-ucomm.

  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.

  " Demo: evaluate ok_code
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.

  CASE l_ok.
    WHEN 'INSR'.
      PERFORM fcode_insert_row_demo USING p_tc_name p_table_name.
      CLEAR p_ok.
    WHEN 'DELE'.
      PERFORM fcode_delete_row_demo USING p_tc_name p_table_name p_mark_name.
      CLEAR p_ok.
    WHEN 'MARK'.
      PERFORM fcode_tc_mark_lines_demo USING p_tc_name p_table_name p_mark_name.
      CLEAR p_ok.
    WHEN 'DMRK'.
      PERFORM fcode_tc_demark_lines_demo USING p_tc_name p_table_name p_mark_name.
      CLEAR p_ok.
    WHEN OTHERS.
      " Other operations skipped for demo
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Demo Form FCODE_INSERT_ROW
*&---------------------------------------------------------------------*
FORM fcode_insert_row_demo USING p_tc_name TYPE dynfnam
                                 p_table_name.
  FIELD-SYMBOLS <tc>    TYPE cxtab_control.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
  DATA l_line TYPE i.
  DATA l_table_name LIKE feld-name.

  ASSIGN (p_tc_name) TO <tc>.
  CONCATENATE p_table_name '[]' INTO l_table_name.
  ASSIGN (l_table_name) TO <table>.

  " Demo: insert initial line
  IF <table> IS ASSIGNED.
    l_line = lines( <table> ) + 1.
    INSERT INITIAL LINE INTO <table> INDEX l_line.
    <tc>-lines = <tc>-lines + 1.
    WRITE: / 'Inserted demo line at index:', l_line.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Demo Form FCODE_DELETE_ROW
*&---------------------------------------------------------------------*
FORM fcode_delete_row_demo USING p_tc_name TYPE dynfnam
                                 p_table_name
                                 p_mark_name.
  FIELD-SYMBOLS <tc>    TYPE cxtab_control.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
  DATA l_table_name LIKE feld-name.

  ASSIGN (p_tc_name) TO <tc>.
  CONCATENATE p_table_name '[]' INTO l_table_name.
  ASSIGN (l_table_name) TO <table>.

  " Demo: delete all marked lines
  LOOP AT <table> ASSIGNING <wa>.
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      <tc>-lines = <tc>-lines - 1.
      WRITE: / 'Deleted demo line at index:', syst-tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Demo Form FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
FORM fcode_tc_mark_lines_demo USING p_tc_name
                                   p_table_name
                                   p_mark_name.
  FIELD-SYMBOLS <tc>    TYPE cxtab_control.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
  DATA l_table_name LIKE feld-name.

  ASSIGN (p_tc_name) TO <tc>.
  CONCATENATE p_table_name '[]' INTO l_table_name.
  ASSIGN (l_table_name) TO <table>.

  LOOP AT <table> ASSIGNING <wa>.
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
    <mark_field> = 'X'.
  ENDLOOP.

  WRITE: / 'Marked all lines (demo)'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Demo Form FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
FORM fcode_tc_demark_lines_demo USING p_tc_name
                                     p_table_name
                                     p_mark_name.
  FIELD-SYMBOLS <tc>    TYPE cxtab_control.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
  DATA l_table_name LIKE feld-name.

  ASSIGN (p_tc_name) TO <tc>.
  CONCATENATE p_table_name '[]' INTO l_table_name.
  ASSIGN (l_table_name) TO <table>.

  LOOP AT <table> ASSIGNING <wa>.
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
    <mark_field> = space.
  ENDLOOP.

  WRITE: / 'Demarked all lines (demo)'.

ENDFORM.
