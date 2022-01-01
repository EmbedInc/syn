{   High level library management.
}
module syn_lib;
define syn_lib_new;
define syn_lib_end;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_LIB_NEW (MEM, SYN_P)
*
*   Create a new use of the SYN library.  MEM is the parent memory context all
*   new dynamic memory for the new library use will be allocated under.  A
*   subordinate memory context for the library use is created.  SYN_P is
*   returned the pointer to the new library use state.
}
procedure syn_lib_new (                {create new use of the SYN library}
  in out  mem: util_mem_context_t;     {parent mem context, will create subordinate}
  out     syn_p: syn_p_t);             {pointer to new SYN library use state}
  val_param;

var
  mem_p: util_mem_context_p_t;         {pointer to private mem context for the new use}

begin
{
*   Allocate memory for the new data structures.
}
  util_mem_context_get (mem, mem_p);   {create new subordinate memory context}
  util_mem_grab (                      {allocate state block under the new context}
    sizeof(syn_p^), mem_p^, false, syn_p);
{
*   Fill in the new library use state.
}
  syn_p^.mem_p := mem_p;
  syn_p^.mem_tree_p := nil;
  syn_p^.sytree_p := nil;
  syn_p^.sytree_last_p := nil;
  syn_p^.names := false;
  syn_p^.stack_exist := false;

  syn_p^.tent_unused_p := nil;
  syn_p^.pos_start.line_p := nil;
  syn_p^.pos_start.ind := 0;
  syn_p^.pos_err.line_p := nil;
  syn_p^.pos_err.ind := 0;
  syn_p^.err := false;
  syn_p^.parse_p := nil;
  syn_p^.parsefunc_p := nil;

  syn_p^.tent_p := nil;
  syn_p^.travstk_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine SYN_LIB_END (SYN_P)
*
*   End a use of the SYN library.  System resources associated with the library
*   use will be deallocated.  SYN_P is returned invalid.
}
procedure syn_lib_end (                {end a use of the SYN library}
  in out  syn_p: syn_p_t);             {handle to library use state, returned invalid}
  val_param;

var
  mem_p: util_mem_context_p_t;         {saved pointer to private memory context}

begin
  mem_p := syn_p^.mem_p;               {save pointer to the private memory context}

  syn_stack_del (syn_p^);              {delete temp state stack, if it exists}
  syn_names_del (syn_p^);              {delete syntax names table, if it exists}
  syn_tree_del (syn_p^);               {delete syntax tree, if it exists}

  util_mem_context_del (mem_p);        {dealloc all mem used by this lib use}
  syn_p := nil;                        {return the handle as invalid}
  end;
