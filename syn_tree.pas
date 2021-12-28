{   Routines that access the syntax tree.
}
module syn_tree;
define syn_tree_init;
define syn_tree_del;
define syn_tree_del_after;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_TREE_INIT (SYN)
*
*   Initialize the syntax tree ready for use.  Any existing syntax tree is
*   deleted first.
}
procedure syn_tree_init (              {init syntax tree, empty, ready for use}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  syn_tree_del (syn);                  {delete the existing tree, if any}

  util_mem_context_get (               {create the mem context for the tree}
    syn.mem_p^, syn.mem_tree_p);
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_DEL (SYN)
*
*   Delete the syntax tree, if it exists.  All state related to the syntax tree
*   is set for no tree existing.
}
procedure syn_tree_del (               {delete syntax tree, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if syn.mem_tree_p <> nil then begin  {memory context exists ?}
    util_mem_context_del (syn.mem_tree_p); {delete it}
    end;

  syn.sytree_p := nil;                 {there is no syntax tree entry}
  syn.tent_unused_p := nil;            {there is no chain of unused entries}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_DEL_AFTER (SYN, ENT_P)
*
*   Delete the entry at ENT_P from the syntax tree, and all following entries.
}
procedure syn_tree_del_after (         {delete all past specific tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in out  ent_p: syn_tent_p_t);        {last entry to keep, delete all after}
  val_param;

begin
  end;
