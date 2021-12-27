@echo off
rem
rem   Define the variables for running builds from this source library.
rem
set srcdir=syn
set buildname=
call treename_var "(cog)source/syn" sourcedir
set libname=syn
set fwname=
call treename_var "(cog)src/%srcdir%/debug_%fwname%.bat" tnam
make_debug "%tnam%"
call "%tnam%"
