*&---------------------------------------------------------------------*
*& Report  ZINSERT_PAYROLL
*&
*&---------------------------------------------------------------------*
*& The purpose of this program is to only insert data into table ZEMP_PAYROLL
*& on a biweekly basis. This program will be executed as background job on
*& first day of next biweekly pay cycle
*&---------------------------------------------------------------------*
REPORT zinsert_payroll.

TABLES: zemp_payroll, zemp_official, zleave_score.

TYPES: BEGIN OF ty_empid,
         empid TYPE zemp_official-empid,
       END OF ty_empid.

DATA: it_empid TYPE STANDARD TABLE OF ty_empid,
      wa_empid LIKE LINE OF it_empid.

DATA: it_pay TYPE STANDARD TABLE OF zemp_payroll,
      wa_pay LIKE LINE OF it_pay.

DATA: lv_annual_sal TYPE zemp_official-salary,
      lv_bi_base    TYPE zemp_official-salary,
      lv_unpaid     TYPE zleave_score-unpaid_leave,
      lv_absent     LIKE zleave_score-unpaid_leave,
      lv_compoff    TYPE zleave_score-compoff,
      lv_bi_start   TYPE sy-datum,
      lv_bi_end     TYPE sy-datum,
      lv_state      TYPE zemp_official-state.

*Fetching all Employee IDs
SELECT empid FROM zemp_official INTO TABLE it_empid.

"Will be executed on 17 Dec, next day of this cycle end
lv_bi_end = sy-datum - 1. "It will be executed in backend at next day of cycle end
lv_bi_start = lv_bi_end - 13.

LOOP AT it_empid INTO wa_empid.

  CLEAR: lv_annual_sal, lv_bi_base.
  SELECT SINGLE salary  FROM zemp_official INTO lv_annual_sal WHERE empid = wa_empid-empid.
  "Biweekly Base salary
  lv_bi_base = lv_annual_sal / 26.

  "Unpaid leaves
  SELECT SINGLE unpaid_leave FROM zleave_score INTO lv_unpaid WHERE empid = wa_empid-empid.

  "Absent count
  SELECT COUNT( * ) FROM zemp_attendance INTO lv_absent WHERE empid = wa_empid-empid AND
    zdate >= lv_bi_start AND zdate <= lv_bi_end AND status = 'Absent'.

  "Compoff Count
  SELECT SINGLE compoff  FROM zleave_score INTO lv_compoff WHERE empid = wa_empid-empid.

  "Determine Taxes

  "Federal tax
  IF lv_annual_sal BETWEEN '48475' AND '103350'.
    wa_pay-federal_tax = '22'.
  ELSEIF lv_annual_sal BETWEEN '103350' AND '197300'.
    wa_pay-federal_tax = '24'.
  ENDIF.

  "State TAX
  SELECT SINGLE state FROM zemp_official INTO lv_state WHERE empid = wa_empid-empid.
  IF lv_state = 'MICHIGAN'.
    wa_pay-state_tax  = '4.25'. "Example state tax rate for Michigan
  ELSEIF lv_state = 'TEXAS'.
    wa_pay-state_tax = '0'. "No state income tax in Texas
  ELSEIF lv_state = 'NEVADA'.
    wa_pay-state_tax = '0'. "No state income tax in Nevada
  ELSEIF lv_state = 'CALIFORNIA'.
    wa_pay-state_tax = '13.30'. "Example highest marginal tax rate for California
  ELSEIF lv_state = 'NEW YORK'.
    wa_pay-state_tax = '10.90'. "Example highest marginal tax rate for New York
  ELSE.
    wa_pay-state_tax = '5'. "Default for unknown states
  ENDIF.

  wa_pay-pay_start = lv_bi_start.
  wa_pay-pay_end = lv_bi_end.
  wa_pay-empid = wa_empid-empid.
  wa_pay-annual_salary = lv_annual_sal.
  wa_pay-bi_base_salary = lv_bi_base.
  wa_pay-unpaid_count = lv_unpaid.
  wa_pay-absent_count = lv_absent.
  wa_pay-compoff_count = lv_compoff.
  wa_pay-ssn_tax = '6.2'.
  wa_pay-medicare_tax = '1.45'.

  "APPEND wa_pay TO it_pay.
  INSERT  zemp_payroll FROM wa_pay.

ENDLOOP.

"DELETE unpaid leave for all employees
UPDATE zleave_score
SET unpaid_leave = ' '.

"DELETE compoff for all employees
UPDATE zleave_score
SET compoff = ' '.
