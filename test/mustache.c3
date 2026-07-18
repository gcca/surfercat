module mustache_test;

import mustache;
import std::core::dstring;
import std::core::test;

fn void test_string() @test
{
	mustache::Mustache template = mustache::create("hello {{ test }}world");
	defer template.destroy();

	mustache::Data data = mustache::create_data();
	defer data.destroy();
	data.set_string("test", "outer");

	DString rendered = template.render(data);
	defer rendered.free();
	test::eq("hello outerworld", rendered.str_view());
}

fn void test_bool_true() @test
{
	mustache::Mustache template = mustache::create("hello {{# test }}world{{/ test }}");
	defer template.destroy();

	mustache::Data data = mustache::create_data();
	defer data.destroy();
	data.set_bool("test", true);

	DString rendered = template.render(data);
	defer rendered.free();
	test::eq("hello world", rendered.str_view());
}

fn void test_bool_false() @test
{
	mustache::Mustache template = mustache::create("hello {{# test }}world{{/ test }}");
	defer template.destroy();

	mustache::Data data = mustache::create_data();
	defer data.destroy();
	data.set_bool("test", false);

	DString rendered = template.render(data);
	defer rendered.free();
	test::eq("hello ", rendered.str_view());
}

fn void test_nested_data() @test
{
	mustache::Mustache template = mustache::create("hello {{ user.name }}");
	defer template.destroy();

	mustache::Data outer = mustache::create_data();
	defer outer.destroy();

	mustache::Data user = mustache::create_data();
	defer user.destroy();
	user.set_string("name", "surfercat");
	outer.set_data("user", user);

	DString rendered = template.render(outer);
	defer rendered.free();
	test::eq("hello surfercat", rendered.str_view());
}