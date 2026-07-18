module surfercat::handling::auth::handlers;

import httplib;
import yyjson;

const String MESSAGE_JSON = "{\"message\":\"men at work\"}";

fn void o_check(httplib::Request, httplib::Response res)
{
	yyjson::MutDoc doc = yyjson::mut_doc_new();
	if (!doc.is_valid())
	{
		res.set_content(MESSAGE_JSON, "application/json");
		return;
	}
	defer doc.free();

	yyjson::MutVal root = doc.obj();
	if (!root.is_valid() || !doc.obj_add_str(root, "message", "men at work"))
	{
		res.set_content(MESSAGE_JSON, "application/json");
		return;
	}
	doc.set_root(root);

	ZString json = doc.writes();
	if (json == null)
	{
		res.set_content(MESSAGE_JSON, "application/json");
		return;
	}
	defer yyjson::freezs(json);

	res.set_status(400);
	res.set_content(json.str_view(), "application/json");
}