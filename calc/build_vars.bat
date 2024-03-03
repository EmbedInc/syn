@echo off
rem
rem   Define the variables for running builds from this source library.
rem
set srcdir=syn
set buildname=calc
call treename_var "(cog)source/syn/calc" sourcedir
set libname=
set fwname=
set pictype=
set picclass=
set t_parms=
call treename_var "(cog)src/%srcdir%/debug_%fwname%.bat" tnam
make_debug "%tnam%"
call "%tnam%"
