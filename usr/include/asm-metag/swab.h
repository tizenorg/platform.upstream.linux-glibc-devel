#ifndef __ASM_METAG_SWAB_H
#define __ASM_METAG_SWAB_H


#include <linux/types.h>
#include <asm-generic/swab.h>

static __inline__  __u16 __arch_swab16(__u16 x)
{
	return __builtin_metag_bswaps(x);
}
#define __arch_swab16 __arch_swab16

static __inline__  __u32 __arch_swab32(__u32 x)
{
	return __builtin_metag_bswap(x);
}
#define __arch_swab32 __arch_swab32

static __inline__  __u64 __arch_swab64(__u64 x)
{
	return __builtin_metag_bswapll(x);
}
#define __arch_swab64 __arch_swab64

#endif /* __ASM_METAG_SWAB_H */
