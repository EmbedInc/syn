{   Private include file for the SYN library.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'fline.ins.pas';
%include 'syn.ins.pas';
{
*   Subroutines and functions.
}
procedure syn_fparse_init (            {init stack for parsing, delete previous contents}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_fparse_level (           {create stack frame for new syntax level}
  in out  syn: syn_t;                  {SYN library use state}
  in      name: string_var_arg_t);     {name of the new syntax level}
  val_param; extern;

procedure syn_fparse_level_pop (       {pop curr syntax level from stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {TRUE save/update state, FALSE restore state}
  val_param; extern;

procedure syn_fparse_save (            {save current parsing state on stack}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_fparse_save_pop (        {pop back to before last saved state}
  in out  syn: syn_t;                  {SYN library use state}
  in      match: boolean);             {TRUE save/update state, FALSE restore state}
  val_param; extern;

procedure syn_names_del (              {delete syntax names table, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_names_init (             {init syntax names symbol table to empty}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_names_get (              {make or find symbol table entry for a name}
  in out  syn: syn_t;                  {SYN library use state}
  in      name: string_var_arg_t;      {name to look up}
  out     name_p: string_var_p_t);     {returned pointing to name string in sym table}
  val_param; extern;

procedure syn_stack_del (              {delete temp state stack, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_stack_init (             {create temp state stack, ready for use}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_stack_pop (              {pop the last frame off the stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      size: sys_int_adr_t);        {size of data to remove from stack}
  val_param; extern;

procedure syn_stack_popback (          {pop stack back to specific location}
  in out  syn: syn_t;                  {SYN library use state}
  in      p: univ_ptr);                {to frame to pop, and all its successors}
  val_param; extern;

procedure syn_stack_push (             {push new frame onto the stack}
  in out  syn: syn_t;                  {SYN library use state}
  in      size: sys_int_adr_t;         {size to reserve for new data}
  out     frame_p: univ_ptr);          {returned pointer to the new frame}
  val_param; extern;

procedure syn_tree_del (               {delete syntax tree, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_tree_del_after (         {delete all past specific tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in out  ent_p: syn_tent_p_t);        {last entry to keep, delete all after}
  val_param; extern;

procedure syn_tree_init (              {init syntax tree, empty, ready for use}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;
