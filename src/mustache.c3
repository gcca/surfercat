module mustache;

import std::core::dstring;

typedef Mustache = void*;
typedef Data = void*;

alias RenderHandler = fn void(void* context, char* chunk, usz length);

extern fn Mustache create(ZString source) @cname("mustache_create");
extern fn void Mustache.destroy(self) @cname("mustache_destroy");
extern fn void Mustache._render(self, Data data, RenderHandler handler, void* context) @cname("mustache_render");

extern fn Data create_data() @cname("data_create");
extern fn void Data.destroy(self) @cname("data_destroy");
extern fn void Data.set_string(self, ZString key, ZString value) @cname("data_setstring");
extern fn void Data.set_bool(self, ZString key, bool value) @cname("data_setbool");
extern fn void Data.set_data(self, ZString key, Data value) @cname("data_setdata");

struct RenderContext
{
	DString output;
}

fn void render_chunk(void* context, char* chunk, usz length)
{
	RenderContext* render_context = (RenderContext*)context;
	render_context.output.append_bytes(chunk[:length]);
}

fn DString Mustache.render(self, Data data, Allocator allocator = mem)
{
	RenderContext context;
	context.output.init(allocator);
	self._render(data, &render_chunk, &context);
	return context.output;
}