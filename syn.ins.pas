{   Public include file for the "new" (2022) syntaxer.  The old syntaxer was
*   renamed SYO.  The syntaxer parses a sequence of text lines according to a
*   formal syntax definition.
*
*   To use the syntaxer, the syntax definition file is compiled to executable
*   code in a linkable library.  This is done by the SST program, taking the
*   syntax definition file (.syn) as input.  The application that interprets the
*   syntax is then linked with the resulting binary.  The application calls
*   routines in the SYN library to cause the input text to be parsed and a
*   syntax tree built.  The app then calls other SYN library routines to
*   traverse the syntax tree.
*
*   This new syntaxer differs from the previous in these ways:
*
*     *  The new SYN library has no internal static state.  This means that most
*        calls have an additional argument that passes in the particular SYN
*        library state to use.
*
*     *  The text input is a collection of lines managed by the FLINE library.
*        These can come from a text file, but can also be generated by an
*        application on the fly, like a preprocessor.  The old library did its
*        own input lines management.  The FLINE library did not exist at the
*        time the old syntaxer was created.
*
*     *  The new syntaxer no longer has hooks for a preprocessor.  Preprocessing
*        is now done, if needed at all, by having the preprocessor produce a
*        collection of text lines managed by the FLINE library.
}
const
  syn_subsys_k = -75;                  {SYN library subsystem ID}
  syn_names_nbuck_k = 64;              {number of buckets in syntax names symbol table}
  syn_name_maxlen_k = 32;              {max name length of a user-defined syntax}
{
*   Special values that can be returned when a 0-255 character code is normally
*   expected.
}
  syn_ichar_eol_k = -1;                {end of line}
  syn_ichar_eof_k = -2;                {end of current file (end of subordinate collection)}
  syn_ichar_eod_k = -3;                {end of all input data}
  syn_ichar_inv_k = -4;                {invalid, should not match anything}
{
*   Special tag values that can be returned by SYN_TRAV_TAG_NEXT.  All user tag
*   values are greater than 0.  These special tag values are 0 or less.
}
  syn_tag_end_k = 0;                   {end of syntax level}
  syn_tag_ntag_k = -1;                 {next syntax tree entry is not a tag}
  syn_tag_err_k = -2;                  {error end of syntax tree encountered}

type
  syn_charcase_k_t = (                 {how to handle input stream character case}
    syn_charcase_down_k,               {convert input to lower case}
    syn_charcase_up_k,                 {convert input to upper case}
    syn_charcase_asis_k);              {do not alter input stream characters (default)}

  syn_tent_k_t = (                     {user-visible syntax tree entry types}
    syn_tent_err_k,                    {error end of syntax tree}
    syn_tent_end_k,                    {end of current level}
    syn_tent_sub_k,                    {subordinate level is here}
    syn_tent_tag_k);                   {tagged input string}

  syn_ttype_k_t = (                    {internal syntax tree entry types}
    syn_ttype_lev_k,                   {start of a syntax level}
    syn_ttype_sub_k,                   {link to subordinate level}
    syn_ttype_tag_k,                   {tagged item}
    syn_ttype_err_k);                  {error end of tree}

  syn_tent_p_t = ^syn_tent_t;
  syn_tent_t = record                  {one syntax tree entry}
    back_p: syn_tent_p_t;              {pointer to previously-created entry}
    next_p: syn_tent_p_t;              {to next entry this level, NIL at end of level}
    levst_p: syn_tent_p_t;             {points to starting entry for this level}
    ttype: syn_ttype_k_t;              {what kind of entry this is}
    case syn_ttype_k_t of
syn_ttype_lev_k: (                     {start of a syntax level}
      level: sys_int_machine_t;        {nesting level, 0 at root}
      lev_up_p: syn_tent_p_t;          {points to SUB entry in parent level}
      lev_name_p: string_var_p_t;      {points to name of this level}
      );
syn_ttype_sub_k: (                     {link to subordinate level}
      sub_p: syn_tent_p_t;             {points to LEV entry for the subordinate level}
      );
syn_ttype_tag_k: (                     {tagged item}
      tag: sys_int_machine_t;          {tag ID}
      tag_st: fline_cpos_t;            {starting char pos of tagged string}
      tag_af: fline_cpos_t;            {first char pos after tagged string}
      );
syn_ttype_err_k: (                     {error end of syntax tree}
      err_pos: fline_cpos_t;           {pos of first char not matching the syntax}
      );
    end;

  syn_fparse_p_t = ^syn_fparse_t;
  syn_fparse_t = record                {temp state stack frame during parsing}
    level: sys_int_machine_t;          {nesting level, 0 at top}
    prev_p: syn_fparse_p_t;            {to previous stack frame, NIL at first}
    frame_lev_p: syn_fparse_p_t;       {to frame of last level start}
    frame_save_p: syn_fparse_p_t;      {to frame of last explict save}
    frame_tag_p: syn_fparse_p_t;       {to frame of current tag start, if any}
    tent_lev_p: syn_tent_p_t;          {to syn tree entry for start of current level}
    tent_p: syn_tent_p_t;              {to current syntax tree entry}
    pos: fline_cpos_t;                 {live input stream position}
    case: syn_charcase_k_t;            {live char case mode}
    tagged: boolean;                   {tag created since level start or last save}
    end;

  syn_ftrav_p_t = ^syn_ftrav_t;
  syn_ftrav_t = record                 {temp state stack frame during tree traversal}
    prev_p: syn_ftrav_p_t;             {points to previous stack frame}
    tent_p: syn_tent_p_t;              {points to current syntax tree frame}
    end;

  syn_p_t = ^syn_t;
  syn_t = record                       {state for one use of the SYN library}
    mem_p: util_mem_context_p_t;       {pointer to private memory context}
    mem_tree_p: util_mem_context_p_t;  {points to private mem for syntax tree}
    sytree_p: syn_tent_p_t;            {points to first syntax tree entry}
    sytree_last_p: syn_tent_p_t;       {points to last-created syntax tree entry}
    nametab: string_hash_handle_t;     {table of syntax construction names}
    names: boolean;                    {NAMETAB has been created}
    stack: util_stack_handle_t;        {temp stacked state when parsing and traversing}
    stack_exist: boolean;              {the temp state stack has been created}
    {
    *   State used when parsing the input stream.
    }
    tent_unused_p: syn_tent_p_t;       {points to chain of unused syn tree entries}
    pos_start: fline_cpos_t;           {starting position of current parse}
    pos_err: fline_cpos_t;             {farthest parsing position char returned for}
    pos_errnext: fline_cpos_t;         {parsing position after returning at POS_ERR}
    err: boolean;                      {doing error re-parse}
    err_end: boolean;                  {err char has been reached in error reparse}
    parse_p: syn_fparse_p_t;           {to current parsing state, on stack}
    parsefunc_p: univ_ptr;             {pointer to top level syntax to parse}
    {
    *   State used when traversing the syntax tree.
    }
    tent_p: syn_tent_p_t;              {pointer to current syntax tree entry}
    travstk_p: syn_ftrav_p_t;          {pointer to current traversing stack entry}
    end;

  syn_parsefunc_p_t = ^function (      {pointer to function to parse a construction}
    in out syn: syn_t)                 {SYN library use state}
    :boolean;                          {syntax matched, tree possibly extended}
    val_param;

  syn_treepos_t = syn_tent_p_t;        {user-stored syntax tree position}
{
********************************************************************************
*
*   General SYN library routines.
}
procedure syn_lib_end (                {end a use of the SYN library}
  in out  syn_p: syn_p_t);             {pointer to lib use state, returned NIL}
  val_param; extern;

procedure syn_lib_new (                {create new use of the SYN library}
  in out  mem: util_mem_context_t;     {parent mem context, will create subordinate}
  out     syn_p: syn_p_t);             {pointer to new SYN library use state}
  val_param; extern;
{
********************************************************************************
*
*   Routines for parsing the input and creating a syntax tree.
}
function syn_parse_coll (              {clear stack, parse input, build syntax tree}
  in out  syn: syn_t;                  {SYN library use state}
  in var  coll: fline_coll_t;          {collection of input lines to parse}
  in      syfunc_p: syn_parsefunc_p_t) {top level syntax to parse against}
  :boolean;                            {no error, syntax tree built}
  val_param; extern;

procedure syn_parse_err_pos (          {get the position of error after failed parse}
  in out  syn: syn_t;                  {SYN library use state}
  out     epos: fline_cpos_t);         {position of first char not to match syntax}
  val_param; extern;

procedure syn_parse_err_reparse (      {reparse after error, builds tree up to err}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;
{
********************************************************************************
*
*   Routines for traversing the syntax tree.
}
function syn_trav_down (               {down into subordinate level from curr entry}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {successfully entered subordinate level}
  val_param; extern;

procedure syn_trav_goto (              {go to previously-saved syn tree position}
  in out  syn: syn_t;                  {SYN library use state}
  in      pos: syn_treepos_t);         {saved position to go to}
  val_param; extern;

procedure syn_trav_init (              {init traversion, at start, stack empty}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

function syn_trav_level (              {get nesting level of curr syntax tree pos}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {0-N, 0 at top level}
  val_param; extern;

procedure syn_trav_level_name (        {get the name of the current syntax tree level}
  in out  syn: syn_t;                  {SYN library use state}
  in out  name: univ string_var_arg_t); {returned name}
  val_param; extern;

function syn_trav_next (               {to next syntax tree entry}
  in out  syn: syn_t)                  {SYN library use state}
  :syn_tent_k_t;                       {type of syntax tree entry found}
  val_param; extern;

function syn_trav_next_down (          {into sub level of next entry}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {next was sub level, moved down}
  val_param; extern;

function syn_trav_next_tag (           {to next entry, return its tag value}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {1-N tag number or SYN_TAG_xxx_K}
  val_param; extern;

procedure syn_trav_pop (               {restore curr syntx tree pos from stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_trav_popdel (            {pop syn tree pos from stack, stay curr pos}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_trav_push (              {save curr syntax tree pos on internal stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_trav_save (              {save current syntax tree position}
  in out  syn: syn_t;                  {SYN library use state}
  out     pos: syn_treepos_t);         {returned syntax tree position}
  val_param; extern;

function syn_trav_tag (                {get ID of current tag entry}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {1-N tag number or SYN_TAG_xxx_K}
  val_param; extern;

procedure syn_trav_tag_start (         {get start loc for tag at curr tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  out     pos: fline_cpos_t);          {start of tagged string in soruce lines}
  val_param; extern;

procedure syn_trav_tag_string (        {get string tagged by current tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in out  tagstr: univ string_var_arg_t); {returned tagged string}
  val_param; extern;

function syn_trav_up (                 {pop up to parent syntax tree level}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {successfully popped to parent level}
  val_param; extern;
{
********************************************************************************
*
*   Routines used by the syntax parsing code.  These routines are called by the
*   code that is compiled from a syntax definition file.  They are declared here
*   so that applications can create syntax parsing routines directly, without
*   the use of a syntax definition file.
*
*   Routines that parse specific syntax constructions should have names starting
*   with "SYN_CH_" (for "syntax check").  The SYN library is guaranteed to not
*   have any symbols with such names.  Such routines are functions that take a
*   single SYN_T argument, and return TRUE or FALSE.
*
*   TRUE means that the parsed input matched the syntax construction.  The input
*   up to the end of the construction has been consumed.  The syntax tree has
*   been extended accordingly.
*
*   FALSE means that the parsed input did not match the syntax construction.
*   The input stream position has been returned to what it was when the routine
*   was called, and the syntax tree has not changed.
}
procedure syn_p_charcase (             {set charcase handling, restored at constr end}
  in out  syn: syn_t;                  {SYN library use state}
  in      ccase: syn_charcase_k_t);    {the new input stream character case handling}
  val_param; extern;

procedure syn_p_constr_end (           {done parsing syntax construction, restore state}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {input matched construction, tree extended}
  val_param; extern;

procedure syn_p_constr_start (         {starting to parse a new syntax construction}
  in out  syn: syn_t;                  {SYN library use state}
  in      name: string;                {name of syntax construction being checked}
  in      namelen: sys_int_machine_t); {number of characters in NAME}
  val_param; extern;

procedure syn_p_cpos_pop (             {pop input character position from parse stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {syntax matched, continue at curr input position}
  val_param; extern;

procedure syn_p_cpos_push (            {push input character position onto parse stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

function syn_p_ichar (                 {get next input char code, charcase applied}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {0-255 character code, or SYN_ICHAR_xxx_K}
  val_param; extern;

procedure syn_p_tag_end (              {end tagged section of input stream}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {input matched, create the tag}
  val_param; extern;

procedure syn_p_tag_start (            {start tagged section of input stream}
  in out  syn: syn_t;                  {SYN library use state}
  in      id: sys_int_machine_t);      {tag ID}
  val_param; extern;

function syn_p_test_eod (              {check for at end of input data}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {at end of input data}
  val_param; extern;

function syn_p_test_eof (              {check for at end of current logical input file}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {at end of input data}
  val_param; extern;

function syn_p_test_eol (              {check for at end of current line}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {at end of line}
  val_param; extern;

function syn_p_test_string (           {check input for matching string}
  in out  syn: syn_t;                  {SYN library use state}
  in      str: string;                 {the string to compare to the input}
  in      strlen: sys_int_machine_t)   {number of characters in STR}
  :boolean;                            {input matched string, position left at end}
  val_param; extern;
