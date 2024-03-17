{   Process calculator command input from the user.
}
module calc_process;
define calc_process;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_PROCESS
*
*   Process calculator command input and update the calculator state
*   accordingly.  The input to process is in the collection of lines pointed to
*   by COLL_P.
}
procedure calc_process;                {process input lines pointed to by COLL_P}
  val_param;

begin
  syn_parse_pos_coll (syn_p^, coll_p^); {init parse position to start of collection}
  err := false;                        {init to no error processing this collection}

  while true do begin                  {back here each input line}
    if syn_parse_end (syn_p^) then exit; {at end of input data ?}

    if not syn_parse_next (            {parse input line, check for syntax error}
        syn_p^, addr(syn_ch_oneline) )
        then begin                     {encountered syntax error}
      syn_parse_err_show (syn_p^);     {show the syntax error location}
      err := true;                     {indicate aborting on error}
      exit;
      end;

    syn_trav_init (syn_p^);            {init for traversing the syntax tree}
    calc_proc_oneline;                 {process one line}
    if err then exit;                  {encountered error, abort ?}
    end;
  end;
