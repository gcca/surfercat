module sqlite3;

import std::core::cinterop;

faultdef OPEN_FAILED, PREPARE_FAILED, STEP_FAILED, BIND_FAILED;

enum Step
{
	ROW,
	DONE,
}

alias NativeDatabase = void*;
alias NativeStatement = void*;
alias Destructor = fn void(void* value);

const CInt SQLITE_OK             = 0;
const CInt SQLITE_OPEN_READONLY  = 1;
const CInt SQLITE_OPEN_READWRITE = 2;
const CInt SQLITE_ROW            = 100;
const CInt SQLITE_DONE           = 101;

struct Database
{
	NativeDatabase handle;
}

struct Statement
{
	NativeDatabase database;
	NativeStatement handle;
}

extern fn CInt _open_v2(ZString filename, NativeDatabase* database, CInt flags, ZString vfs) @cname("sqlite3_open_v2");
extern fn CInt _close(NativeDatabase database) @cname("sqlite3_close");
extern fn CInt _prepare_v2(
	NativeDatabase database,
	ZString sql,
	CInt length,
	NativeStatement* statement,
	ZString* tail
) @cname("sqlite3_prepare_v2");
extern fn CInt _finalize(NativeStatement statement) @cname("sqlite3_finalize");
extern fn ZString _error_message(NativeDatabase database) @cname("sqlite3_errmsg");
extern fn CInt _bind_text(
	NativeStatement statement,
	CInt index,
	ZString value,
	CInt length,
	Destructor destructor
) @cname("sqlite3_bind_text");
extern fn CInt _bind_blob(
	NativeStatement statement,
	CInt index,
	void* value,
	CInt length,
	Destructor destructor
) @cname("sqlite3_bind_blob");
extern fn CInt _bind_int64(NativeStatement statement, CInt index, long value) @cname("sqlite3_bind_int64");
extern fn CInt _step(NativeStatement statement) @cname("sqlite3_step");
extern fn char* _column_text(NativeStatement statement, CInt index) @cname("sqlite3_column_text");
extern fn long _column_int64(NativeStatement statement, CInt index) @cname("sqlite3_column_int64");
extern fn void* _column_blob(NativeStatement statement, CInt index) @cname("sqlite3_column_blob");
extern fn CInt _column_bytes(NativeStatement statement, CInt index) @cname("sqlite3_column_bytes");

fn Database? open(ZString filename, CInt flags)
{
	NativeDatabase handle = null;
	if (_open_v2(filename, &handle, flags, null) != SQLITE_OK || !handle)
	{
		if (handle) _close(handle);
		return OPEN_FAILED~;
	}
	return { .handle = handle };
}

fn Database? open_ro(ZString filename) => open(filename, SQLITE_OPEN_READONLY);

fn Database? open_rw(ZString filename) => open(filename, SQLITE_OPEN_READWRITE);

fn void Database.close(&self)
{
	_close(self.handle);
	self.handle = null;
}

fn Statement? Database.prepare(&self, ZString sql)
{
	NativeStatement handle = null;
	if (_prepare_v2(self.handle, sql, -1, &handle, null) != SQLITE_OK || !handle)
	{
		return PREPARE_FAILED~;
	}
	return { .database = self.handle, .handle = handle };
}

fn ZString Database.error_message(&self) => _error_message(self.handle);

fn void Statement.finalize(&self)
{
	_finalize(self.handle);
	self.handle = null;
}

fn ZString Statement.error_message(&self) => _error_message(self.database);

fn void? Statement.bind_text(&self, CInt index, ZString value)
{
	if (_bind_text(self.handle, index, value, -1, null) != SQLITE_OK) return BIND_FAILED~;
}

fn void? Statement.bind_blob(&self, CInt index, String value)
{
	if (_bind_blob(self.handle, index, value.ptr, (CInt)value.len, null) != SQLITE_OK) return BIND_FAILED~;
}

fn void? Statement.bind_int64(&self, CInt index, long value)
{
	if (_bind_int64(self.handle, index, value) != SQLITE_OK) return BIND_FAILED~;
}

fn Step? Statement.step(&self)
{
	switch (_step(self.handle))
	{
		case SQLITE_ROW: return Step.ROW;
		case SQLITE_DONE: return Step.DONE;
		default: return STEP_FAILED~;
	}
}

fn String Statement.column_text(&self, CInt index)
{
	char* value = _column_text(self.handle, index);
	if (!value) return "";
	CInt length = _column_bytes(self.handle, index);
	return length > 0 ? (String)value[:(usz)length] : "";
}

fn long Statement.column_int(&self, CInt index) => _column_int64(self.handle, index);

fn String Statement.column_blob(&self, CInt index)
{
	CInt length = _column_bytes(self.handle, index);
	if (length <= 0) return "";
	char* value = (char*)_column_blob(self.handle, index);
	return value ? (String)value[:(usz)length] : "";
}