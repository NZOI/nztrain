#include <cstdio>

using namespace std;

int main() {
  FILE* in = fopen("add.in", "r");
  FILE* out = fopen("add.out", "w");
  int a,b;
  fscanf(in, "%d %d", &a, &b);
  int c = a+b;
  fprintf(out, "%d\n",c);
  return 0;
}
