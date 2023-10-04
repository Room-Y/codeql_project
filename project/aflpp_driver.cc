#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *buf, size_t len);

char * ReadFile(char * path, int *length){
  FILE * pfile;
  char * data;
  pfile = fopen(path, "rb");
  if (pfile == NULL) {
    return NULL;
  }
  fseek(pfile, 0, SEEK_END);
  *length = ftell(pfile); 
  data = (char *)malloc((*length + 1) * sizeof(char));
  rewind(pfile);
  *length = fread(data, 1, *length, pfile);
  data[*length] = '\0';
  fclose(pfile);
  return data;
 }

int main(int argc, char *argv[]) {
   int len = 0;
   uint8_t *buf = (uint8_t*)ReadFile(argv[1],&len);
   LLVMFuzzerTestOneInput(buf, len);
   free(buf);
}

