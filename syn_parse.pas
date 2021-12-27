{   Routines for parsing the input stream and building the syntax tree.
}
module syn_parse;
define syn_parse_coll;
define syn_parse_err_reparse;
define syn_parse_err_pos;
%include 'syn2.ins.pas';
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

var
  match: boolean;                      {the input stream matched the syntax definition}

begin
  fline_coll_line_first (coll, syn.pos_start.line_p); {get pointer to first input line}
  syn.pos_start.ind := 0;              {init position to before first char}
  syn.parsefunc_p := syfunc_p;         {save pointer to top level syntax to parse}

  syn_stack_init (syn);                {init temp data stack, ready for use}
  syn_tree_init (syn);                 {init syntax tree, empty, ready to add to}
  syn_names_init (syn);                {init syntax names symbol table to empty}

  syn.pos_err := syn.pos_start;        {init farthest character parsed to}
  syn.err := false;                    {doing normal parse, not error re-parse}

  match := syfunc_p^ (syn);            {parse, TRUE iff input matched syntax}
  syn.err := not match;                {remember whether there was error or not}
  syn_parse_coll := match;             {returned syntax matched yes/no condition}
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

begin
  if not syn.err then return;          {no previous error, ignore request ?}

  syn_stack_init (syn);                {init temp data stack, ready for use}
  syn_tree_init (syn);                 {init syntax tree, empty, ready to add to}

  syfunc_p := syn.parsefunc_p;         {get pointer to top level syntax routine}
  discard( syfunc_p^ (syn) );          {parse, stop when reach error character}
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
