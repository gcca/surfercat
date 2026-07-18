#include "httplibshim.hpp"

#include <new>

#include "httplib.h"

struct Server {
  httplib::Server server;
};

struct Request {
  const httplib::Request &request;
};

struct Response {
  httplib::Response &response;
};

Server *server_create(void) { return new (std::nothrow) Server{}; }

void server_destroy(Server *server) { delete server; }

Server *server_get(Server *server, const char *pattern, Handler handler) {
  server->server.Get(pattern, [handler](const httplib::Request &request,
                                        httplib::Response &response) {
    Request shim_request{request};
    Response shim_response{response};
    handler(&shim_request, &shim_response);
  });
  return server;
}

Server *server_post(Server *server, const char *pattern, Handler handler) {
  server->server.Post(pattern, [handler](const httplib::Request &request,
                                         httplib::Response &response) {
    Request shim_request{request};
    Response shim_response{response};
    handler(&shim_request, &shim_response);
  });
  return server;
}

Server *server_put(Server *server, const char *pattern, Handler handler) {
  server->server.Put(pattern, [handler](const httplib::Request &request,
                                        httplib::Response &response) {
    Request shim_request{request};
    Response shim_response{response};
    handler(&shim_request, &shim_response);
  });
  return server;
}

Server *server_delete(Server *server, const char *pattern, Handler handler) {
  server->server.Delete(pattern, [handler](const httplib::Request &request,
                                           httplib::Response &response) {
    Request shim_request{request};
    Response shim_response{response};
    handler(&shim_request, &shim_response);
  });
  return server;
}

void server_listen(Server *server, const char *host, int port) {
  server->server.listen(host, port);
}

String request_body(Request *request) {
  return String{request->request.body.data(), request->request.body.length()};
}

void response_set_status(Response *response, int status) {
  response->response.status = status;
}

void response_set_redirect(Response *response, const char *url) {
  response->response.set_redirect(url);
}

void response_set_content(Response *response, const char *content,
                          size_t length, const char *content_type) {
  response->response.set_content(content, length, content_type);
}
