	.model flat,c
	.const

	StartMinVal qword 0ffffffffffffffffh

	.code

; extern "C" char MMXMin_(char* src, int num );

MMXMin_ proc
	push ebp
	mov  ebp, esp

	; ʡ����Ч�Լ��

	mov ecx, [ebp+12] ; num
	shr ecx, 5        ; num /32 һ�μ���128λ4��mmx�Ĵ���

	mov edx, [ebp+8]    ; src

	; ��ʼ��mmx4567Ϊ���ֵ
	movq mm4, [StartMinVal]
	movq mm5, mm4
	movq mm6, mm4
	movq mm7, mm4

	; loop �Ƚ�
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

	; ��mm4567���ҳ���С��ֵ

	pminub mm4, mm6
	pminub mm5, mm7

	pminub mm4, mm5

	; �������е���Сֵ����mm4���ˣ�ʹ��shuffle�ķ�ʽ�����Ƚϵ�λת��
	pshufw mm0, mm4, 00001110b
	pminub mm4, mm0
	pshufw mm0, mm4, 00000001b
	pminub mm4, mm0

	pextrw eax, mm4, 0

	cmp ah, al
	jae @f
	xchg ah, al; ����ah��al
@@: mov ah, 0; ah ����

Done:
	emms
	pop ebp
	ret

MMXMin_ endp
	end