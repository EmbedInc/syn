@echo off
rem
rem   Set up for building a Pascal module.
rem
call build_vars

call src_getbase
call src_getfrom math math.ins.pas
call src_getfrom stuff stuff.ins.pas
call src_getfrom fline fline.ins.pas
call src_getfrom syn syn.ins.pas

make_debug debug_switches.ins.pas

call src_builddate "%srcdir%"

if exist calc_syn.obj del calc_syn.obj
call src_syn calc
rename calc.obj calc_syn.obj
