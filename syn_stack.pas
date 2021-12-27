{   Routines for managing the temporary state stack.
*
*   This stack is used to retain nesting information during parsing, and during
*   traversing of the syntax tree.  Each of these uses are separate, but do not
*   occur at the same time.
}
module syn_stack;
define syn_stack_init;
define syn_stack_del;
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
  end;
