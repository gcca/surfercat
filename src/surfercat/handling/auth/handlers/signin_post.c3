module surfercat::handling::auth::handlers;

import httplib;
import yyjson;

fn void signin_post(httplib::Request req, httplib::Response res)
{
  yyjson::Doc doc = yyjson::reads(req.body());
  defer doc.free();

  yyjson::Val root     = doc.get_root();
  yyjson::Val username = root.get("username");
  yyjson::Val password = root.get("password");

  String username_s = username.get_str();
  String password_s = password.get_str();

  @pool_init(mem, 4096)
  {
    String body = string::tformat(`{"u":"%s","p":"%s"}`, username_s, password_s);
    res.set_content(body, "application/json");
  };
}
