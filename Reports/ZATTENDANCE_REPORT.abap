*&---------------------------------------------------------------------*
*& Report  ZATTENDANCE_REPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zattendance_report.

TABLES: zemp_attendance.

TYPES: BEGIN OF ty_att,
         icon         TYPE char4,
         " empid type Z120_EMPID,
         day          TYPE dtresr-weekday,
         zdate        TYPE zemp_attendance-zdate,
         clock_in     TYPE zemp_attendance-clock_in,
         clock_out    TYPE zemp_attendance-clock_out,
         hours_worked TYPE zemp_attendance-hours_worked,
         status       TYPE zemp_attendance-status,
       END OF ty_att.

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
    SORT it_att BY zdate.
    LOOP AT it_att INTO wa_att.
      IF wa_att-status = 'Present' OR wa_att-status = 'Compoff'. "Fully paid
        MOVE c_green TO wa_att-icon.
        MODIFY it_att FROM wa_att.
      ELSEIF wa_att-status = 'Sick Leave' OR wa_att-status = 'Bereavement Leave' OR wa_att-status = 'Vacation Leave'
        OR wa_att-status = 'Earned Leave' OR wa_att-status = 'Maternity Leave' OR wa_att-status = 'Paternity Leave' .
        "No pay deduction but hasn't worked
        MOVE c_yellow TO wa_att-icon.
        MODIFY it_att FROM wa_att.
      ELSEIF wa_att-status = 'Absent' OR wa_att-status = 'Unpaid Leave'. "Pay will be deducted
        MOVE c_red TO wa_att-icon.
        MODIFY it_att FROM wa_att.
      ELSEIF wa_att-status = 'Saturday' OR wa_att-status = 'Sunday'.
        MOVE c_sun TO wa_att-icon.
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

  wa_fieldcat-fieldname = 'ICON'.
  wa_fieldcat-seltext_m = ' '.
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-outputlen = 4.
  wa_fieldcat-just = 'C'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'ZDATE'.
  wa_fieldcat-seltext_m = 'Date'.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'DAY'.
  wa_fieldcat-seltext_m = 'Day'.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'CLOCK_IN'.
  wa_fieldcat-seltext_m = 'Clock In'.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'CLOCK_OUT'.
  wa_fieldcat-seltext_m = 'Clock Out'.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'HOURS_WORKED'.
  wa_fieldcat-seltext_m = 'Hours Worked'.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'STATUS'.
  wa_fieldcat-seltext_m = 'Status'.
  wa_fieldcat-col_pos = 7.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.


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
