#include "mustacheshim.hpp"

#include <new>

#include "mustache.hpp"

struct Mustache {
  kainjow::mustache::mustache mustache;
};

struct Data {
  kainjow::mustache::data data;
};

Mustache *mustache_create(const char *source) {
  return new (std::nothrow) Mustache{kainjow::mustache::mustache{source}};
}

void mustache_destroy(Mustache *mustache) { delete mustache; }

void mustache_render(Mustache *mustache, Data *data, RenderHandler handler,
                     void *context) {
  mustache->mustache.render(data->data,
                            [handler, context](const std::string &chunk) {
                              handler(context, chunk.data(), chunk.size());
                            });
}

Data *data_create(void) { return new (std::nothrow) Data{}; }

void data_destroy(Data *data) { delete data; }

void data_setstring(Data *data, const char *key, const char *value) {
  data->data.set(key, value);
}

void data_setbool(Data *data, const char *key, bool value) {
  data->data.set(key, value);
}

void data_setdata(Data *data, const char *key, Data *value) {
  data->data.set(key, value->data);
}
