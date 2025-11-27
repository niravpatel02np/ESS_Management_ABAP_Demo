*&---------------------------------------------------------------------*
*& Report  ZPDF_SMARTFORM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zpdf_smartform.

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

DATA :
  form_name         TYPE rs38l_fnam,
  gs_control_params TYPE ssfctrlop,
  gs_output_options TYPE ssfcompop.

DATA :
  t_otfdata          TYPE ssfcrescl,
  t_pdf_tab          LIKE tline OCCURS 0 WITH HEADER LINE, " SAPscript: Text Lines
  t_otf              TYPE itcoo OCCURS 0 WITH HEADER LINE, " OTF Structure
  w_bin_filesize(10) TYPE c.

DATA :
  gv_initialdirectory TYPE string,
  gv_filename         TYPE string,
  gv_path             TYPE string,
  gv_fullpath         TYPE string.

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

  IF pa_file IS INITIAL.
    gv_initialdirectory = 'C:\'.
  ELSE.
    gv_initialdirectory = pa_file.
  ENDIF.

  " Display File Open Dialog control/screen
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Save SmartForm as ...'
      default_extension = '.pdf'
      default_file_name = 'smartform.pdf'
      file_filter       = '.pdf'
      initial_directory = gv_initialdirectory
    CHANGING
      filename          = gv_filename
      path              = gv_path
      fullpath          = gv_fullpath.

  IF sy-subrc = 0.
    " Write path on input area
    p_pa_file = gv_fullpath.
  ENDIF.

ENDFORM. " U_SELECTFOLDER

FORM uf_downloadtoclient .

  DATA : lv_filename(128) TYPE c.

  lv_filename = gv_fullpath.

  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
      bin_filesize            = w_bin_filesize
      filename                = lv_filename
      filetype                = 'BIN'
    TABLES
      data_tab                = t_pdf_tab
    EXCEPTIONS
      file_open_error         = 1
      file_write_error        = 2
      invalid_filesize        = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      no_authority            = 10
      OTHERS                  = 11.

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

  gs_output_options-tdnoprev = 'X'.
  " gs_output_options-tdprinter = 'LP01'. "able to skip
  gs_control_params-no_dialog = 'X'.
  gs_control_params-getotf = 'X'.
  gs_control_params-preview = ' '.
  "  gs_control_params-no_open = 'X'.
  "gs_control_params-no_close = 'X'.

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

  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
      max_linewidth         = 132
    IMPORTING
      bin_filesize          = w_bin_filesize
    TABLES
      otf                   = t_otf
      lines                 = t_pdf_tab
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4.

ENDFORM. " UF_CONVERTTOOTF
