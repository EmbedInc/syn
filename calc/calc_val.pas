{   Manipulating calculator values.
}
module calc_val;
define calc_val_set_fp;
define calc_val_default;
define calc_val_fp;
define calc_val_make_fp;
define calc_val_show;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_VAL_SET_FP (FP, V)
*
*   Set the calculator value descriptor V to the floating point value FP.
}
procedure calc_val_set_fp (            {set calc value to floating point}
  in      fp: double;                  {the floating point value to set it to}
  out     v: val_t);                   {resulting calculator value descriptor}
  val_param;

begin
  v.valtype := valtype_fp_k;
  v.fp := fp;
  end;
{
********************************************************************************
*
*   Subroutine CALC_VAL_DEFAULT (V)
*
*   Set the calculator value V to the global default.
}
procedure calc_val_default (           {set a calculator value to global default}
  out     v: val_t);                   {value to set to default}
  val_param;

begin
  calc_val_set_fp (0.0, v);            {set to floating point 0}
  end;
{
********************************************************************************
*
*   Function CALC_VAL_FP (V)
*
*   Return the calculator value V in floating point.
}
function calc_val_fp (                 {get floating point value}
  in      v: val_t)                    {to get floating point value of}
  :double;
  val_param;

begin
  case v.valtype of                    {what type is it now ?}
valtype_int_k: begin                   {integer}
      calc_val_fp := v.int;
      end;
valtype_fp_k: begin                    {floating point}
      calc_val_fp := v.fp;
      end;
otherwise
    writeln ('INTERNAL ERROR: Unexpected value type ', ord(v.valtype), ' in CALC_VAL_FP');
    err := true;
    calc_val_fp := 0.0;                {return arbitrary value}
    end;                               {end of existing value type cases}
  end;
{
********************************************************************************
*
*   Subroutine CALC_VAL_MAKE_FP (V)
*
*   Convert the value V to floating point, if it is not already.
}
procedure calc_val_make_fp (           {make value floating point, if not already}
  in out  v: val_t);                   {value to make floating point}
  val_param;

begin
  v.fp := calc_val_fp (v);             {get the floating point value}
  v.valtype := valtype_fp_k;           {indicate not in FP format}
  end;
{
********************************************************************************
*
*   Subroutine CALC_VAL_SHOW (V)
*
*   Show the calculator value V on STDOUT.
}
procedure calc_val_show (              {show a calculator value}
  in      v: val_t);                   {the value to show}
  val_param;

begin
  case v.valtype of                    {what type of value is it ?}
valtype_int_k: begin
      writeln (v.int);
      end;
otherwise
    writeln (calc_val_fp(v));          {show the floating point value}
    end;
  end;
