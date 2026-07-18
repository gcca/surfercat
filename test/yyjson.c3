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