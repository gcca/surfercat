module surfercat::handling::auth::routes;

import httplib;
import surfercat::handling::auth::handlers;

fn void init_routes(httplib::Server server)
{
  server
    .post("/surfercat/auth/signin", &handlers::signin_post)
    .get("/surfercat/auth/o/token", &handlers::o_token)
    .get("/surfercat/auth/o/check", &handlers::o_check);
}
