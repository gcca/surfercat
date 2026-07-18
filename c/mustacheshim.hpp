#pragma once

#include <stdbool.h>
#include <stddef.h>

typedef struct Mustache Mustache;
typedef struct Data Data;

typedef void (*RenderHandler)(void *context, const char *chunk, size_t length);

#ifdef __cplusplus
extern "C" {
#endif

Mustache *mustache_create(const char *source);
void mustache_destroy(Mustache *mustache);
void mustache_render(Mustache *mustache, Data *data, RenderHandler handler,
                     void *context);

Data *data_create(void);
void data_destroy(Data *data);
void data_setstring(Data *data, const char *key, const char *value);
void data_setbool(Data *data, const char *key, bool value);
void data_setdata(Data *data, const char *key, Data *value);

#ifdef __cplusplus
}
#endif
