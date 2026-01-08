#include <stdio.h>
#include "mjs.h"

int main(void) {
  struct mjs *mjs = mjs_create(NULL);
  mjs_val_t res;
  mjs_err_t err;

  // Test case 1: Prefix increment on simple variable
  printf("Testing prefix increment on simple variable...\n");
  const char *src1 = "let a = 1; ++a;";
  err = mjs_exec(mjs, src1, &res);
  if (err != MJS_OK) {
    printf("Error: %s\n", mjs_strerror(mjs, err));
    mjs_print_error(mjs, stdout, NULL, 1);
  } else {
    printf("Result: %g\n", mjs_get_double(mjs, res));
    if (mjs_get_double(mjs, res) == 2.0) {
        printf("PASS\n");
    } else {
        printf("FAIL\n");
    }
  }

  // Test case 2: Prefix increment on object property (the issue)
  printf("Testing prefix increment on object property...\n");
  const char *src2 = "let o = {b: 1}; ++o.b;";
  err = mjs_exec(mjs, src2, &res);
  if (err != MJS_OK) {
    printf("Error: %s\n", mjs_strerror(mjs, err));
    mjs_print_error(mjs, stdout, NULL, 1);
  } else {
    printf("Result: %g\n", mjs_get_double(mjs, res));
    // Verify side effect
    mjs_val_t o = mjs_get(mjs, mjs_get_global(mjs), "o", ~0);
    mjs_val_t b = mjs_get(mjs, o, "b", ~0);
    double b_val = mjs_get_double(mjs, b);
    printf("o.b: %g\n", b_val);

    if (mjs_get_double(mjs, res) == 2.0 && b_val == 2.0) {
        printf("PASS\n");
    } else {
        printf("FAIL\n");
    }
  }
  
  // Test case 3: Prefix increment on nested object property
  printf("Testing prefix increment on nested object property...\n");
  const char *src3 = "let obj = {inner: {val: 5}}; ++obj.inner.val;";
  err = mjs_exec(mjs, src3, &res);
  if (err != MJS_OK) {
    printf("Error: %s\n", mjs_strerror(mjs, err));
    mjs_print_error(mjs, stdout, NULL, 1);
  } else {
    printf("Result: %g\n", mjs_get_double(mjs, res));
     if (mjs_get_double(mjs, res) == 6.0) {
        printf("PASS\n");
    } else {
        printf("FAIL\n");
    }
  }
  
  // Test case 4: Prefix increment with bracket access
  printf("Testing prefix increment with bracket access...\n");
  const char *src4 = "let arr = [10]; ++arr[0];";
  err = mjs_exec(mjs, src4, &res);
  if (err != MJS_OK) {
    printf("Error: %s\n", mjs_strerror(mjs, err));
    mjs_print_error(mjs, stdout, NULL, 1);
  } else {
    printf("Result: %g\n", mjs_get_double(mjs, res));
     if (mjs_get_double(mjs, res) == 11.0) {
        printf("PASS\n");
    } else {
        printf("FAIL\n");
    }
  }

  mjs_destroy(mjs);
  return 0;
}
