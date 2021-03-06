#include <yaos/linkage.h>
#include <asm/cpufeature.h>
#include <asm/alternative-asm.h>

/*
 * Most CPUs support enhanced REP MOVSB/STOSB instructions. It is
 * recommended to use this when possible and we do use them by default.
 * If enhanced REP MOVSB/STOSB is not available, try to use fast string.
 * Otherwise, use original.
 */

/*
 * Zero a page.
 * %rdi	- page
 */
ENTRY(clear_4k_page)

	ALTERNATIVE_2 "jmp clear_page_orig", "", X86_FEATURE_REP_GOOD, \
		      "jmp clear_page_c_e", X86_FEATURE_ERMS

	movl $4096/8,%ecx
	xorl %eax,%eax
	rep stosq
	ret
ENDPROC(clear_4k_page)

ENTRY(clear_page_orig)

	xorl   %eax,%eax
	movl   $4096/64,%ecx
	.p2align 4
.Lloop:
	decl	%ecx
#define PUT(x) movq %rax,x*8(%rdi)
	movq %rax,(%rdi)
	PUT(1)
	PUT(2)
	PUT(3)
	PUT(4)
	PUT(5)
	PUT(6)
	PUT(7)
	leaq	64(%rdi),%rdi
	jnz	.Lloop
	nop
	ret
ENDPROC(clear_page_orig)

ENTRY(clear_page_c_e)
	movl $4096,%ecx
	xorl %eax,%eax
	rep stosb
	ret
ENDPROC(clear_page_c_e)
