	.model flat,c

	.code
	; extern "C" bool MMXMean_(char* src, int num, double *mean);
MMXMean_ proc
	push ebp
	mov ebp, esp
	sub esp, 8				; 和转为double，记录和
	
	xor eax, eax			; 清空返回值
	mov edx, [ebp+8]		; src
	mov ecx, [ebp+12]		; num
	shr ecx, 4				; 一次处理16个数

	pxor mm4, mm4			; 保存结果
	pxor mm5, mm5			; 保存结果
	pxor mm7, mm7			; 用来在unpack时提供0

	; 加载16字节数据
@@: movq mm0, [edx]
	movq mm1, [edx+8]

	; 扩展为字
	movq mm2, mm0
	movq mm3, mm1

	punpcklbw mm0, mm7  ;[edx]  的低位值
	punpcklbw mm1, mm7
	punpckhbw mm2, mm7	;[edx]  的高位值
	punpckhbw mm3, mm7

	paddw mm0, mm2		;[edx]  的和，用字存放
	paddw mm1, mm3

	paddw mm0, mm1		;16个字节 16个符号整数转化为4个字的和

	; 把上述的4个字的和，加到4个双字中，用到两个mm寄存器
	movq mm1, mm0
	punpcklwd mm0, mm7
	punpckhwd mm1, mm7

	paddd mm4, mm0
	paddd mm5, mm1

	add edx, 16
	dec ecx
	jnz @B

	; 最后mm4和mm5保存的4个双字求和
	paddd mm4, mm5
	pshufw mm5, mm4, 00001110b
	paddd mm4, mm5
	movd eax, mm4
	emms

	; 计算均值 （x87指令）
	mov dword ptr [ebp-8], eax
	mov dword ptr [ebp-4], 0
	fild qword ptr [ebp-8]		; st[0] sum
	fild dword ptr [ebp+12]		; st[0] n st[1] sum
	fdivp						; st[0] sum/n

	mov edx, [ebp+16]
	fstp real8 ptr [edx]
	mov eax, 1

	mov esp, ebp				; 清空临时变量
	pop ebp
	ret

MMXMean_ endp

	end