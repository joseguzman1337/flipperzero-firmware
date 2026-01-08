#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

typedef intptr_t ffi_word_t;
struct ffi_arg;
typedef void(ffi_fn_t)(void);

void ffi_set_word(struct ffi_arg* arg, ffi_word_t v) {}
void ffi_set_ptr(struct ffi_arg* arg, void* v) {}
void ffi_set_bool(struct ffi_arg* arg, bool v) {}
void ffi_set_double(struct ffi_arg* arg, double v) {}
void ffi_set_float(struct ffi_arg* arg, float v) {}
int ffi_call_mjs(ffi_fn_t* func, int nargs, struct ffi_arg* res, struct ffi_arg* args) { return 0; }
char *cs_read_file(const char *path, size_t *size) { return NULL; }
