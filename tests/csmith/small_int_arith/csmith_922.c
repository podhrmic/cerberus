// Options:   --no-arrays --no-pointers --no-structs --no-unions --argc --no-bitfields --checksum --comma-operators --compound-assignment --concise --consts --divs --embedded-assigns --pre-incr-operator --pre-decr-operator --post-incr-operator --post-decr-operator --unary-plus-operator --jumps --longlong --int8 --uint8 --no-float --main --math64 --muls --safe-math --no-packed-struct --no-paranoid --no-volatiles --no-volatile-pointers --const-pointers --no-builtins --max-array-dim 1 --max-array-len-per-dim 4 --max-block-depth 1 --max-block-size 4 --max-expr-complexity 1 --max-funcs 1 --max-pointer-depth 2 --max-struct-fields 2 --max-union-fields 2 -o csmith_922.c
#include "csmith.h"


static long __undefined;



static uint16_t g_2 = 0x53D0L;



static int64_t  func_1(void);




static int64_t  func_1(void)
{ 
    uint16_t l_6 = 65532UL;
    g_2 ^= 6L;
    for (g_2 = 0; (g_2 < 30); g_2 = safe_add_func_uint16_t_u_u(g_2, 3))
    { 
        int8_t l_5 = 0x1FL;
        l_5 |= g_2;
        if (g_2)
            continue;
    }
    return l_6;
}





int main (int argc, char* argv[])
{
    int print_hash_value = 0;
    if (argc == 2 && strcmp(argv[1], "1") == 0) print_hash_value = 1;
    platform_main_begin();
    crc32_gentab();
    func_1();
    transparent_crc(g_2, "g_2", print_hash_value);
    platform_main_end(crc32_context ^ 0xFFFFFFFFUL, print_hash_value);
    return 0;
}
