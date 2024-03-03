{   Program CALC
*
*   Example program for using the Embed syntaxer.  This program implements
*   rudimentary calculator functions.  While it does work, it is not intended to
*   be a useful calculator.
}
program calc;
%include 'calc.ins.pas';
define calc;                           {define common block declared in include file}

begin
  writeln ('Program CALC, built on ', build_dtm_str);
  writeln;

  calc_prog_init;                      {initialize global program state}
  calc_cmline;                         {process the command line}

  end.
