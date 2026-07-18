#include <cstddef>
#include <cstdint>

#include "yyjson.h"

extern "C" {
void yyjson_doc_free_(yyjson_doc *doc) { yyjson_doc_free(doc); }

yyjson_val *yyjson_doc_get_root_(yyjson_doc *doc) {
  return yyjson_doc_get_root(doc);
}

yyjson_val *yyjson_obj_getn_(yyjson_val *obj, const char *_key,
                             std::size_t key_len) {
  return yyjson_obj_getn(obj, _key, key_len);
}

const char *unsafe_yyjson_get_str_(const yyjson_val *val) {
  return val->uni.str;
}

yyjson_type unsafe_yyjson_get_type_(const yyjson_val *val) {
  std::uint8_t tag = val->tag;
  return (yyjson_type)(tag & YYJSON_TYPE_MASK);
}

yyjson_mut_val *yyjson_mut_obj_(yyjson_mut_doc *doc) {
  return yyjson_mut_obj(doc);
}

void yyjson_mut_doc_set_root_(yyjson_mut_doc *doc, yyjson_mut_val *obj) {
  yyjson_mut_doc_set_root(doc, obj);
}

bool yyjson_mut_obj_add_str_(yyjson_mut_doc *doc, yyjson_mut_val *obj,
                             const char *key, const char *val) {
  return yyjson_mut_obj_add_str(doc, obj, key, val);
}

bool yyjson_mut_obj_add_int_(yyjson_mut_doc *doc, yyjson_mut_val *obj,
                             const char *key, std::int64_t val) {
  return yyjson_mut_obj_add_int(doc, obj, key, val);
}

yyjson_mut_val *yyjson_mut_arr_with_sint32_(yyjson_mut_doc *doc,
                                            const std::int32_t *vals,
                                            std::size_t count) {
  return yyjson_mut_arr_with_sint32(doc, vals, count);
}

bool yyjson_mut_obj_add_val_(yyjson_mut_doc *doc, yyjson_mut_val *obj,
                             const char *key, yyjson_mut_val *val) {
  return yyjson_mut_obj_add_val(doc, obj, key, val);
}
}
