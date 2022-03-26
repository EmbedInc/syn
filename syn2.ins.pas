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
  in      tlev_p: syn_tent_p_t);       {to tree entry starting the new level}
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

procedure syn_fparse_tag (             {create stack frame for start of tagged input}
  in out  syn: syn_t;                  {SYN library use state}
  in      ttag_p: syn_tent_p_t);       {to syntax tree entry for this tag}
  val_param; extern;

procedure syn_fparse_tag_pop (         {pop tag from the stack}
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
  in      name: univ string_var_arg_t; {name to look up}
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

procedure syn_tree_add_err (           {add error end of syntax entry to syn tree}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  in      cpos: fline_cpos_t;          {error position in input stream}
  out     err_p: syn_tent_p_t);        {returned pointer to the new syn tree entry}
  val_param; extern;

procedure syn_tree_add_sub (           {add subordinate level to syntax tree}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  in      name_p: string_var_p_t;      {pointer to name of new level, if any}
  out     lev_p: syn_tent_p_t);        {returned pointer to start of new level}
  val_param; extern;

procedure syn_tree_add_tag (           {add syntax tree entry for tagged item}
  in out  syn: syn_t;                  {SYN library use state}
  in out  par: syn_tent_t;             {parent syntax tree entry}
  in      id: sys_int_machine_t;       {tag ID}
  in      cpos: fline_cpos_t;          {tagged string start position}
  out     tag_p: syn_tent_p_t);        {returned pointer to new syntax tree entry}
  val_param; extern;

procedure syn_tree_del (               {delete syntax tree, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_tree_init (              {init syntax tree, empty, ready for use}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_tree_trunc (             {truncate tree past specific entry}
  in out  syn: syn_t;                  {SYN library use state}
  in out  ent: syn_tent_t);            {last entry to keep, delete all after}
  val_param; extern;
