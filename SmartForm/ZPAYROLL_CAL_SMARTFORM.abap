*&---------------------------------------------------------------------*
*& Report  ZPAYROLL_CAL_SMARTFORM
*&
*&---------------------------------------------------------------------*
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*& The report is executed whenever employee want to see their payslip.
*& This Report is actually Driver program for the smartform.
*&---------------------------------------------------------------------*
REPORT zpayroll_cal_smartform.

TABLES: zemp_official, zemp_personal, zleave_score, zemp_attendance, zemp_payroll, zpay_per  .

DATA: v_empid TYPE zemp_official-empid.

  " Code removed here

DATA: fm_name TYPE rs38l_fnam.


TYPES: BEGIN OF ty_period,
         period TYPE zpay_per-period,
       END OF ty_period.

  " Code removed here

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS: p_period TYPE zpay_period-pay_period OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_period.

  SELECT * FROM zpay_per  INTO CORRESPONDING FIELDS OF TABLE it_period.

  wa_map-fldname = 'F0001'. "Field for Position 1
  wa_map-dyfldname = 'P_PERIOD'.
  APPEND wa_map TO it_map.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      "DDIC_STRUCTURE         = 'ZPAY_PERIOD'
      retfield        = 'PAY_PERIOD'
*     PVALKEY         = ' '
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'P_PERIOD'
*     STEPL           = 0
*     WINDOW_TITLE    =
*     VALUE           = ' '
      value_org       = 'S'
    " multiple_choice = 'X'
*     DISPLAY         = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM   = ' '
*     CALLBACK_METHOD =
*     MARK_TAB        =
*   IMPORTING
*     USER_RESET      =
    TABLES
      value_tab       = it_period
*     FIELD_TAB       =
*     RETURN_TAB      =
      dynpfld_mapping = it_map
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


START-OF-SELECTION.
***Generating Data for Smartform
  IMPORT v_empid  FROM MEMORY ID 'ID3'.
  "v_empid = '111111'.

***ID, Designation & Practice Unit
  " Code removed here
***Name
  " Code removed here


***Extracting Biweekly Pay period start and end date
  " Code removed here

  "end date
  " Code removed here

  lv_bi_end = v_date.

  lv_pay_date = lv_bi_end + 1. "need to pass

  SELECT SINGLE * FROM zemp_payroll INTO wa_pay WHERE empid = v_empid AND pay_start = lv_bi_start AND pay_end = lv_bi_end .
  IF wa_pay IS INITIAL.
    MESSAGE 'No payslip is available for this pay period.' TYPE 'E'.
  ENDIF.
*Annual Salary
  lv_annual_sal  = wa_pay-annual_salary.  "need to pass
*Biweekly Base salary
  lv_bi_base = wa_pay-bi_base_salary. "need to pass


  "Daily rate
  " Code removed here


  "Additional pay for compoff overwork
  lv_addition = wa_pay-compoff_count * lv_daily_rate.  "need to pass

*Total Gross Pay
  lv_gross  = lv_bi_base + lv_addition.

  "Deduction
*Unpaid leaves
  v_unpaid =  wa_pay-unpaid_count.
  lv_unpaid_ded = wa_pay-unpaid_count * lv_daily_rate. "need to pass

*Absent
  v_absent = wa_pay-absent_count.
  lv_absent_ded = wa_pay-absent_count * lv_daily_rate. "need to pass

*TAXES
*Federal Tax
  " Code removed here

*Net pay
  lv_net = lv_gross - lv_ded.

  CLEAR: wa_smartform.

  " Code removed here


END-OF-SELECTION.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZEMP_SALARYSLIP'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  "Every time you change the smartform , you need to recall FM
  CALL FUNCTION fm_name
    EXPORTING
*     ARCHIVE_INDEX    =
*     ARCHIVE_INDEX_TAB          =
*     ARCHIVE_PARAMETERS         =
*     CONTROL_PARAMETERS         =
*     MAIL_APPL_OBJ    =
*     MAIL_RECIPIENT   =
*     MAIL_SENDER      =
*     OUTPUT_OPTIONS   =
*     USER_SETTINGS    = 'X'
      wa_smartform     = wa_smartform
      v_unpaid         = v_unpaid
      v_absent         = v_absent
*   IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO  =
*     JOB_OUTPUT_OPTIONS         =
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
