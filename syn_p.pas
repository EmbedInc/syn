{   Routines used by syntax parsing code.  Such syntax parsing code is usually
*   generated automatically from a syntax definition file.  However, parsing
*   routines can also be created manually.
*
*   All the routines here are named SYN_P_xxx.  These are the only syn routines
*   that should be called from parsing code.
}
module syn_p;
define syn_p_charcase;
define syn_p_constr_start;
define syn_p_constr_end;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_P_CHARCASE (SYN, CCASE)
*
*   Set the character case interpretation to CCASE.  This applies to the rest of
*   this sytax level, and is the default for lower levels.
}
procedure syn_p_charcase (             {set charcase handling, restored at constr end}
  in out  syn: syn_t;                  {SYN library use state}
  in      ccase: syn_charcase_k_t);    {the new input stream character case handling}
  val_param;

begin
  end;
