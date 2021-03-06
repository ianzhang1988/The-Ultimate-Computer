	.model flat, c

; 平行四边形结构体，与C中的对应
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

; bool SseSfpParallelograms_(Parallelogram* pdata);
; 局部栈:	[ebp-8], x87 输出计算结果
;			[ebp-16], 调用sin时输入角度

SseSfpParallelograms_ proc
	push ebp
	mov ebp, esp

	sub esp, 16 ;局部栈

	mov edx, [ebp+8] ; pdata

	movsd xmm6, real8 ptr [r8_180p0] ; 180
	xorpd xmm7, xmm7 ; 0.0
	
	; 验证A B
	movsd xmm0, [edx + Parallelograms.A]
	movsd xmm1, [edx + Parallelograms.B]
	comisd xmm0, xmm7
	jp InvalidValue
	jbe InvalidValue
	comisd xmm1, xmm7
	jp InvalidValue
	jbe InvalidValue

	; 验证 Alpha
	movsd xmm0, [edx + Parallelograms.Alpha]
	comisd xmm0, xmm7 ; compared to 0
	jp InvalidValue
	jbe InvalidValue
	comisd xmm0, real8 ptr [r8_180p0]
	jp InvalidValue
	jae InvalidValue	
	
	; get beta -> 180-Alpha
	movsd xmm0, xmm6
	movsd xmm1, [edx + Parallelograms.Alpha]
	subsd xmm0, xmm1
	movsd real8 ptr [edx + Parallelograms.Beta], xmm0

	; get H -> A * sin(alpha)
	movsd xmm0, [edx + Parallelograms.Alpha]
	mulsd xmm0, real8 ptr [DegToRad]
	movsd real8 ptr [ebp-16], xmm0 ; 保留Rad，为后面的计算用 —— 实际上用。。

	push edx					; 易变寄存器，调用其他函数时要保存起来，或者使用ebx，这个非易变的寄存器
	
	; 用于传递给sin函数的栈
	sub esp, 8
	movsd real8 ptr [esp], xmm0 ; 传参数
	call sin					; 注意，调用结束以后，VC++不保证xmm寄存器保留原来的值
	fstp real8 ptr [ebp-8] ; [ebp-8] sin(alpha)
	add esp, 8 ; 恢复调用使用的栈

	pop edx
	movsd xmm0, real8 ptr [edx + Parallelograms.A]
	mulsd xmm0, real8 ptr [ebp-8] ; H
	movsd real8 ptr[edx + Parallelograms.H], xmm0

	; get Area -> B*H
	mulsd xmm0, real8 ptr [edx + Parallelograms.B]
	movsd real8 ptr[edx + Parallelograms.Area], xmm0

	mov dword ptr [edx+Parallelograms.BadVal], 0 ; 计算没有问题

Done:
	mov esp, ebp
	pop ebp
	ret

InvalidValue:
	movsd xmm0, real8 ptr [r8_MinusOne]
	movsd real8 ptr [edx+Parallelograms.A], xmm0
	movsd real8 ptr [edx+Parallelograms.B], xmm0
	movsd real8 ptr [edx+Parallelograms.Alpha], xmm0
	movsd real8 ptr [edx+Parallelograms.Beta], xmm0
	movsd real8 ptr [edx+Parallelograms.H], xmm0
	movsd real8 ptr [edx+Parallelograms.Area], xmm0
	mov dword ptr [edx+Parallelograms.BadVal], 1
	jmp Done

SseSfpParallelograms_ endp
	end