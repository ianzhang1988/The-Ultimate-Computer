	.model flat,c
	.code

; _Mat4x4Transpose macro
;
; Description:  This macro computes the transpose of a 4x4
;               single-precision floating-point matrix.
;
;   Input Matrix A      
;           a0 a1 a2 a3
;           b0 b1 b2 b3
;           c0 c1 c2 c3
;           d0 d1 d2 d3
;
;   Input Matrix                    Output Matrtix
;   memory  high -> low
;   xmm0    a3 a2 a1 a0             xmm4    d0 c0 b0 a0
;   xmm1    b3 b2 b1 b0             xmm5    d1 c1 b1 a1
;   xmm2    c3 c2 c1 c0             xmm6    d2 c2 b2 a2
;   xmm3    d3 d2 d1 d0             xmm7    d3 c3 b3 a3
;
; Note:     这里矩阵的转置是为了方面后面的乘法计算
;			xmm0 点积 xmm4 （假设xmm0，是刚加载的src1中的第一行）就可以直接得到c00
; 


;		没有转置前矩阵A和xmm寄存器的关系, xmm装载的是行向量，用x0 1 2 3表示
;		A:	x0
;			x1
;			x2
;			x3

_Mat4x4Transpose macro
        movaps xmm4,xmm0
        unpcklps xmm4,xmm1                  ;xmm4 = b1 a1 b0 a0
        unpckhps xmm0,xmm1                  ;xmm0 = b3 a3 b2 a2
        movaps xmm5,xmm2
        unpcklps xmm5,xmm3                  ;xmm5 = d1 c1 d0 c0
        unpckhps xmm2,xmm3                  ;xmm2 = d3 c3 d2 c2

;       注意这里，实际上用xmm0 2 4 5装下了所有的元素，xmm寄存器不再代表一行元素，代表一块
;		用X0 2 4 5 分别表示一个2x2的矩阵则A现在和xmm寄存器的关系是这样的
;		A：	X4 X0
;			X5 X2
;
;		这样X4 的低位两个元素和 X5 的低位两个元素合起来就是A的第一列
;		movlhps xmm4,xmm5 就把第一列放到了xmm4中


        movaps xmm1,xmm4
        movlhps xmm4,xmm5                   ;xmm4 = d0 c0 b0 a0
        movhlps xmm5,xmm1                   ;xmm5 = d1 c1 b1 a1
        movaps xmm6,xmm0
        movlhps xmm6,xmm2                   ;xmm6 = d2 c2 b2 a2
        movaps xmm7,xmm2
        movhlps xmm7,xmm0                   ;xmm7 = d3 c3 b2 a3
        endm

SsePfpMatrix4x4Multiply proc
	push ebp
	mov ebp, esp
	push ebx

	; 计算src2的转置
	mov ebx, [ebp+16]
	movaps xmm0, [ebx]
	movaps xmm1, [ebx+16]
	movaps xmm2, [ebx+32]
	movaps xmm3, [ebx+48]
	_Mat4x4Transpose ; src2_T xmm4-7

	; 初始化
	mov ecx, 4			; src1的行数
	mov edx, [ebp+8]	; 目标地址
	mov ebx, [ebp+12]	; src1的地址
	xor eax, eax

	; 加载src1中的一行
		
	align 16 ; http://stackoverflow.com/questions/39614017/why-and-where-align-16-is-used-for-sse-alignment-for-instructions
				; Modern processors fetch code in blocks of 16 (or maybe 32, sort of, AMD does weird things) bytes
				; 有助于提高fetch的命中率，这里是用来优化循环的，不过由于新的处理器在指令缓存中的进步，实际上不写效率应该也是接近的
@@:	movaps xmm0, [ebx+eax]

	; C[i][0]
	movaps xmm1, xmm0
	dpps xmm1, xmm4, 11110001b
	insertps xmm3, xmm1, 00000000b

	; C[i][1]
	movaps xmm2, xmm0
	dpps xmm2, xmm5, 11110001b
	insertps xmm3, xmm2, 00010000b

	; C[i][2]
	movaps xmm1, xmm0
	dpps xmm1, xmm6, 11110001b
	insertps xmm3, xmm1, 00100000b

	; C[i][3]
	movaps xmm2, xmm0
	dpps xmm2, xmm7, 11110001b
	insertps xmm3, xmm2, 00110000b
	
	movaps [edx+eax], xmm3
	add eax, 16
	dec ecx
	jnz @B

	pop ebx
	pop ebp
	ret	
	
SsePfpMatrix4x4Multiply endp

	end