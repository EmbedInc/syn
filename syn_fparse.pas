{   Routines that handle frames on the temporary state stack during parsing.
}
module syn_fparse;
define syn_fparse_init;
define syn_fparse_level;
define syn_fparse_save;
define syn_fparse_tag;
define syn_fparse_level_pop;
define syn_fparse_save_pop;
define syn_fparse_tag_pop;
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
  syn_stack_init (syn);                {create new empty stack, delete any old}

  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the root stack frame}

  fr_p^.level := 0;                    {init current nesting level}
  fr_p^.prev_p := nil;                 {no previous stack frame}
  fr_p^.frame_lev_p := nil;            {no previous level start}
  fr_p^.frame_save_p := nil;           {no previous saved state}
  fr_p^.frame_tag_p := nil;            {not in a tag}
  fr_p^.tent_p := nil;                 {init to no curr syntax tree entry}
  fr_p^.pos := syn.pos_start;          {init input stream reading position}
  fr_p^.case := syn_charcase_asis_k;   {init to default char case interpretation}
  fr_p^.tagged := false;               {nothing tagged yet}

  syn.parse_p := fr_p;                 {set this frame as the current state}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_LEVEL (SYN, TLEV_P)
*
*   Push a frame on the stack for the start of a new syntax level.  TLEV_P
*   points to the syntax tree entry for the start of the new level.
*
*   The new stack frame will be created, initialized, and made the current
*   frame.
}
procedure syn_fparse_level (           {create stack frame for new syntax level}
  in out  syn: syn_t;                  {SYN library use state}
  in      tlev_p: syn_tent_p_t);       {to tree entry starting the new level}
  val_param;

var
  fr_p: syn_fparse_p_t;                {pointer to the new stack frame}

begin
  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the new stack frame}

  fr_p^.level := syn.parse_p^.level + 1; {nested one more level down}
  fr_p^.prev_p := syn.parse_p;         {point back to previous stack frame}
  fr_p^.frame_lev_p := fr_p;           {this frame will be start of current level}
  fr_p^.frame_save_p := syn.parse_p^.frame_save_p; {pointer to last explicit save}
  fr_p^.frame_tag_p := syn.parse_p^.frame_tag_p; {pointer to tag start, if any}
  fr_p^.tent_p := tlev_p;              {point to syn tree entry starting this level}
  fr_p^.pos := syn.parse_p^.pos;       {init input stream parsing position}
  fr_p^.case := syn.parse_p^.case;     {init current char case interpretation}
  fr_p^.tagged := false;               {nothing tagged yet this level}

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
  fr_p^.frame_tag_p := syn.parse_p^.frame_tag_p; {pointer to tag start, if any}
  fr_p^.tent_p := syn.parse_p^.tent_p; {init pointer to current syntax tree entry}
  fr_p^.pos := syn.parse_p^.pos;       {init input stream parsing position}
  fr_p^.case := syn.parse_p^.case;     {init current char case interpretation}
  fr_p^.tagged := false;               {nothing tagged yet since this save}

  syn.parse_p := fr_p;                 {the current state is now in this new frame}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_TAG (SYN, TTAG_P)
*
*   Create a new temporary state stack frame for the start of a tag.  TTAG_P
*   must point to the syntax tree entry for the start of the tag.
}
procedure syn_fparse_tag (             {create stack frame for start of tagged input}
  in out  syn: syn_t;                  {SYN library use state}
  in      ttag_p: syn_tent_p_t);       {to syntax tree entry for this tag}
  val_param;

var
  fr_p: syn_fparse_p_t;                {pointer to the new stack frame}

begin
  syn_stack_push (syn, sizeof(fr_p^), fr_p); {create the new stack frame}

  fr_p^.level := syn.parse_p^.level;   {staying within same nesting level}
  fr_p^.prev_p := syn.parse_p;         {point back to previous stack frame}
  fr_p^.frame_lev_p := syn.parse_p^.frame_lev_p; {to start of current level}
  fr_p^.frame_save_p := syn.parse_p^.frame_save_p; {to last explicit save}
  fr_p^.frame_tag_p := fr_p;           {this frame is the last tag start}
  fr_p^.tent_p := ttag_p;              {pointer to the tag start syntax tree entry}
  fr_p^.pos := syn.parse_p^.pos;       {init input stream parsing position}
  fr_p^.case := syn.parse_p^.case;     {init current char case interpretation}
  fr_p^.tagged := true;                {there is now a tag since start of level}

  syn.parse_p := fr_p;                 {the current state is now in this new frame}
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
  old_p: syn_fparse_p_t;               {points to previous frame before this level}

begin
  lev_p := syn.parse_p^.frame_lev_p;   {point to frame that started this level}
  if lev_p = nil then return;          {not in a level ?}
  old_p := lev_p^.prev_p;              {point to frame before this level}
  if old_p = nil then return;          {no previous frame (shouldn't happen) ?}

  if match
    then begin                         {update old state to the current}
      old_p^.pos := syn.parse_p^.pos;  {update to current input stream position}
      if syn.parse_p^.tagged
        then begin                     {tags created, keep the new level}
          old_p^.tent_p := lev_p^.tent_p^.lev_up_p; {continue on after link}
          old_p^.tagged := true;
          end
        else begin                     {not tags created, delete new tree entries}
          syn_tree_trunc (syn, old_p^.tent_p); {restore original syntax tree}
          end
        ;
      end
    else begin                         {completely restore to the old state}
      syn_tree_trunc (syn, old_p^.tent_p); {restore original syntax tree}
      end
    ;

  syn.parse_p := old_p;                {go back to the old stack frame}
  syn_stack_popback (syn, lev_p);      {pop the frames off the temp state stack}
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
  old_p: syn_fparse_p_t;               {points to original state that was saved}

begin
  save_p := syn.parse_p^.frame_save_p; {point to frame to remove}
  if save_p = nil then return;         {not in temp saved state ?}
  old_p := save_p^.prev_p;             {point to frame with saved state}
  if old_p = nil then return;          {no previous frame (shouldn't happen) ?}

  if match
    then begin                         {update old state to the current}
      old_p^.pos := syn.parse_p^.pos;  {update to current input stream position}
      if syn.parse_p^.tagged           {tagged data since save ?}
        then begin
          old_p^.tagged := true;       {indicate there is tagged data}
          old_p^.tent_p := syn.parse_p^.tent_p; {continue with existing syntax tree}
          end
        else begin
          syn_tree_trunc (syn, old_p^.tent_p); {restore original syntax tree}
          end
        ;
      if old_p^.level = syn.parse_p^.level then begin {popping within same level ?}
        old_p^.case := syn.parse_p^.case; {update to current char case interpretation}
        end;
      old_p^.tagged := old_p^.tagged or syn.parse_p^.tagged; {update tagged state}
      end
    else begin                         {completely restore to the old state}
      syn_tree_trunc (syn, old_p^.tent_p); {restore original syntax tree}
      end
    ;

  syn.parse_p := old_p;                {go back to the old stack frame}
  syn_stack_popback (syn, save_p);     {pop the frames off the temp state stack}
  end;
{
********************************************************************************
*
*   Subroutine SYN_FPARSE_TAG_POP (SYN, MATCH)
*
*   Pop the state off the temporary state stack to before the last tag start.
*
*   MATCH indicates whether the input stream matched the syntax definition.
*
*   When MATCH is TRUE, then the orginal state before this level is updated to
*   the current state, and nothing is done to the syntax tree.
*
*   When MATCH is FALSE, then the original state before this level is restored.
*   The syntax tree is also restored to what it was when this level was entered.
}
procedure syn_fparse_tag_pop (         {pop tag from the stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {TRUE save/update state, FALSE restore state}
  val_param;

var
  tag_p: syn_fparse_p_t;               {points to frame after saved state}
  old_p: syn_fparse_p_t;               {points to original state that was saved}

begin
  tag_p := syn.parse_p^.frame_tag_p;   {point to frame to remove}
  if tag_p = nil then return;          {not in a tag ?}
  old_p := tag_p^.prev_p;              {point to frame with saved state}
  if old_p = nil then return;          {no previous frame (shouldn't happen) ?}

  if match
    then begin                         {update old state to the current}
      old_p^.pos := syn.parse_p^.pos;  {update to current input stream position}
      old_p^.tagged := true;           {there is now tagged data here}
      if old_p^.level = syn.parse_p^.level then begin {popping within same level ?}
        old_p^.case := syn.parse_p^.case; {update to current char case interpretation}
        end;
      old_p^.tent_p := syn.parse_p^.tent_p; {continue with existing syntax tree}
      end
    else begin                         {completely restore to the old state}
      syn_tree_trunc (syn, old_p^.tent_p); {restore original syntax tree}
      end
    ;

  syn.parse_p := old_p;                {go back to the old stack frame}
  syn_stack_popback (syn, tag_p);      {pop the frames off the temp state stack}
  end;
