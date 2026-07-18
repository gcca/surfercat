module httplib;

import std::core::cinterop;

alias Server = void*;
alias Request = void*;
alias Response = void*;

alias Handler = fn void(Request request, Response response);

extern fn Server create() @cname("server_create");
extern fn void Server.destroy(self) @cname("server_destroy");
extern fn Server Server.get(self, ZString pattern, Handler handler) @cname("server_get");
extern fn Server Server.post(self, ZString pattern, Handler handler) @cname("server_post");
extern fn Server Server.put(self, ZString pattern, Handler handler) @cname("server_put");
extern fn Server Server.delete(self, ZString pattern, Handler handler) @cname("server_delete");
extern fn void Server.listen(self, ZString host, CInt port) @cname("server_listen");

extern fn String Request.body(self) @cname("request_body");

extern fn void Response.set_status(self, CInt status) @cname("response_set_status");
extern fn void Response.set_redirect(self, ZString url) @cname("response_set_redirect");
extern fn void Response._set_content(self, char* s, usz n, ZString content_type) @cname("response_set_content");

fn void Response.set_content(self, String s, ZString content_type) => self._set_content(s.ptr, s.len, content_type);