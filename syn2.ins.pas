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
procedure syn_names_del (              {delete syntax names table, if exists}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;

procedure syn_names_init (             {init syntax names symbol table to empty}
  in out  syn: syn_t);                 {SYN library use state}
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

procedure syn_tree_init (              {init syntax tree, empty, ready for use}
  in out  syn: syn_t);                 {SYN library use state}
  val_param; extern;
