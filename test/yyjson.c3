module yyjson_test;

import yyjson;
import std::core::test;

fn void test_mutable_document() @test
{
	yyjson::MutDoc document = yyjson::mut_doc_new();
	test::@check(document.is_valid());
	defer document.free();

	yyjson::MutVal root = document.obj();
	test::@check(root.is_valid());
	document.set_root(root);

	test::@check(document.obj_add_str(root, "name", "Mash"));
	test::@check(document.obj_add_int(root, "star", 4));

	int[4] hit_values   = { 2, 2, 1, 3 };
	yyjson::MutVal hits = document.arr_with_sint32(hit_values[..]);
	test::@check(hits.is_valid());
	test::@check(document.obj_add_val(root, "hits", hits));

	usz json_length;
	ZString json = document.write(yyjson::WriteFlag.NOFLAG, &json_length);
	test::@check(json != null);
	defer yyjson::freezs(json);

	test::eq("{\"name\":\"Mash\",\"star\":4,\"hits\":[2,2,1,3]}", (String)json[:json_length]);
}

fn void test_read_string_field() @test
{
	yyjson::Doc document = yyjson::reads("{\"name\":\"Mash\",\"star\":4}");
	defer document.free();

	yyjson::Val root = document.get_root();
	test::@check(root.is_valid());

	yyjson::Val name = root.get("name");
	test::@check(name.is_valid());
	test::@check(name.is_str());
	test::eq("Mash", name.get_str());

	yyjson::Val star = root.get("star");
	test::@check(star.is_valid());
	test::@check(!star.is_str());
	test::eq("", star.get_str());
}

fn void test_read_missing_key() @test
{
	yyjson::Doc document = yyjson::reads("{\"name\":\"Mash\"}");
	defer document.free();

	yyjson::Val root = document.get_root();
	test::@check(root.is_valid());

	yyjson::Val absent = root.get("absent");
	test::@check(!absent.is_valid());
	test::eq("", absent.get_str());
}

fn void test_read_invalid_json() @test
{
	yyjson::Doc document = yyjson::reads("{ this is not valid json");
	defer document.free();

	yyjson::Val root = document.get_root();
	test::@check(!root.is_valid());
}

fn void test_write_read_roundtrip() @test
{
	yyjson::MutDoc document = yyjson::mut_doc_new();
	test::@check(document.is_valid());
	defer document.free();

	yyjson::MutVal root = document.obj();
	document.set_root(root);
	test::@check(document.obj_add_str(root, "kind", "cat"));

	ZString json = document.writes();
	test::@check(json != null);
	defer yyjson::freezs(json);

	yyjson::Doc parsed = yyjson::reads(json.str_view());
	defer parsed.free();

	yyjson::Val kind = parsed.get_root().get("kind");
	test::@check(kind.is_str());
	test::eq("cat", kind.get_str());
}

fn void test_write_pretty_is_larger() @test
{
	yyjson::MutDoc document = yyjson::mut_doc_new();
	test::@check(document.is_valid());
	defer document.free();

	yyjson::MutVal root = document.obj();
	document.set_root(root);
	test::@check(document.obj_add_str(root, "name", "Mash"));
	test::@check(document.obj_add_int(root, "star", 4));

	ZString minified = document.writes();
	test::@check(minified != null);
	defer yyjson::freezs(minified);

	usz pretty_length;
	ZString pretty = document.write(yyjson::WriteFlag.PRETTY, &pretty_length);
	test::@check(pretty != null);
	defer yyjson::freezs(pretty);

	test::@check(pretty_length > minified.str_view().len);
}