*&---------------------------------------------------------------------*
*& Report  ZINSERT_ATTENDANCE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zinsert_attendance.

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

"IF sy-batch = 'X'. "only execute logic if it is daily background job

SELECT empid FROM zemp_official INTO TABLE it_empid.

LOOP AT it_empid INTO wa_empid.

  wa_att-empid = wa_empid-empid.
  wa_att-zdate = sy-datum.

  SELECT * FROM zleave_histo INTO TABLE it_leave WHERE empid = wa_empid-empid .

  IF it_leave IS NOT INITIAL. "Employee has leave applocations
    LOOP AT it_leave INTO wa_leave.


      IF  wa_leave-begin_date LE sy-datum .
        IF  wa_leave-end_date GE sy-datum. "Today's date found record in leave table

          IF wa_leave-status = 'Approved'. "leave was approved
            wa_att-status = wa_leave-leave_type.

            IF wa_leave-leave_type <> 'Compoff'.
              IF wa_leave-day_type = 'Full Day'.
                wa_att-clock_in = '000000'.
                wa_att-clock_out = '000000'.
                wa_att-hours_worked = 0.
              ELSE.
                wa_att-clock_in = '080000'.
                wa_att-clock_out = '120000'.
                wa_att-hours_worked = 4.
              ENDIF.
            ELSE.
              IF wa_leave-day_type = 'Full Day'.
                wa_att-clock_in = '080000'.
                wa_att-clock_out = '150000'.
                wa_att-hours_worked = 8.
              ELSE.
                wa_att-clock_in = '080000'.
                wa_att-clock_out = '120000'.
                wa_att-hours_worked = 4.
              ENDIF.
            ENDIF.

          ELSE. "Leave is rejected
            wa_att-clock_in = '080000'.
            wa_att-clock_out = '150000'.
            wa_att-hours_worked = 8.
            wa_att-status = 'Present'.
          ENDIF.

        ENDIF.
        EXIT. "Today's record found in it_leave, hence no need to check more
      ELSE.
        "No record for today's date at current line

      ENDIF.

    ENDLOOP.
    IF wa_att-clock_in IS INITIAL AND  wa_att-clock_out IS INITIAL. "No leave record available for today
      wa_att-clock_in = '080000'.
      wa_att-clock_out = '150000'.
      wa_att-hours_worked = 8.
      wa_att-status = 'Present'.
    ENDIF.

  ELSE.
    "Employee has No paid leave,unpaid leave, compoff entries exist
    "check , as no leave exist, then is it saturday or sunday?
    CALL FUNCTION 'DATE_TO_DAY'
      EXPORTING
        date    = sy-datum
      IMPORTING
        weekday = v_day.

    IF v_day <> 'Sunday' AND v_day <> 'Saturday'.
      wa_att-clock_in = '080000'.
      wa_att-clock_out = '150000'.
      wa_att-hours_worked = 8.
      wa_att-status = 'Present'.
    ELSE.
      wa_att-clock_in = '000000'.
      wa_att-clock_out = '000000'.
      wa_att-hours_worked = 0.
      wa_att-status = v_day.
    ENDIF.
  ENDIF.
  "Insert want allow modification of record
  INSERT INTO zemp_attendance VALUES wa_att.
ENDLOOP.
"ENDIF.
