*&---------------------------------------------------------------------*
*& Report  ZATTENDANCE_REPORT
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zattendance_report.

TABLES: zemp_attendance.

  " Code removed here

CONSTANTS: c_green  TYPE icon-id VALUE '@5B@',
           c_yellow TYPE icon-id VALUE '@5D@',
           c_red    TYPE icon-id VALUE '@5C@',
           c_sun    TYPE icon-id VALUE '@IQ@'.

DATA: v_empid TYPE zemp_official-empid.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat LIKE LINE OF it_fieldcat.

DATA: v_program TYPE sy-repid.

DATA: it_att TYPE STANDARD TABLE OF ty_att,
      wa_att LIKE LINE OF it_att.

DATA: v_day LIKE dtresr-weekday.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

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
  IMPORT v_empid  FROM MEMORY ID 'ID2'.

  SELECT * FROM zemp_attendance INTO CORRESPONDING FIELDS OF TABLE it_att
    WHERE empid  = v_empid AND
          zdate IN s_date.


  IF it_att IS INITIAL.
    MESSAGE 'No attendance records were found within the specified date range.' TYPE 'I'.
  ELSE.
      " Code removed here
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
