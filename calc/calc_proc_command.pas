{   Process COMMAND syntax construction.
}
module calc_proc_command;
define calc_proc_command;
%include 'calc.ins.pas';
%include 'math.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_PROC_COMMAND
*
*   Process the COMMAND syntax.  The current syntax tree entry is the start of
*   the COMMAND tree level.
}
procedure calc_proc_command;           {process the COMMAND syntax}
  val_param;

var
  tag: sys_int_machine_t;              {tag indicating the command}
  tagstr: string_var8192_t;            {tagged string}
  fp: double;                          {scratch floating point value}
  v: val_t;                            {scratch calculator value}
  dat_p: symdat_p_t;                   {pointer to symbol data}

label
  error;

begin
  tagstr.max := size_char(tagstr.str); {init local var string}

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
  if fp < 0.0 then begin               {invalid value ?}
    writeln ('Error: SQRT of negative value');
    goto error;
    end;
  calc_val_set_fp (sqrt(fp), currval);
  end;

3: begin                               {ln}
  fp := calc_val_fp (currval);         {get current value in floating point}
  if fp < 0.0 then begin               {invalid value ?}
    writeln ('Error: LOG of negative value');
    goto error;
    end;
  calc_val_set_fp (ln(fp), currval);
  end;

4: begin                               {log}
  fp := calc_val_fp (currval);         {get current value in floating point}
  if fp < 0.0 then begin               {invalid value ?}
    writeln ('Error: LOG of negative value');
    goto error;
    end;
  calc_val_set_fp (math_log10(fp), currval);
  end;

5: begin                               {log2}
  fp := calc_val_fp (currval);         {get current value in floating point}
  if fp < 0.0 then begin               {invalid value ?}
    writeln ('Error: LOG of negative value');
    goto error;
    end;
  calc_val_set_fp (math_log2(fp), currval);
  end;

6: begin                               {+}
  calc_proc_value (v);                 {get the value after the operator}
  if
      (currval.valtype = valtype_int_k) and
      (v.valtype = valtype_int_k)
    then begin                         {both values are integer}
      calc_val_set_int (currval.int + v.int, currval);
      end
    else begin                         {at least one value is floating point}
      calc_val_set_fp (                {set current value to floating point}
        calc_val_fp(currval) + calc_val_fp(v), {value to set to}
        currval);                      {value descriptor to set}
      end
    ;
  end;

7: begin                               {-}
  calc_proc_value (v);                 {get the value after the operator}
  if
      (currval.valtype = valtype_int_k) and
      (v.valtype = valtype_int_k)
    then begin                         {both values are integer}
      calc_val_set_int (currval.int - v.int, currval);
      end
    else begin                         {at least one value is floating point}
      calc_val_set_fp (                {set current value to floating point}
        calc_val_fp(currval) - calc_val_fp(v), {value to set to}
        currval);                      {value descriptor to set}
      end
    ;
  end;

8: begin                               {*}
  calc_proc_value (v);                 {get the value after the operator}
  if
      (currval.valtype = valtype_int_k) and
      (v.valtype = valtype_int_k)
    then begin                         {both values are integer}
      calc_val_set_int (currval.int * v.int, currval);
      end
    else begin                         {at least one value is floating point}
      calc_val_set_fp (                {set current value to floating point}
        calc_val_fp(currval) * calc_val_fp(v), {value to set to}
        currval);                      {value descriptor to set}
      end
    ;
  end;

9: begin                               {/}
  calc_proc_value (v);                 {get the value after the operator}
  calc_val_set_fp (                    {set current value to floating point}
    calc_val_fp(currval) / calc_val_fp(v), {value to set to}
    currval);                          {value descriptor to set}
  end;

10: begin                              {^}
  calc_proc_value (v);                 {get the value after the operator}
  fp := calc_val_fp (currval);         {get current value in floating point}
  if v.valtype <> valtype_int_k then begin {not raising to integer power}
    if fp < 0.0 then begin
      writeln ('Error: Negative value to non-integer power');
      goto error;
      end;
    end;
  calc_val_set_fp (                    {set current value to floating point}
    calc_val_fp(currval) ** calc_val_fp(v), {value to set to}
    currval);                          {value descriptor to set}
  end;

11: begin                              {set}
  syn_trav_tag_string (syn_p^, tagstr); {get the variable name}
  if calc_sym_err (tagstr) then goto error; {invalid symbol name ?}
  calc_sym_find_var (tagstr, dat_p);   {get pointer to data for this var}
  if dat_p^.symtype <> symtype_var_k then begin
    writeln ('Symbol "', tagstr.str:tagstr.len, '" is not a variable.');
    goto error;
    end;
  dat_p^.var_val := currval;           {assign the current value to the variable}
  end;

12: begin
  quit := true;
  end;

otherwise
    writeln ('INTERNAL ERROR: Unexpected COMMAND tag ', tag);
error:
    writeln;
    err := true;
    end;                               {end of command tag cases}
  end;
