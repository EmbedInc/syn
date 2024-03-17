{   Routines that emit messages to standard output.  None of these routines are
*   required to use the syntaxer, but are provided as a convenience to
*   applications.
*
*   The routines SYN_MSG_xxx unconditionally emit messages.  The routines
*   SYN_ERROR_xxx take a STAT argument (type SYS_ERR_T) and only perform their
*   action if the STAT argument indicates other than normal status.
*
*   These routines are only valid to call when the application is traversing the
*   syntax tree that was built by parsing the input stream.  In other words,
*   the routines here are for use with the SYN_TRAV_xxx routines.
}
module syn_msg;
define syn_pos_show;
define syn_msg_pos;
define syn_msg_pos_bomb;
define syn_error;
define syn_error_bomb;
define syn_msg_tag_err;
define syn_msg_tag_bomb;
%include 'syn2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYN_POS_SHOW (SYN)
*
*   Show the input stream position associated with the current syntax tree
*   entry.
}
procedure syn_pos_show (               {show input stream pos at curr tree entry}
  in out  syn: syn_t);                 {SYN library use state}
  val_param;

begin
  if syn.tent_p = nil then begin       {no current syntax tree entry ?}
    sys_message_bomb ('syn', 'no_tree_entry', nil, 0);
    end;

  fline_cpos_show (syn.tent_p^.pos);
  end;
{
********************************************************************************
*
*   Subroutine SYN_MSG_POS (SYN, SUBSYS, MSG, PARMS, NPARMS)
*
*   Write the message indicated by SUBSYS, MSG, PARMS, and NPARMS, then show the
*   input stream position of the current syntax tree entry.
}
procedure syn_msg_pos (                {show input stream pos at curr tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in      subsys: string;              {subsystem name of caller's message}
  in      msg: string;                 {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      nparms: sys_int_machine_t);  {number of parameters in PARMS}
  val_param;

begin
  sys_message_parms (subsys, msg, parms, nparms); {write user's message}
  syn_pos_show (syn);                  {show input stream position}
  end;
{
********************************************************************************
*
*   Subroutine SYN_MSG_POS_BOMB (SYN, SUBSYS, MSG, PARMS, NPARMS)
*
*   Like SYN_MSG_POS, but bombs the program after the messages are written.
*   This routine never returns.
}
procedure syn_msg_pos_bomb (           {show input stream pos at curr tree entry}
  in out  syn: syn_t;                  {SYN library use state}
  in      subsys: string;              {subsystem name of caller's message}
  in      msg: string;                 {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      nparms: sys_int_machine_t);  {number of parameters in PARMS}
  options (val_param, noreturn);

begin
  syn_msg_pos (syn, subsys, msg, parms, nparms);
  sys_bomb;
  end;
{
********************************************************************************
*
*   Subroutine SYN_ERROR (SYN, STAT, SUBSYS, MSG, PARMS, NPARMS)
*
*   If STAT indicates error, write the message indicated by SUBSYS, MSG, PARMS,
*   and NPARMS, then show the input stream location associated with the current
*   syntax tree entry.  Nothing is done if STAT indicates normal status.
}
procedure syn_error (                  {show msg and curr position on error}
  in out  syn: syn_t;                  {SYN library use state}
  in      stat: sys_err_t;             {error status}
  in      subsys: string;              {subsystem name of caller's message}
  in      msg: string;                 {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      nparms: sys_int_machine_t);  {number of parameters in PARMS}
  val_param;

begin
  if not sys_error(stat) then return;  {no error, nothing to do ?}

  sys_error_print (stat, subsys, msg, parms, nparms); {write STAT and user messages}
  syn_pos_show (syn);                  {show current input stream position}
  end;
{
********************************************************************************
*
*   Subroutine SYN_ERROR_BOMB (SYN, STAT, SUBSYS, MSG, PARMS, NPARMS)
*
*   If STAT indicates error, write the message indicated by SUBSYS, MSG, PARMS,
*   and NPARMS, show the input stream location associated with the current
*   syntax tree entry, then bomb the program.  Nothing is done if STAT indicates
*   normal status.
}
procedure syn_error_bomb (             {show msg and curr position on error}
  in out  syn: syn_t;                  {SYN library use state}
  in      stat: sys_err_t;             {error status}
  in      subsys: string;              {subsystem name of caller's message}
  in      msg: string;                 {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      nparms: sys_int_machine_t);  {number of parameters in PARMS}
  val_param;

begin
  if not sys_error(stat) then return;  {no error, nothing to do ?}

  syn_error (syn, stat, subsys, msg, parms, nparms);
  sys_bomb;
  end;
{
********************************************************************************
*
*   Subroutine SYN_MSG_TAG_ERR (SYN, SUBSYS, MSG, PARMS, NPARMS)
*
*   Write error message about unexpected tag at the current syntax tree entry.
*   The error message indicated by SUSBYS, MSG, PARMS, and N_PARMS is written
*   first.
}
procedure syn_msg_tag_err (            {unexpected tag from curr entry, show error}
  in out  syn: syn_t;                  {SYN library use state}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      nparms: sys_int_machine_t);  {number of parameters in PARMS}
  val_param;

const
  max_msg_args = 2;                    {max arguments we can pass to a message}

var
  entype: syn_tent_k_t;                {type of entry where error occurred}
  tag: sys_int_machine_t;              {tag number of current entry}
  name: string_var32_t;                {name of current syntax construction}
  name2: string_var32_t;               {name of other syntax construction}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;

begin
  name.max := size_char(name.str);     {init local var strings}
  name2.max := size_char(name2.str);
  name2.len := 0;

  sys_message_parms (subsys, msg, parms, nparms); {write caller's error message}

  syn_trav_level_name (syn, name);     {get name of this syntax construction}
  entype := syn_trav_type (syn);       {get type of syntax tree entry}
  tag := syn_trav_tag (syn);           {get tag number of this tree entry}

  case entype of                       {what type of syntax tree entry is here ?}
syn_tent_lev_k: begin
      sys_msg_parm_vstr (msg_parm[1], name);
      sys_message_parms ('syn', 'tag_lev_start', msg_parm, 1);
      end;
syn_tent_sub_k: begin
      sys_msg_parm_vstr (msg_parm[1], name);
      if syn.tent_p^.sub_p^.lev_name_p <> nil then begin
        string_copy (syn.tent_p^.sub_p^.lev_name_p^, name2);
        end;
      sys_msg_parm_vstr (msg_parm[2], name2);
      sys_message_parms ('syn', 'tag_sub', msg_parm, 2);
      end;
syn_tent_tag_k: begin
      sys_msg_parm_vstr (msg_parm[1], name);
      sys_msg_parm_int (msg_parm[2], tag);
      sys_message_parms ('syn', 'tag_unexpected', msg_parm, 2);
      end;
syn_tent_end_k: begin
      sys_msg_parm_vstr (msg_parm[1], name);
      sys_message_parms ('syn', 'tag_lev_end', msg_parm, 1);
      end;
syn_tent_err_k: begin
      sys_message_parms ('syn', 'tag_err', nil, 0);
      end;
otherwise
    writeln ('INTERNAL ERROR: Urecognized syntax tree entry type of ',
      ord(syn.tent_p^.ttype), ' encountered in SYN_TRAV_TAG_ERR.');
    sys_bomb;
    end;

  syn_pos_show (syn);                  {show the input stream position}
  end;
{
********************************************************************************
*
*   Subroutine SYN_MSG_TAG_BOMB (SYN, SUBSYS, MSG, PARMS, NPARMS)
*
*   Like SYN_MSG_TAG_ERR, but bombs the program after the messages are written.
*   This routine never returns.
}
procedure syn_msg_tag_bomb (           {unexpected tag, show error and bomb}
  in out  syn: syn_t;                  {SYN library use state}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      nparms: sys_int_machine_t);  {number of parameters in PARMS}
  options (val_param, noreturn);

begin
  syn_msg_tag_err (syn, subsys, msg, parms, nparms);
  sys_bomb;
  end;
