#include <stdlib.h>

div_t div(int numer, int denom) {
  div_t x;
  x.quot = numer / denom;
  x.rem = numer % denom;
  return x;
}