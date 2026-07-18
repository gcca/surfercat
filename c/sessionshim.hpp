#pragma once

#include <stdbool.h>
#include <stdint.h>

typedef struct SessionClient SessionClient;

#ifdef __cplusplus
extern "C" {
#endif

SessionClient *session_client_create(const char *target);
void session_client_destroy(SessionClient *client);
const char *session_client_error(SessionClient *client);

bool session_client_create_session(SessionClient *client, const char *user_id,
                                   int64_t ttl_seconds,
                                   const char **out_session_key,
                                   int64_t *out_expires_at_seconds);

bool session_client_validate_session(SessionClient *client,
                                     const char *session_key,
                                     bool force_refresh, bool *out_valid,
                                     const char **out_user_id,
                                     const char **out_reason,
                                     int64_t *out_expires_at_seconds);

bool session_client_invalidate_session(SessionClient *client,
                                       const char *session_key,
                                       const char *reason, bool *out_success);

bool session_client_ping(SessionClient *client, bool *out_healthy,
                         int64_t *out_server_time_seconds);

#ifdef __cplusplus
}
#endif
