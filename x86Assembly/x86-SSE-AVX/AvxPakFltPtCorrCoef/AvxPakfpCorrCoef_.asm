	.model flat, c
	.code
	extern	CcEpsilon:real8	

; bool AvxPfpCorrCoef_(const double* x, const double* y, int n, double sums[5], double* rho)
;
; ����Թ�ʽ��
;                            n*sum(xi*yi) - sum(xi)*sum(yi)
; coef = ---------------------------------------------------------------
;         sqrt( n*sum(xi^2) - sum(xi)^2 ) * sqrt( n*sum(yi^2) - sum(yi)^2 )
;
; ��Ҫ�� sum(xi*yi) sum(xi) sum(yi) sum(xi^2) sum(yi^2)

AvxPfpCorrCoef_ proc
	push ebp
	mov ebp, esp

	; ��ʼ������֤
	mov eax, [ebp+8]
	test eax, 1fh
	jnz BadArg	
	mov edx, [ebp+12]
	test edx, 1fh		; û�ж���
	jnz BadArg	
	mov ecx, [ebp+16]
	cmp ecx,4			; С��4
	jl BadArg
	test ecx, 3			; 4�ı���
	jnz BadArg
	shr ecx,2			; һ�δ���4��˫�֣�ѭ����������4��

	; sum(xi*yi) sum(xi) sum(yi) sum(xi^2) sum(yi^2)
	; ymm3       ymm4    ymm5    ymm6      ymm7
	
	vxorpd ymm3, ymm3, ymm3
	vmovapd	ymm4, ymm3
	vmovapd	ymm5, ymm3
	vmovapd	ymm6, ymm3
	vmovapd	ymm7, ymm3

	; ѭ������������
@@:	vmovapd	ymm0, ymmword ptr [eax] ; xi
	vmovapd	ymm1, ymmword ptr [edx] ; yi
	vmulpd	ymm2, ymm0, ymm1		; xi*yi
	vaddpd	ymm3, ymm3, ymm2		; sum(xi*yi)
	vaddpd	ymm4, ymm4, ymm0		; sum(xi)
	vaddpd	ymm5, ymm5, ymm1		; sum(yi)
	vmulpd	ymm2, ymm0, ymm0		; xi*xi
	vaddpd	ymm6, ymm6, ymm2		; sum(xi^2)
	vmulpd	ymm2, ymm1, ymm1		; yi*yi
	vaddpd	ymm7, ymm7, ymm2		; sum(yi^2)

	add eax, 32
	add edx, 32
	dec ecx
	jnz @B

	; ���� ymm3-7 ���������ݵĺͣ�������ymm���������ĺ�
	vextractf128	xmm0, ymm3, 1		; ymm3�еĸ�λ�ŵ�xmm0��
	vaddpd			xmm3, xmm3, xmm0
	vhaddpd			xmm3, xmm3, xmm3	; xmm3��λ�д�ŵľ��� sum(xi*yi)
	vextractf128	xmm0, ymm4, 1		; ymm3�еĸ�λ�ŵ�xmm0��
	vaddpd			xmm4, xmm4, xmm0
	vhaddpd			xmm4, xmm4, xmm4	
	vextractf128	xmm0, ymm5, 1		
	vaddpd			xmm5, xmm5, xmm0
	vhaddpd			xmm5, xmm5, xmm5	
	vextractf128	xmm0, ymm6, 1		
	vaddpd			xmm6, xmm6, xmm0
	vhaddpd			xmm6, xmm6, xmm6	
	vextractf128	xmm0, ymm7, 1		
	vaddpd			xmm7, xmm7, xmm0
	vhaddpd			xmm7, xmm7, xmm7

	; ����sum
	mov edx, [ebp + 20]
	vmovsd real8 ptr [edx],		xmm4
	vmovsd real8 ptr [edx+8],	xmm5
	vmovsd real8 ptr [edx+16],	xmm6
	vmovsd real8 ptr [edx+24],	xmm7
	vmovsd real8 ptr [edx+32],	xmm3


	; ��nת��Ϊ˫����
	vcvtsi2sd xmm2, xmm2, dword ptr [ebp+16]

	; �������
	vmulsd	xmm0, xmm2, xmm3
	vmulsd	xmm1, xmm4, xmm5
	vsubsd	xmm3, xmm0, xmm1		; xmm3 �ӹ�ʽ�Ͽ������治���ˣ����Է��ӵĽ������������

	; �����ĸ
	vmulsd	xmm0, xmm2, xmm6
	vmulsd	xmm1, xmm4, xmm4
	vsubsd	xmm0, xmm0, xmm1
	vsqrtsd	xmm6, xmm0, xmm0		; xmm6 �������ˣ������ĸ��ǰ�벿��

	vmulsd	xmm0, xmm2, xmm7
	vmulsd	xmm1, xmm5, xmm5
	vsubsd	xmm0, xmm0, xmm1
	vsqrtsd	xmm0, xmm0, xmm0

	vmulsd	xmm6, xmm6, xmm0		; xmm6 �����ĸ

	; ȷ�� ��ĸ xmm6 ������
	vcomisd	xmm6, [CcEpsilon]
	setae al
	jb BadDe

	; ������ض�
	vdivsd	xmm0, xmm3, xmm6
	mov edx, [ebp+24]
	vmovsd	real8 ptr [edx], xmm0
	jmp Done

BadDe:
	vxorpd	xmm0, xmm0, xmm0
	mov edx, [ebp+24]
	vmovsd	real8 ptr [edx], xmm0

BadArg:
	xor eax, eax

Done:
	pop ebp
	ret

AvxPfpCorrCoef_ endp
	end