*&---------------------------------------------------------------------*
*& Demo version of Attendance Insert Program
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&---------------------------------------------------------------------*
REPORT zinsert_attendance_demo.

TABLES: zemp_attendance, zemp_official, zleave_histo.

DATA: it_att TYPE STANDARD TABLE OF zemp_attendance,
      wa_att LIKE LINE OF it_att.

DATA: it_leave TYPE STANDARD TABLE OF zleave_histo,
      wa_leave LIKE LINE OF it_leave.

TYPES: BEGIN OF ty_empid,
         empid TYPE z120_empid,
       END OF ty_empid.

DATA: it_empid TYPE STANDARD TABLE OF ty_empid,
      wa_empid LIKE LINE OF it_empid.

DATA: v_day LIKE dtresr-weekday.

" Demo: select employee IDs (kept as harmless query example)
SELECT empid FROM zemp_official INTO TABLE it_empid.
WRITE: / 'Number of employees fetched (demo):', lines( it_empid ).

LOOP AT it_empid INTO wa_empid.

  " Fill demo attendance record
  wa_att-empid = wa_empid-empid.
  wa_att-zdate = sy-datum.

  " Demo: select leave history (example kept to show query structure)
  " Database interaction removed for safety
  CLEAR it_leave.
  " SELECT * FROM zleave_histo INTO TABLE it_leave WHERE empid = wa_empid-empid.
  WRITE: / 'Checking leave records for employee (demo):', wa_empid-empid.

  " Demo conditional logic to show coding skill
  IF it_leave IS NOT INITIAL.
    LOOP AT it_leave INTO wa_leave.
      IF wa_leave-begin_date LE sy-datum AND wa_leave-end_date GE sy-datum.
        IF wa_leave-status = 'Approved'.
          wa_att-status = wa_leave-leave_type.
        ELSE.
          wa_att-status = 'Present'.
        ENDIF.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    " No leave record demo logic
    CALL FUNCTION 'DATE_TO_DAY'
      EXPORTING
        date    = sy-datum
      IMPORTING
        weekday = v_day.

    IF v_day <> 'Sunday' AND v_day <> 'Saturday'.
      wa_att-status = 'Present'.
    ELSE.
      wa_att-status = v_day.
    ENDIF.
  ENDIF.

  " Demo insert removed for safety
  " INSERT INTO zemp_attendance VALUES wa_att.
  WRITE: / 'Attendance record prepared (demo) for employee:', wa_att-empid, wa_att-status.

ENDLOOP.
