{   Managing symbols and the symbol table.
}
module calc_sym;
define calc_sym_valid;
define calc_sym_get;
define calc_sym_dat;
%include 'calc.ins.pas';
{
********************************************************************************
*
*   Function CALC_SYM_VALID (NAME)
*
*   Check NAME for being a valid symbol name.  The function returns TRUE if the
*   symbol name is valid, and FALSE otherwise.
*
*   This routine assumes the symbol name has already matched the SYMBOL syntax
*   construction.  Additional tests not performed by the SYMBOL construction are
*   applied.
}
function calc_sym_valid (              {check for symbol name being valid}
  in      name: univ string_var_arg_t) {symbol name to check}
  :boolean;                            {symbol name is valid}
  val_param;

begin
  calc_sym_valid := false;             {init to symbol name is not valid}
  if name.len < 1 then return;         {name is too short ?}
  if name.len > symlen then return;    {name is too long ?}

  calc_sym_valid := true;              {symbol name passed all the tests}
  return;
  end;
{
********************************************************************************
*
*   Subroutine CALC_SYM_GET (NAME, DAT_P)
*
*   Get the data of an existing symbol.  NAME is the symbol name.  DAT_P is
*   returned pointing to the symbol data.  DAT_P is returned NIL when there is
*   no such symbol in the symbol table.
}
procedure calc_sym_get (               {get data on existing symbol}
  in      name: univ string_var_arg_t; {name of symbol to look up}
  out     dat_p: symdat_p_t);          {pointer to symbol data, NIL on not found}
  val_param;

var
  name_p: string_var_p_t;              {pointer to name string in symbol table}

begin
  string_hash_ent_lookup (             {look up name in the symbol table}
    symtab_h,                          {handle to the symbol table}
    name,                              {name to look up}
    name_p,                            {returned pointer to name string in table}
    dat_p);                            {returned pointer to symbol data, NIL on none}
  end;
{
********************************************************************************
*
*   Subroutine CALC_SYM_DAT (NAME, DAT_P)
*
*   Find the data for the symbol NAME in the symbol table.  DAT_P is returned
*   pointing to the symbol data.  The symbol is created and its data initialized
*   to default if it does not previously exist.
}
procedure calc_sym_dat (               {get data on symbol, create if not existing}
  in      name: univ string_var_arg_t; {symbol name}
  out     dat_p: symdat_p_t);          {returned pointer to symbol data}
  val_param;

var
  pos: string_hash_pos_t;              {position into symbol table}
  name_p: string_var_p_t;              {pointer to name string in symbol table}
  found: boolean;                      {symbol was found in table}

begin
  string_hash_pos_lookup (             {find position in table for symbol name}
    symtab_h,                          {handle to the symbol table}
    name,                              {name to find position for}
    pos,                               {returned position for the name}
    found);                            {TRUE iff symbol was found}

  if found then begin                  {symbol was found ?}
    string_hash_ent_atpos (            {get info on symbol at found position}
      pos,                             {position in symbol table}
      name_p,                          {returned pointer to name in table}
      dat_p);                          {returned pointer to symbol data}
    return;
    end;
{
*   The symbol does not exist.
}
  string_hash_ent_add (                {create new entry at position for this name}
    pos,                               {position to add new symbol table entry at}
    name_p,                            {returned pointer to name in symbol table}
    dat_p);                            {returned pointer to symbol data}

  dat_p^.var_val := 0.0;               {init symbol data to default}
  end;
