{   Include file used by SYN front end of SST to define the subroutines and
*   symbols referenced by the generated syntax parsing code.  The minimum
*   necessary include files are referenced so that all the symbols used in
*   SYN.INS.PAS are defined.
*
*   Syntax parsing code is intended to call the SYN_P_xxx routines in the SYN
*   library.  It also needs access to some fields of the SYN_T structure that
*   is its SYN library use state.
}
%include '(cog)lib/sys.ins.pas';
%include '(cog)lib/util.ins.pas';
%include '(cog)lib/string.ins.pas';
%include '(cog)lib/file.ins.pas';
%include '(cog)lib/fline.ins.pas';
%include '(cog)lib/syn.ins.pas';
