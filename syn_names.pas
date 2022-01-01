{   Procedural access to the list of syntax construction names.
*
*   The list is implemented as a STRING library hash table, for easy random
*   access by name.
}
module syn_names;
define syn_names_init;
define syn_names_del;
define syn_names_get;
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
  syn_names_del (syn);                 {delete any previously existing names table}

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
{
********************************************************************************
*
*   Subroutine SYN_NAMES_GET (SYN, NAME, NAME_P)
*
*   Set NAME_P pointing to the name NAME string in the names table.  An entry
*   for NAME is created if it does not already exist.
}
procedure syn_names_get (              {make or find symbol table entry for a name}
  in out  syn: syn_t;                  {SYN library use state}
  in      name: string_var_arg_t;      {name to look up}
  out     name_p: string_var_p_t);     {returned pointing to name string in sym table}
  val_param;

var
  pos: string_hash_pos_t;              {position within table}
  data_p: univ_ptr;                    {pointer to symbol data in names table}
  found: boolean;                      {name was found in symbol table}

begin
  string_hash_pos_lookup (             {get position for this name}
    syn.nametab,                       {handle to the symbol table}
    name,                              {symbol name to get position of}
    pos,                               {returned position for this name}
    found);                            {name was found}

  if found
    then begin                         {the name already exists in the table}
      string_hash_ent_atpos (          {get pointers to the existing entry}
        pos, name_p, data_p);
      end
    else begin                         {this name is not already in the table}
      string_hash_ent_add (            {create new entry, get pointers to it}
        pos, name_p, data_p);
      end
    ;
  end;
