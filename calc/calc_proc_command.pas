{   Process COMMAND syntax construction.
}
module calc_proc_command;
define calc_proc_command;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_PROC_COMMAND
*
*   Process the COMMAND syntax.  The next syntax tree entry is for the
*   subordinate COMMAND construction.
}
procedure calc_proc_command;           {process the COMMAND syntax}
  val_param;

var
  tag: sys_int_machine_t;              {tag indicating the command}
  tagstr: string_var8192_t;            {tagged string}
  fp: double;                          {scratch floating point value}
  v: val_t;                            {scratch calculator value}

begin
  tagstr.max := size_char(tagstr.str); {init local var string}

  if not syn_trav_next_down (syn_p^) then begin {down into COMMAND}
    err := true;
    return;
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for command ID}
  if trace then begin                  {syntax tracing debug enabled ?}
    syn_dbg_tree_ent_show (syn_p^);
    end;
  syn_trav_tag_string (syn_p^, tagstr); {get the tagged string}
  case tag of                          {which command is this ?}

1: begin                               {VALUE}
  calc_proc_value (v);                 {get the value}
  currval := v;                        {update the current value}
  end;

2: begin                               {sqrt}
  fp := calc_val_fp (currval);         {get current value in floating point}
  if fp >= 0.0
    then begin                         {valid to take square root of}
      calc_val_set_fp (sqrt(fp), currval);
      end
    else begin                         {can't take square root}
      writeln ('Error: SQRT of negative value');
      end
    ;
  end;

3: begin                               {ln}
  end;

4: begin                               {log}
  end;

5: begin                               {log2}
  end;

6: begin                               {+}
  end;

7: begin                               {-}
  end;

8: begin                               {*}
  end;

9: begin                               {/}
  end;

10: begin                              {^}
  end;

11: begin                              {put}
  end;

12: begin
  quit := true;
  end;

otherwise
    writeln ('INTERNAL ERROR: Unexpected COMMAND tag ', tag);
    err := true;
    end;                               {end of command tag cases}

  discard( syn_trav_up (syn_p^) );     {back up from COMMAND syntax}
  end;
