*&---------------------------------------------------------------------*
*&  Include           ZESS_TECH_APP_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
*Cancel functionality is implemented here, as if it is written in AT EXIT COMMAND,
*the screen values wil not be passed to declared variables
    WHEN 'CANCEL'.
      CLEAR: in_loginid, in_password.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LEAVE_0100  INPUT
*&---------------------------------------------------------------------*
*       text: AT EXIT-COMMAND, will allow all the function keys with
*             Type 'E' to skip field validations
*----------------------------------------------------------------------*
MODULE leave_0100 INPUT.
  CASE ok_code.
    WHEN 'EXIT' OR 'BACK'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      CLEAR: in_loginid, in_password.
    WHEN OTHERS.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_CREDENTIALS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_credentials INPUT.

  CASE ok_code.
    WHEN 'CANCEL'.
      CLEAR: in_loginid, in_password.
  ENDCASE.

  CLEAR: wa_emp.
  IF in_loginid IS NOT INITIAL.
    SELECT SINGLE * FROM zemp_credes INTO wa_emp WHERE loginid = in_loginid.
    IF wa_emp IS INITIAL.
      MESSAGE 'Login ID does not exist' TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Please Enter Login ID' TYPE 'E'.
  ENDIF.

  CASE ok_code.
    WHEN 'CANCEL'.
      CLEAR: in_loginid, in_password.
  ENDCASE.

  IF in_password IS INITIAL.
    MESSAGE 'Please Enter Password.' TYPE 'E'.
  ENDIF.

  CASE ok_code.
    WHEN 'LOGIN'.
      CLEAR: wa_emp.
      SELECT SINGLE * FROM zemp_credes INTO wa_emp WHERE loginid = in_loginid AND password = in_password.
      IF wa_emp IS INITIAL.
        MESSAGE 'Password is Incorrect' TYPE 'E'.
      ELSE.
        MESSAGE 'Login Successful' TYPE 'I'.
        CALL SCREEN 0200.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE ok_code.
*    WHEN 'EXIT'.
*      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      PERFORM update_information.
    WHEN 'CANCEL'.
      PERFORM clear_fields.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_INFORMATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_information .
  MODIFY zemp_personal FROM wa_per.
  IF sy-subrc = 0.
    MESSAGE 'Your Information is updated successfully!' TYPE 'I'.
  ELSE.
    MESSAGE 'Failed to update Information' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CLEAR_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_fields .

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR      = ' '
*     DIAGNOSE_OBJECT             = ' '
      text_question = 'This action will erase all unsaved changes. Are you sure you want to clear all fields?'
      text_button_1 = 'Yes'
*     ICON_BUTTON_1 = ' '
      text_button_2 = 'No'
*     ICON_BUTTON_2 = ' '
    IMPORTING
      answer        = lv_answer.

  IF lv_answer = '1'.
    CLEAR: wa_per-prefer_name, wa_per-pronouns, wa_per-gender_expression, wa_per-marital_status, wa_per-religion,
                wa_per-country_code, wa_per-contact_number, wa_per-email_id, wa_per-emergency_name, wa_per-emergency_code,
                wa_per-emergency_contact, wa_per-current_house, wa_per-current_city, wa_per-current_pincode.
    IF sy-subrc = 0.
      MESSAGE 'All fields are cleared!' TYPE 'I'. " Yes action
    ENDIF.
  ELSE.
    MESSAGE 'Action cancelled.' TYPE 'I'. " No action
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  CASE ok_code.
    WHEN 'SUBMIT'.

      CLEAR: lv_leaveid, lv_no_days.
      SELECT MAX( leaveid ) FROM zleave_histo INTO lv_leaveid.

      lv_leaveid = lv_leaveid + 1.
      wa_leave-leaveid = lv_leaveid.
      wa_leave-empid = wa_emp-empid.
      wa_leave-applydate = sy-datum.
      wa_leave-applytime = sy-uzeit.
      wa_leave-begin_date =  wa_leave-begin_date .
      "wa_leave-no_of_days = ( wa_leave-end_date - wa_leave-begin_date ) + 1.
      lv_no_days = ( wa_leave-end_date - wa_leave-begin_date ) + 1.

      IF wa_leave-day_type = 'Half Day'.
        lv_no_days = lv_no_days / 2.
      ENDIF.
      wa_leave-no_of_days = lv_no_days.
      wa_leave-status = 'Pending'.

      FIELD-SYMBOLS: <fs_balance> TYPE zleave_score-leave_balance.

      " Determine the field name dynamically based on the leave type
      CASE wa_leave-leave_type.
        WHEN 'S'. "Sick Leave
          lv_fieldname = 'SICK_LEAVE'.
        WHEN 'B'.
          lv_fieldname = 'BEREAVEMENT_LEAVE'.
        WHEN 'V'. "Vacation Leave
          lv_fieldname = 'VACATION_LEAVE'.
        WHEN 'E'.
          lv_fieldname = 'EARNED_LEAVE'.
        WHEN 'P'. "Paternity Leave
          lv_fieldname = 'PATERNITY_LEAVE'.
        WHEN 'M'. "Maternity Leave
          lv_fieldname = 'MATERNITY_LEAVE'.
      ENDCASE.

      " Fetch the corresponding field dynamically
      SELECT SINGLE * FROM zleave_score INTO wa_bal
             WHERE empid = wa_emp-empid.

      ASSIGN COMPONENT lv_fieldname OF STRUCTURE wa_bal TO <fs_balance>.
      IF sy-subrc = 0.
        lv_bal = <fs_balance>.
        IF lv_bal < wa_leave-no_of_days.
          MESSAGE 'You do not have enough leave balance for the selected type' TYPE 'E'.
        ENDIF.
      ENDIF.

      SELECT SINGLE leave_balance FROM zleave_score INTO lv_balance WHERE empid = wa_emp-empid.
      wa_leave-leave_balance = lv_balance.

      INSERT INTO zleave_histo VALUES wa_leave.
      IF sy-subrc = 0.
        MESSAGE 'Your leave request has been successfully submitted.' TYPE 'I'.
      ENDIF.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'LAPPLY'.
      CALL SCREEN 0400.
    WHEN 'ME'.
      CALL SCREEN 0310.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'LAPPROVE'.
      CALL SCREEN 0450.
    WHEN 'LHISTORY'.
      CLEAR: v_empid.
      v_empid =  wa_emp-empid .
      EXPORT v_empid TO MEMORY ID 'ID1'.
      SUBMIT zleave_history_report AND RETURN VIA SELECTION-SCREEN.
    WHEN 'ATTEND'.
      CLEAR: v_empid.
      v_empid =  wa_emp-empid .
      EXPORT v_empid TO MEMORY ID 'ID2'.
      SUBMIT zattendance_report AND RETURN VIA SELECTION-SCREEN.
    WHEN 'PAY'.
      CLEAR: v_empid.
      v_empid =  wa_emp-empid .
      EXPORT v_empid TO MEMORY ID 'ID3'.
      SUBMIT zpayroll_cal_smartform AND RETURN VIA SELECTION-SCREEN.
    WHEN 'SFPDF'.
      CLEAR: v_empid.
      v_empid =  wa_emp-empid .
      EXPORT v_empid TO MEMORY ID 'ID4'.
      SUBMIT zpdf_smartform AND RETURN VIA SELECTION-SCREEN.
    WHEN 'LOGOUT'.
      LEAVE PROGRAM.
    WHEN 'LAPP'.
      CLEAR: v_id, wa_off.
      SELECT SINGLE * FROM zemp_official INTO wa_off WHERE empid = wa_emp-empid.
      v_id =  wa_off-email_id .
      EXPORT v_id TO MEMORY ID 'ID5'.
      SUBMIT zleave_applications_manager AND RETURN VIA SELECTION-SCREEN.
    WHEN 'TATTEN'.
      CLEAR: v_empid.
      v_empid =  wa_emp-empid .
      EXPORT v_empid TO MEMORY ID 'ID6'.
      SUBMIT zattendance_report_manager AND RETURN VIA SELECTION-SCREEN.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LEAVE_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE leave_0400 INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_0400 INPUT.

  CASE ok_code.

    WHEN 'CANCEL'.
      CLEAR: wa_leave-begin_date, wa_leave-end_date, wa_leave-day_type,
             wa_leave-leave_type,wa_leave-approver, wa_leave-reason.

    WHEN 'SUBMIT'.
      CLEAR: lv_contains_weekend.
      IF wa_leave-begin_date IS INITIAL OR wa_leave-end_date IS INITIAL OR wa_leave-day_type IS INITIAL OR
         wa_leave-leave_type IS INITIAL OR wa_leave-approver IS INITIAL .
        MESSAGE 'Fill in all required entry fields' TYPE 'E'.
      ENDIF.

      IF wa_leave-begin_date < sy-datum .
        IF wa_leave-leave_type <> 'C'.
          MESSAGE 'Leave start date cannot be in the past' TYPE 'E'.
        ENDIF.
      ELSE.
        IF wa_leave-leave_type = 'C'.
          MESSAGE 'Compoff date cannot be in the future' TYPE 'E'.
        ENDIF.
      ENDIF.

      IF wa_leave-end_date < sy-datum .
        IF wa_leave-leave_type <> 'C'.
          MESSAGE 'Leave end date cannot be in the past' TYPE 'E'.
        ENDIF.
      ELSE.
        IF wa_leave-leave_type = 'C'.
          MESSAGE 'Compoff date cannot be in the future' TYPE 'E'.
        ENDIF.
      ENDIF.

      CLEAR: it_leave.
      SELECT  * FROM zleave_histo INTO TABLE it_leave WHERE empid = wa_emp-empid.

      LOOP AT it_leave ASSIGNING FIELD-SYMBOL(<fs_leave>).
        IF  ( wa_leave-begin_date >= <fs_leave>-begin_date AND wa_leave-begin_date <= <fs_leave>-end_date )
          OR ( wa_leave-end_date >= <fs_leave>-begin_date AND wa_leave-end_date <= <fs_leave>-end_date ).
          MESSAGE 'It seems your selected time range conflicts with an existing leave application. Please adjust the dates and try again.' TYPE 'E'.
        ENDIF.
      ENDLOOP.

      " Loop through the date range
      CLEAR: lv_date, lv_day.
      lv_date = wa_leave-begin_date.
      WHILE lv_date <= wa_leave-end_date.

        CALL FUNCTION 'DATE_TO_DAY'
          EXPORTING
            date    = lv_date
          IMPORTING
            weekday = lv_day.

        " Check if the day is Saturday  or Sunday
        IF lv_day = 'Saturday' OR lv_day = 'Sunday'.
          IF wa_leave-leave_type <> 'C'. "Compoff
            lv_contains_weekend = abap_true.
            EXIT. " No need to check further, exit the loop
          ENDIF.
        ENDIF.

        " Increment the date
        lv_date = lv_date + 1.
      ENDWHILE.

      " Message based on the result
      IF lv_contains_weekend = abap_true.
        MESSAGE 'Date range contains a weekend' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.

************************************************************************************************************
*Tabstrip Wizard generated code
************************************************************************************************************
*&SPWIZARD: INPUT MODULE FOR TS 'ZTAB_EMP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
MODULE ztab_emp_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_ztab_emp-tab1.
      g_ztab_emp-pressed_tab = c_ztab_emp-tab1.
    WHEN c_ztab_emp-tab2.
      g_ztab_emp-pressed_tab = c_ztab_emp-tab2.
    WHEN c_ztab_emp-tab3.
      g_ztab_emp-pressed_tab = c_ztab_emp-tab3.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0450 INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'APPROVE'.
      LOOP AT it_leave_man INTO wa_leave_man WHERE mark = 'X'.

        "MOVE-CORRESPONDING wa_leave_man TO wa_leave_app.

        IF  wa_leave_man-status <> 'Approved' AND wa_leave_man-status <> 'Rejected' .

***Checking if while approving employee has sufficient leave balance
          FIELD-SYMBOLS: <fs_balance1> TYPE zleave_score-leave_balance.

          CLEAR: lv_fieldname.
          " Determine the field name dynamically based on the leave type
          CASE wa_leave_man-leave_type.
            WHEN 'Sick Leave'.
              lv_fieldname = 'SICK_LEAVE'.
            WHEN 'Bereavement Leave'.
              lv_fieldname = 'BEREAVEMENT_LEAVE'.
            WHEN 'Vacation Leave'.
              lv_fieldname = 'VACATION_LEAVE'.
            WHEN 'Earned Leave'.
              lv_fieldname = 'EARNED_LEAVE'.
            WHEN 'Paternity Leave'.
              lv_fieldname = 'PATERNITY_LEAVE'.
            WHEN 'Maternity Leave'.
              lv_fieldname = 'MATERNITY_LEAVE'.
          ENDCASE.

          CLEAR: wa_bal.
          " Fetch the corresponding field dynamically
          SELECT SINGLE * FROM zleave_score INTO wa_bal
                 WHERE empid = wa_leave_man-empid.

          CLEAR: lv_bal.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE wa_bal TO <fs_balance1>.
          IF sy-subrc = 0.
            lv_bal = <fs_balance1>.
            IF lv_bal < wa_leave_man-no_of_days.
              MESSAGE 'Employee has not enough leave balance for the applied leave type' TYPE 'E'.
            ENDIF.
          ENDIF.

*** Modifying Table Control
          wa_leave_man-status = 'Approved'.
          lv_upd_bal = wa_leave_man-leave_balance  - wa_leave_man-no_of_days.
          wa_leave_man-leave_balance = lv_upd_bal.
          wa_leave_man-approved_on = sy-datum.
          "wa_leave_man-zcomment
          MODIFY it_leave_man FROM wa_leave_man.

*** Updating DDIC Table
          wa_leave_man-approved_on = sy-datum.
          wa_leave_man-leave_balance = lv_upd_bal.
          wa_leave_man-approved_on = sy-datum.
          MODIFY zleave_histo FROM wa_leave_man.

          SELECT SINGLE * FROM zleave_score INTO wa_score WHERE empid = wa_leave_man-empid.


          " Determine the field name dynamically based on the leave type
          CASE wa_leave_man-leave_type.
            WHEN 'Sick Leave'. "Sick Leave
              lv_fieldname = 'SICK_LEAVE'.
              wa_score-sick_leave = wa_score-sick_leave - wa_leave_man-no_of_days.
            WHEN 'Bereavement Leave'.
              lv_fieldname = 'BEREAVEMENT_LEAVE'.
              wa_score-bereavement_leave = wa_score-bereavement_leave - wa_leave_man-no_of_days.
            WHEN 'Vacation Leave'. "
              lv_fieldname = 'VACATION_LEAVE'.
              wa_score-vacation_leave = wa_score-vacation_leave  - wa_leave_man-no_of_days.
            WHEN 'Earned Leave'.
              lv_fieldname = 'EARNED_LEAVE'.
              wa_score-earned_leave = wa_score-earned_leave - wa_leave_man-no_of_days.
            WHEN 'Paternity Leave'.
              lv_fieldname = 'PATERNITY_LEAVE'.
              wa_score-paternity_leave = wa_score-paternity_leave  - wa_leave_man-no_of_days.
            WHEN 'Maternity Leave'.
              lv_fieldname = 'MATERNITY_LEAVE'.
              wa_score-maternity_leave = wa_score-maternity_leave - wa_leave_man-no_of_days.
          ENDCASE.

          wa_score-leave_balance = lv_upd_bal.

          MODIFY zleave_score FROM wa_score.

          IF sy-subrc = 0.
            MESSAGE 'Selected leave applications are successfully approved!' TYPE 'I'.
          ENDIF.
        ELSE.
          MESSAGE  | Leave application { wa_leave_man-leaveid } is already processed |  TYPE 'I'.
        ENDIF.
        "same way for reject

      ENDLOOP.
    WHEN 'REJECT'.
      LOOP AT it_leave_man INTO wa_leave_man WHERE mark = 'X'.
        IF  wa_leave_man-status <> 'Approved' AND wa_leave_man-status <> 'Rejected' .
*** Modifying Table Control
          wa_leave_man-status = 'Rejected'.
          wa_leave_man-approved_on = sy-datum.
          MODIFY it_leave_man FROM wa_leave_man.

*** Updating DDIC Table
          wa_leave_man-approved_on = sy-datum.
          MODIFY zleave_histo FROM wa_leave_man.
          IF sy-subrc = 0.
            MESSAGE 'Selected leave applications are successfully rejected!' TYPE 'I'.
          ENDIF.
        ELSE.
          MESSAGE  | Leave application { wa_leave_man-leaveid } is already processed |  TYPE 'I'.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC1_LEAVE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc1_leave_modify INPUT.
  MODIFY it_leave_man
    FROM wa_leave_man
    INDEX tc1_leave-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC1_LEAVE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE tc1_leave_mark INPUT.
  DATA: g_tc1_leave_wa2 LIKE LINE OF it_leave_man.
  IF tc1_leave-line_sel_mode = 1
  AND wa_leave_man-mark = 'X'.
    LOOP AT it_leave_man INTO g_tc1_leave_wa2
      WHERE mark = 'X'.
      g_tc1_leave_wa2-mark = ''.
      MODIFY it_leave_man
        FROM g_tc1_leave_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY it_leave_man
    FROM wa_leave_man
    INDEX tc1_leave-current_line
    TRANSPORTING mark.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC1_LEAVE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc1_leave_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC1_LEAVE'
                              'IT_LEAVE_MAN'
                              'MARK'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
