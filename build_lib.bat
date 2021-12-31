@echo off
rem
rem   BUILD_LIB
rem
rem   Build the SYN library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_chsyn
call src_pas %srcdir% %libname%_fparse
call src_pas %srcdir% %libname%_lib
call src_pas %srcdir% %libname%_names
call src_pas %srcdir% %libname%_p
call src_pas %srcdir% %libname%_parse
call src_pas %srcdir% %libname%_stack
call src_pas %srcdir% %libname%_tree

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
call src_doc syn_file
