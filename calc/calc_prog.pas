{   Global program management.
}
module calc_prog;
define calc_prog_init;
define calc_prog_start;
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

  calc_val_default (currval);          {init current value to global default}

  trace := false;
  err := false;
  quit := false;
  end;
{
********************************************************************************
*
*   Subroutine CALC_PROG_START
*
*   Initialize and start basic program operation.  The global state must have
*   been previously initialized, and the command line read with state updated
*   accordingly.
}
procedure calc_prog_start;             {initialize and start basic program operation}
  val_param;

begin
  syn_lib_new (mem_p^, syn_p);         {start our use of the SYN library}
  end;
