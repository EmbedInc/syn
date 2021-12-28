{   Routines that access the syntax tree.
}
module syn_tree;
define syn_tree_init;
define syn_tree_del;
define syn_tree_ent_add;
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
  syn.sytree_last_p := nil;
  syn.tent_unused_p := nil;            {there is no chain of unused entries}
  end;
{
********************************************************************************
*
*   Local subroutine SYN_TREE_ENT_ALLOC (SYN, ENT_P)
*
*   Effectively allocate a new syntax tree entry descriptor, and return ENT_P
*   pointing to it.
*
*   New memory is only actually allocated when a previously-allocated but unused
*   descriptor is not available.  Otherwise, unused descriptors are re-used.
}
procedure syn_tree_ent_alloc (         {allocate new syntax tree entry descriptor}
  in out  syn: syn_t;                  {SYN library use state}
  out     ent_p: syn_tent_p_t);        {returned pointer to the new descriptor}
  val_param; internal;

begin
  if syn.tent_unused_p = nil
    then begin                         {no unused entry available, create new}
      util_mem_grab (                  {allocate memory for the new entry}
        sizeof(ent_p^),                {amount of memory to allocate}
        syn.mem_tree_p^,               {memory context to allocate under}
        false,                         {won't individually deallocate this mem}
        ent_p);                        {returned pointer to the new memory}
      end
    else begin                         {grab an unused entry}
      ent_p := syn.tent_unused_p;      {get pointer to first unused entry}
      syn.tent_unused_p := ent_p^.next_p; {update pointer to next unused entry}
      end
    ;
  end;
{
********************************************************************************
*
*   Local subroutine SYN_TREE_ENT_DEALLOC (SYN, ENT_P)
*
*   Effectively deallocate the syntax tree entry descriptor pointed to by ENT_P.
*   ENT_P is returned NIL.
*
*   Unused syntax tree entries are not actually deallocated.  Instead, they are
*   placed on the unused list.  When a new entry is required, it is taken from
*   the unused list when possible.  New memory is only allocated when there are
*   no unused entries to re-use.
}
procedure syn_tree_ent_dealloc (       {deallocate syntax tree entry descriptor}
  in out  syn: syn_t;                  {SYN library use state}
  in out  ent_p: syn_tent_p_t);        {pointer to entry to dealloc, returned NIL}
  val_param; internal;

begin
  ent_p^.next_p := syn.tent_unused_p;  {link to start of unused list}
  syn.tent_unused_p := ent_p;
  ent_p := nil;                        {pointer to this entry is no longer valid}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_ENT_ADD (SYN, ENT_P)
*
*   Create a new syntax tree entry.  ENT_P will be returned pointing to the new
*   entry.  The new entry will be linked to the tree after the current entry,
*   but otherwise uninitialized.
}
procedure syn_tree_ent_add (           {make new syntax tree entry after curr}
  in out  syn: syn_t;                  {SYN library use state}
  out     ent_p: syn_tent_p_t);        {returned pointer to the new entry}
  val_param;

begin
  syn_tree_ent_alloc (syn, ent_p);     {allocate memory for the descriptor}

  if syn.sytree_p = nil then begin     {this entry starts the syntax tree ?}
    syn.sytree_p := ent_p;
    end;
  ent_p^.back_p := syn.sytree_last_p;  {point back to last-created entry}
  syn.sytree_last_p := ent_p;          {new entry is now the last-created}
  ent_p^.next_p := nil;                {init to no following entry at this level}
  syn.parse_p^.tent_p^.next_p := ent_p; {new entry is next after current entry}
  end;
{
********************************************************************************
*
*   Local subroutine SYN_TREE_ENT_DEL_LAST (SYN)
*
*   Delete the most recently created entry from the syntax tree.  The entry is
*   removed and the tree state updated.
}
procedure syn_tree_ent_del_last (      {delete last-created syntax tree entry}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; internal;

var
  ent_p: syn_tent_p_t;                 {pointer to entry to delete}

begin
  ent_p := syn.sytree_last_p;          {get pointer to the entry to delete}
  if ent_p = nil then return;          {no entry to delete, nothing to do ?}

  syn.sytree_last_p := ent_p^.back_p;  {update pointer to new last entry}
  if syn.sytree_last_p = nil then begin {the tree is now empty ?}
    syn.sytree_p := nil;
    end;

  syn_tree_ent_dealloc (syn, ent_p);   {deallocate this entry descriptor}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_DEL_AFTER (SYN, ENT_P)
*
*   Delete all the syntax tree entries created after ENT_P.  If the current
*   entry is deleted, then the entry at ENT_P will become the current.
}
procedure syn_tree_del_after (         {delete all past specific tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in      ent_p: syn_tent_p_t);        {last entry to keep, delete all after}
  val_param;

begin
  if ent_p = nil then return;          {nothing to delete ?}

  while syn.sytree_last_p <> ent_p do begin {loop until ENT_P points to last entry}
    if syn.sytree_last_p = nil then return; {didn't find entry, internal error ?}
    if syn.parse_p^.tent_p = syn.sytree_last_p then begin {last entry is the curent ?}
      syn.parse_p^.tent_p := ent_p;    {switch current to what will be last entry}
      end;
    syn_tree_ent_del_last (syn);       {delete the last entry}
    end;                               {back to check the new last entry}
  end;
