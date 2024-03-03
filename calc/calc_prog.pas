{   Global program management.
}
module calc_prog;
define calc_prog_init;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_PROG_INIT
*
*   Initialize the global program state.
}
procedure calc_prog_init;              {initialize global program state}
  val_param;

begin
  fline_p := nil;
  coll_p := nil;
  syn_p := nil;
  end;
