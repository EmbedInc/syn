{   Routines that handle frames on the temporary state stack during parsing.
}
module syn_fparse;
define fparse_init;
define fparse_level;
define fparse_save;
define fparse_level_pop;
define fparse_save_pop;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_INIT (SYN)
*
*   Initialize the temporary state stack for parsing.  Previous data on the
*   stack, if any, will be deleted.  The stack will contain the single frame for
*   the root context, which will be made the current frame.
}
procedure syn_fparse_init (            {init stack for parsing, delete previous contents}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

var
  fr_p: syn_fparse_p_t;                {pointer to the root state frame}

begin
  syn_stack_init (syn);                {create new empty stack, delete an old}

  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the root stack frame}

  fr_p^.level := 0;                    {init current nesting level}
  fr_p^.prev_p := nil;                 {no previous stack frame}
  fr_p^.frame_lev_p := nil;            {no previous level start}
  fr_p^.frame_save_p := nil;           {no previous saved state}
  fr_p^.name_p := nil;                 {the root doesn't have a name}
  fr_p^.tent_p := nil;                 {init to no curr syntax tree entry}
  fr_p^.pos := syn.pos_start;          {init input stream reading position}
  fr_p^.case := syn_charcase_asis_k;   {init to default char case interpretation}

  syn.parse_p := fr_p;                 {set this frame as the current state}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_LEVEL (SYN, NAME)
*
*   Push a frame on the stack for the start of a new syntax level.  NAME is the
*   name of the syntax construction this new level is for.
*
*   The new stack frame will be created, initialized, and made the current
*   frame.  NAME will be added to the names symbol table, if not already there.
}
procedure syn_fparse_level (           {create stack frame for new syntax level}
  in out  syn: syn_t;                  {SYN library use state}
  in      name: string_var_arg_t);     {name of the new syntax level}
  val_param;

var
  fr_p: syn_fparse_p_t;                {pointer to the new stack frame}

begin
  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the new stack frame}

  fr_p^.level := syn.parse_p^.level + 1; {nested one more level down}
  fr_p^.prev_p := syn.parse_p;         {point back to previous stack frame}
  fr_p^.frame_lev_p := fr_p;           {this frame will be start of current level}
  fr_p^.frame_save_p := syn.parse_p^.frame_save_p; {pointer to last explicit save}
  syn_names_get (syn, name, fr_p^.name_p); {pointer to name saved in names table}
  fr_p^.tent_p := syn.parse_p^.tent_p; {init pointer to curr syntax tree entry}
  fr_p^.pos := syn.parse_p^.pos;       {init input stream parsing position}
  fr_p^.case := syn.parse_p^.case;     {init current char case interpretation}

  syn.parse_p := fr_p;                 {the current state is now in this new frame}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_SAVE (SYN)
*
*   Save the current parsing state onto the temporary state stack.  The new
*   frame is made current.
}
procedure syn_fparse_save (            {save current parsing state on stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

var
  fr_p: syn_fparse_p_t;                {pointer to the new stack frame}

begin
  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the new stack frame}

  fr_p^.level := syn.parse_p^.level;   {staying within same nesting level}
  fr_p^.prev_p := syn.parse_p;         {point back to previous stack frame}
  fr_p^.frame_lev_p := syn.parse_p^.frame_lev_p; {to start of current level}
  fr_p^.frame_save_p := fr_p;          {this frame is now last explicit save}
  fr_p^.name_p := nil;                 {this save doesn't have a name}
  fr_p^.tent_p := syn.parse_p^.tent_p; {init pointer to last syntax tree entry}
  fr_p^.pos := syn.parse_p^.pos;       {init input stream parsing position}
  fr_p^.case := syn.parse_p^.case;     {init current char case interpretation}

  syn.parse_p := fr_p;                 {the current state is now in this new frame}
  end;
{
********************************************************************************
*
*   Local subroutine POPBACK (SYN, OLD_P, POP_P, UPDATE)
*
*   Pop the temporary state stack to remove the entry POP_P and everything
*   after it.  OLD_P will be the new top of stack entry.
*
*   When UPDATE is false, the state is completely restored to what it was when
*   the entry at POP_P was created.  Any syntax tree entries created since then
*   are also deleted.
*
*   When UPDATE is true, then the current input parsing position and the current
*   syntax tree are preserved.  Put another way, the state at OLD_P is updated
*   with the current state before the frames are popped from the stack.
}
procedure popback (                    {pop frame and all after it off the stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      old_p: syn_fparse_p_t;       {points to old frame that will be current}
  in      pop_p: syn_fparse_p_t;       {pop this frame and all after it}
  in      update: boolean);            {update old state to current}
  val_param; internal;

begin
  if update
    then begin                         {update old state to the current}
      old_p^.tent_p := syn.parse_p^.tent_p; {update to current syntax tree state}
      old_p^.pos := syn.parse_p^.pos;  {update to current input stream position}
      if old_p^.level = syn.parse_p^.level then begin {popping within same level ?}
        old_p^.case := syn.parse_p^.case; {update to current char case interpretation}
        end;
      end
    else begin                         {completely restore to the old state}
      syn_tree_trunc (syn, old_p^.tent_p); {restore original syntax tree}
      end
    ;

  syn_stack_popback (syn, pop_p);      {pop the frames off the temp state stack}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_LEVEL_POP (SYN, MATCH)
*
*   Pop the state off the temporary state stack associated with the current
*   syntax level.
*
*   MATCH indicates whether the input stream matched the syntax definition.
*
*   When MATCH is TRUE, then the orginal state before this level is updated to
*   the current state, and nothing is done to the syntax tree.
*
*   When MATCH is FALSE, then the original state before this level is restored.
*   The syntax tree is also restored to what it was when this level was entered.
}
procedure syn_fparse_level_pop (       {pop curr syntax level from stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {TRUE save/update state, FALSE restore state}
  val_param;

var
  lev_p: syn_fparse_p_t;               {points to start of current level}
  prev_p: syn_fparse_p_t;              {points to previous frame before this level}

begin
  lev_p := syn.parse_p^.frame_lev_p;   {point to frame that started this level}
  if lev_p = nil then return;          {not in a level ?}
  prev_p := lev_p^.prev_p;             {point to frame before this level}
  if prev_p = nil then return;         {no previous frame (shouldn't happen) ?}

  popback (syn, prev_p, lev_p, match); {do the pop, conditionally update state}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_SAVE_POP (SYN, MATCH)
*
*   Pop the state off the temporary state stack to before the last explicit
*   state save.
*
*   MATCH indicates whether the input stream matched the syntax definition.
*
*   When MATCH is TRUE, then the orginal state before this level is updated to
*   the current state, and nothing is done to the syntax tree.
*
*   When MATCH is FALSE, then the original state before this level is restored.
*   The syntax tree is also restored to what it was when this level was entered.
}
procedure syn_fparse_save_pop (        {pop back to before last saved state}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {TRUE save/update state, FALSE restore state}
  val_param;

var
  save_p: syn_fparse_p_t;              {points to frame after saved state}
  prev_p: syn_fparse_p_t;              {points to original state that was saved}

begin
  save_p := syn.parse_p^.frame_save_p; {point to frame to remove}
  if save_p = nil then return;         {not in temp saved state ?}
  prev_p := save_p^.prev_p;            {point to frame with saved state}
  if prev_p = nil then return;         {no previous frame (shouldn't happen) ?}

  popback (syn, prev_p, save_p, match); {do the pop, conditionally update state}
  end;
