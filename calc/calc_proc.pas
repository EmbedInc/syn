{   Process syntax constructions.
}
module calc_proc;
define calc_proc_oneline;
define calc_proc_expression;
define calc_proc_value;
define calc_proc_numer;
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
  dat_p: symdat_p_t;                   {to symbol data}

label
  error, leave;

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
      calc_proc_number (v);
      end;

2:  begin                              {SYMBOL}
      syn_trav_tag_string (syn_p^, tagstr); {get the symbol name}
      if calc_sym_err (tagstr) then goto error; {invalid symbol name ?}
      calc_sym_get (tagstr, dat_p);    {loop up the symbol}
      if dat_p = nil then begin        {no such symbol ?}
        writeln ('Symbol "', tagstr.str:tagstr.len, '" does not exist.');
        goto error;
        end;
      if dat_p^.symtype <> symtype_var_k then begin
        writeln ('Symbol "', tagstr.str:tagstr.len, '" is not a variable.');
        goto error;
        end;
      v := dat_p^.var_val;             {return the variable's value}
      end;

3:  begin                              {nested expression}
      calc_proc_expression (v);
      end;

4:  begin                              {pi}
      calc_val_set_fp (3.141592653589793, v);
      end;

5:  begin                              {e}
      calc_val_set_fp (2.71828182845904523536, v);
      end;

otherwise
    syn_msg_tag_err (syn_p^, '', '', nil, 0);
error:                                 {error enountered, message already written}
    writeln;
    err := true;
    end;

leave:                                 {common exit point when in VALUE syntax}
  discard( syn_trav_up (syn_p^) );     {back up from VALUE syntax}
  end;
{
********************************************************************************
*
*   Local function DIGITVAL (C)
*
*   Return the value of the digit character C.  The digits 0-9 will be
*   interpreted normally.  The letters A-Z will be interpreted as digit values
*   10-35.  Only 0-9 and the upper case letters A-Z are supported.  The result
*   is undefined when C is any other character.
}
function digitval (                    {get digit value}
  in      c: char)                     {digit character}
  :double;                             {resulting integer digit value}
  val_param; internal;

begin
{
*   Check for regular 0-9 digit.
}
  if (ord(c) >= ord('0')) and (ord(c) <= ord('9')) then begin {0-9 digit ?}
    digitval := ord(c) - ord('0');
    return;
    end;
{
*   Assume letter A-Z.
}
  digitval := ord(c) + 10 - ord('A');
  end;
{
********************************************************************************
*
*   Subroutine CALC_PROC_NUMBER (V)
*
*   Process the NUMBER syntax.  The next syntax tree entry is for the
*   subordinate NUMBER construction.  V is returned the resulting value.
}
procedure calc_proc_number (           {process NUMBER syntax, return the number}
  out     v: val_t);                   {the resulting value}
  val_param;

var
  tag: sys_int_machine_t;              {value type tag}
  tagstr: string_var80_t;              {tagged string}
  fp: double;                          {scratch floating point}
  base: sys_int_machine_t;             {number base (radix)}
  ii: sys_int_machine_t;               {scratch integer and loop counter}
  pos: boolean;                        {positive, not negative}
  stat: sys_err_t;                     {completion status}

label
  digits, tag_bad, error, leave;

begin
  tagstr.max := size_char(tagstr.str); {init local var string}
  calc_val_default (v);                {init returned value to default}

  if not syn_trav_next_down (syn_p^) then begin {down into NUMBER}
    err := true;
    return;
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag indicating sign of remaining number}
  if trace then begin                  {syntax tracing debug enabled ?}
    syn_dbg_tree_ent_show (syn_p^);
    end;
  case tag of
1:  pos := true;                       {positive}
2:  pos := false;                      {negative}
otherwise
    goto tag_bad;
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for overall number type}
  if trace then begin                  {syntax tracing debug enabled ?}
    syn_dbg_tree_ent_show (syn_p^);
    end;
  case tag of                          {which number format is it ?}
{
*   Hexadecimal integer.
}
1: begin
  base := 16;
  goto digits;
  end;
{
*   Binary integer.
}
2: begin
  base := 2;
  goto digits;
  end;
{
*   Floating point.
}
3: begin
  syn_trav_tag_string (syn_p^, tagstr); {get the number string}
  string_upcase (tagstr);              {guarantee letters are upper case}
  string_t_fp2 (tagstr, fp, stat);     {interpret string into FP}
  if sys_error_check (stat, '', '', nil, 0) then goto error;
  if not pos then fp := -fp;           {apply sign}
  calc_val_set_fp (fp, v);             {return the value}
  end;
{
*   Decimal integer.
}
4: begin
  base := 10;
  goto digits;
  end;
{
*   Unexpected number format tag.
}
otherwise
    goto tag_bad;
    end;                               {end of overall number format cases}
  goto leave;
{
*   The tag string is a sequence of digits.  Interpret them as an integer in
*   the base BASE.
}
digits:
  syn_trav_tag_string (syn_p^, tagstr); {get the number string}
  string_upcase (tagstr);              {make all letter digits upper case}
  fp := 0.0;                           {init the accumulated number}
  for ii := 1 to tagstr.len do begin   {each digit, most to least significant order}
    fp := (fp * base) + digitval(tagstr.str[ii]); {add this digit}
    end;                               {back for next digit}
  if not pos then fp := -fp;           {apply the sign}
  calc_val_set_int (fp, v);            {return the value}
  goto leave;
{
*   An unexpected tag was encountered.
}
tag_bad:
  syn_msg_tag_err (syn_p^, '', '', nil, 0);
  writeln;

error:                                 {error, message already emitted}
  err := true;

leave:                                 {pop back to parent level and exit}
  discard( syn_trav_up (syn_p^) );     {back up from NUMBER syntax}
  end;
