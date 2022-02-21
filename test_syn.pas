{   Program TEST_SYN [fnam]
*
*   Test program for the SYN library.  The input file is read as a syntax
*   definition file.  The syntax tree resulting from parsing it is shown.
}
program test_syn;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'fline.ins.pas';
%include 'syn.ins.pas';
%include 'builddate.ins.pas';

const
  max_msg_args = 2;                    {max arguments we can pass to a message}

var
  fnam_in:                             {input file name}
    %include '(cog)lib/string_treename.ins.pas';
  iname_set: boolean;                  {TRUE if the input file name already set}
  fline_p: fline_p_t;                  {to FLINE library use state}
  coll_p: fline_coll_p_t;              {the input file lines in FLINE collection}
  syn_p: syn_p_t;                      {so SYN library use state}
  cpos: fline_cpos_t;                  {character position within input lines}
  line_p: string_var_p_t;              {pointer to source line}
  tabort: boolean;                     {abort processing syntax tree}
  nent: sys_int_machine_t;             {number of syntax tree entries found}

  opt:                                 {upcased command line option}
    %include '(cog)lib/string_treename.ins.pas';
  parm:                                {command line option parameter}
    %include '(cog)lib/string_treename.ins.pas';
  pick: sys_int_machine_t;             {number of token picked from list}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status code}

label
  next_opt, err_parm, parm_bad, done_opts;

function syn_ch_toplev (               {declare the top level syntax parsing routine}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {syntax matched}
  val_param; extern;
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
*   Local subroutine SHOW_LEVEL
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

  level := syn_trav_level (syn_p^);    {get nesting level here}
  syn_trav_level_name (syn_p^, name);  {get the name of this level}

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
  tent := syn_trav_next (syn_p^);      {to next entry, get its type ID}
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
      if not syn_trav_up (syn_p^) then begin {failed to pop to parent level ?}
        indent (level);
        writeln ('Failure on popping to parent level');
        tabort := true;
        end;
      return;
      end;
syn_tent_sub_k: begin                  {subordinate level}
      indent (level);
      if not syn_trav_down (syn_p^) then begin {failed to go down to sub level ?}
        indent (level);
        writeln ('Failed to enter sub level');
        tabort := true;
        return;
        end;
      nent := nent + 1;                {count one more syntax tree entry}
      show_level;                      {show the subordinate level}
      end;
syn_tent_tag_k: begin                  {tagged source string}
      tagid := syn_trav_tag (syn_p^);  {get tag ID}
      syn_trav_tag_start (syn_p^, cpos); {get tagged string start position}
      syn_trav_tag_string (syn_p^, tagstr); {get tagged string}
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
********************************************************************************
*
*   Start of main routine.
}
begin
  writeln ('Program TEST_SYN, built on ', build_dtm_str);
  writeln;
{
*   Initialize before reading the command line.
}
  string_cmline_init;                  {init for reading the command line}
  iname_set := false;                  {no input file name specified}
{
*   Back here each new command line option.
}
next_opt:
  string_cmline_token (opt, stat);     {get next command line option name}
  if string_eos(stat) then goto done_opts; {exhausted command line ?}
  sys_error_abort (stat, 'string', 'cmline_opt_err', nil, 0);
  if (opt.len >= 1) and (opt.str[1] <> '-') then begin {implicit pathname token ?}
    if not iname_set then begin        {input file name not set yet ?}
      string_copy (opt, fnam_in);      {set the input file name}
      iname_set := true;               {input file name is now set}
      goto next_opt;
      end;
    sys_msg_parm_vstr (msg_parm[1], opt);
    sys_message_bomb ('string', 'cmline_opt_conflict', msg_parm, 1);
    end;
  string_upcase (opt);                 {make upper case for matching list}
  string_tkpick80 (opt,                {pick command line option name from list}
    '',
    pick);                             {number of keyword picked from list}
  case pick of                         {do routine for specific option}
{
*   Unrecognized command line option.
}
otherwise
    string_cmline_opt_bad;             {unrecognized command line option}
    end;                               {end of command line option case statement}

err_parm:                              {jump here on error with parameter}
  string_cmline_parm_check (stat, opt); {check for bad command line option parameter}
  goto next_opt;                       {back for next command line option}

parm_bad:                              {jump here on got illegal parameter}
  string_cmline_reuse;                 {re-read last command line token next time}
  string_cmline_token (parm, stat);    {re-read the token for the bad parameter}
  sys_msg_parm_vstr (msg_parm[1], parm);
  sys_msg_parm_vstr (msg_parm[2], opt);
  sys_message_bomb ('string', 'cmline_parm_bad', msg_parm, 2);

done_opts:                             {done with all the command line options}

  if not iname_set then begin
    string_vstring (fnam_in, 't.syn'(0), -1); {get default input file name}
    end;
{
*   Read the input file into a FLINE collection.
}
  writeln ('Reading the input file into in-memory collection of lines.');

  fline_lib_new (                      {open the FLINE library}
    util_top_mem_context,              {parent memory context}
    fline_p,                           {returned pointer to new library use state}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  fline_file_get_suff (                {read the input file into a collection}
    fline_p^,                          {FLINE library use state}
    fnam_in, '.syn',                   {file name and mandatory suffix}
    coll_p,                            {returned pointer to the collection}
    stat);
  sys_error_abort (stat, '', '', nil, 0);
{
*   Parse the input file to build the syntax tree.
}
  writeln ('Parsing, building the syntax tree.');

  syn_lib_new (                        {open the SYN library}
    util_top_mem_context,              {parent memory context}
    syn_p);                            {returned pointer to new library use state}

  if syn_parse_coll (                  {parse the collection of input file lines}
      syn_p^,                          {SYN library use state}
      coll_p^,                         {collection of lines to parse}
      addr(syn_ch_toplev))             {pointer to top level syntax to parse}
    then begin                         {no error}
      writeln ('No syntax error');
      end
    else begin                         {syntax error found}
      syn_parse_err_pos (syn_p^, cpos); {get position of error character}
      if cpos.line_p = nil
        then begin                     {at end of collection}
          writeln ('Syntax error at end of data.');
          end
        else begin                     {at a specific line}
          writeln ('Syntax error on line ', cpos.line_p^.lnum, ' at char ', cpos.ind, ':');
          if (cpos.line_p <> nil) and then (cpos.line_p^.str_p <> nil) then begin
            line_p := cpos.line_p^.str_p;
            writeln (line_p^.str:line_p^.len);
            if cpos.ind <= 0 then begin
              writeln ('Error before start of line.');
              end;
            if cpos.ind = 1 then begin
              writeln ('^');
              end;
            if cpos.ind >= 2 then begin
              writeln (' ':(cpos.ind-1), '^');
              end;
            end;
          end
        ;
      syn_parse_err_reparse (syn_p^);  {re-parse up to error position}
      end;
    ;
  writeln;
{
*   Show the resulting syntax tree.
}
  writeln ('Traversing the syntax tree.');

  syn_trav_init (syn_p^);              {init for traversing the syntax tree}
  tabort := false;                     {init to not abort syntax tree processing}
  nent := 1;                           {init number of syntax tree entries}
  show_level;                          {show the current syntax tree level}

  writeln;
  string_f_fp_eng (                    {make amount of memory used string}
    parm,                              {output string}
    nent * sizeof(syn_tent_t),         {bytes used by syntax tree entries}
    3,                                 {required significant digits}
    opt);                              {returned units factor of 1000 prefix}
  writeln (nent, ' syntax tree entries found, ',
    parm.str:parm.len, ' ', opt.str:opt.len, 'bytes');
{
*   Clean up and leave.
}
  syn_lib_end (syn_p);                 {end this use of the SYN library}
  fline_lib_end (fline_p);             {end this use of the FLINE library}
  end.
