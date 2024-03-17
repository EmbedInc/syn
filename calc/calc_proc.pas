{   Process syntax constructions.
}
module calc_proc;
define calc_proc_oneline;
define calc_proc_expression;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_PROC_ONELINE
*
*   Process the ONELINE syntax.  The next syntax tree entry is for the
*   subordinate ONELINE construction.
}
procedure calc_proc_oneline;           {process the ONELINE syntax}
  val_param;

var
  expval: val_t;                       {nexted expression value}

begin
  if not syn_trav_next_down (syn_p^) then begin {down into ONELINE}
    err := true;
    return;
    end;
  if trace then begin                  {syntax tracing debug enabled ?}
    syn_dbg_tree_ent_show (syn_p^);
    end;

  calc_proc_expression (expval);       {process EXPRESSION, get value}
  if not err then begin                {no error, expression value is valid ?}
    currval := expval;                 {update the current calculator value}
    end;

  discard( syn_trav_up (syn_p^) );     {back up from ONELINE syntax}
  end;
{
********************************************************************************
*
*   Subroutine CALC_PROC_EXPRESSION (V)
*
*   Process the EXPRESSION syntax.  The next syntax tree entry is for the
*   subordinate EXPRESSION construction.  V is returned the value of the
*   expression.
}
procedure calc_proc_expression (       {process the EXPRESSION syntax, return the value}
  out     v: val_t);                   {the resulting value}
  val_param;

var
  valsave: val_t;                      {saved value before expression}

label
  leave;

begin
  valsave := currval;                  {save current value before expr is run}

  if not syn_trav_next_down (syn_p^) then begin {down into EXPRESSION}
    err := true;
    goto leave;
    end;

  while true do begin                  {loop over the commands in this expression}
    if trace then begin                {syntax tracing debug enabled ?}
      syn_dbg_tree_ent_show (syn_p^);
      end;
    if syn_trav_type(syn_p^) = syn_tent_end_k then exit; {end of EXPRESSION ?}
    calc_proc_command;                 {process the next command}
    if err then exit;                  {abort on error}
    end;
  discard( syn_trav_up (syn_p^) );     {back up from EXPRESSION syntax}

leave:
  v := currval;                        {pass back result of expression}
  currval := valsave;                  {restore current value to before expression}
  end;
