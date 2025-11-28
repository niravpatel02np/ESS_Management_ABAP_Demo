*&---------------------------------------------------------------------*
*& Demo version of Payroll Insert Program
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&---------------------------------------------------------------------*
REPORT zinsert_payroll_demo.

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

" Demo: fetch all employee IDs (harmless query example)
SELECT empid FROM zemp_official INTO TABLE it_empid.
WRITE: / 'Number of employees fetched (demo):', lines( it_empid ).

" Demo: biweekly period calculation
lv_bi_end = sy-datum - 1.
lv_bi_start = lv_bi_end - 13.

LOOP AT it_empid INTO wa_empid.

  CLEAR: lv_annual_sal, lv_bi_base, lv_unpaid, lv_absent, lv_compoff.

  " Demo: fetch annual salary (example kept to show SELECT)
  " Database interaction removed for demo
  " SELECT SINGLE salary FROM zemp_official INTO lv_annual_sal WHERE empid = wa_empid-empid.
  lv_annual_sal = 52000. " Example demo value

  " Biweekly Base salary
  lv_bi_base = lv_annual_sal / 26.
  WRITE: / 'Biweekly base salary (demo):', lv_bi_base.

  " Demo: unpaid leaves fetch removed
  lv_unpaid = 0.

  " Demo: absent count calculation removed
  lv_absent = 1.

  " Demo: compoff fetch removed
  lv_compoff = 0.

  " Determine Federal Tax (demo conditional logic)
  IF lv_annual_sal BETWEEN 48475 AND 103350.
    wa_pay-federal_tax = '22'.
  ELSEIF lv_annual_sal BETWEEN 103350 AND 197300.
    wa_pay-federal_tax = '24'.
  ELSE.
    wa_pay-federal_tax = '20'.
  ENDIF.

  " Demo: state tax determination logic
  lv_state = 'MICHIGAN'. " Demo value
  IF lv_state = 'MICHIGAN'.
    wa_pay-state_tax  = '4.25'.
  ELSEIF lv_state = 'TEXAS'.
    wa_pay-state_tax = '0'.
  ELSEIF lv_state = 'NEVADA'.
    wa_pay-state_tax = '0'.
  ELSEIF lv_state = 'CALIFORNIA'.
    wa_pay-state_tax = '13.30'.
  ELSEIF lv_state = 'NEW YORK'.
    wa_pay-state_tax = '10.90'.
  ELSE.
    wa_pay-state_tax = '5'.
  ENDIF.

  " Demo: fill payroll record
  wa_pay-pay_start = lv_bi_start.
  wa_pay-pay_end   = lv_bi_end.
  wa_pay-empid     = wa_empid-empid.
  wa_pay-annual_salary = lv_annual_sal.
  wa_pay-bi_base_salary = lv_bi_base.
  wa_pay-unpaid_count   = lv_unpaid.
  wa_pay-absent_count   = lv_absent.
  wa_pay-compoff_count  = lv_compoff.
  wa_pay-ssn_tax        = '6.2'.
  wa_pay-medicare_tax   = '1.45'.

  " Demo: append to table or insert removed
  " APPEND wa_pay TO it_pay.
  " INSERT zemp_payroll FROM wa_pay.
  WRITE: / 'Payroll record prepared (demo) for employee:', wa_pay-empid.

ENDLOOP.

" Demo: leave score updates removed for safety
" UPDATE zleave_score SET unpaid_leave = ' '.
" UPDATE zleave_score SET compoff = ' '.
WRITE: / 'Leave score updates skipped (demo).'.
