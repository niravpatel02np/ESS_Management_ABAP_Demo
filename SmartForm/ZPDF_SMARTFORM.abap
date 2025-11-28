*&---------------------------------------------------------------------*
*& Report  ZPDF_SMARTFORM
*&
*&---------------------------------------------------------------------*
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&
*&---------------------------------------------------------------------*
REPORT zpdf_smartform.

  " Code removed here

CONSTANTS : c_defaultpath(100) TYPE c VALUE 'C:\'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS: p_period TYPE zpay_period-pay_period OBLIGATORY.
PARAMETERS : pa_file LIKE rlgrap-filename DEFAULT c_defaultpath.

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_period.
  SELECT * FROM zpay_per  INTO CORRESPONDING FIELDS OF TABLE it_period.

  wa_map-fldname = 'F0001'. "Field for Position 1
  wa_map-dyfldname = 'P_PERIOD'.
  APPEND wa_map TO it_map.

  " Code removed here


AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.

  PERFORM u_selectfolder USING pa_file.


START-OF-SELECTION.
  PERFORM uf_getreportdata.
  PERFORM uf_getsmartformmodulename.
  PERFORM uf_runsmartform.
  PERFORM uf_converttootf.
  PERFORM uf_downloadtoclient.


FORM u_selectfolder USING p_pa_file.

  DATA :
    lv_subrc  LIKE sy-subrc,
    lt_it_tab TYPE filetable.

   " Code removed here
ENDFORM. " U_SELECTFOLDER

FORM uf_downloadtoclient .

    " Code removed here

ENDFORM. " UF_DOWNLOADTOCLIENT

FORM uf_getreportdata .

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
  " Code removed here

  lv_bi_start = v_date.

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
  " Code removed here

  CLEAR: wa_smartform.

  " Code removed here


ENDFORM. " UF_GETREPORTDATA

FORM uf_getsmartformmodulename .

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

ENDFORM. " UF_GETSMARTFORMMODULENAME

FORM uf_runsmartform .

  " Code removed here

  "Every time you change the smartform , you need to recall FM
  CALL FUNCTION fm_name
    EXPORTING
*     ARCHIVE_INDEX      =
*     ARCHIVE_INDEX_TAB  =
*     ARCHIVE_PARAMETERS =
      control_parameters = gs_control_params
*     MAIL_APPL_OBJ      =
*     MAIL_RECIPIENT     =
*     MAIL_SENDER        =
      output_options     = gs_output_options
      user_settings      = ' '
      wa_smartform       = wa_smartform
      v_unpaid           = v_unpaid
      v_absent           = v_absent
    IMPORTING
      "document_output_info =
      job_output_info    = t_otfdata
      "job_output_options   =
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM. " UF_RUNSMARTFORM

FORM uf_converttootf .

  t_otf[] = t_otfdata-otfdata[].

  " Code removed here

ENDFORM. " UF_CONVERTTOOTF
