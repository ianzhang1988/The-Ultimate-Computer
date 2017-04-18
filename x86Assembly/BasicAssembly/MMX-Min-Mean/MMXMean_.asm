	.model flat,c

	.code
	; extern "C" bool MMXMean_(char* src, int num, double *mean);
MMXMean_ proc
	push ebp
	mov ebp, esp
	sub esp, 8				; ��תΪdouble����¼��
	
	xor eax, eax			; ��շ���ֵ
	mov edx, [ebp+8]		; src
	mov ecx, [ebp+12]		; num
	shr ecx, 4				; һ�δ���16����

	pxor mm4, mm4			; ������
	pxor mm5, mm5			; ������
	pxor mm7, mm7			; ������unpackʱ�ṩ0

	; ����16�ֽ�����
@@: movq mm0, [edx]
	movq mm1, [edx+8]

	; ��չΪ��
	movq mm2, mm0
	movq mm3, mm1

	punpcklbw mm0, mm7  ;[edx]  �ĵ�λֵ
	punpcklbw mm1, mm7
	punpckhbw mm2, mm7	;[edx]  �ĸ�λֵ
	punpckhbw mm3, mm7

	paddw mm0, mm2		;[edx]  �ĺͣ����ִ��
	paddw mm1, mm3

	paddw mm0, mm1		;16���ֽ� 16����������ת��Ϊ4���ֵĺ�

	; ��������4���ֵĺͣ��ӵ�4��˫���У��õ�����mm�Ĵ���
	movq mm1, mm0
	punpcklwd mm0, mm7
	punpckhwd mm1, mm7

	paddd mm4, mm0
	paddd mm5, mm1

	add edx, 16
	dec ecx
	jnz @B

	; ���mm4��mm5�����4��˫�����
	paddd mm4, mm5
	pshufw mm5, mm4, 00001110b
	paddd mm4, mm5
	movd eax, mm4
	emms

	; �����ֵ ��x87ָ�
	mov dword ptr [ebp-8], eax
	mov dword ptr [ebp-4], 0
	fild qword ptr [ebp-8]		; st[0] sum
	fild dword ptr [ebp+12]		; st[0] n st[1] sum
	fdivp						; st[0] sum/n

	mov edx, [ebp+16]
	fstp real8 ptr [edx]
	mov eax, 1

	mov esp, ebp				; �����ʱ����
	pop ebp
	ret

MMXMean_ endp

	end