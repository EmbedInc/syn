@echo off
rem
rem   BUILD_LIB
rem
rem   Build the SYN library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_get %srcdir% %libname%_%libname%.ins.pas
copya %libname%_%libname%.ins.pas (cog)lib/%libname%_%libname%.ins.pas

call src_pas %srcdir% %libname%_dbg
call src_pas %srcdir% %libname%_chsyn
call src_pas %srcdir% %libname%_fparse
call src_pas %srcdir% %libname%_lib
call src_pas %srcdir% %libname%_msg
call src_pas %srcdir% %libname%_names
call src_pas %srcdir% %libname%_p
call src_pas %srcdir% %libname%_parse
call src_pas %srcdir% %libname%_stack
call src_pas %srcdir% %libname%_trav
call src_pas %srcdir% %libname%_tree

call src_c %srcdir% syn

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
call src_doc syn_file
