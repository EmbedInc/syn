{   Program CALC
*
*   Example program for using the Embed syntaxer.  This program implements
*   rudimentary calculator functions.  While it does work, it is not intended to
*   be a useful calculator.
}
program calc;
%include 'calc.ins.pas';
define calc;                           {define common block declared in include file}

var
  stat: sys_err_t;                     {completion status}

begin
  writeln ('Program CALC, built on ', build_dtm_str);
  writeln;

  calc_prog_init;                      {initialize global program state}
  calc_cmline;                         {process the command line}
  calc_prog_start;                     {start up basic program operation}

  while not quit do begin              {loop until need to quit the program}
    calc_in_get (stat);                {show value, get user input into COLL_P^}
    sys_error_abort (stat, '', '', nil, 0);
    calc_process;                      {process the lines in COLL_P^}
    end;                               {back to get and process next input}
  end.
