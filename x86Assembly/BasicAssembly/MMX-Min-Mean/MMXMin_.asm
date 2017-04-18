	.model flat,c
	.const

	StartMinVal qword 0ffffffffffffffffh

	.code

; extern "C" char MMXMin_(char* src, int num );

MMXMin_ proc
	push ebp
	mov  ebp, esp

	; 省略有效性检查

	mov ecx, [ebp+12] ; num
	shr ecx, 5        ; num /32 一次加载128位4个mmx寄存器

	mov edx, [ebp+8]    ; src

	; 初始化mmx4567为最大值
	movq mm4, [StartMinVal]
	movq mm5, mm4
	movq mm6, mm4
	movq mm7, mm4

	; loop 比较
@@:	movq mm0, [edx]
	movq mm1, [edx+8]
	movq mm2, [edx+16]
	movq mm3, [edx+24]

	pminub mm4, mm0
	pminub mm5, mm1
	pminub mm6, mm2
	pminub mm7, mm3

	add edx, 32
	dec ecx
	jnz @B

	; 从mm4567中找出最小的值

	pminub mm4, mm6
	pminub mm5, mm7

	pminub mm4, mm5

	; 现在所有的最小值都在mm4中了，使用shuffle的方式，将比较低位转移
	pshufw mm0, mm4, 00001110b
	pminub mm4, mm0
	pshufw mm0, mm4, 00000001b
	pminub mm4, mm0

	pextrw eax, mm4, 0

	cmp ah, al
	jae @f
	xchg ah, al; 交换ah，al
@@: mov ah, 0; ah 清零

Done:
	emms
	pop ebp
	ret

MMXMin_ endp
	end