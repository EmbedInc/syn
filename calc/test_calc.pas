{   Program TEST_CALC
*
*   Program to test a file against the CALC syntax, as defined by CALC.SYN.  The
*   syntax tree resulting from parsing the input file is shown.
}
program test_calc;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'fline.ins.pas';
%include 'syn.ins.pas';
%include 'builddate.ins.pas';

const
  fnam_suffix = '.calc';               {mandatory input file name suffix}
  max_msg_args = 2;                    {max arguments we can pass to a message}

function syn_ch_oneline (              {parse one top level construction}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {TRUE iff input matched expected syntax}
  val_param; extern;

var
  top_syn_p: syn_parsefunc_p_t         {pointer to top syntax to parse}
    := addr(syn_ch_oneline);

  fnam_in:                             {input file name}
    %include '(cog)lib/string_treename.ins.pas';
  iname_set: boolean;                  {TRUE if the input file name already set}
  fline_p: fline_p_t;                  {to FLINE library use state}
  coll_p: fline_coll_p_t;              {the input file lines in FLINE collection}
  syn_p: syn_p_t;                      {to SYN library use state}
  nent: sys_int_machine_t;             {number of syntax tree entries found}
  match: boolean;                      {syntax matched}

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

begin
  writeln ('Program TEST_CALC, built on ', build_dtm_str);
  writeln;
{
*   Initialize before reading the command line.
}
  string_cmline_init;                  {init for reading the command line}
  iname_set := false;                  {no input file name specified yet}
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
    '-IN',
    pick);                             {number of keyword picked from list}
  case pick of                         {do routine for specific option}
{
*   -IN fnam
*
*   FNAM is the name of the input file to read.
}
1:  begin
      if iname_set then begin          {input file name previously set ?}
        sys_msg_parm_vstr (msg_parm[1], opt);
        sys_message_bomb ('string', 'cmline_opt_conflict', msg_parm, 1);
        end;
      string_cmline_token (fnam_in, stat); {get next token as input file name}
      sys_error_abort (stat, 'string', 'cmline_opt_err', nil, 0);
      iname_set := true;               {input file name is now set}
      end;
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
    string_vstring (fnam_in, 't'(0), -1); {get default input file name}
    end;
{
*   Read the input file into memory.  COLL_P is set pointing to the resulting
*   collection of lines managed by the FLINE library.
}
  fline_lib_new (                      {open the FLINE library}
    util_top_mem_context,              {parent memory context}
    fline_p,                           {returned pointer to new library use state}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  fline_file_get_suff (                {read the input file into a collection}
    fline_p^,                          {FLINE library use state}
    fnam_in, fnam_suffix,              {file name and mandatory suffix}
    coll_p,                            {returned pointer to the collection}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  writeln ('Done reading "', coll_p^.name_p^.str:coll_p^.name_p^.len, '".');
{
*   Open the SYN library and initialize the parsing state.
}
  syn_lib_new (                        {open the SYN library}
    util_top_mem_context,              {parent memory context}
    syn_p);                            {returned pointer to new library use state}

  syn_parse_pos_coll (syn_p^, coll_p^); {set parse position to start of input}
{
*   Parse each top level syntax construction in the input file.  Show the
*   resulting syntax tree for each.
}
  while true do begin                  {back here for each new top level construction}
    writeln;
    match := syn_parse_next (          {parse from the current position}
      syn_p^,                          {SYN library use state}
      top_syn_p);                      {to top level syntax construction to parse}
    if match
      then begin                       {no syntax error}
        writeln ('No syntax error');
        end
      else begin                       {syntax error found}
        syn_parse_err_show (syn_p^);   {show the syntax error location}
        syn_parse_err_reparse (syn_p^); {re-parse up to error position}
        end
      ;
    {
    *   Show the syntax tree resulting from this top level syntax construction.
    }
    syn_trav_init (syn_p^);            {init for traversing the syntax tree}
    syn_dbg_tree_show_n (syn_p^, nent); {show tree, get number of entries}

    string_f_fp_eng (                  {make amount of memory used string}
      parm,                            {output string}
      nent * sizeof(syn_tent_t),       {bytes used by syntax tree entries}
      3,                               {required significant digits}
      opt);                            {returned units factor of 1000 prefix}
    writeln (nent, ' syntax tree entries found, ',
      parm.str:parm.len, ' ', opt.str:opt.len, 'bytes');

    if not match then exit;            {don't continue on syntax error}
    if syn_parse_end (syn_p^) then exit; {consumed all input data ?}
    end;                               {back to parse next chunk of input data}
{
*   Clean up and leave.
}
  syn_lib_end (syn_p);                 {end this use of the SYN library}
  fline_lib_end (fline_p);             {end this use of the FLINE library}
  end.
