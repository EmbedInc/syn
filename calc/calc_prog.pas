{   Global program management.
}
module calc_prog;
define calc_prog_init;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Subroutine CALC_PROG_INIT
*
*   Initialize the global program state.
}
procedure calc_prog_init;              {initialize global program state}
  val_param;

begin
  util_mem_context_get (util_top_mem_context, mem_p); {create our private mem context}
  util_mem_context_err_bomb (mem_p);   {bomb on didn't get mem context}

  fline_p := nil;
  coll_p := nil;
  syn_p := nil;

  string_hash_create (                 {create symbol table}
    symtab_h,                          {hash table to initialize}
    nhashbuck,                         {number of buckets in hash table}
    symlen,                            {max suppoted symbol name length}
    sizeof(symdat_t),                  {size of data for each table entry}
    [],                                {no special configuration}
    mem_p^);                           {parent memory context}

  currval := 0.0;
  end;
