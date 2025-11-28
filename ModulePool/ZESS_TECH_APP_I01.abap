*&---------------------------------------------------------------------*
*& Include           ZESS_TECH_APP_I01 (Demo)
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'CANCEL'.
      CLEAR: in_loginid, in_password.
  ENDCASE.
ENDMODULE.

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

MODULE validate_credentials INPUT.
  CASE ok_code.
    WHEN 'CANCEL'.
      CLEAR: in_loginid, in_password.
  ENDCASE.

  CLEAR: wa_emp.

  " Code removed here

  IF in_loginid IS INITIAL.
    " Code removed here
  ENDIF.

  IF in_password IS INITIAL.
   " Code removed here
  ENDIF.

  CASE ok_code.
    WHEN 'LOGIN'.
      " Code removed here
  ENDCASE.
ENDMODULE.

MODULE user_command_0300 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      " Code removed: PERFORM update_information
    WHEN 'CANCEL'.
      " Code removed: PERFORM clear_fields
  ENDCASE.
ENDMODULE.

FORM update_information .
  " Code removed: MODIFY zemp_personal
ENDFORM.

FORM clear_fields .
  " Code removed
ENDFORM.

MODULE user_command_0400 INPUT.
  CASE ok_code.
    WHEN 'SUBMIT'.
      " Code removed
      WRITE: / 'Submit leave request demo'.
  ENDCASE.
ENDMODULE.

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
      " Code removed here
    WHEN 'ATTEND'.
      " Code removed here
    WHEN 'PAY'.
     " Code removed here
    WHEN 'SFPDF'.
     " Code removed here
    WHEN 'LOGOUT'.
      LEAVE PROGRAM.
    WHEN 'LAPP'.
    " Code removed here
    WHEN 'TATTEN'.
    " Code removed here
  ENDCASE.
ENDMODULE.

MODULE leave_0400 INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.

MODULE validate_0400 INPUT.
  CASE ok_code.
    WHEN 'CANCEL'.
      CLEAR: wa_leave-begin_date, wa_leave-end_date, wa_leave-day_type,
             wa_leave-leave_type, wa_leave-approver, wa_leave-reason.
    WHEN 'SUBMIT'.
      " Code removed: full leave validation & DB checks
      WRITE: / 'Leave validation demo'.
  ENDCASE.
ENDMODULE.

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
      " Do nothing
  ENDCASE.
ENDMODULE.

MODULE user_command_0450 INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'APPROVE'.
      LOOP AT it_leave_man INTO wa_leave_man WHERE mark = 'X'.
        " Code removed: DB updates, balance checks, MODIFY zleave_histo/zleave_score
        WRITE: / |Approve leave demo for ID { wa_leave_man-leaveid }|.
      ENDLOOP.
    WHEN 'REJECT'.
      LOOP AT it_leave_man INTO wa_leave_man WHERE mark = 'X'.
        " Code removed: DB updates, MODIFY zleave_histo
        WRITE: / |Reject leave demo for ID { wa_leave_man-leaveid }|.
      ENDLOOP.
  ENDCASE.
ENDMODULE.

MODULE tc1_leave_modify INPUT.
  " Code removed: MODIFY it_leave_man
ENDMODULE.

MODULE tc1_leave_mark INPUT.
  " Code removed: table control mark/demark logic
ENDMODULE.

MODULE tc1_leave_user_command INPUT.
  PERFORM user_ok_tc USING 'TC1_LEAVE' 'IT_LEAVE_MAN' 'MARK' CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
