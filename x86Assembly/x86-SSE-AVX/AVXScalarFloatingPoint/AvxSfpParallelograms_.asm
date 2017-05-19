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

; bool AvxSfpParallelograms_(Parallelogram* pdata);
; 局部栈:	[ebp-8], x87 输出计算结果
;			[ebp-16], 调用sin时输入角度

AvxSfpParallelograms_ proc
	push ebp
	mov ebp, esp

	sub esp, 16 ;局部栈

	mov edx, [ebp+8] ; pdata

	vmovsd xmm6, real8 ptr [r8_180p0] ; 180
	vxorpd xmm7, xmm7, xmm7 ; 0.0
	
	; 验证A B
	vmovsd xmm0, [edx + Parallelograms.A]
	vmovsd xmm1, [edx + Parallelograms.B]
	vcomisd xmm0, xmm7
	jp InvalidValue
	jbe InvalidValue
	vcomisd xmm1, xmm7
	jp InvalidValue
	jbe InvalidValue

	; 验证 Alpha
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
	; 因为使用了3目的方式avx指令一步实现了原来3步的运算

	vsubsd xmm0, xmm6, [edx + Parallelograms.Alpha] ; 与前三句等价

	vmovsd real8 ptr [edx + Parallelograms.Beta], xmm0

	; get H -> A * sin(alpha)
	;movsd xmm0, [edx + Parallelograms.Alpha]
	;mulsd xmm0, real8 ptr [DegToRad]
	; 这里3目运算就没有提升，2目就够了
	vmovsd xmm0, [edx + Parallelograms.Alpha]
	vmulsd xmm0, xmm0, real8 ptr [DegToRad]
	vmovsd real8 ptr [ebp-16], xmm0 ; 保留Rad，为后面的计算用 —— 实际上没用。。

	push edx					; 易变寄存器，调用其他函数时要保存起来，或者使用ebx，这个非易变的寄存器
	
	; 用于传递给sin函数的栈
	sub esp, 8
	vmovsd real8 ptr [esp], xmm0 ; 传参数
	call sin					; 注意，调用结束以后，VC++不保证xmm寄存器保留原来的值
	fstp real8 ptr [ebp-8] ; [ebp-8] sin(alpha)
	add esp, 8 ; 恢复调用使用的栈

	pop edx

	; A * sin(alpha)
	; movsd xmm0, real8 ptr [edx + Parallelograms.A]
	; mulsd xmm0, real8 ptr [ebp-8] ; H
	; movsd real8 ptr[edx + Parallelograms.H], xmm0
	; B*H
	; mulsd xmm0, real8 ptr [edx + Parallelograms.B]
	; movsd real8 ptr[edx + Parallelograms.Area], xmm0

	; avx 可以把保存放到后面
	vmovsd xmm0, real8 ptr [ebp-8] ; sin(alpha)
	vmulsd xmm2, xmm0, real8 ptr [edx + Parallelograms.A] ; xmm2 A*sin(alpha) -> H
	vmulsd xmm3, xmm2, real8 ptr [edx + Parallelograms.B] ; xmm3 H*B -> area

	vmovsd real8 ptr[edx + Parallelograms.H], xmm2
	vmovsd real8 ptr[edx + Parallelograms.Area], xmm3

	mov dword ptr [edx+Parallelograms.BadVal], 0 ; 计算没有问题

Done:
	vzeroupper ; 清空ymm高128位，避免avx到see潜在的切换
	
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