module session;

faultdef CREATE_SESSION_FAILED, VALIDATE_SESSION_FAILED, INVALIDATE_SESSION_FAILED, PING_FAILED;

typedef Client = void*;

fn bool Client.is_valid(self) => (void*)self != null;

struct CreateSessionResult
{
	String session_key;
	long expires_at_seconds;
}

struct ValidateSessionResult
{
	bool valid;
	String user_id;
	String reason;
	long expires_at_seconds;
}

struct InvalidateSessionResult
{
	bool success;
}

struct PingResult
{
	bool healthy;
	long server_time_seconds;
}

extern fn Client create(ZString target) @cname("session_client_create");
extern fn void Client.destroy(self) @cname("session_client_destroy");
extern fn ZString Client.last_error(self) @cname("session_client_error");

extern fn bool Client._create_session(
	self,
	ZString user_id,
	long ttl_seconds,
	ZString* out_session_key,
	long* out_expires_at_seconds
) @cname("session_client_create_session");

extern fn bool Client._validate_session(
	self,
	ZString session_key,
	bool force_refresh,
	bool* out_valid,
	ZString* out_user_id,
	ZString* out_reason,
	long* out_expires_at_seconds
) @cname("session_client_validate_session");

extern fn bool Client._invalidate_session(
	self,
	ZString session_key,
	ZString reason,
	bool* out_success
) @cname("session_client_invalidate_session");

extern fn bool Client._ping(self, bool* out_healthy, long* out_server_time_seconds) @cname("session_client_ping");

fn CreateSessionResult? Client.create_session(self, ZString user_id, long ttl_seconds, Allocator allocator = mem)
{
	ZString session_key;
	long expires_at_seconds;
	if (!self._create_session(user_id, ttl_seconds, &session_key, &expires_at_seconds))
	{
		return CREATE_SESSION_FAILED~;
	}
	return { .session_key = session_key.copy(allocator), .expires_at_seconds = expires_at_seconds };
}

fn ValidateSessionResult? Client.validate_session(
	self,
	ZString session_key,
	bool force_refresh,
	Allocator allocator = mem
)
{
	bool valid;
	ZString user_id;
	ZString reason;
	long expires_at_seconds;
	if (!self._validate_session(session_key, force_refresh, &valid, &user_id, &reason, &expires_at_seconds))
	{
		return VALIDATE_SESSION_FAILED~;
	}
	return {
		.valid = valid,
		.user_id = user_id.copy(allocator),
		.reason = reason.copy(allocator),
		.expires_at_seconds = expires_at_seconds
	};
}

fn InvalidateSessionResult? Client.invalidate_session(self, ZString session_key, ZString reason)
{
	bool success;
	if (!self._invalidate_session(session_key, reason, &success))
	{
		return INVALIDATE_SESSION_FAILED~;
	}
	return { .success = success };
}

fn PingResult? Client.ping(self)
{
	bool healthy;
	long server_time_seconds;
	if (!self._ping(&healthy, &server_time_seconds))
	{
		return PING_FAILED~;
	}
	return { .healthy = healthy, .server_time_seconds = server_time_seconds };
}