{   Syntax parsing routines for the SYN syntax definition file syntax.  The SYN
*   syntax definition file format is described in the SYN_FILE help file.
*
*   The routines here be created by compiling the SYN.SYN syntax definition
*   file.  However, there is a circular problem because that requires parsing
*   that file, which requires the result of compiling it.  This module was
*   originally hand-written to implement the minimum syntax that SYN.SYN adheres
*   to.  Once it is possible to compile syntax definition files, the code here
*   should be replaced by the result of compiling SYN.SYN.
*
*   All the routines here are named SYN_CHSYN_name.  Such names are guaranteed
*   to not be used elsewhere in the SYN library, and are different from the
*   names reserved for automatic generation of syntax parsing routines.
*
*   This module is included in the SYN library, but would not be linked with
*   ordinary applications since there would be no references to SYN_CHSYN_xxx
*   names.
}
module syn_chsyn;
define syn_chsyn_command;
define syn_ch_toplev;
%include 'syn2.ins.pas';

function syn_chsyn_expression (
  in out  syn: syn_t)
  :boolean;
  val_param; forward;

function syn_chsyn_item (
  in out  syn: syn_t)
  :boolean;
  val_param; forward;
{
********************************************************************************
}
function syn_chsyn_pad (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  spos: fline_cpos_t;                  {saved input stream position}

label
  done;

begin
  syn_chsyn_pad := false;

  while true do begin                  {back here to try each new character}
    spos := syn.parse_p^.pos;          {save position before this character}
    case syn_p_ichar(syn) of           {what character is this ?}
ord(' '),
syn_ichar_eol_k,
syn_ichar_eof_k: ;
otherwise
      goto done;
      end;                             {end of characters to skip over cases}
    end;                               {this char matched, back to try next}

done:
  if syn.err_end then return;          {end of error re-parse ?}
  syn.parse_p^.pos := spos;            {back to first char that didn't match}
  syn_chsyn_pad := true;               {always matches}
  end;
{
********************************************************************************
}
function syn_chsyn_space (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_space := false;            {init to syntax did not match}

  syn_p_cpos_push (syn);               {save position before first char}
  case syn_p_ichar(syn) of             {what character is it ?}
ord(' '),
syn_ichar_eol_k: begin
      match := true;
      end;
otherwise
    match := false;
    end;
  if syn.err_end then return;          {end of error re-parse ?}
  syn_p_cpos_pop (syn, match);
  if not match then goto leave;

  match := syn_chsyn_pad (syn);

leave:
  if syn.err_end then return;
  syn_chsyn_space := match;
  end;
{
********************************************************************************
}
function syn_chsyn_integer (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  n: sys_int_machine_t;                {number of characters}
  ichar: sys_int_machine_t;            {character code}
  match: boolean;                      {syntax matched}
  spos: fline_cpos_t;                  {saved input stream position}

begin
  syn_chsyn_integer := false;          {init to syntax did not match}
  match := false;
  syn_p_constr_start (syn, 'INTEGER', 7);

  n := 0;                              {init number of matching chars found}
  while true do begin
    spos := syn.parse_p^.pos;          {save position before reading this char}
    ichar := syn_p_ichar (syn);        {get this input character}
    if syn.err_end then return;        {end of error re-parse ?}
    if (ichar < ord('0')) or (ichar > ord('9')) {hit first non-matching char ?}
      then exit;
    n := n + 1;                        {count one more matching character}
    end;                               {this char matches, back to try next}
  syn.parse_p^.pos := spos;            {restore to first non-matching char}

  match := n > 0;                      {syntax matched if 1 or more digits}
  syn_p_constr_end (syn, match);
  syn_chsyn_integer := match;
  end;
{
********************************************************************************
}
function syn_chsyn_symbol (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  n: sys_int_machine_t;                {number of characters}
  ichar: sys_int_machine_t;            {character code}
  match: boolean;                      {syntax matched}
  spos: fline_cpos_t;                  {saved input stream position}

begin
  syn_chsyn_symbol := false;           {init to syntax did not match}
  syn_p_constr_start (syn, 'SYMBOL', 6);

  n := 0;                              {init number of matching chars found}
  while true do begin
    spos := syn.parse_p^.pos;          {save position before reading this char}
    ichar := syn_p_ichar (syn);        {get this input character}
    if syn.err_end then return;        {end of error re-parse ?}
    if not (                           {hit first non-matching char ?}
        ((ichar >= ord('a')) and (ichar <= ord('z'))) or
        (ichar = ord('_'))
        )
      then exit;
    n := n + 1;                        {count one more matching character}
    end;                               {this char matches, back to try next}
  syn.parse_p^.pos := spos;            {restore to before first non-matching char}
  match := n > 0;                      {syntax matched if 1 or more digits}

  syn_p_constr_end (syn, match);
  syn_chsyn_symbol := match;
  end;
{
********************************************************************************
}
function syn_chsyn_string (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}
  spos: fline_cpos_t;                  {saved input stream position}
  ichar: sys_int_machine_t;            {character code}
  iq: sys_int_machine_t;               {quote character code}

label
  leave;

begin
  syn_chsyn_string := false;           {set return state for aborting}
  match := false;
  syn_p_constr_start (syn, 'STRING', 6); {start this construction}

  iq := syn_p_ichar (syn);             {get starting quote character}
  if syn.err_end then return;          {end of error re-parse ?}
  if (iq <> ord('"')) and (iq <> ord('''')) {invalid quote start ?}
    then goto leave;

  match := true;                       {init to syntax matched}
  syn_p_tag_start (syn, 1);            {start tagged input string}
  while true do begin                  {back here each new string character}
    spos := syn.parse_p^.pos;          {save position before this character}
    ichar := syn_p_ichar (syn);        {get this char}
    if syn.err_end then return;        {end of error re-parse ?}
    if ichar = iq then exit;           {hit closing quote character ?}
    if (ichar < ord(' ')) or (ichar > ord('~')) then begin {bad char ?}
      match := false;                  {indicate syntax does not match}
      exit;
      end;
    end;                               {this char is string body, back for next}

  syn.parse_p^.pos := spos;            {go back to before the ending quote}
  syn_p_tag_end (syn, match);          {end the tag for the string content}
  if match then begin                  {there was a valid ending quote}
    discard( syn_p_ichar(syn) );       {consume the ending quote}
    end;

leave:                                 {end syntax construction and return}
  syn_p_constr_end (syn, match);
  syn_chsyn_string := match;
  end;
{
********************************************************************************
}
function syn_chsyn_char (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}
  ichar: sys_int_machine_t;            {character code}
  iq: sys_int_machine_t;               {quote character code}

label
  abort, leave;

begin
  syn_chsyn_char := false;             {init to syntax did not match}
  match := false;
  syn_p_constr_start (syn, 'CHAR', 4); {start this construction}

  iq := syn_p_ichar (syn);             {get starting quote character}
  if syn.err_end then return;          {end of error re-parse ?}
  if (iq <> ord('"')) and (iq <> ord('''')) {invalid quote start ?}
    then goto leave;

  syn_p_tag_start (syn, 1);            {start tagged input string}
  ichar := syn_p_ichar (syn);          {get the char}
  if syn.err_end then return;          {end of error re-parse ?}
  if                                   {not a valid quoted char ?}
      (ichar = iq) or                  {is the end quote character ?}
      (ichar < ord(' ')) or            {before valid range ?}
      (ichar > ord('~'))               {after valid range ?}
    then goto abort;

  ichar := syn_p_ichar (syn);          {get the end quote character}
  if syn.err_end then return;          {end of error re-parse ?}
  if ichar <> iq then goto abort;      {not valid end quote ?}
  match := true;                       {syntax matched}

abort:                                 {abort to here when tag open}
  syn_p_tag_end (syn, match);          {end the string body tag}

leave:
  syn_p_constr_end (syn, match);
  syn_chsyn_char := match;
  end;
{
********************************************************************************
}
function syn_chsyn_end_range (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_end_range := false;        {init to syntax did not match}
  match := false;
  syn_p_constr_start (syn, 'END_RANGE', 9);

  syn_p_tag_start (syn, 1);            {start tag for INTEGER}
  match := syn_chsyn_integer (syn);
  syn_p_tag_end (syn, match);
  if match then goto leave;

  syn_p_tag_start (syn, 2);            {start tag for "inf"}
  match := syn_p_test_string (syn, 'inf', 3);
  syn_p_tag_end (syn, match);

leave:
  syn_p_constr_end (syn, match);
  syn_chsyn_end_range := match;
  end;
{
********************************************************************************
}
function syn_chsyn_untagged_item (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_untagged_item := false;    {init to syntax did not match}
  match := false;
  syn_p_constr_start (syn, 'UNTAGGED_ITEM', 13);
{
*   Nested expression.
}
  syn_p_cpos_push (syn);
  while true do begin
    match := syn_p_ichar(syn) = ord('(');
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    syn_p_tag_start (syn, 7);
    match := syn_chsyn_expression (syn);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord(')');
    exit;
    end;
  if syn.err_end then return;
  syn_p_cpos_pop (syn, match);
  if match then goto leave;
{
*   .EOL
}
  syn_p_tag_start (syn, 1);
  match := syn_p_test_string (syn, '.eol', 4);
  syn_p_tag_end (syn, match);
  if syn.err_end then return;
  if match then goto leave;
{
*   .EOF
}
  syn_p_tag_start (syn, 2);
  match := syn_p_test_string (syn, '.eof', 4);
  syn_p_tag_end (syn, match);
  if syn.err_end then return;
  if match then goto leave;
{
*   .EOD
}
  syn_p_tag_start (syn, 12);
  match := syn_p_test_string (syn, '.eod', 4);
  syn_p_tag_end (syn, match);
  if syn.err_end then return;
  if match then goto leave;
{
*   .RANGE
}
  syn_p_tag_start (syn, 5);
  while true do begin
    match := syn_p_test_string (syn, '.range', 6);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord('[');
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    syn_p_tag_start (syn, 1);
    match := syn_chsyn_char (syn);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_chsyn_space (syn);
    if not match then exit;

    match := syn_p_test_string (syn, 'thru', 4);
    if not match then exit;

    match := syn_chsyn_space (syn);
    if not match then exit;

    syn_p_tag_start (syn, 1);
    match := syn_chsyn_char (syn);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord(']');
    exit;
    end;
  if syn.err_end then return;
  syn_p_tag_end (syn, match);
  if match then goto leave;
{
*   .OCCURS
}
  syn_p_tag_start (syn, 6);
  while true do begin
    match := syn_p_test_string (syn, '.occurs', 7);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord('[');
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    syn_p_tag_start (syn, 1);
    match := syn_chsyn_integer (syn);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_chsyn_space (syn);
    if not match then exit;

    match := syn_p_test_string (syn, 'to', 2);
    if not match then exit;

    match := syn_chsyn_space (syn);
    if not match then exit;

    match := syn_chsyn_end_range (syn);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord(']');
    if not match then exit;

    match := syn_chsyn_space (syn);
    if not match then exit;

    match := syn_chsyn_item (syn);
    if not match then exit;
    exit;
    end;
  if syn.err_end then return;
  syn_p_tag_end (syn, match);
  if match then goto leave;
{
*   .CHARCASE
}
  syn_p_tag_start (syn, 8);
  while true do begin
    match := syn_p_test_string (syn, '.charcase', 9);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord('[');
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    while true do begin
      syn_p_tag_start (syn, 1);
      match := syn_p_test_string (syn, 'upper', 5);
      syn_p_tag_end (syn, match);
      if not match then exit;

      syn_p_tag_start (syn, 2);
      match := syn_p_test_string (syn, 'lower', 5);
      syn_p_tag_end (syn, match);
      if not match then exit;

      syn_p_tag_start (syn, 3);
      match := syn_p_test_string (syn, 'off', 3);
      syn_p_tag_end (syn, match);
      exit;
      end;
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_p_ichar(syn) = ord(']');
    exit;
    end;
  if syn.err_end then return;
  syn_p_tag_end (syn, match);
  if match then goto leave;
{
*   .UPTO
}
  while true do begin
    syn_p_tag_start (syn, 10);
    match := syn_p_test_string (syn, '.upto', 5);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_chsyn_item (syn);
    exit;
    end;
  if syn.err_end then return;
  if match then goto leave;
{
*   .NOT
}
  while true do begin
    syn_p_tag_start (syn, 11);
    match := syn_p_test_string (syn, '.not', 4);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_chsyn_pad (syn);
    if not match then exit;

    match := syn_chsyn_item (syn);
    exit;
    end;
  if syn.err_end then return;
  if match then goto leave;
{
*   .NULL
}
  syn_p_tag_start (syn, 9);
  match := syn_p_test_string (syn, '.null', 5);
  if syn.err_end then return;
  syn_p_tag_end (syn, match);
  if match then goto leave;
{
*   .OPTIONAL
}
  while true do begin
    match := syn_p_test_string (syn, '.optional', 9);
    if not match then exit;

    match := syn_chsyn_space (syn);
    if not match then exit;

    syn_p_tag_start (syn, 13);
    match := syn_chsyn_item (syn);
    syn_p_tag_end (syn, match);
    exit;
    end;
  if syn.err_end then return;
  if match then goto leave;
{
*   symbol
}
  syn_p_tag_start (syn, 3);
  match := syn_chsyn_symbol (syn);
  if syn.err_end then return;
  syn_p_tag_end (syn, match);
  if match then goto leave;
{
*   string
}
  syn_p_tag_start (syn, 4);
  match := syn_chsyn_string (syn);
  if syn.err_end then return;
  syn_p_tag_end (syn, match);

leave:
  syn_p_constr_end (syn, match);
  syn_chsyn_untagged_item := match;
  end;
{
********************************************************************************
}
function syn_chsyn_item (
  in out  syn: syn_t)
  :boolean;
  val_param;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_item := false;             {init to syntax did not match}
  match := false;
  syn_p_constr_start (syn, 'ITEM', 4);

  match := syn_chsyn_untagged_item (syn);
  if not match then goto leave;

  syn_p_cpos_push (syn);               {save position before optional tag}
  while true do begin
    match := syn_p_ichar(syn) = ord('[');
    if not match then exit;

    syn_p_tag_start (syn, 1);
    match := syn_chsyn_integer (syn);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_p_ichar(syn) = ord(']');
    exit;
    end;
  if syn.err_end then return;
  syn_p_cpos_pop (syn, match);         {restore pos if no tag found}
  if match then goto leave;

  syn_p_tag_start (syn, 2);
  match := true;
  syn_p_tag_end (syn, match);

leave:
  syn_p_constr_end (syn, match);
  syn_chsyn_item := match;
  end;
{
********************************************************************************
}
function syn_chsyn_expression (
  in out  syn: syn_t)
  :boolean;
  val_param;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_expression := false;       {init to syntax did not match}
  match := false;
  syn_p_constr_start (syn, 'EXPRESSION', 10);

  match := syn_chsyn_item (syn);
  if not match then goto leave;

  syn_p_cpos_push (syn);
  while true do begin
    match := syn_chsyn_space (syn);
    if not match then exit;

    syn_p_cpos_push (syn);
    while true do begin
      match := syn_p_test_string (syn, '.or', 3);
      if not match then exit;

      match := syn_chsyn_space (syn);
      if not match then exit;

      syn_p_tag_start (syn, 2);
      match := syn_chsyn_expression (syn);
      syn_p_tag_end (syn, match);
      exit;
      end;
    if syn.err_end then return;
    syn_p_cpos_pop (syn, match);
    if match then exit;

    syn_p_tag_start (syn, 1);
    match := syn_chsyn_expression (syn);
    syn_p_tag_end (syn, match);
    exit;
    end;
  if syn.err_end then return;
  syn_p_cpos_pop (syn, match);
  if match then goto leave;

  syn_p_tag_start (syn, 3);
  match := true;
  syn_p_tag_end (syn, match);

leave:
  syn_p_constr_end (syn, match);
  syn_chsyn_expression := match;
  end;
{
********************************************************************************
}
function syn_chsyn_define (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_define := false;           {init to syntax did not match}
  syn_p_constr_start (syn, 'DEFINE', 6);

  match := syn_p_test_string (syn, '.define', 7);
  if not match then goto leave;

  match := syn_chsyn_space (syn);
  if not match then goto leave;

  syn_p_tag_start (syn, 8);
  match := syn_chsyn_symbol (syn);
  syn_p_tag_end (syn, match);
  if not match then goto leave;

  match := syn_chsyn_space (syn);
  if not match then goto leave;

  match := syn_p_test_string (syn, '.as', 3);
  if not match then goto leave;

  match := syn_chsyn_space (syn);
  if not match then goto leave;

  syn_p_tag_start (syn, 9);
  match := syn_chsyn_expression (syn);
  syn_p_tag_end (syn, match);

leave:
  if syn.err_end then return;
  syn_p_constr_end (syn, match);
  syn_chsyn_define := match;
  end;
{
********************************************************************************
}
function syn_chsyn_declare (
  in out  syn: syn_t)
  :boolean;
  val_param; internal;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_declare := false;          {init to syntax did not match}
  syn_p_constr_start (syn, 'DECLARE', 7);

  match := syn_p_test_string (syn, '.symbol', 7);
  if not match then goto leave;

  match := syn_chsyn_space (syn);
  if not match then goto leave;

  syn_p_tag_start (syn, 5);
  match := syn_chsyn_symbol (syn);
  syn_p_tag_end (syn, match);
  if not match then goto leave;

  match := syn_chsyn_pad (syn);
  if not match then goto leave;

  syn_p_cpos_push (syn);
  while true do begin
    match := syn_p_ichar(syn) = ord('[');
    if not match then exit;

    syn_p_tag_start (syn, 6);
    match := syn_chsyn_symbol (syn);
    syn_p_tag_end (syn, match);
    if not match then exit;

    match := syn_p_ichar(syn) = ord(']');
    if not match then exit;

    syn_p_cpos_push (syn);
    while true do begin
      match := syn_chsyn_space (syn);
      if not match then exit;

      syn_p_tag_start (syn, 7);
      match := syn_p_test_string (syn, 'external', 8);
      syn_p_tag_end (syn, match);
      exit;
      end;
    if syn.err_end then return;
    syn_p_cpos_pop (syn, match);

    match := true;
    exit;
    end;
  if syn.err_end then return;
  syn_p_cpos_pop (syn, match);
  match := true;

leave:
  if syn.err_end then return;
  syn_p_constr_end (syn, match);
  syn_chsyn_declare := match;
  end;
{
********************************************************************************
}
function syn_chsyn_command (
  in out  syn: syn_t)
  :boolean;
  val_param;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_chsyn_command := false;          {init to syntax did not match}
  syn_p_constr_start (syn, 'COMMAND', 7);

  syn_p_tag_start (syn, 3);
  match := syn_chsyn_declare (syn);
  if syn.err_end then return;
  syn_p_tag_end (syn, match);
  if match then goto leave;

  syn_p_tag_start (syn, 4);
  match := syn_chsyn_define (syn);
  if syn.err_end then return;
  syn_p_tag_end (syn, match);

leave:
  if syn.err_end then return;
  syn_p_constr_end (syn, match);
  syn_chsyn_command := match;
  end;
{
********************************************************************************
}
function syn_ch_toplev (
  in out  syn: syn_t)
  :boolean;
  val_param;

var
  match: boolean;                      {syntax matched}

label
  leave;

begin
  syn_ch_toplev := false;              {init to syntax did not match}
  syn_p_constr_start (syn, 'TOPLEV', 6);

  syn_p_charcase (syn, syn_charcase_down_k);

  while true do begin
    match := syn_chsyn_pad (syn);
    if not match then exit;
    match := syn_chsyn_command (syn);
    if not match then exit;
    end;
  if syn.err_end then return;

  match := syn_chsyn_pad (syn);
  if not match then goto leave;

  match := syn_p_test_eod (syn);

leave:
  if syn.err_end then return;
  syn_p_constr_end (syn, match);
  syn_ch_toplev := match;
  end;
