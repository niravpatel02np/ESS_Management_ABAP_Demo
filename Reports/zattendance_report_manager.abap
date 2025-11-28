*&---------------------------------------------------------------------*
*& Report  ZATTENDANCE_REPORT
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zattendance_report_manager.

TABLES: zemp_attendance.

 " Code removed here

DATA: v_day LIKE dtresr-weekday.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS: p_empid TYPE zemp_attendance-empid.
SELECT-OPTIONS: s_date FOR zemp_attendance-zdate.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM fetch_data.

END-OF-SELECTION.
  PERFORM set_fieldcat.
  PERFORM display_alv.
*&---------------------------------------------------------------------*
*&      Form  FETCH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_data .
  IMPORT v_empid  FROM MEMORY ID 'ID6'.

  CLEAR: it_empl, it_att.

 " Code removed here

  IF it_att IS INITIAL.
    " Code removed here
  ELSE.
    SORT it_att BY zdate.
    LOOP AT it_att INTO wa_att.
      IF wa_att-status = 'Present' OR wa_att-status = 'Compoff'. "Fully paid
        " Code removed here
        MODIFY it_att FROM wa_att.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT it_att INTO wa_att.
    CALL FUNCTION 'DATE_TO_DAY'
      EXPORTING
        date    = wa_att-zdate
      IMPORTING
        weekday = v_day.

    wa_att-day = v_day.
    MODIFY it_att FROM wa_att TRANSPORTING day.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fieldcat .
***Building Fieldcatalog
  CLEAR: it_fieldcat.

 " Code removed here

  LOOP AT it_fieldcat INTO wa_fieldcat.
    wa_fieldcat-tabname = 'IT_ATT'.
    "wa_fieldcat-just = 'C'.
    " wa_fieldcat-outputlen = 15.
    wa_fieldcat-icon = 'X'.
    MODIFY it_fieldcat FROM  wa_fieldcat TRANSPORTING tabname.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  CLEAR: v_program.
  v_program = sy-repid.

  IF it_att IS NOT INITIAL.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = v_program
*       IS_LAYOUT          =
        it_fieldcat        = it_fieldcat
*       i_grid_title       = v_title
*       IT_EVENTS          =
*       IT_EVENT_EXIT      =
* IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        t_outtab           = it_att
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      MESSAGE 'Some errors occurred while displaying ALV.' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.
