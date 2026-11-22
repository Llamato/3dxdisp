#include <stdio.h>
#include <string.h>
#include "3dxdisp.h"

enum Filetypes  {
    PACKED,
    UNPACKED,
    UNKNOWN
};

int endsWith(const char *str, const char *suffix) {
    if (!str || !suffix) return 0;
    size_t lenstr = strlen(str);
    size_t lensuffix = strlen(suffix);
    if (lensuffix >  lenstr) return 0;
    return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}

int main(int argc, char** argv) {
    //Catch incorrect usage
    if(tdx_open() == -1) {
        fprintf(stderr, "Spacepilot device could not be found.");
        return 1;
    }
    if(argc < 2) {
        fprintf(stderr, "No bitmap filename provided.");
        return 2;
    }

    //Determine input file format
    const char* filename = argv[1];
    enum Filetypes filetype = UNKNOWN;
    if(endsWith(filename, ".packed") || (argc > 2 && !strcmp(argv[2], "packed"))) {
        filetype = PACKED;
    }else if(endsWith(filename, ".unpacked") || (argc > 2 && !strcmp(argv[2], "unpacked"))) {
        filetype = UNPACKED;
    }
    if(filetype == UNKNOWN) {
        fprintf(stderr, "Filetype of %s could not be determined\n", filename);
        return 3;
    }

    //Read input file
    FILE* fileDescriptor = fopen(filename, "r");
    if(fileDescriptor == NULL) {
        fprintf(stderr, "Unable to open %s\n", filename);
        return 3;
    }
    unsigned char bitmap[240*64*8];
    fread(bitmap, 240*64, filetype == PACKED ? 1 : 8, fileDescriptor);

    //Write input file contents to display
    if(filetype == PACKED) {
        tdx_blit_packed(0, 0, 240, 64, bitmap);
    }else{
        tdx_blit(0, 0, 240, 64, bitmap);
    }
    tdx_update();
    
    //End of line
    fclose(fileDescriptor);
    tdx_close();
    return 0;
}   