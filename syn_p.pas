{   Routines used by syntax parsing code.  Such syntax parsing code is usually
*   generated automatically from a syntax definition file.  However, parsing
*   routines can also be created manually.
*
*   All the routines here are named SYN_P_xxx.  These are the only syn routines
*   that should be called from parsing code.
}
module syn_p;
define syn_p_charcase;
define syn_p_ichar;
define syn_p_constr_start;
define syn_p_constr_end;
define syn_p_cpos_push;
define syn_p_cpos_pop;
define syn_p_cpos_get;
define syn_p_cpos_set;
define syn_p_tag_start;
define syn_p_tag_end;
define syn_p_test_eol;
define syn_p_test_eof;
define syn_p_test_eod;
define syn_p_test_string;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_P_CHARCASE (SYN, CCASE)
*
*   Set the character case interpretation to CCASE.  This applies to the rest of
*   this sytax level, and is the default for lower levels.
}
procedure syn_p_charcase (             {set charcase handling, restored at constr end}
  in out  syn: syn_t;                  {SYN library use state}
  in      ccase: syn_charcase_k_t);    {the new input stream character case handling}
  val_param;

begin
  syn.parse_p^.case := ccase;          {set the new case as current}
  end;
{
********************************************************************************
*
*   Function SYN_P_ICHAR (SYN)
*
*   Return the code of the next input character, or one of the special character
*   IDs.  Character codes are 0-255, and the special IDs are always negative.
*   Use names SYN_ICHAR_xxx_K for the special ID values.
*
*   During normal parsing, the furthest character reached is updated.
*
*   During an error re-parse, SYN.ERR_END is set when the error character
*   position is reached.  In that case, calling routines should abort the parse.
}
function syn_p_ichar (                 {get next input char code, charcase applied}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {0-255 character code, or SYN_ICHAR_xxx_K}
  val_param;

var
  ch: char;                            {character from input line}
  upderr: boolean;                     {update error char position}

begin
  if                                   {at err char during err reparse ?}
      syn.err and                      {in error reparse ?}
      (syn.parse_p^.pos.line_p = syn.pos_err.line_p) and
      (syn.parse_p^.pos.ind = syn.pos_err.ind)
      then begin
    syn.err_end := true;               {indicate the error char has been reached}
    syn_p_ichar := syn_ichar_inv_k;    {return invalid character}
    return;
    end;
{
*   Return the character.
}
  upderr :=                            {need to update error position state ?}
    (not syn.err) and                  {not in err reparse ?}
    (syn.parse_p^.pos.line_p = syn.pos_errnext.line_p) and {at next char after err ?}
    (syn.parse_p^.pos.ind = syn.pos_errnext.ind);
  if upderr then begin                 {update error position state ?}
    syn.pos_err := syn.parse_p^.pos;   {update pos of farthest returned char}
    end;

  if syn.parse_p^.pos.line_p = nil
    then begin                         {at end of collection}
      syn_p_ichar := syn_ichar_eod_k;  {return end of data indication}
      end
    else begin                         {still within the collection}
      if fline_char (syn.parse_p^.pos, ch)
        then begin                     {got a character normally}
          case syn.parse_p^.case of    {how to handle character case ?}
syn_charcase_down_k: begin             {convert to lower case}
              syn_p_ichar := ord(string_downcase_char(ch));
              end;
syn_charcase_up_k: begin               {convert to upper case}
              syn_p_ichar := ord(string_upcase_char(ch));
              end;
otherwise
            syn_p_ichar := ord(ch);    {leave character case as is}
            end;                       {end of character case handling cases}
          end
        else begin                     {hit end of the current line}
          syn_p_ichar := syn_ichar_eol_k; {return end of line indication}
          discard( fline_cpos_nextline(syn.parse_p^.pos) ); {advance to next line}
          end
        ;
      end
    ;

  if upderr then begin                 {update error position state ?}
    syn.pos_errnext := syn.parse_p^.pos; {save position immediately after err char}
    end;
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_CONSTR_START (SYN, NAME, NAMELEN)
*
*   Start a new nested syntax construction.  NAME is a bare string, and is the
*   name of this construction.  NAMELEN is the number of characters in NAME.
*
*   A new syntax tree level will be started, and a new temporary state stack
*   frame created for the new level.  The new stack frame will be made current.
}
procedure syn_p_constr_start (         {starting to parse a new syntax construction}
  in out  syn: syn_t;                  {SYN library use state}
  in      name: string;                {name of syntax construction being checked}
  in      namelen: sys_int_machine_t); {number of characters in NAME}
  val_param;

var
  vname: string_var32_t;               {var string name}
  name_p: string_var_p_t;              {pointer to name string in names table}
  tlev_p: syn_tent_p_t;                {pointer to tree entry for new level}

begin
  vname.max := size_char(vname.str);   {init local var string}
  string_vstring (vname, name, namelen); {make var string name in VNAME}
  syn_names_get (syn, vname, name_p);  {get pointer to name in names table}
{
*   Create the SUB and LEV syntax tree entries for the new syntax level.
}
  syn_tree_add_sub (                   {create the new level in the syntax tree}
    syn,                               {SYN library use state}
    syn.parse_p^.tent_p^,              {tree entry to append after}
    name_p,                            {pointer to name of this new level}
    tlev_p);                           {returned pointer to LEV tree entry}
{
*   Create the temp parsing stack entry for the start of the new syntax level.
*   This entry will point to the LEV syntax tree entry.
}
  syn_fparse_level (syn, tlev_p);      {create parse stack frame, point to LEV}
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_CONSTR_END (SYN, MATCH)
*
*   Ends the current nested syntax construction.  MATCH indicates whether the
*   input stream matched the expected syntax.  If so, the syntax tree state is
*   retained, and the input stream will continue to be read at the current
*   position.
*
*   If the input did not match the syntax or no tags were created, then all
*   state is popped back to what it was when the level was started.  Any syntax
*   tree entries since then will be removed, and the input stream position will
*   be restored to the start of the syntax level.
}
procedure syn_p_constr_end (           {done parsing syntax construction, restore state}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {input matched construction, tree extended}
  val_param;

begin
  if syn.err_end then return;          {leave state as is after hit err reparse end}
  syn_fparse_level_pop (syn, match);   {pop back to before start of this level}
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_CPOS_PUSH (SYN)
*
*   Push the current input stream position and related state onto the temporary
*   state stack.  The syntax tree is not altered.  Pushing the current state
*   onto the stack allows restoring to that state later if the syntax about to
*   be checked doesn't match.
}
procedure syn_p_cpos_push (            {push input character position onto parse stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  syn_fparse_save (syn);               {save state on temp state stack}
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_CPOS_POP (SYN, MATCH)
*
*   Pop the state saved with the last call to SYN_P_CPOS_PUSH off the temporary
*   state stack.  MATCH is intended to indicate whether the syntax matched since
*   the state was saved.
*
*   When MATCH is TRUE, then anything that was added to the syntax tree since
*   the save is removed.  When MATCH is TRUE and at least one tag was created,
*   then the syntax tree is left as is.
}
procedure syn_p_cpos_pop (             {pop input character position from parse stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {syntax matched, continue at curr input position}
  val_param;

begin
  if syn.err_end then return;          {leave state as is after hit err reparse end}
  syn_fparse_save_pop (syn, match);
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_CPOS_GET (SYN, POS)
*
*   Get the current parsing character position into POS.  No parsing state is
*   altered.
}
procedure syn_p_cpos_get (             {get the current parsing character position}
  in out  syn: syn_t;                  {SYN library use state}
  out     pos: fline_cpos_t);          {returned pasing position}
  val_param;

begin
  pos := syn.parse_p^.pos;
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_CPOS_SET (SYN, POS)
*
*   Set the current parsing position to POS.  The next character returned by
*   SYN_P_ICHAR will be the character at POS.
}
procedure syn_p_cpos_set (             {set the current parsing character position}
  in out  syn: syn_t;                  {SYN library use state}
  in      pos: fline_cpos_t);          {character position to go to}
  val_param;

begin
  syn.parse_p^.pos := pos;
  end;
{
********************************************************************************
*
*   Subroutine SYN_P_TAG_START (SYN, ID)
*
*   Indicate that a tagged section of the input stream starts at the current
*   location.  ID is the integer identifier for this tag.
}
procedure syn_p_tag_start (            {start tagged section of input stream}
  in out  syn: syn_t;                  {SYN library use state}
  in      id: sys_int_machine_t);      {tag ID}
  val_param;

var
  ent_p: syn_tent_p_t;                 {pointer to syntax tree entry for the tag}

begin
  syn_tree_add_tag (                   {add syntax tree entry for the tag}
    syn,                               {SYN libarary use state}
    syn.parse_p^.tent_p^,              {syntax tree entry to add after}
    id,                                {tag ID}
    syn.parse_p^.pos,                  {tagged string start position}
    ent_p);                            {returned pointer to new syntax tree entry}

  syn_fparse_tag (syn, ent_p);         {create temp state stack frame}
  end;
{
********************************************************************************
}
procedure syn_p_tag_end (              {end tagged section of input stream}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {input matched, create the tag}
  val_param;

var
  ftag_p: syn_fparse_p_t;              {pointer to stack frame for tag start}

begin
  ftag_p := syn.parse_p^.frame_tag_p;  {point to frame for tag start}
  if ftag_p = nil then return;         {not within a tag ?}
  ftag_p^.tent_def_p^.tag_af := syn.parse_p^.pos; {save first pos after tag}
  if syn.err_end then return;          {leave state as is after hit err reparse end}

  syn_fparse_tag_pop (syn, match);     {pop tag state from stack}
  end;
{
********************************************************************************
*
*   Function SYN_P_TEST_EOL (SYN)
*
*   Syntax construction routine that expects end of line (EOL).
}
function syn_p_test_eol (              {syntax construction for end of line}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {at end of input data}
  val_param;

var
  spos: fline_cpos_t;                  {saved input stream position}

label
  no;

begin
  spos := syn.parse_p^.pos;            {save original input stream position}

  if syn_p_ichar(syn) <> syn_ichar_eol_k {not the right character ?}
    then goto no;
  if syn.err_end                       {hit end of error re-parse ?}
    then goto no;

  syn_p_test_eol := true;              {syntax matched}
  return;

no:                                    {return syntax didn't match indication}
  syn.parse_p^.pos := spos;            {restore original input stream position}
  syn_p_test_eol := false;             {indicate did not match}
  end;
{
********************************************************************************
*
*   Function SYN_P_TEST_EOF (SYN)
*
*   Syntax construction routine that expects end of file (EOF).
}
function syn_p_test_eof (              {syntax construction for end of file}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {at end of input data}
  val_param;

var
  spos: fline_cpos_t;                  {saved input stream position}

label
  no;

begin
  spos := syn.parse_p^.pos;            {save original input stream position}

  if syn_p_ichar(syn) <> syn_ichar_eof_k {not the right character ?}
    then goto no;
  if syn.err_end                       {hit end of error re-parse ?}
    then goto no;

  syn_p_test_eof := true;              {syntax matched}
  return;

no:                                    {return syntax didn't match indication}
  syn.parse_p^.pos := spos;            {restore original input stream position}
  syn_p_test_eof := false;             {indicate did not match}
  end;
{
********************************************************************************
*
*   Function SYN_P_TEST_EOD (SYN)
*
*   Syntax construction routine that expects the end of data (EOD).
}
function syn_p_test_eod (              {syntax construction for end of data}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {at end of input data}
  val_param;

var
  spos: fline_cpos_t;                  {saved input stream position}

label
  no;

begin
  spos := syn.parse_p^.pos;            {save original input stream position}

  if syn_p_ichar(syn) <> syn_ichar_eod_k {not the right character ?}
    then goto no;
  if syn.err_end                       {hit end of error re-parse ?}
    then goto no;

  syn_p_test_eod := true;              {syntax matched}
  return;

no:                                    {return syntax didn't match indication}
  syn.parse_p^.pos := spos;            {restore original input stream position}
  syn_p_test_eod := false;             {indicate did not match}
  end;
{
********************************************************************************
*
*   Function SYN_P_TEST_STRING (SYN, STR, STRLEN)
*
*   Syntax construction routine that expects the string STR, which is STRLEN
*   characters long.
}
function syn_p_test_string (           {check input for matching string}
  in out  syn: syn_t;                  {SYN library use state}
  in      str: string;                 {the string to compare to the input}
  in      strlen: sys_int_machine_t)   {number of characters in STR}
  :boolean;                            {input matched string, position left at end}
  val_param;

var
  spos: fline_cpos_t;                  {saved input stream position}
  ind: sys_int_machine_t;              {character string index}

label
  no;

begin
  spos := syn.parse_p^.pos;            {save original input stream position}

  for ind := 1 to strlen do begin      {loop over each string character}
    if syn_p_ichar(syn) <> ord(str[ind]) {input doesn't match this char ?}
      then goto no;
    if syn.err_end then goto no;       {hit end of error re-parse ?}
    end;                               {this char matched, back to check next}

  syn_p_test_string := true;           {the input matched the string}
  return;

no:                                    {return syntax didn't match indication}
  syn.parse_p^.pos := spos;            {restore original input stream position}
  syn_p_test_string := false;          {indicate did not match}
  end;
