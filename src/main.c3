module surfercat;

import std::io;
import httplib;

fn int main(String[] args)
{
	int port = 8000;

	httplib::Server server = httplib::create();
	if (server == null)
	{
		io::eprintn("Failed to create the HTTP server");
		return 1;
	}
	defer server.destroy();

	io::printfn("Listening on http://localhost:%d", port);

	surfercat::handling::auth::routes::init_routes(server);

	server.get("/", fn (request, response)
	{
		response.set_content("🍻", "text/plain");
	}).get("/surfercat/healthcheck", fn (request, response)
	{
		response.set_content("🍻", "text/plain");
	}).listen("0.0.0.0", port);

	return 0;
}