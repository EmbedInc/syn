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

  valtype_k_t = (                      {types of numeric values}
    valtype_int_k,                     {integer}
    valtype_fp_k);                     {floating point}

  val_t = record                       {one numeric value}
    valtype: valtype_k_t;              {type of this value}
    case valtype_k_t of
valtype_int_k: (                       {integer}
      int: sys_int_machine_t;
      );
valtype_fp_k: (                        {floating point}
      fp: double;
      );
    end;

var (calc)
  mem_p: util_mem_context_p_t;         {to our private memory context}
  fline_p: fline_p_t;                  {to FLINE library use state}
  coll_p: fline_coll_p_t;              {the input file lines in FLINE collection}
  syn_p: syn_p_t;                      {to SYN library use state}
  symtab_h: string_hash_handle_t;      {handle to symbol table}
  currval: val_t;                      {current calculator value}
  trace: boolean;                      {syntax trace debug outputs enabled}
  err: boolean;                        {error, abort processing of current line}
  quit: boolean;                       {end the program}

procedure calc_cmline;                 {read command line, set global state accordingly}
  val_param; extern;

procedure calc_in_get (                {get new input lines, COLL_P will pnt to result}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure calc_proc_command;           {process the COMMAND syntax}
  val_param; extern;

procedure calc_proc_expression (       {process the EXPRESSION syntax, return the value}
  out     v: val_t);                   {the resulting value}
  val_param; extern;

procedure calc_proc_number (           {process NUMBER syntax, return the number}
  out     v: val_t);                   {the resulting value}
  val_param; extern;

procedure calc_proc_oneline;           {process the ONELINE syntax}
  val_param; extern;

procedure calc_proc_symbol (           {get/validate sym name, curr ent is tagged sym}
  out     name: univ string_var_arg_t);
  val_param; extern;

procedure calc_proc_value (            {process VALUE syntax, return the value}
  out     v: val_t);                   {the resulting value}
  val_param; extern;

procedure calc_process;                {process input lines pointed to by COLL_P}
  val_param; extern;

procedure calc_prog_init;              {initialize global program state}
  val_param; extern;

procedure calc_prog_start;             {initialize and start basic program operation}
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

procedure calc_val_default (           {set a calculator value to global default}
  out     v: val_t);                   {value to set to default}
  val_param; extern;

function calc_val_fp (                 {get floating point value}
  in      v: val_t)                    {to get floating point value of}
  :double;
  val_param; extern;

procedure calc_val_make_fp (           {make value floating point, if not already}
  in out  v: val_t);                   {value to make floating point}
  val_param; extern;

procedure calc_val_set_fp (            {set calc value to floating point}
  in      fp: double;                  {the floating point value to set it to}
  out     v: val_t);                   {resulting calculator value descriptor}
  val_param; extern;

procedure calc_val_show (              {show a calculator value}
  in      v: val_t);                   {the value to show}
  val_param; extern;

function syn_ch_oneline (              {parse one top level construction}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {TRUE iff input matched expected syntax}
  val_param; extern;