{   Procedural access to the list of syntax construction names.
*
*   The list is implemented as a STRING library hash table, for easy random
*   access by name.
}
module syn_names;
define syn_names_init;
define syn_names_del;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_NAMES_INIT (SYN)
*
*   Initialize the names list to be ready for use.  Any previous names list is
*   deleted first.
}
procedure syn_names_init (             {init syntax names symbol table to empty}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  syn_stack_del (syn);                 {delete any previously existing temp state stack}

  string_hash_create (                 {create the syntax construction names table}
    syn.nametab,                       {symbol table to create}
    syn_names_nbuck_k,                 {number of buckets to create}
    syn_name_maxlen_k,                 {max characters for each table entry}
    0,                                 {size of the data associated with each entry}
    [string_hashcre_nodel_k],          {we won't individually delete entries}
    syn.mem_p^);                       {parent memory context}
  syn.names := true;                   {indicate names table exists}
  end;
{
********************************************************************************
*
*   Subroutine SYN_NAMES_DEL (SYN)
*
*   Delete the syntax names table, if it exists.  The table is guaranteed to not
*   exist after this call.
}
procedure syn_names_del (              {delete syntax names table, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if not syn.names then return;        {table doesn't exist, nothing to do ?}

  string_hash_delete (syn.nametab);    {delete syntax names symbol table}
  syn.names := false;                  {indicate names table doesn't exist}
  end;
