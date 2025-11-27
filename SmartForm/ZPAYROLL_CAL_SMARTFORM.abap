*&---------------------------------------------------------------------*
*& Report  ZPAYROLL_CAL_SMARTFORM
*&
*&---------------------------------------------------------------------*
*& The report is executed whenever employee want to see their payslip.
*& This Report is actually Driver program for the smartform.
*&---------------------------------------------------------------------*
REPORT zpayroll_cal_smartform.

TABLES: zemp_official, zemp_personal, zleave_score, zemp_attendance, zemp_payroll, zpay_per  .

DATA: v_empid TYPE zemp_official-empid.

DATA: it_off TYPE STANDARD TABLE OF   zemp_official,
      wa_off LIKE LINE OF it_off.

DATA: it_per TYPE STANDARD TABLE OF   zemp_personal,
      wa_per LIKE LINE OF it_per.

DATA: it_pay TYPE STANDARD TABLE OF zemp_payroll,
      wa_pay LIKE LINE OF it_pay.

DATA: it_map TYPE STANDARD TABLE OF dselc,
      wa_map TYPE dselc.

DATA: fm_name TYPE rs38l_fnam.


TYPES: BEGIN OF ty_period,
         period TYPE zpay_per-period,
       END OF ty_period.

TYPES: BEGIN OF ty_smartform,
         empid       TYPE zemp_official-empid,
         name        TYPE c LENGTH 60,
         designation TYPE zemp_official-designation,
         department  TYPE zemp_official-practice_unit,
         pay_start   TYPE sy-datum,
         pay_end     TYPE sy-datum,
         pay_date    TYPE sy-datum,
         annual_sal  TYPE zemp_official-salary,
         base_sal    TYPE zemp_official-salary,
         compff      TYPE zemp_official-salary,
         gross       TYPE zemp_official-salary,
         unpaid_ded  TYPE zemp_official-salary,
         absent_dad  TYPE zemp_official-salary,
         federal     TYPE zemp_official-salary,
         state       TYPE zemp_official-salary,
         ssn         TYPE zemp_official-salary,
         medicare    TYPE zemp_official-salary,
         tax         TYPE zemp_official-salary,
         total_ded   TYPE zemp_official-salary,
         net_sal     TYPE zemp_official-salary,
       END OF ty_smartform.

DATA: it_period TYPE STANDARD TABLE OF ty_period.

DATA: wa_smartform TYPE ty_smartform.

DATA: lv_annual_sal TYPE zemp_official-salary,
      lv_bi_base    TYPE zemp_official-salary,
      lv_daily_rate TYPE zemp_official-salary, "usd/day
      lv_compoff    TYPE zleave_score-compoff,
      lv_unpaid     TYPE zleave_score-unpaid_leave,
      lv_addition   TYPE zemp_official-salary,
      lv_unpaid_ded TYPE zemp_official-salary,
      lv_absent_ded TYPE zemp_official-salary,
      lv_gross      TYPE zemp_official-salary,
      lv_bi_start   TYPE sy-datum,
      lv_bi_end     TYPE sy-datum,
      lv_pay_date   TYPE sy-datum,
      lv_federal    TYPE  zemp_official-salary,
      lv_state      TYPE  zemp_official-salary,
      lv_ssn        TYPE  zemp_official-salary,
      lv_med        TYPE  zemp_official-salary,
      lv_tax        TYPE  zemp_official-salary,
      lv_ded        TYPE  zemp_official-salary,
      lv_net        TYPE  zemp_official-salary,
      v_day         TYPE c LENGTH 2,
      v_month       TYPE c LENGTH 2,
      v_year        TYPE c LENGTH 4,
      v_date        TYPE c LENGTH 8,
      v_name        TYPE string,
      v_unpaid      TYPE zemp_payroll-unpaid_count,
      v_absent      TYPE zemp_payroll-absent_count.



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
  CLEAR: wa_off.   "need to pass
  SELECT SINGLE * FROM zemp_official INTO wa_off WHERE empid = v_empid.

***Name
  CLEAR: wa_per.
  SELECT SINGLE * FROM zemp_personal INTO wa_per WHERE empid = v_empid.
  CONCATENATE wa_per-firstname wa_per-middlename wa_per-lastname INTO v_name SEPARATED BY space.


***Extracting Biweekly Pay period start and end date
  "start date
  CLEAR: v_day, v_month, v_year,v_date.
  v_day = p_period+0(2).
  v_month = p_period+2(2).
  v_year = p_period+4(4).
  CONCATENATE v_year v_month  v_day INTO v_date .

  lv_bi_start = v_date.

  "end date
  CLEAR: v_day, v_month, v_year,v_date.
  v_day = p_period+9(2).
  v_month = p_period+11(2).
  v_year = p_period+13(4).
  CONCATENATE v_year v_month  v_day INTO v_date .

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
  lv_daily_rate = lv_annual_sal / 260.
*260 days is based on a typical full-time work year, excluding weekends and holidays
*52 weeks in a year
*5 working days per week (Monday through Friday).
*52 weeks × 5 days = 260 working days.


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
  lv_federal = ( lv_gross * wa_pay-federal_tax ) / 100.

*State Tax
  lv_state = ( lv_gross * wa_pay-state_tax ) / 100.

*SSN Tax
  lv_ssn = ( lv_gross * wa_pay-ssn_tax ) / 100.

*Medicare Tax
  lv_med = ( lv_gross * wa_pay-medicare_tax ) / 100.

*Total Taxes
  lv_tax = lv_federal + lv_state + lv_ssn + lv_med.

*Total deductions
  lv_ded = lv_unpaid_ded + lv_absent_ded + lv_tax.

*Net pay
  lv_net = lv_gross - lv_ded.

  CLEAR: wa_smartform.

  wa_smartform-empid = v_empid.
  wa_smartform-name       = v_name.
  wa_smartform-designation = wa_off-designation.
  wa_smartform-department  = wa_off-practice_unit.
  wa_smartform-pay_start   = lv_bi_start.
  wa_smartform-pay_end    = lv_bi_end.
  wa_smartform-pay_date    = lv_pay_date.
  wa_smartform-annual_sal  = lv_annual_sal.
  wa_smartform-base_sal   = lv_bi_base.
  wa_smartform-compff      = lv_addition.
  wa_smartform-gross      = lv_gross.
  wa_smartform-unpaid_ded = lv_unpaid_ded.
  wa_smartform-absent_dad  = lv_absent_ded.
  wa_smartform-federal     = lv_federal.
  wa_smartform-state      = lv_state.
  wa_smartform-ssn         = lv_ssn.
  wa_smartform-medicare    = lv_med.
  wa_smartform-tax = lv_tax.
  wa_smartform-total_ded   = lv_ded.
  wa_smartform-net_sal     = lv_net.


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
