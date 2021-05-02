int initialized = 0;

typedef unsigned long long size_t;

typedef struct {
	unsigned char magic[2];
	unsigned char mode;
	unsigned char charsize;
} FontHeader;

typedef struct {
	FontHeader* fontHeader;
	void* glyphBuffer;
} Font;

typedef struct {
    int mode, shutdown;
} KernelData;

typedef struct {
	void* Address;
	size_t Size;
	unsigned int Width, Height;
	unsigned int PPSL;
} Framebuffer;

typedef struct {
	Framebuffer* framebuffer;
	Font* font;
} BootData;

typedef struct {
    unsigned int X;
    unsigned int Y;
} Point;

void setpixel(void* Address, unsigned int PPSL, unsigned int x, unsigned int y, unsigned int color) {
    unsigned int* pixPtr = (unsigned int*)Address;
    *(unsigned int*)(pixPtr + x + (y * PPSL)) = color;
}

void putChar(Framebuffer* framebuffer, Font* font, unsigned int colour, char chr, unsigned int xOff, unsigned int yOff)
{
    unsigned int* pixPtr = (unsigned int*)framebuffer->Address;
    char* fontPtr = font->glyphBuffer + (chr * font->fontHeader->charsize);
    for (unsigned long y = yOff; y < yOff + 16; y++){
        for (unsigned long x = xOff; x < xOff+8; x++){
            if ((*fontPtr & (0b10000000 >> (x - xOff))) > 0){
                    *(unsigned int*)(pixPtr + x + (y * framebuffer->PPSL)) = colour;
                }

        }
        fontPtr++;
    }
}

Point CursorPosition;
void Print(Framebuffer* framebuffer, Font* psf1_font, unsigned int colour, char* str)
{
    
    char* chr = str;
    while(*chr != 0){
        putChar(framebuffer, psf1_font, colour, *chr, CursorPosition.X, CursorPosition.Y);
        CursorPosition.X+=8;
        if(CursorPosition.X + 8 > framebuffer->Width)
        {
            CursorPosition.X = 0;
            CursorPosition.Y += 16;
        }
        chr++;
    }
}

KernelData* main(BootData* bootdata) {
    KernelData* kernelData;
    kernelData->mode = 22;
    kernelData->shutdown = 0;
    if (initialized) {
        //for (unsigned int x = 0;x<bootdata->framebuffer->Width/2;x++) *(unsigned int*)((unsigned int*) bootdata->framebuffer->Address+x+(50*bootdata->framebuffer->PPSL)) = 0xFFFFFF;
        //putchar(0xFFFFFF, 'A', 0, 0);
        //*(unsigned int*)((unsigned int*) bootdata->Address+22+(22*bootdata->PPSL)) = 0xFFFFFF;
        CursorPosition.X = 10;
        CursorPosition.Y = 10;
        Print(bootdata->framebuffer, bootdata->font, 0xffffffff, "Hello, World!");
        while(1) {}
        return kernelData;
    } else initialized = 1;
    return kernelData;
}