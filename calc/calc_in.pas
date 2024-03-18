{   Handle calculator command input from the user.
}
module calc_in;
define calc_in_get;
%include 'calc.ins.pas';

const
  prompt = ': '(0);                    {prompt to user for entering new line}
{
********************************************************************************
*
*   Subroutine CALC_IN_GET (STAT)
*
*   Get the next input line or lines from the user.  COLL_P will be set up to
*   point to the collection of input lines.
*
*   This version only returns a single line.
}
procedure calc_in_get (                {get new input lines, COLL_P will pnt to result}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  promptv: string_var4_t;              {var string prompt}
  line: string_var8192_t;              {input line entered by user}

label
  loop;

begin
  promptv.max := size_char(promptv.str); {init local var strings}
  line.max := size_char(line.str);
  string_vstring (promptv, prompt, -1); {make var string prompt}
  sys_error_none (stat);               {init to no error}

loop:
  calc_val_show (currval);             {show the current value to the user}
  string_prompt (promptv);             {prompt user to enter new line}
  string_readin (line);                {get the line entered by the user}
  string_unpad (line);                 {strip trailing blanks from input line}
  if line.len <= 0 then goto loop;     {nothing entered, try again ?}

  if fline_p <> nil then begin         {we have FLINE library open ?}
    fline_lib_end (fline_p);           {end this use of the FLINE library}
    coll_p := nil;                     {current collection no longer exists}
    end;
  fline_lib_new (mem_p^, fline_p, stat); {create a new use of the FLINE library}
  if sys_error(stat) then return;

  fline_coll_new_lmem (                {create new collection of lines}
    fline_p^, string_v('in'(0)), coll_p);
  fline_line_add_end (fline_p^, coll_p^, line); {add user line to collection}
  end;
