@echo off
rem
rem   BUILD_PROGS
rem
rem   Build the executable programs from this source directory.
rem
setlocal
call build_pasinit

src_progl calc -link calc_syn.obj
src_progl test_calc -link calc_syn.obj
