// Options:   --no-arrays --no-pointers --no-structs --no-unions --argc --no-bitfields --checksum --comma-operators --compound-assignment --concise --consts --divs --embedded-assigns --pre-incr-operator --pre-decr-operator --post-incr-operator --post-decr-operator --unary-plus-operator --jumps --longlong --int8 --uint8 --no-float --main --math64 --muls --safe-math --no-packed-struct --no-paranoid --no-volatiles --no-volatile-pointers --const-pointers --no-builtins --max-array-dim 1 --max-array-len-per-dim 4 --max-block-depth 1 --max-block-size 4 --max-expr-complexity 1 --max-funcs 1 --max-pointer-depth 2 --max-struct-fields 2 --max-union-fields 2 -o csmith_928.c
#include "csmith.h"


static long __undefined;



static uint32_t g_2 = 0x92BEAA32L;
static uint64_t g_5 = 18446744073709551615UL;
static int64_t g_13 = (-7L);
static uint32_t g_14 = 0x807383CCL;
static uint32_t g_17 = 0x890FC520L;
static uint32_t g_19 = 0x9D70CADDL;



static int8_t  func_1(void);




static int8_t  func_1(void)
{ 
    uint32_t l_3 = 0x9F7FD1E8L;
    uint32_t l_8 = 0x82ABBF9AL;
    uint16_t l_9 = 0xB49DL;
    int32_t l_11 = 0xAD5A519DL;
    if (g_2)
    { 
        int16_t l_4 = 0xC633L;
        l_4 = l_3;
        ++g_5;
        return g_5;
    }
    else
    { 
        l_8 &= l_3;
    }
    if (l_9)
    { 
        uint32_t l_10 = 4294967288UL;
        int32_t l_12 = 0L;
        l_11 = l_10;
        g_14++;
    }
    else
    { 
        uint8_t l_18 = 0x39L;
        g_17 = g_13;
        l_18 |= 0xD46758E3L;
    }
    ++g_19;
    return l_3;
}





int main (int argc, char* argv[])
{
    int print_hash_value = 0;
    if (argc == 2 && strcmp(argv[1], "1") == 0) print_hash_value = 1;
    platform_main_begin();
    crc32_gentab();
    func_1();
    transparent_crc(g_2, "g_2", print_hash_value);
    transparent_crc(g_5, "g_5", print_hash_value);
    transparent_crc(g_13, "g_13", print_hash_value);
    transparent_crc(g_14, "g_14", print_hash_value);
    transparent_crc(g_17, "g_17", print_hash_value);
    transparent_crc(g_19, "g_19", print_hash_value);
    platform_main_end(crc32_context ^ 0xFFFFFFFFUL, print_hash_value);
    return 0;
}
