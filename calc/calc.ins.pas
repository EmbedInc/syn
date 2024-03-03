{   Private include file for the CALC program.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'fline.ins.pas';
%include 'syn.ins.pas';
%include 'builddate.ins.pas';

var (calc)
  fline_p: fline_p_t;                  {to FLINE library use state}
  coll_p: fline_coll_p_t;              {the input file lines in FLINE collection}
  syn_p: syn_p_t;                      {to SYN library use state}

procedure calc_cmline;                 {read command line, set global state accordingly}
  val_param; extern;

procedure calc_prog_init;              {initialize global program state}
  val_param; extern;
