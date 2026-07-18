module yyjson;

typedef Doc = void*;
typedef Val = void*;
typedef MutDoc = void*;
typedef MutVal = void*;
typedef Alc = void*;

typedef ReadErr = void*;
typedef WriteErr = void*;

enum ReadFlag : (uint flag)
{
  NOFLAG         { 0 },
  INSITU         { 1 << 0 },
  STOP_WHEN_DONE { 1 << 1 },
}

enum WriteFlag : (uint flag)
{
  NOFLAG         { 0 },
  PRETTY         { 1 << 0 },
  ESCAPE_UNICODE { 1 << 1 },
}

enum Type : (char type)
{
  NONE { 0 },
  RAW  { 1 },
  NULL { 2 },
  BOOL { 3 },
  NUM  { 4 },
  STR  { 5 },
  ARR  { 6 },
  OBJ  { 7 },
}

extern fn Doc read_opts(ZString dat, usz len, ReadFlag flg, Alc* alc, ReadErr* err) @cname("yyjson_read_opts");
extern fn void Doc.free(self) @cname("yyjson_doc_free_");
extern fn Val Doc.get_root(self) @cname("yyjson_doc_get_root_");

extern fn Val Val.getn(self, ZString _key, usz key_len) @cname("yyjson_obj_getn_");

extern fn ZString Val.unsafe_get_str(self) @cname("unsafe_yyjson_get_str_");
extern fn Type Val.unsafe_get_type(self) @cname("unsafe_yyjson_get_type_");

extern fn MutDoc _mut_doc_new(void* allocator) @cname("yyjson_mut_doc_new");
extern fn void freezs(ZString s) @cname("free");

extern fn void MutDoc.free(self) @cname("yyjson_mut_doc_free");
extern fn MutVal MutDoc.obj(self) @cname("yyjson_mut_obj_");
extern fn void MutDoc.set_root(self, MutVal root) @cname("yyjson_mut_doc_set_root_");

<*
 @param [in] alc
 @param [out] len
 @param [out] err
*>
extern fn ZString MutDoc.write_opts(
  self,
  WriteFlag flg,
  Alc* alc,
  usz* len,
  WriteErr* err
) @cname("yyjson_mut_write_opts");

// ---

extern fn bool MutDoc.obj_add_str(self, MutVal obj, ZString key, ZString val) @cname("yyjson_mut_obj_add_str_");
extern fn bool MutDoc.obj_add_int(self, MutVal obj, ZString key, long val) @cname("yyjson_mut_obj_add_int_");
extern fn bool MutDoc.obj_add_val(self, MutVal object, ZString key, MutVal value) @cname("yyjson_mut_obj_add_val_");

extern fn MutVal MutDoc._arr_with_sint32(self, int* values, usz count) @cname("yyjson_mut_arr_with_sint32_");

// ---

fn Doc readsf(
  String s,
  ReadFlag flg
) => read_opts((ZString)s.ptr, s.len, (ReadFlag)((uint)flg & ~(uint)ReadFlag.INSITU), null, null);

fn Doc reads(String s) => read_opts((ZString)s.ptr, s.len, ReadFlag.NOFLAG, null, null);

fn bool Val.is_valid(self) => (void*)self != null;

fn bool Val.unsafe_is_str(self) => self.unsafe_get_type() == Type.STR;
fn bool Val.is_str(self) => self ? self.unsafe_is_str() : false;

fn Val Val.get(self, String key) => self.getn((ZString)key.ptr, key.len);
fn String Val.get_str(self) => self.is_str() ? self.unsafe_get_str().str_view() : "";

fn MutDoc mut_doc_new(void* allocator = null) => _mut_doc_new(allocator);

fn ZString MutDoc.write(self, WriteFlag flg, usz* len) => self.write_opts(flg, null, len, null);
fn ZString MutDoc.writes(self) => self.write(WriteFlag.NOFLAG, null);

fn bool MutDoc.is_valid(self) => (void*)self != null;
fn bool MutVal.is_valid(self) => (void*)self != null;

fn MutVal MutDoc.arr_with_sint32(self, int[] vals) => self._arr_with_sint32(vals.ptr, vals.len);
