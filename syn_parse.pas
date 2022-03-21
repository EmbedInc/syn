{   High level routines for parsing the input stream and building the syntax
*   tree.
}
module syn_parse;
define syn_parse_pos_coll;
define syn_parse_next;
define syn_parse_coll;
define syn_parse_err_reparse;
define syn_parse_err_pos;
define syn_parse_err_show;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_PARSE_POS_COLL (SYN, COLL)
*
*   Set the parsing position to the start of the collection COLL.
}
procedure syn_parse_pos_coll (         {set parse position to start of collection}
  in out  syn: syn_t;                  {SYN library use state}
  in var  coll: fline_coll_t);         {collection to go to start of}
  val_param;

begin
  fline_cpos_coll_start (              {get start of collection position}
    syn.pos_start,                     {returned position}
    coll);                             {collection to set position to start of}
  end;
{
********************************************************************************
*
*   Function SYN_PARSE_NEXT (SYN, SYNFUNC_P)
*
*   Start a top level parse from the position in SYN.POS_START.  When there is
*   no error, this position is advanced to after where the parse completes.
*
*   The function returns TRUE if the input stream matched the syntax definition,
*   and FALSE when not.
}
function syn_parse_next (              {parse, continue from current position}
  in out  syn: syn_t;                  {SYN library use state}
  in      syfunc_p: syn_parsefunc_p_t) {top level syntax to parse against}
  :boolean;                            {no error, syntax tree built}
  val_param;

var
  match: boolean;                      {the input stream matched the syntax definition}

begin
  syn.parsefunc_p := syfunc_p;         {save pointer to top level syntax to parse}

  syn_names_init (syn);                {init syntax names symbol table to empty}
  syn_fparse_init (syn);               {init temp state stack for parsing}
  syn_tree_init (syn);                 {init syntax tree, empty, ready to add to}
  syn.parse_p^.tent_def_p := syn.sytree_p; {init tree entry for start of curr level}
  syn.parse_p^.tent_p := syn.sytree_p; {init curr tree entry to the first}

  syn.pos_err := syn.pos_start;        {init farthest character parsed to}
  syn.pos_errnext := syn.pos_start;
  syn.err := false;                    {doing normal parse, not error re-parse}
  syn.err_end := false;                {not reached err char on error re-parse}

  match := syfunc_p^ (syn);            {parse, TRUE iff input matched syntax}
  syn.err := not match;                {remember whether there was error or not}
  if match then begin                  {no syntax error ?}
    syn.pos_start := syn.parse_p^.pos; {update start position for next parse}
    end;

  syn_parse_next := match;             {returned syntax matched yes/no condition}
  end;
{
********************************************************************************
*
*   Function SYN_PARSE_COLL (SYN, COLL, SYNFUNC_P)
*
*   Reset the parsing state and clear the syntax tree, then parse the input
*   stream.  The input stream is the lines collection COLL.  SYNFUNC_P is a
*   pointer to the top level syntax to parse the input stream against.
*
*   If the input stream matches the syntax definition, then the function returns
*   TRUE.  A syntax tree will have been built.
*
*   If the input stream does not match the syntax definition, then the function
*   returns FALSE.  No syntax tree is built, but farthest character that matches
*   the syntax is determined.
}
function syn_parse_coll (              {clear stack, parse input, build syntax tree}
  in out  syn: syn_t;                  {SYN library use state}
  in var  coll: fline_coll_t;          {collection of input lines to parse}
  in      syfunc_p: syn_parsefunc_p_t) {top level syntax to parse against}
  :boolean;                            {no error, syntax tree built}
  val_param;

begin
  syn_parse_pos_coll (syn, coll);      {set parse position to start of collection}
  syn_parse_coll := syn_parse_next (syn, syfunc_p); {parse, return matched Y/N}
  end;
{
********************************************************************************
*
*   Subroutine SYN_PARSE_ERR_REPARSE (SYN)
*
*   Re-parses the input stream up to the error position.  This routine is only
*   valid after a normal parse was performed that failed.
*
*   The syntax tree is built up to when the next character to be fetched would
*   be the error character.
*
*   A normal parse deletes syntax tree additions as a result of input that did
*   not end up matching any of the syntax paths.  The result of a normal parse
*   with an input error is therefore an empty syntax tree.  This is of little
*   in diagnosing errors.  An error re-parse leaves the syntax tree at the time
*   the error character is encountered.  The progress thru nested levels of
*   syntax constructions can then be determined.
*
*   The error re-parse stops when the next character from the input stream is
*   known to be the first character that does not match the syntax definition.
*   It is possible that multiple syntax paths lead to just before the error
*   character.  The error re-parse only identifies the first of these if there
*   are multiple.
}
procedure syn_parse_err_reparse (      {reparse after error, builds tree up to err}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

var
  syfunc_p: syn_parsefunc_p_t;         {pointer to top level syntax to parse}
  ent_p: syn_tent_p_t;                 {pointer to new error end entry}

begin
  if not syn.err then return;          {no previous error, ignore request ?}

  syn_fparse_init (syn);               {init temp state stack for parsing}
  syn_tree_init (syn);                 {init syntax tree, empty, ready to add to}
  syn.parse_p^.tent_def_p := syn.sytree_p; {init tree entry for start of curr level}
  syn.parse_p^.tent_p := syn.sytree_p; {init curr tree entry to the root entry}
  syn.err_end := false;                {init to not reached err reparse end}

  syfunc_p := syn.parsefunc_p;         {get pointer to top level syntax routine}
  discard( syfunc_p^ (syn) );          {parse, stop when reach error character}

  syn_tree_add_err (                   {add error end entry to syntax tree}
    syn,                               {SYN library use state}
    syn.parse_p^.tent_p^,              {parent entry to add after}
    syn.pos_err,                       {error character position}
    ent_p);                            {returned pointer to the new entry}
  syn.parse_p^.tent_p := ent_p;        {make the new entry current}
  end;
{
********************************************************************************
*
*   Subroutine SYN_PARSE_ERR_POS (SYN, EPOS)
*
*   Returns the position of the first character that didn't match the syntax
*   definition.  This routine is only valid after a normal parse was performed
*   that failed.
}
procedure syn_parse_err_pos (          {get the position of error after failed parse}
  in out  syn: syn_t;                  {SYN library use state}
  out     epos: fline_cpos_t);         {position of first char not to match syntax}
  val_param;

begin
  epos := syn.pos_err;                 {return the first error character position}
  end;
{
********************************************************************************
*
*   Subroutine SYN_PARSE_ERR_SHOW (SYN)
*
*   Show the syntax error from the last full parse.  Nothing is done if the last
*   full parse did not end with a syntax error.
}
procedure syn_parse_err_show (         {show error position after failed parse}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if not syn.err then return;          {no syntax error to complain about ?}

  sys_message ('syn', 'syntax_error');
  fline_cpos_show (syn.pos_err);       {show position where syntax error encountered}
  end;
