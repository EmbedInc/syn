{   Routines that access the syntax tree.
}
module syn_tree;
define syn_tree_init;
define syn_tree_del;
define syn_tree_add_sub;
define syn_tree_add_tag;
define syn_tree_add_err;
define syn_tree_add_end;
define syn_tree_trunc;
%include 'syn2.ins.pas';
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
*   Entries are re-used in the order they are chained onto the free list.
}
procedure syn_tree_ent_alloc (         {allocate new syntax tree entry descriptor}
  in out  syn: syn_t;                  {SYN library use state}
  out     ent_p: syn_tent_p_t);        {returned pointer to the new descriptor}
  val_param; internal;

begin
  if syn.tent_free_p = nil
    then begin                         {no unused entry available, create new}
      util_mem_grab (                  {allocate memory for the new entry}
        sizeof(ent_p^),                {amount of memory to allocate}
        syn.mem_tree_p^,               {memory context to allocate under}
        false,                         {won't individually deallocate this mem}
        ent_p);                        {returned pointer to the new memory}
      end
    else begin                         {grab an unused entry}
      ent_p := syn.tent_free_p;        {get pointer to first unused entry}
      syn.tent_free_p := ent_p^.next_p; {update pointer to next unused entry}
      if syn.tent_free_p = nil then begin {unused entries list is now empty ?}
        syn.tent_free_last_p := nil;
        end;
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
*   placed on the free entries list.  When a new entry is required, it is taken
*   from the free list when possible.  New memory is only allocated when there
*   are no unused entries to re-use.
*
*   New entries are added to the end of the free list.  Since entries are
*   usually deallocated in tree order, this leaves the oldest entry at the start
*   of the list.  This oldest entry will be re-used first.  The purpose of this
*   is to possibly have a slight benefit in use of dynamic memory.  If a deep
*   tree is temporarily created, the "far" entries won't be immediately re-used.
*   The more heavily accessed earlier entries will be re-used first.
}
procedure syn_tree_ent_dealloc (       {deallocate syntax tree entry descriptor}
  in out  syn: syn_t;                  {SYN library use state}
  in out  ent_p: syn_tent_p_t);        {pointer to entry to dealloc, returned NIL}
  val_param; internal;

begin
  ent_p^.next_p := nil;                {no following entry, will be at end of list}

  if syn.tent_free_last_p = nil
    then begin                         {this will be first free list entry}
      syn.tent_free_p := ent_p;
      end
    else begin                         {link to end of existing free list}
      syn.tent_free_last_p^.next_p := ent_p;
      end
    ;

  syn.tent_free_last_p := ent_p;       {update pointer to last entry in list}
  ent_p := nil;                        {pointer to this entry is no longer valid}
  end;
{
********************************************************************************
*
*   Local subroutine SYN_TREE_ENT_ADD (SYN, ENT_P)
*
*   Create a new syntax tree entry.  ENT_P will be returned pointing to the new
*   entry.  Only the following fields will be filled in or initialized:
*
*     NEXT_P  -  Initialized to NIL as a convenience.
*
*     POS  -  Initialized to the current parsing position if there is one.
*
*   All other fields are uninitialized.
}
procedure syn_tree_ent_add (           {make new syntax tree entry after curr}
  in out  syn: syn_t;                  {SYN library use state}
  out     ent_p: syn_tent_p_t);        {returned pointer to the new entry}
  val_param; internal;

begin
  syn_tree_ent_alloc (syn, ent_p);     {allocate memory for the descriptor}
  ent_p^.next_p := nil;                {init to no following entry at this level}
  if syn.parse_p = nil
    then begin                         {current position is not available}
      ent_p^.pos.line_p := nil;        {not on a particular line}
      ent_p^.pos.ind := -1;            {indicate before any data}
      end
    else begin                         {there is a current position}
      ent_p^.pos := syn.parse_p^.pos;  {init to at current parsing position}
      end
    ;
  end;
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

var
  ent_p: syn_tent_p_t;                 {pointer to new root syntax tree entry}

begin
  syn_tree_del (syn);                  {delete the existing tree, if any}

  util_mem_context_get (               {create the mem context for the tree}
    syn.mem_p^, syn.mem_tree_p);

  syn_tree_ent_add (syn, ent_p);       {create the root entry}
  ent_p^.back_p := nil;                {there is no previous entry}
  ent_p^.levst_p := ent_p;             {this entry starts this level}
  ent_p^.ttype := syn_ttype_lev_k;     {this entry starts a syntax level}
  ent_p^.level := 0;                   {nesting level}
  ent_p^.lev_up_p := nil;              {there is no parent level}
  ent_p^.lev_name_p := nil;            {root level has no name}

  syn.sytree_p := ent_p;               {save pointer to root entry that starts tree}
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
  syn.tent_free_p := nil;              {there is no chain of unused entries}
  syn.tent_free_last_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_ADD_SUB (SYN, PAR, NAME_P, LEV_P)
*
*   Start a new subordinate syntax tree level after the entry PAR.  NAME_P
*   points to the name string for this new level.  LEV_P will be returned
*   pointing to the tree entry that starts the new level.
}
procedure syn_tree_add_sub (           {add subordinate level to syntax tree}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  in      name_p: string_var_p_t;      {pointer to name of new level, if any}
  out     lev_p: syn_tent_p_t);        {returned pointer to start of new level}
  val_param;

var
  sub_p: syn_tent_p_t;                 {to new entry that links to sub level}

begin
  syn_tree_ent_add (syn, sub_p);       {create descriptor for the link entry}
  sub_p^.back_p := addr(par);          {point back to previous entry}
  syn_tree_ent_add (syn, lev_p);       {create descriptor for start of new level}
  lev_p^.back_p := sub_p;              {point back to parent entry}

  par.next_p := sub_p;                 {link immediately follows parent entry}

  sub_p^.levst_p := par.levst_p;       {link is at same level as parent}
  sub_p^.ttype := syn_ttype_sub_k;     {this entry is link to subordinate level}
  sub_p^.sub_p := lev_p;               {point down to start of the new level}

  lev_p^.levst_p := lev_p;             {this entry is the start of this level}
  lev_p^.ttype := syn_ttype_lev_k;     {this entry starts a level}
  lev_p^.level := par.levst_p^.level + 1; {depth this level is nested}
  lev_p^.lev_up_p := sub_p;            {point to link entry in parent level}
  lev_p^.lev_name_p := name_p;         {point to name for this level}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_ADD_TAG (SYN, PAR, ID, CPOS, TAG_P)
*
*   Add a syntax tree entry for a tagged item.  PAR is the parent syntax tree
*   entry to append to.  ID is the ID for the tag.  CPOS is the starting input
*   stream position for the tagged string.  The ending position will also be
*   initialized to CPOS.  TAG_P is returned pointing to the new syntax tree
*   entry.
}
procedure syn_tree_add_tag (           {add syntax tree entry for tagged item}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  in      id: sys_int_machine_t;       {tag ID}
  in      cpos: fline_cpos_t;          {tagged string start position}
  out     tag_p: syn_tent_p_t);        {returned pointer to new syntax tree entry}
  val_param;

begin
  syn_tree_ent_add (syn, tag_p);       {create descriptor for the new tree entry}
  tag_p^.back_p := addr(par);          {point back to previous entry}
  par.next_p := tag_p;                 {link to from parent tree entry}

  tag_p^.levst_p := par.levst_p;       {point to entry for start of this level}
  tag_p^.pos := cpos;                  {save input stream position here}
  tag_p^.ttype := syn_ttype_tag_k;     {this entry is for tagged input string}
  tag_p^.tag := id;                    {save tag ID}
  tag_p^.tag_af := cpos;               {init ending input stream position}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_ADD_ERR (SYN, PAR, CPOS, ERR_P)
*
*   Add the syntax tree entry for the error end of syntax.  PAR is the parent
*   tree entry to append to.  CPOS is the input stream position of the error.
*   ERR_P is returned pointing to the new syntax tree entry.
}
procedure syn_tree_add_err (           {add error end of syntax entry to syn tree}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  in      cpos: fline_cpos_t;          {error position in input stream}
  out     err_p: syn_tent_p_t);        {returned pointer to the new syn tree entry}
  val_param;

begin
  syn_tree_ent_add (syn, err_p);       {create descriptor for the new tree entry}
  err_p^.back_p := addr(par);          {point back to previous entry}
  par.next_p := err_p;                 {link to from parent tree entry}

  err_p^.levst_p := par.levst_p;       {point to entry for start of this level}
  err_p^.pos := cpos;                  {save input stream position of the error}
  err_p^.ttype := syn_ttype_err_k;     {this entry is for error end of syntax}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_ADD_END (SYN, PAR, END_P)
*
*   Add the syntax tree entry to end the current syntax level.  PAR is the
*   syntax tree entry to append to.  END_P is returned pointing to the new
*   syntax tree entry.
}
procedure syn_tree_add_end (           {add end of level entry to syntax tree}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  out     end_p: syn_tent_p_t);        {returned pointer to the new syn tree entry}
  val_param;

begin
  syn_tree_ent_add (syn, end_p);       {create descriptor for the new tree entry}
  end_p^.back_p := addr(par);          {point back to previous entry}
  par.next_p := end_p;                 {link to from parent tree entry}

  end_p^.levst_p := par.levst_p;       {point to entry for start of this level}
  end_p^.ttype := syn_ttype_end_k;     {indicate end of this syntax level}
  end;
{
********************************************************************************
*
*   Subroutine SYN_TREE_TRUNC (SYN, ENT)
*
*   Truncate the syntax tree so that there are no entries following ENT at the
*   same level.
}
procedure syn_tree_trunc (             {truncate tree past specific entry}
  in out  syn: syn_t;                  {SYN library use state}
  in out  ent: syn_tent_t);            {last entry to keep, delete all after}
  val_param;

var
  next_p: syn_tent_p_t;                {pointer to next entry to delete}
  del_p: syn_tent_p_t;                 {pointer to current entry to delete}

begin
  del_p := ent.next_p;                 {init pointer to first entry to delete}
  while del_p <> nil do begin          {loop over chain of entries}
    case del_p^.ttype of               {what kind of entry is this ?}
syn_ttype_sub_k: begin                 {this entry points to subordinate level}
        syn_tree_trunc (syn, del_p^.sub_p^); {dealloc sub level}
        syn_tree_ent_dealloc (syn, del_p^.sub_p) ; {dealloc LEV entry}
        end;
      end;
    next_p := del_p^.next_p;           {save pointer to next entry to delete}
    syn_tree_ent_dealloc (syn, del_p); {deallocate this entry}
    del_p := next_p;                   {update pointer to new entry to delete}
    end;                               {back to delete this new entry}
  ent.next_p := nil;                   {there are now no following entries}
  end;
