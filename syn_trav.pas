{   Low level routines for traversing an existing syntax tree.
}
module syn_trav;
define syn_trav_init;
define syn_trav_next;
define syn_trav_down;
define syn_trav_next_down;
define syn_trav_up;
define syn_trav_level;
define syn_trav_level_name;
define syn_trav_next_tag;
define syn_trav_tag;
define syn_trav_tag_start;
define syn_trav_tag_string;
define syn_trav_save;
define syn_trav_goto;
define syn_trav_push;
define syn_trav_pop;
define syn_trav_popdel;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_TRAV_INIT (SYN)
*
*   Initialize for traversing the syntax tree.  This routine must be called once
*   before attempting to traverse the syntax tree.
*
*   Any temporary parsing state is deleted, the position set to the start of the
*   syntax tree, and the traversing stack reset or initialized to empty.
}
procedure syn_trav_init (              {init traversion, at start, stack empty}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  syn_stack_init (syn);                {clear/reset temp state stack}
  syn.travstk_p := nil;                {init temporary state stack pointer}
  syn.tent_p := syn.sytree_p;          {init position to start of syntax tree}
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_NEXT (SYN)
*
*   Go to the next syntax tree entry this level, and return the new entry type.
}
function syn_trav_next (               {to next syntax tree entry}
  in out  syn: syn_t)                  {SYN library use state}
  :syn_tent_k_t;                       {type of syntax tree entry found}
  val_param;

begin
  if syn.tent_p^.next_p = nil then begin {there is no next entry}
    syn_trav_next := syn_tent_end_k;   {indicate end of this level}
    return;
    end;

  syn.tent_p := syn.tent_p^.next_p;    {go to the next entry}
  case syn.tent_p^.ttype of            {what kind of entry is this ?}
syn_ttype_sub_k: syn_trav_next := syn_tent_sub_k;
syn_ttype_tag_k: syn_trav_next := syn_tent_tag_k;
syn_ttype_err_k: syn_trav_next := syn_tent_err_k;
otherwise
    writeln ('INTERNAL ERROR: Found unexpected syntax tree entry ID of ',
      ord(syn.tent_p^.ttype), ' in SYN_TRAV_NEXT.');
    sys_bomb;
    end;
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_DOWN (SYN)
*
*   Go down into the subordinate level of the current syntax tree entry.  The
*   function returns TRUE when this is done successfully.  FALSE means that the
*   current syntax tree entry is not a subordinate level.
}
function syn_trav_down (               {down into subordinate level from curr entry}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {successfully entered subordinate level}
  val_param;

begin
  if syn.tent_p^.ttype <> syn_ttype_sub_k then begin {not at subordinate level ?}
    syn_trav_down := false;
    return;
    end;

  syn.tent_p := syn.tent_p^.sub_p;     {go to start of the subordinate level}
  syn_trav_down := true;               {indicate success}
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_NEXT_DOWN (SYN)
*
*   If the next syntax tree entry is a subordinate level, go down to the start
*   of that level.  In that case, the function returns TRUE.  If the next entry
*   is not a subordinate level, then the syntax tree position is not changed,
*   and the function returns FALSE.
}
function syn_trav_next_down (          {into sub level of next entry}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {next was sub level, moved down}
  val_param;

begin
  syn_trav_next_down := false;         {init to next is not subordinate level}
  if syn.tent_p^.next_p = nil then return; {there is no next entry ?}
  if syn.tent_p^.next_p^.ttype <> syn_ttype_sub_k {next level not sub ?}
    then return;

  syn.tent_p := syn.tent_p^.next_p^.sub_p; {to sub level of next entry}
  syn_trav_next_down := true;          {indicate success}
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_UP (SYN)
*
*   Pop up to the parent level.  The position will be at the entry for the
*   subordinate level.  The function returns TRUE normally.  The function
*   returns FALSE when there is no parent level.  In that case the syntax tree
*   position is not changed.
}
function syn_trav_up (                 {pop up to parent syntax tree level}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {successfully popped to parent level}
  val_param;

begin
  if syn.tent_p^.levst_p^.lev_up_p = nil then begin {no parent level ?}
    syn_trav_up := false;
    return;
    end;

  syn.tent_p := syn.tent_p^.levst_p^.lev_up_p; {to SUB entry in parent level}
  syn_trav_up := true;
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_LEVEL (SYN)
*
*   Returns the 0-N nesting level of the current syntax tree position.  0 is the
*   top level that has no parent.
}
function syn_trav_level (              {get nesting level of curr syntax tree pos}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {0-N, 0 at top level}
  val_param;

begin
  syn_trav_level := syn.tent_p^.levst_p^.level;
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_LEVEL_NAME (SYN, NAME)
*
*   Get the name of the current syntax tree level into NAME.
}
procedure syn_trav_level_name (        {get the name of the current syntax tree level}
  in out  syn: syn_t;                  {SYN library use state}
  in out  name: univ string_var_arg_t); {returned name}
  val_param;

var
  lev_p: syn_tent_p_t;                 {pointer to start of level syntax tree entry}

begin
  name.len := 0;                       {init the returned string to empty}
  lev_p := syn.tent_p^.levst_p;        {get pointer to start of level entry}
  if lev_p = nil then return;          {no start of level available (shouldn't happen) ?}
  if lev_p^.lev_name_p = nil then return; {name of this level unavailable ?}

  string_copy (lev_p^.lev_name_p^, name); {return the name of the current level}
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_NEXT_TAG (SYN)
*
*   Goes to the next syntax tree entry and return its tag ID.  On success, the
*   function returns the 1-N tag number.  Otherwise, the function returns one
*   of the special values SYN_TAG_xxx_K, which all have values less than 1:
*
*     SYN_TAG_END_K  -  At end of syntax level.  There is no next entry.
*
*     SYN_TAG_NTAG_K  -  There is a next entry, but it is not a tag.
*
*     SYN_TAG_ERR_K  -  Hit error end of the syntax tree.
}
function syn_trav_next_tag (           {to next entry, return its tag value}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {1-N tag number or SYN_TAG_xxx_K}
  val_param;

begin
  if syn.tent_p^.next_p = nil then begin {there is no next entry ?}
    syn_trav_next_tag := syn_tag_end_k;
    return;
    end;

  case syn.tent_p^.next_p^.ttype of    {what type of entry is next ?}
syn_ttype_tag_k: begin                 {tag entry, as expected}
      syn.tent_p := syn.tent_p^.next_p; {go to this tag entry}
      syn_trav_next_tag := syn.tent_p^.tag; {return the 1-N tag ID}
      end;
syn_ttype_err_k: begin                 {hit error end of syntax tree}
      syn_trav_next_tag := syn_tag_err_k;
      end;
otherwise
    syn_trav_next_tag := syn_tag_ntag_k; {not a tag entry, didn't move}
    end;
  end;
{
********************************************************************************
*
*   Function SYN_TRAV_TAG (SYN)
*
*   Get the tag ID for the current syntax tree entry.  SYN_TAG_NTAG_K is
*   returned if the current syntax tree position is on at a tag.
}
function syn_trav_tag (                {get ID of current tag entry}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {1-N tag number or SYN_TAG_NTAG_K}
  val_param;

begin
  if syn.tent_p^.ttype <> syn_ttype_tag_k then begin {not at a tag ?}
    syn_trav_tag := syn_tag_ntag_k;
    return;
    end;

  syn_trav_tag := syn.tent_p^.tag;     {return the tag ID}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_TAG_START (SYN, POS)
*
*   Get the position of the start of the string tagged by the current syntax
*   tree entry into POS.  If the current syntax tree entry is not a tag, then
*   POS is set to invalid.
}
procedure syn_trav_tag_start (         {get start loc for tag at curr tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  out     pos: fline_cpos_t);          {start of tagged string in soruce lines}
  val_param;

begin
  if syn.tent_p^.ttype <> syn_ttype_tag_k then begin {not at a tag ?}
    pos.line_p := nil;                 {return invalid position}
    pos.ind := 0;
    return;
    end;

  pos := syn.tent_p^.tag_st;           {return pos of first tagged char}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_TAG_STRING (SYN, TAGSTR)
*
*   Get the source string tagged by the current syntax tree entry.  The empty
*   string is returned if the current syntax tree entry is not a tag.
}
procedure syn_trav_tag_string (        {get string tagged by current tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in out  tagstr: univ string_var_arg_t); {returned tagged string}
  val_param;

var
  pos: fline_cpos_t;                   {source character position}
  ch: char;                            {input string character}

begin
  tagstr.len := 0;                     {init the returned string to empty}
  if syn.tent_p^.ttype <> syn_ttype_tag_k {not at a tag ?}
    then return;

  pos := syn.tent_p^.tag_st;           {init to starting character position}
  while                                {back here until after end of tagged string}
      (pos.ind <> syn.tent_p^.tag_af.ind) or
      (pos.line_p <> syn.tent_p^.tag_af.line_p)
      do begin
    if not fline_char (pos, ch)        {unable to get this character ?}
      then exit;
    string_append1 (tagstr, ch);       {append this char to end of returned string}
    end;                               {back to get the next character}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_SAVE (SYN, POS)
*
*   Save the current syntax tree position in POS.
}
procedure syn_trav_save (              {save current syntax tree position}
  in out  syn: syn_t;                  {SYN library use state}
  out     pos: syn_treepos_t);         {returned syntax tree position}
  val_param;

begin
  pos := syn.tent_p;
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_GOTO (SYN, POS)
*
*   Go to the saved syntax tree position POS.  POS must have been previously set
*   by SYN_TRAV_SAVE.
}
procedure syn_trav_goto (              {go to previously-saved syn tree position}
  in out  syn: syn_t;                  {SYN library use state}
  in      pos: syn_treepos_t);         {saved position to go to}
  val_param;

begin
  syn.tent_p := pos;
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_PUSH (SYN)
*
*   Push the current syntax tree position onto an internal stack.
}
procedure syn_trav_push (              {save curr syntax tree pos on internal stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

var
  fr_p: syn_ftrav_p_t;                 {pointer to new stack frame}

begin
  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the new stack frame}
  fr_p^.prev_p := syn.travstk_p;       {point back to previous stack frame}
  fr_p^.tent_p := syn.tent_p;          {save current position}
  syn.travstk_p := fr_p;               {update pointer to top of stack frame}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_POP (SYN)
*
*   Pop the last-pushed syntax tree position off the internal stack and go
*   there.  Nothing is done when the stack is empty.
}
procedure syn_trav_pop (               {restore curr syntx tree pos from stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if syn.travstk_p = nil then return;  {no stack frame to pop ?}

  syn.tent_p := syn.travstk_p^.tent_p; {go to position saved on stack}
  syn.travstk_p := syn.travstk_p^.prev_p; {point back to previous stack frame}
  syn_stack_pop (syn, sizeof(syn.travstk_p^)); {pop the stack}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TRAV_POPDEL (SYN)
*
*   Pop the last-pushed syntax tree position off the internal stack and discard
*   it.  The current syntax tree position is not changed.  Nothing is done when
*   the stack is empty.
}
procedure syn_trav_popdel (            {pop syn tree pos from stack, stay curr pos}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if syn.travstk_p = nil then return;  {no stack frame to pop ?}

  syn.travstk_p := syn.travstk_p^.prev_p; {point back to previous stack frame}
  syn_stack_pop (syn, sizeof(syn.travstk_p^)); {pop the stack}
  end;
