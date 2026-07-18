module surfercat::handling::auth::handlers;

import httplib;
import yyjson;

fn void o_token(httplib::Request, httplib::Response res)
{
	yyjson::MutDoc doc = yyjson::mut_doc_new();
	defer doc.free();

	yyjson::MutVal root = doc.obj();
	doc.obj_add_str(root, "message", "men at work");
	doc.set_root(root);

	ZString json = doc.writes();
	defer yyjson::freezs(json);

	res.set_status(400);
	res.set_content(json.str_view(), "application/json");
}