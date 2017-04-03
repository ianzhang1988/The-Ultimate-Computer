.model flat,c
.code

AddQuadWord_ proc

	push ebp
	mov ebp,esp
	push ebx

	mov eax, [ebp+8]
	mov ebx, [ebp+12]

	; add 不能直接加内存地址，所以要先把第二个参数指向的内容放到寄存器中
	mov ecx, dword ptr [ebx]

	add dword ptr [eax], ecx

	mov ecx, dword ptr [ebx+4]

	；32位模式加64位的原理，在高位上面加低位的进位，如果有128位的加法也是同理的
	adc dword ptr [eax+4], ecx
	
	pop ebx
	pop ebp
	ret

AddQuadWord_ endp
	end