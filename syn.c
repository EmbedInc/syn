#define util_mem_list_size_k 15

typedef unsigned char int8u_t;

typedef int8u_t sys_size1_t;

typedef sys_size1_t sys_sys_threadlock_t[32];

typedef struct util_mem_context_t *util_mem_context_p_t;

typedef struct util_mem_list_t *util_mem_list_p_t;

typedef int sys_int_machine_t;

typedef unsigned int sys_int_adr_t;

typedef struct util_mem_context_t {
  sys_sys_threadlock_t lock;
  util_mem_context_p_t parent_p;
  util_mem_context_p_t prev_sib_p;
  util_mem_context_p_t next_sib_p;
  util_mem_context_p_t child_p;
  util_mem_list_p_t first_list_p;
  sys_int_machine_t n_in_first;
  sys_int_adr_t pool_size;
  sys_int_adr_t max_pool_chunk;
  void * pool_p;
  sys_int_adr_t pool_left;
  } util_mem_context_t;

typedef unsigned char string_t[80];

typedef struct util_stack_block_t *util_stack_block_p_t;

typedef struct util_stack_admin_t {
  util_mem_context_p_t mem_context_p;
  util_stack_block_p_t first_p;
  util_stack_block_p_t last_p;
  sys_int_adr_t stack_len;
  } util_stack_admin_t;

typedef struct fline_lpos_t *fline_lpos_p_t;

typedef struct fline_line_t *fline_line_p_t;

typedef struct fline_lpos_t {
  fline_lpos_p_t prev_p;
  fline_line_p_t line_p;
  } fline_lpos_t;

#define string_hashcre_memdir_k 0
#define string_hashcre_nodel_k 1
typedef unsigned char string_hashcre_k_t;

typedef short sys_int_min16_t;

typedef short string_index_t;

typedef unsigned char string80_t[80];

typedef struct string_var_arg_t {
  string_index_t max;
  string_index_t len;
  string80_t str;
  } string_var_arg_t;

typedef unsigned char string80_1_t[80];

typedef struct string_var80_t {
  string_index_t max;
  string_index_t len;
  string80_1_t str;
  } string_var80_t;

typedef struct syn_fparse_t *syn_fparse_p_t;

typedef union syn_tent_t *syn_tent_p_t;

typedef struct fline_cpos_t {
  fline_line_p_t line_p;
  sys_int_machine_t ind;
  } fline_cpos_t;

#define syn_charcase_down_k 0
#define syn_charcase_up_k 1
#define syn_charcase_asis_k 2
typedef unsigned char syn_charcase_k_t;

typedef struct syn_fparse_t {
  sys_int_machine_t level;
  syn_fparse_p_t prev_p;
  syn_fparse_p_t frame_lev_p;
  syn_fparse_p_t frame_save_p;
  syn_fparse_p_t frame_tag_p;
  syn_tent_p_t tent_def_p;
  syn_tent_p_t tent_p;
  fline_cpos_t pos;
  syn_charcase_k_t case_1;
  unsigned char tagged;
  } syn_fparse_t;

typedef struct util_stack_block_t {
  util_stack_block_p_t prev_p;
  util_stack_block_p_t next_p;
  sys_int_adr_t curr_adr;
  sys_int_adr_t start_adr;
  sys_int_adr_t stack_len;
  sys_int_adr_t len_left;
  } util_stack_block_t;

typedef struct string_hash_t *string_hash_p_t;

typedef string_hash_p_t string_hash_handle_t;

typedef util_stack_admin_t *util_stack_admin_p_t;

typedef util_stack_admin_p_t util_stack_handle_t;

typedef struct syn_ftrav_t *syn_ftrav_p_t;

typedef struct syn_t {
  util_mem_context_p_t mem_p;
  util_mem_context_p_t mem_tree_p;
  syn_tent_p_t sytree_p;
  string_hash_handle_t nametab;
  unsigned char names;
  util_stack_handle_t stack;
  unsigned char stack_exist;
  syn_tent_p_t tent_free_p;
  syn_tent_p_t tent_free_last_p;
  fline_cpos_t pos_start;
  fline_cpos_t pos_err;
  fline_cpos_t pos_errnext;
  unsigned char err;
  unsigned char err_end;
  syn_fparse_p_t parse_p;
  void * parsefunc_p;
  syn_tent_p_t tent_p;
  syn_ftrav_p_t travstk_p;
  } syn_t;

typedef struct fline_flist_ent_t *fline_flist_ent_p_t;

typedef struct fline_coll_t *fline_coll_p_t;

typedef struct fline_flist_ent_t {
  fline_flist_ent_p_t next_p;
  fline_coll_p_t coll_p;
  } fline_flist_ent_t;

typedef unsigned char string_hashcre_t;

typedef unsigned char string4_t[4];

typedef struct string_var4_t {
  string_index_t max;
  string_index_t len;
  string4_t str;
  } string_var4_t;

typedef struct syn_ftrav_t {
  syn_ftrav_p_t prev_p;
  syn_tent_p_t tent_p;
  } syn_ftrav_t;

typedef string_var_arg_t *string_var_p_t;

typedef struct fline_virtlin_t *fline_virtlin_p_t;

typedef struct fline_line_t {
  fline_line_p_t prev_p;
  fline_line_p_t next_p;
  fline_coll_p_t coll_p;
  sys_int_machine_t lnum;
  string_var_p_t str_p;
  fline_virtlin_p_t virt_p;
  fline_lpos_p_t lpos_p;
  } fline_line_t;

typedef struct fline_t *fline_p_t;

#define fline_colltyp_any_k 0
#define fline_colltyp_file_k 1
#define fline_colltyp_lmem_k 2
#define fline_colltyp_virt_k 3
typedef unsigned char fline_colltyp_k_t;

typedef struct fline_coll_t {
  fline_p_t fline_p;
  fline_line_p_t first_p;
  fline_line_p_t last_p;
  string_var_p_t name_p;
  fline_colltyp_k_t colltyp;
  } fline_coll_t;

#define syn_ttype_lev_k 0
#define syn_ttype_sub_k 1
#define syn_ttype_tag_k 2
#define syn_ttype_end_k 3
#define syn_ttype_err_k 4
typedef unsigned char syn_ttype_k_t;

typedef union syn_tent_t {
  struct {
    syn_tent_p_t back_p;
    syn_tent_p_t next_p;
    syn_tent_p_t levst_p;
    fline_cpos_t pos;
    syn_ttype_k_t ttype;
    } base;
  struct {
    char unused[24];
    sys_int_machine_t level;
    syn_tent_p_t lev_up_p;
    string_var_p_t lev_name_p;
    } lev;
  struct {
    char unused_1[24];
    syn_tent_p_t p;
    } sub;
  struct {
    char unused_2[24];
    sys_int_machine_t tag;
    fline_cpos_t tag_af;
    } tag;
  } syn_tent_t;

typedef void * array_t[15];

typedef struct util_mem_list_t {
  util_mem_list_p_t next_p;
  array_t list;
  } util_mem_list_t;

typedef union string_hash_entry_t *string_hash_entry_p_t;

typedef struct string_hash_bucket_t {
  string_hash_entry_p_t first_p;
  string_hash_entry_p_t mid_p;
  string_hash_entry_p_t last_p;
  sys_int_machine_t n;
  sys_int_machine_t n_after;
  } string_hash_bucket_t;

typedef sys_int_machine_t array_1_t[256];

typedef string_hash_bucket_t array_2_t[1];

typedef struct string_hash_t {
  sys_int_machine_t n_buckets;
  sys_int_machine_t mask;
  sys_int_machine_t max_name_len;
  sys_int_adr_t entry_size;
  sys_int_adr_t data_offset;
  string_hash_entry_p_t free_p;
  util_mem_context_p_t mem_p;
  string_hashcre_t flags;
  array_1_t func;
  array_2_t bucket;
  } string_hash_t;

typedef struct fline_virtlin_t {
  fline_coll_p_t coll_p;
  sys_int_machine_t lnum;
  } fline_virtlin_t;

typedef sys_int_machine_t array_3_t[1];

typedef union string_hash_entry_t {
  struct {
    string_hash_entry_p_t prev_p;
    string_hash_entry_p_t next_p;
    sys_int_machine_t namei_len;
    } base;
  struct {
    char unused[12];
    string_var80_t name;
    } i1;
  struct {
    char unused_1[12];
    string_index_t unused1;
    string_index_t unused2;
    array_3_t namei;
    } i2;
  } string_hash_entry_t;

typedef struct fline_t {
  util_mem_context_p_t mem_p;
  fline_flist_ent_p_t coll_first_p;
  fline_flist_ent_p_t coll_last_p;
  string_var4_t nullstr;
  } fline_t;

extern __declspec(dllexport) sys_int_machine_t __stdcall syn_p_ichar (
  syn_t *);

extern __declspec(dllexport) void __stdcall syn_p_tag_start (
  syn_t *,
  sys_int_machine_t);

extern __declspec(dllexport) void __stdcall syn_p_cpos_pop (
  syn_t *,
  unsigned char);

extern __declspec(dllexport) void __stdcall syn_p_constr_end (
  syn_t *,
  unsigned char);

extern __declspec(dllexport) void __stdcall syn_p_tag_end (
  syn_t *,
  unsigned char);

extern __declspec(dllexport) void __stdcall syn_p_cpos_push (
  syn_t *);

extern __declspec(dllexport) unsigned char __stdcall syn_p_test_string (
  syn_t *,
  string_t,
  sys_int_machine_t);

extern __declspec(dllexport) void __stdcall syn_p_charcase (
  syn_t *,
  syn_charcase_k_t);

extern __declspec(dllexport) void __stdcall syn_p_constr_start (
  syn_t *,
  string_t,
  sys_int_machine_t);

extern __declspec(dllexport) unsigned char __stdcall syn_chsyn_symbol (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_item (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_command (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_define (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_space (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_pad (
  syn_t *);

extern __declspec(dllexport) unsigned char __stdcall syn_chsyn_integer (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_expression (
  syn_t *);

__declspec(dllexport) unsigned char __stdcall syn_chsyn_declare (
  syn_t *);

extern __declspec(dllexport) unsigned char __stdcall syn_chsyn_untagged_item (
  syn_t *);

/*****************************
**
**   Start of global routine SYN_CHSYN_PAD.
*/
#define true 1
#define false 0

__declspec(dllexport) unsigned char __stdcall syn_chsyn_pad (
    syn_t *syn) {

  unsigned char match;
  sys_int_machine_t i1;
  sys_int_machine_t i2;
  sys_int_machine_t i3;

  static string_t str_1 = "PAD";
  static string_t str_2 = " ";
  static string_t str_3 = "/*";
  /*
  **   Executable code for routine SYN_CHSYN_PAD.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "PAD" */
    3);
  i1 = 0;
lab1: ;
  syn_p_cpos_push (syn);
  match = syn_p_test_string(syn, str_2, /* " " */
    1);
  if (syn->err_end) {
    goto err;
    };
  if (match) {
    goto lab2;
    };
  syn_p_cpos_push (syn);
  match = syn_p_ichar(syn) == (-1);
  if (syn->err_end) {
    goto err;
    };
  syn_p_cpos_pop (
    syn,
    match);
  if (match) {
    goto lab2;
    };
  syn_p_cpos_push (syn);
  match = syn_p_ichar(syn) == (-2);
  if (syn->err_end) {
    goto err;
    };
  syn_p_cpos_pop (
    syn,
    match);
  if (match) {
    goto lab2;
    };
  syn_p_cpos_push (syn);
  match = syn_p_test_string(syn, str_3, /* "/*" */
    2);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab3;
    };
  i2 = 0;
lab4: ;
  syn_p_cpos_push (syn);
  i3 = syn_p_ichar(syn);
  if (syn->err_end) {
    goto err;
    };
  match = (i3 >= 32) && (i3 <= 126);
  syn_p_cpos_pop (
    syn,
    match);
  if (!match) {
    match = true;
    goto lab5;
    };
  i2 = i2 + 1;
  goto lab4;
lab5: ;
  if (!match) {
    goto lab3;
    };
  syn_p_cpos_push (syn);
  match = syn_p_ichar(syn) == (-1);
  if (syn->err_end) {
    goto err;
    };
  syn_p_cpos_pop (
    syn,
    match);
lab3: ;
  syn_p_cpos_pop (
    syn,
    match);
lab2: ;
  syn_p_cpos_pop (
    syn,
    match);
  if (!match) {
    match = true;
    goto lab6;
    };
  i1 = i1 + 1;
  goto lab1;
lab6: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }

/*****************************
**
**   Start of global routine SYN_CHSYN_SPACE.
*/

__declspec(dllexport) unsigned char __stdcall syn_chsyn_space (
    syn_t *syn) {

  unsigned char match;

  static string_t str_1 = "SPACE";
  static string_t str_2 = " ";
  /*
  **   Executable code for routine SYN_CHSYN_SPACE.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "SPACE" */
    5);
  syn_p_cpos_push (syn);
  match = syn_p_test_string(syn, str_2, /* " " */
    1);
  if (syn->err_end) {
    goto err;
    };
  if (match) {
    goto lab1;
    };
  syn_p_cpos_push (syn);
  match = syn_p_ichar(syn) == (-1);
  if (syn->err_end) {
    goto err;
    };
  syn_p_cpos_pop (
    syn,
    match);
lab1: ;
  syn_p_cpos_pop (
    syn,
    match);
  if (!match) {
    goto lab2;
    };
  match = syn_chsyn_pad(syn);
  if (syn->err_end) {
    goto err;
    };
lab2: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }

/*****************************
**
**   Start of global routine SYN_CHSYN_ITEM.
*/

__declspec(dllexport) unsigned char __stdcall syn_chsyn_item (
    syn_t *syn) {

  unsigned char match;

  static string_t str_1 = "ITEM";
  static string_t str_2 = "[";
  static string_t str_3 = "]";
  /*
  **   Executable code for routine SYN_CHSYN_ITEM.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "ITEM" */
    4);
  match = syn_chsyn_untagged_item(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_cpos_push (syn);
  match = syn_p_test_string(syn, str_2, /* "[" */
    1);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab2;
    };
  syn_p_tag_start (
    syn,
    1);
  match = syn_chsyn_integer(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
  if (!match) {
    goto lab2;
    };
  match = syn_p_test_string(syn, str_3, /* "]" */
    1);
  if (syn->err_end) {
    goto err;
    };
lab2: ;
  syn_p_cpos_pop (
    syn,
    match);
  if (match) {
    goto lab3;
    };
  syn_p_tag_start (
    syn,
    2);
  match = true;
  syn_p_tag_end (
    syn,
    match);
lab3: ;
lab1: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }

/*****************************
**
**   Start of global routine SYN_CHSYN_EXPRESSION.
*/

__declspec(dllexport) unsigned char __stdcall syn_chsyn_expression (
    syn_t *syn) {

  unsigned char match;

  static string_t str_1 = "EXPRESSION";
  static string_t str_2 = ".or";
  /*
  **   Executable code for routine SYN_CHSYN_EXPRESSION.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "EXPRESSION" */
    10);
  match = syn_chsyn_item(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_cpos_push (syn);
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab2;
    };
  syn_p_cpos_push (syn);
  match = syn_p_test_string(syn, str_2, /* ".or" */
    3);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab3;
    };
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab3;
    };
  syn_p_tag_start (
    syn,
    2);
  match = syn_chsyn_expression(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
lab3: ;
  syn_p_cpos_pop (
    syn,
    match);
  if (match) {
    goto lab4;
    };
  syn_p_tag_start (
    syn,
    1);
  match = syn_chsyn_expression(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
lab4: ;
lab2: ;
  syn_p_cpos_pop (
    syn,
    match);
  if (match) {
    goto lab5;
    };
  syn_p_tag_start (
    syn,
    3);
  match = true;
  syn_p_tag_end (
    syn,
    match);
lab5: ;
lab1: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }

/*****************************
**
**   Start of global routine SYN_CHSYN_DEFINE.
*/

__declspec(dllexport) unsigned char __stdcall syn_chsyn_define (
    syn_t *syn) {

  unsigned char match;

  static string_t str_1 = "DEFINE";
  static string_t str_2 = ".define";
  static string_t str_3 = ".as";
  /*
  **   Executable code for routine SYN_CHSYN_DEFINE.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "DEFINE" */
    6);
  match = syn_p_test_string(syn, str_2, /* ".define" */
    7);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_tag_start (
    syn,
    1);
  match = syn_chsyn_symbol(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
  if (!match) {
    goto lab1;
    };
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  match = syn_p_test_string(syn, str_3, /* ".as" */
    3);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_tag_start (
    syn,
    1);
  match = syn_chsyn_expression(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
lab1: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }

/*****************************
**
**   Start of global routine SYN_CHSYN_DECLARE.
*/

__declspec(dllexport) unsigned char __stdcall syn_chsyn_declare (
    syn_t *syn) {

  unsigned char match;

  static string_t str_1 = "DECLARE";
  static string_t str_2 = ".symbol";
  static string_t str_3 = "[";
  static string_t str_4 = "]";
  static string_t str_5 = "external";
  /*
  **   Executable code for routine SYN_CHSYN_DECLARE.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "DECLARE" */
    7);
  match = syn_p_test_string(syn, str_2, /* ".symbol" */
    7);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_tag_start (
    syn,
    1);
  match = syn_chsyn_symbol(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
  if (!match) {
    goto lab1;
    };
  match = syn_chsyn_pad(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_cpos_push (syn);
  syn_p_cpos_push (syn);
  match = syn_p_test_string(syn, str_3, /* "[" */
    1);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab2;
    };
  syn_p_tag_start (
    syn,
    1);
  match = syn_chsyn_symbol(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
  if (!match) {
    goto lab2;
    };
  match = syn_p_test_string(syn, str_4, /* "]" */
    1);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab2;
    };
  syn_p_cpos_push (syn);
  syn_p_cpos_push (syn);
  match = syn_chsyn_space(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab3;
    };
  syn_p_tag_start (
    syn,
    2);
  match = syn_p_test_string(syn, str_5, /* "external" */
    8);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
lab3: ;
  syn_p_cpos_pop (
    syn,
    match);
  syn_p_cpos_pop (
    syn,
    match);
  match = true;
lab2: ;
  syn_p_cpos_pop (
    syn,
    match);
  syn_p_cpos_pop (
    syn,
    match);
  match = true;
lab1: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }

/*****************************
**
**   Start of global routine SYN_CHSYN_COMMAND.
*/

__declspec(dllexport) unsigned char __stdcall syn_chsyn_command (
    syn_t *syn) {

  unsigned char match;

  static string_t str_1 = "COMMAND";
  /*
  **   Executable code for routine SYN_CHSYN_COMMAND.
  */
  syn_p_constr_start (
    syn,
    str_1,                             /* "COMMAND" */
    7);
  syn_p_charcase (
    syn,
    syn_charcase_down_k);
  match = true;
  if (!match) {
    goto lab1;
    };
  match = syn_chsyn_pad(syn);
  if (syn->err_end) {
    goto err;
    };
  if (!match) {
    goto lab1;
    };
  syn_p_cpos_push (syn);
  syn_p_tag_start (
    syn,
    1);
  syn_p_cpos_push (syn);
  match = syn_p_ichar(syn) == (-3);
  if (syn->err_end) {
    goto err;
    };
  syn_p_cpos_pop (
    syn,
    match);
  syn_p_tag_end (
    syn,
    match);
  if (match) {
    goto lab2;
    };
  syn_p_tag_start (
    syn,
    2);
  match = syn_chsyn_define(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
  if (match) {
    goto lab2;
    };
  syn_p_tag_start (
    syn,
    3);
  match = syn_chsyn_declare(syn);
  if (syn->err_end) {
    goto err;
    };
  syn_p_tag_end (
    syn,
    match);
lab2: ;
  syn_p_cpos_pop (
    syn,
    match);
lab1: ;
  syn_p_constr_end (
    syn,
    match);
  return match;
err: ;
  match = false;
  return match;
  }
