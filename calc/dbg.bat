@echo off
rem
rem   DBG prog [arg ... arg]
rem
rem   Build the program in debug mode, then debug it.  The optional arguments
rem   are passed to the program when run in the debugger.
rem
rem   This version is different from the generic DBG script in that it also
rem   links the result of CALC.SYN to the program being built.
rem
setlocal
set debug=vs
set debugging=true
call build_pasinit
call src_progl "%~1" -link calc_syn.obj
call extpath_var msvc/debugger.exe tnam
server "%tnam%" /DebugExe %1.exe %2 %3 %4 %5 %6 %7 %8 %9
