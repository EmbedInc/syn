{   Routines intended for debugging and development with the SYN library.
}
module syn_dbg;
define syn_dbg_tree_internal;
define syn_dbg_tree_show_n;
define syn_dbg_tree_show;
define syn_dbg_tree_ent_show;
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
*   Indent the start of a new line according to the nesting level.  Level 0
*   starts in column 1.  Each level lower is indented an additional 2 spaces.
*   This routine writes blanks to STDOUT according to the nesting level.  The
*   line is not ended.
}
procedure indent (                     {indent new line according to nesting level}
  in      level: sys_int_machine_t);   {0-N level below top}
  val_param; internal;

var
  ii: sys_int_machine_t;               {loop counter}

begin
  if level <= 0 then return;           {don't indent at all ?}
  write ('  ');                        {indent the first level}
  for ii := 2 to level do begin        {once for each remaining level}
    write ('. ');
    end;
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
*   Subroutine SYN_DBG_TREE_INTERNAL (SYN)
*
*   Show the current syntax tree on standard output.  The low 16 bits of
*   addresses are shown in hexadecimal to help correlate the output with data
*   visible in the debugger.
}
procedure syn_dbg_tree_internal (      {show syntax tree, internal details}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  show_level (syn.sytree_p, 0);        {show top level and everything below it}
  end;
{
********************************************************************************
*
*   Subroutine SYN_DBG_TREE_SHOW_N (SYN, NENT)
*
*   Show the syntax tree with user-level information from the current position.
}
procedure syn_dbg_tree_show_n (        {show syntax tree, user-level details}
  in out  syn: syn_t;                  {SYN library use state}
  out     nent: sys_int_machine_t);    {number of syntax tree entries found}
  val_param;

var
  tabort: boolean;                     {abort processing syntax tree}
{
****************************************
*
*   Internal subroutine SHOW_LEVEL
*   This routine is internal to SYN_DBG_TREE_SHOW.
*
*   Traverse and show the current syntax tree level.  The current syntax tree
*   position should be at the start of the level to show.
}
procedure show_level;
  val_param; internal;

var
  level: sys_int_machine_t;            {nesting level, 0 at top}
  name: string_var32_t;                {name of this syntax level}
  tent: syn_tent_k_t;                  {syntax tree entry type}
  tagid: sys_int_machine_t;            {ID of current tag}
  cpos: fline_cpos_t;                  {scratch input string character position}
  tagstr: string_var80_t;              {tagged string}

label
  loop_ent;

begin
  name.max := size_char(name.str);     {init local var strings}
  tagstr.max := size_char(tagstr.str);

  level := syn_trav_level (syn);       {get nesting level here}
  syn_trav_level_name (syn, name);     {get the name of this level}

  if level = 0
    then begin
      writeln ('level 0');
      end
    else begin
      writeln (name.str:name.len, ', level ', level);
      end
    ;

loop_ent:                              {back here to get each new entry}
  if tabort then return;               {tree traversal already aborted ?}
  tent := syn_trav_next (syn);         {to next entry, get its type ID}
  if tent <> syn_tent_end_k then begin
    nent := nent + 1;                  {count one more syntax tree entry}
    end;
  case tent of                         {what type of entry is this ?}
syn_tent_err_k: begin                  {error end of syntax tree}
      indent (level);
      writeln ('Error end');
      tabort := true;                  {abort tree traversal}
      return;
      end;
syn_tent_end_k: begin                  {normal end of this level}
      indent (level);
      if level <= 0 then begin
        writeln ('End of syntax tree');
        return;
        end;
      writeln ('End of level');
      if not syn_trav_up (syn) then begin {failed to pop to parent level ?}
        indent (level);
        writeln ('Failure on popping to parent level');
        tabort := true;
        end;
      return;
      end;
syn_tent_sub_k: begin                  {subordinate level}
      indent (level);
      if not syn_trav_down (syn) then begin {failed to go down to sub level ?}
        indent (level);
        writeln ('Failed to enter sub level');
        tabort := true;
        return;
        end;
      nent := nent + 1;                {count one more syntax tree entry}
      show_level;                      {show the subordinate level}
      end;
syn_tent_tag_k: begin                  {tagged source string}
      tagid := syn_trav_tag (syn);     {get tag ID}
      syn_trav_tag_start (syn, cpos);  {get tagged string start position}
      syn_trav_tag_string (syn, tagstr); {get tagged string}
      indent (level);
      write ('Tag ', tagid, ', ');
      if cpos.line_p = nil
        then begin
          writeln ('EOD');
          end
        else begin
          writeln ('line ', cpos.line_p^.lnum, ' col ', cpos.ind,
            ' "', tagstr.str:tagstr.len, '"');
          end
        ;
      end;
otherwise
    indent (level);
    writeln ('Unexpected entry with type ID ', ord(tent));
    end;
  goto loop_ent;
  end;
{
****************************************
*
*   Start of SYN_DBG_TREE_SHOW
}
begin
  syn_trav_push (syn);                 {save original position on stack}

  nent := 1;                           {init number of syntax tree entries found}
  tabort := false;                     {init to not abort syntax tree processing}
  show_level;                          {show this level and everything below it}

  syn_trav_pop (syn);                  {restore original syntax tree position}
  end;
{
********************************************************************************
*
*   Subroutine SYN_DBG_TREE_SHOW (SYN)
*
*   Show the syntax tree with user-level information from the current position.
}
procedure syn_dbg_tree_show (          {show syntax tree, user-level details}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

var
  nent: sys_int_machine_t;             {number of syntax tree entries found}

begin
  syn_dbg_tree_show_n (syn, nent);
  end;
{
********************************************************************************
*
*   Subroutine SYN_DBG_TREE_ENT_SHOW (SYN)
*
*   Show the current syntax tree entry.
}
procedure syn_dbg_tree_ent_show (      {show current syntax tree entry}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

var
  level: sys_int_machine_t;            {levels down from top}
  entype: syn_tent_k_t;                {syntax tree entry type ID}
  name: string_var32_t;                {name of current level}
  tag: sys_int_machine_t;              {entry tag number}
  tagstr: string_var132_t;             {tagged string}

begin
  name.max := size_char(name.str);     {init local var strings}
  tagstr.max := size_char(tagstr.str);

  level := syn_trav_level (syn);       {get number of levels down from top}
  entype := syn_trav_type (syn);       {get type of this tree entry}
  syn_trav_level_name (syn, name);     {get name of this syntax construction}

  indent (level);                      {show nesting level with indentation}
  write (name.str:name.len, ': ');     {show syntax construction name}

  case entype of                       {what kind of syntax tree entry is this ?}
syn_tent_lev_k: begin
      write ('start');
      end;
syn_tent_sub_k: begin
      write ('sub level');
      end;
syn_tent_tag_k: begin
      tag := syn_trav_tag (syn);       {get the tag number}
      syn_trav_tag_string (syn, tagstr); {get the tagged string}
      write ('tag ', tag, ' "', tagstr.str:tagstr.len, '"');
      end;
syn_tent_end_k: begin
      write ('end');
      end;
syn_tent_err_k: begin
      write ('error end');
      end;
otherwise
    write ('unexpected entry type ID ', ord(entype));
    end;
  writeln;
  end;
