{   Private include file for the CALC program.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'fline.ins.pas';
%include 'syn.ins.pas';
%include 'builddate.ins.pas';

const
  nhashbuck = 32;                      {number of buckets in symbol hash table, 2^N}
  symlen = 32;                         {max symbol length, characters}

type
  symdat_p_t = ^symdat_t;
  symdat_t = record                    {data for each symbol table entry}
    var_val: double;                   {variable value}
    end;

var (calc)
  mem_p: util_mem_context_p_t;         {to our private memory context}
  fline_p: fline_p_t;                  {to FLINE library use state}
  coll_p: fline_coll_p_t;              {the input file lines in FLINE collection}
  syn_p: syn_p_t;                      {to SYN library use state}
  symtab_h: string_hash_handle_t;      {handle to symbol table}
  currval: double;                     {current calculator value}

procedure calc_cmline;                 {read command line, set global state accordingly}
  val_param; extern;

procedure calc_prog_init;              {initialize global program state}
  val_param; extern;

procedure calc_sym_dat (               {get data on symbol, create if not existing}
  in      name: univ string_var_arg_t; {symbol name}
  out     dat_p: symdat_p_t);          {returned pointer to symbol data}
  val_param; extern;

procedure calc_sym_get (               {get data on existing symbol}
  in      name: univ string_var_arg_t; {name of symbol to look up}
  out     dat_p: symdat_p_t);          {pointer to symbol data, NIL on not found}
  val_param; extern;

function calc_sym_valid (              {check for symbol name being valid}
  in      name: univ string_var_arg_t) {symbol name to check}
  :boolean;                            {symbol name is valid}
  val_param; extern;
