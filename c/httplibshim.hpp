#pragma once

#include <stddef.h>

typedef struct Server Server;
typedef struct Request Request;
typedef struct Response Response;

typedef void (*Handler)(const Request *request, Response *response);

typedef struct {
  const char *ptr;
  size_t len;
} String;

#ifdef __cplusplus
extern "C" {
#endif

Server *server_create(void);
void server_destroy(Server *);

Server *server_get(Server *, const char *pattern, Handler handler);
Server *server_post(Server *, const char *pattern, Handler handler);
Server *server_put(Server *, const char *pattern, Handler handler);
Server *server_delete(Server *, const char *pattern, Handler handler);
void server_listen(Server *, const char *host, int port);

String request_body(Request *);

void response_set_status(Response *, int status);
void response_set_redirect(Response *, const char *url);
void response_set_content(Response *, const char *s, size_t n,
                          const char *content_type);

#ifdef __cplusplus
}
#endif
