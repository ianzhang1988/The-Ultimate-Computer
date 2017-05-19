	.model flat, c

; ƽ���ı��νṹ�壬��C�еĶ�Ӧ
Parallelograms struct
A		real8 ?
B		real8 ?
Alpha	real8 ?
Beta	real8 ?
H		real8 ?
Area	real8 ?
BadVal	byte ?
Pad		byte 7 dup(?)
Parallelograms ends

	.const
SizeofParallelogramX86 dword size Parallelograms
r8_180p0	real8 180.0
r8_MinusOne real8 -1.0


	.code
	extern sin: proc, cos: proc
	extern DegToRad: real8

; bool AvxSfpParallelograms_(Parallelogram* pdata);
; �ֲ�ջ:	[ebp-8], x87 ���������
;			[ebp-16], ����sinʱ����Ƕ�

AvxSfpParallelograms_ proc
	push ebp
	mov ebp, esp

	sub esp, 16 ;�ֲ�ջ

	mov edx, [ebp+8] ; pdata

	vmovsd xmm6, real8 ptr [r8_180p0] ; 180
	vxorpd xmm7, xmm7, xmm7 ; 0.0
	
	; ��֤A B
	vmovsd xmm0, [edx + Parallelograms.A]
	vmovsd xmm1, [edx + Parallelograms.B]
	vcomisd xmm0, xmm7
	jp InvalidValue
	jbe InvalidValue
	vcomisd xmm1, xmm7
	jp InvalidValue
	jbe InvalidValue

	; ��֤ Alpha
	vmovsd xmm0, [edx + Parallelograms.Alpha]
	vcomisd xmm0, xmm7 ; compared to 0
	jp InvalidValue
	jbe InvalidValue
	vcomisd xmm0, real8 ptr [r8_180p0]
	jp InvalidValue
	jae InvalidValue	
	
	; get beta -> 180-Alpha

	;movsd xmm0, xmm6
	;movsd xmm1, [edx + Parallelograms.Alpha]
	;subsd xmm0, xmm1
	; ��Ϊʹ����3Ŀ�ķ�ʽavxָ��һ��ʵ����ԭ��3��������

	vsubsd xmm0, xmm6, [edx + Parallelograms.Alpha] ; ��ǰ����ȼ�

	vmovsd real8 ptr [edx + Parallelograms.Beta], xmm0

	; get H -> A * sin(alpha)
	;movsd xmm0, [edx + Parallelograms.Alpha]
	;mulsd xmm0, real8 ptr [DegToRad]
	; ����3Ŀ�����û��������2Ŀ�͹���
	vmovsd xmm0, [edx + Parallelograms.Alpha]
	vmulsd xmm0, xmm0, real8 ptr [DegToRad]
	vmovsd real8 ptr [ebp-16], xmm0 ; ����Rad��Ϊ����ļ����� ���� ʵ����û�á���

	push edx					; �ױ�Ĵ�����������������ʱҪ��������������ʹ��ebx��������ױ�ļĴ���
	
	; ���ڴ��ݸ�sin������ջ
	sub esp, 8
	vmovsd real8 ptr [esp], xmm0 ; ������
	call sin					; ע�⣬���ý����Ժ�VC++����֤xmm�Ĵ�������ԭ����ֵ
	fstp real8 ptr [ebp-8] ; [ebp-8] sin(alpha)
	add esp, 8 ; �ָ�����ʹ�õ�ջ

	pop edx

	; A * sin(alpha)
	; movsd xmm0, real8 ptr [edx + Parallelograms.A]
	; mulsd xmm0, real8 ptr [ebp-8] ; H
	; movsd real8 ptr[edx + Parallelograms.H], xmm0
	; B*H
	; mulsd xmm0, real8 ptr [edx + Parallelograms.B]
	; movsd real8 ptr[edx + Parallelograms.Area], xmm0

	; avx ���԰ѱ���ŵ�����
	vmovsd xmm0, real8 ptr [ebp-8] ; sin(alpha)
	vmulsd xmm2, xmm0, real8 ptr [edx + Parallelograms.A] ; xmm2 A*sin(alpha) -> H
	vmulsd xmm3, xmm2, real8 ptr [edx + Parallelograms.B] ; xmm3 H*B -> area

	vmovsd real8 ptr[edx + Parallelograms.H], xmm2
	vmovsd real8 ptr[edx + Parallelograms.Area], xmm3

	mov dword ptr [edx+Parallelograms.BadVal], 0 ; ����û������

Done:
	vzeroupper ; ���ymm��128λ������avx��seeǱ�ڵ��л�
	
	mov esp, ebp
	pop ebp
	ret

InvalidValue:
	vmovsd xmm0, real8 ptr [r8_MinusOne]
	vmovsd real8 ptr [edx+Parallelograms.A], xmm0
	vmovsd real8 ptr [edx+Parallelograms.B], xmm0
	vmovsd real8 ptr [edx+Parallelograms.Alpha], xmm0
	vmovsd real8 ptr [edx+Parallelograms.Beta], xmm0
	vmovsd real8 ptr [edx+Parallelograms.H], xmm0
	vmovsd real8 ptr [edx+Parallelograms.Area], xmm0
	mov dword ptr [edx+Parallelograms.BadVal], 1
	jmp Done

AvxSfpParallelograms_ endp
	end