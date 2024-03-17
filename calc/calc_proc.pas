{   Process syntax constructions.
}
module calc_proc;
define calc_proc_oneline;
define calc_proc_expression;
define calc_proc_value;
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
    if syn_trav_next_down (syn_p^)
      then begin                       {got into subordinate COMMAND level}
        calc_proc_command;             {process the COMMAND syntax}
        discard( syn_trav_up (syn_p^) ); {back up from COMMAND syntax}
        if err then exit;              {abort on error}
        end
      else begin                       {no new subordinate level}
        exit;
        end
      ;
    end;                               {back to do next command in expression}
  discard( syn_trav_up (syn_p^) );     {back up from EXPRESSION syntax}

leave:
  v := currval;                        {pass back result of expression}
  currval := valsave;                  {restore current value to before expression}
  end;
{
********************************************************************************
*
*   Subroutine CALC_PROC_VALUE (V)
*
*   Process the VALUE syntax.  The next syntax tree entry is for the subordinate
*   VALUE construction.  V is returned the value.
}
procedure calc_proc_value (            {process VALUE syntax, return the value}
  out     v: val_t);                   {the resulting value}
  val_param;

var
  tag: sys_int_machine_t;              {value type tag}
  tagstr: string_var80_t;              {tagged string}

begin
  tagstr.max := size_char(tagstr.str); {init local var string}
  calc_val_default (v);                {init returned value to default}

  if not syn_trav_next_down (syn_p^) then begin {down into VALUE}
    err := true;
    return;
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for the type of this value}
  if trace then begin                  {syntax tracing debug enabled ?}
    syn_dbg_tree_ent_show (syn_p^);
    end;

  case tag of                          {which type of value is this ?}

1:  begin                              {NUMBER}
      end;

2:  begin                              {SYMBOL}
      end;

3:  begin                              {nested expression}
      end;

4:  begin                              {pi}
      calc_val_set_fp (3.141592653589793, v);
      end;

5:  begin                              {e}
      end;

otherwise
    syn_msg_tag_err (syn_p^, '', '', nil, 0);
    writeln;
    err := true;
    end;

  discard( syn_trav_up (syn_p^) );     {back up from ONELINE syntax}
  end;
