{   Routines intended for debugging and development with the SYN library.
}
module syn_dbg;
define syn_dbg_tree;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Local subroutine SHOW_ADR (ADR)
*
*   Write the low 16 bits of the address in hexadecimal to standard output.
}
procedure show_adr (                   {show low 16 bits of address on STDOUT}
  in      adr: univ_ptr);              {address to show}
  val_param; internal;

var
  tk: string_var4_t;                   {HEX string}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_int16h (                    {make HEX string}
    tk,                                {output string}
    sys_int_adr_t(adr) & 16#FFFF);     {input integer}
  write (tk.str:tk.len);
  end;
{
********************************************************************************
*
*   Local subroutine INDENT (LEVEL)
*
*   Indent from the start of the line appropriate for the indicated nesting
*   level.
}
procedure indent (                     {indent for a specific nesting level}
  in      level: sys_int_machine_t);   {0-N nesting level}
  val_param; internal;

begin
  if level <= 0 then return;           {at top level, no indentation ?}

  write (' ':(level * 2));             {indent according to the level}
  end;
{
********************************************************************************
*
*   Local subroutine SHOW_TENT (ENT_P, LEVEL)
*
*   Show the contents of the syntax tree entry pointed to by ENT_P.  LEVEL is
*   the number of levels this entry is nested below the top level.
}
procedure show_tent (                  {show one syntax tree entry contents}
  in      ent_p: syn_tent_p_t;         {pointer to the entry to show}
  in      level: sys_int_machine_t);   {number of levels below root level}
  val_param; internal;

begin
  if ent_p = nil then return;          {nothing to show ?}

  indent (level);                      {indent according to nesting level}
  show_adr (ent_p);                    {show address of descriptor}
  write (' back ');                    {show BACK pointer}
  show_adr (ent_p^.back_p);
  write (' next ');                    {show NEXT pointer}
  show_adr (ent_p^.next_p);
  write (' lev ');                     {show level start pointer}
  show_adr (ent_p^.levst_p);

  write (', ');
  case ent_p^.ttype of                 {what type of entry is this ?}
syn_ttype_lev_k: begin                 {start of subordinate level}
      write ('level ', ent_p^.level, ' up ');
      show_adr (ent_p^.lev_up_p);
      if ent_p^.lev_name_p <> nil then begin
        write (' "', ent_p^.lev_name_p^.str:ent_p^.lev_name_p^.len, '"');
        end;
      end;
syn_ttype_sub_k: begin                 {link to subordinate level}
      write ('sub ');
      show_adr (ent_p^.sub_p);
      end;
syn_ttype_tag_k: begin                 {tagged item}
      write ('tag ', ent_p^.tag);
      end;
syn_ttype_err_k: begin                 {error end of syntax tree}
      write ('error end');
      end;
otherwise                              {unexpected tree entry type}
    write ('type ', ord(ent_p^.ttype));
    end;

  writeln;                             {end this line}
  end;
{
********************************************************************************
*
*   Local subroutine SHOW_LEVEL (ENT_P, LEVEL)
*
*   Show the syntax tree level starting with the entry pointed to by ENT_P.
*   LEVEL is the number of levels down from the top.  The root level is 0.
}
procedure show_level (                 {show syntax tree level}
  in      ent_p: syn_tent_p_t;         {pointer to first entry to show}
  in      level: sys_int_machine_t);   {0-N nesting level}
  val_param; internal;

var
  e_p: syn_tent_p_t;                   {pointer to current entry}

begin
  e_p := ent_p;                        {init current entry to show}
  while e_p <> nil do begin            {loop over entries in this level}
    show_tent (e_p, level);            {show this entry}
    case e_p^.ttype of                 {check entries that require special handling}
syn_ttype_sub_k: begin                 {this entry links to subordinate level ?}
        show_level (e_p^.sub_p, level+1); {show the subordinate level}
        end;
      end;                             {end of special handling entry types}
    e_p := e_p^.next_p;                {to next entry in this level}
    end;                               {back to show this new entry}
  end;
{
********************************************************************************
*
*   Subroutine SYN_DBG_TREE (SYN)
*
*   Show the current syntax tree on standard output.  The low 16 bits of
*   addresses are shown in hexadecimal to help correlate the output with data
*   visible in the debugger.
}
procedure syn_dbg_tree (               {show syntax tree on STDOUT, for debugging}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  show_level (syn.sytree_p, 0);        {show top level and everything below it}
  end;
