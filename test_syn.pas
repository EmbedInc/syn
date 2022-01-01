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
    string_vstring (fnam_in, 'syn.syn'(0), -1); {get default input file name}
    end;
{
*   Read the input file into a FLINE collection.
}
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
      writeln ('Syntax error on line ', cpos.line_p^.lnum, ' at char ', cpos.ind);
      syn_parse_err_reparse (syn_p^);  {re-parse up to error position}
      end;
    ;
  writeln;
{
*   Show the resulting syntax tree.
}

{
*   Clean up and leave.
}
  syn_lib_end (syn_p);                 {end this use of the SYN library}
  fline_lib_end (fline_p);             {end this use of the FLINE library}
  end.
