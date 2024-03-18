{   Low level routines for managing the temporary state stack.
*
*   This stack is used to retain nesting information during parsing, and during
*   traversing of the syntax tree.  Each of these uses are separate, but do not
*   occur at the same time.
}
module syn_stack;
define syn_stack_init;
define syn_stack_del;
define syn_stack_push;
define syn_stack_pop;
define syn_stack_popback;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_STACK_INIT (SYN)
*
*   Set up the stack ready for use.  Any previously existing stack is deleted
*   first.
}
procedure syn_stack_init (             {create temp state stack, ready for use}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  syn_stack_del (syn);                 {make sure any existing stack is deleted}

  util_stack_alloc (                   {create the stack}
    syn.mem_p^,                        {parent memory context}
    syn.stack);                        {returned handle to the new stack}
  syn.stack_exist := true;             {indicate that the stack exists}
  end;
{
********************************************************************************
*
*   Subroutine SYN_STACK_DEL (SYN)
*
*   Delete the temporary state stack, if it exists.  The stack is guaranteed not
*   to exist after this call.
}
procedure syn_stack_del (              {delete temp state stack, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if not syn.stack_exist then return;  {stack doesn't exist, nothing to do ?}

  util_stack_dalloc (syn.stack);       {delete the temp state stack}
  syn.stack_exist := false;            {indicate the stack does not exist}
  syn.parse_p := nil;                  {invalidate pointers into stack}
  syn.travstk_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine SYN_STACK_PUSH (SYN, SIZE, FRAME_P)
*
*   Create space for a new frame on the stack.  SIZE is the size required of the
*   new frame in bytes.  FRAME_P is returned pointing to the new frame.
}
procedure syn_stack_push (             {push new frame onto the stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      size: sys_int_adr_t;         {size to reserve for new data}
  out     frame_p: univ_ptr);          {returned pointer to the new frame}
  val_param;

begin
  util_stack_push (                    {create the new space on the stack}
    syn.stack,                         {handle to the stack}
    size,                              {amount of space to add to top of stack}
    frame_p);                          {returned pointer to the new space}
  end;
{
********************************************************************************
*
*   Subroutine SYN_STACK_POP (SYN, SIZE)
*
*   Remove the frame of SIZE bytes from the top of the stack.
}
procedure syn_stack_pop (              {pop the last frame off the stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      size: sys_int_adr_t);        {size of data to remove from stack}
  val_param;

begin
  util_stack_pop (                     {remove memory from the top of the stack}
    syn.stack,                         {handle to the stack}
    size);                             {amount of memory to remove}
  end;
{
********************************************************************************
*
*   Subroutine SYN_STACK_POPBACK (SYN, P)
*
*   Pop the stack so that the frame at P and all subsequent frames are removed.
}
procedure syn_stack_popback (          {pop stack back to specific location}
  in out  syn: syn_t;                  {SYN library use state}
  in      p: univ_ptr);                {to frame to pop, and all its successors}
  val_param;

begin
  util_stack_popto (                   {pop stack back to specific location}
    syn.stack,                         {handle to the stack}
    p);                                {pointer to last location to remove}
  end;
