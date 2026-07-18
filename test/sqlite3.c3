module sqlite3_test;

import sqlite3;
import std::core::test;
import std::io;
import std::io::file;

const String DATABASE_PATH = "build/sqlite3-test.db";

fn void create_database()
{
	File database_file = file::open(DATABASE_PATH, "wb")!!;
	database_file.close()!!;

	sqlite3::Database database = sqlite3::open_rw(DATABASE_PATH)!!;
	defer database.close();

	sqlite3::Statement statement = database.prepare(
		"CREATE TABLE items (name TEXT NOT NULL, quantity INTEGER NOT NULL, payload BLOB NOT NULL)"
	)!!;
	defer statement.finalize();
	test::eq(sqlite3::Step.DONE, statement.step()!!);
}

fn void insert_item()
{
	sqlite3::Database database = sqlite3::open_rw(DATABASE_PATH)!!;
	defer database.close();

	sqlite3::Statement statement = database.prepare("INSERT INTO items (name, quantity, payload) VALUES (?, ?, ?)")!!;
	defer statement.finalize();

	char[3] payload = { 0, 0x7f, 0xff };
	statement.bind_text(1, "surfercat")!!;
	statement.bind_int64(2, 42)!!;
	statement.bind_blob(3, (String)payload[..])!!;
	test::eq(sqlite3::Step.DONE, statement.step()!!);
}

fn void verify_item()
{
	sqlite3::Database database = sqlite3::open_ro(DATABASE_PATH)!!;
	defer database.close();

	sqlite3::Statement statement = database.prepare("SELECT name, quantity, payload FROM items")!!;
	defer statement.finalize();

	test::eq(sqlite3::Step.ROW, statement.step()!!);
	test::eq("surfercat", statement.column_text(0));
	test::eq((long)42, statement.column_int(1));

	String payload = statement.column_blob(2);
	test::@check(payload.len == 3);
	test::eq((char)0, payload[0]);
	test::eq((char)0x7f, payload[1]);
	test::eq((char)0xff, payload[2]);
	test::eq(sqlite3::Step.DONE, statement.step()!!);
}

fn void test_read_write_database() @test
{
	file::delete(DATABASE_PATH);
	defer file::delete(DATABASE_PATH);

	create_database();
	insert_item();
	verify_item();
}