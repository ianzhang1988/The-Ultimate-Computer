.model flat,c
.code

AddQuadWord_ proc

	push ebp
	mov ebp,esp
	push ebx

	mov eax, [ebp+8]
	mov ebx, [ebp+12]

	; add ����ֱ�Ӽ��ڴ��ַ������Ҫ�Ȱѵڶ�������ָ������ݷŵ��Ĵ�����
	mov ecx, dword ptr [ebx]

	add dword ptr [eax], ecx

	mov ecx, dword ptr [ebx+4]

	��32λģʽ��64λ��ԭ���ڸ�λ����ӵ�λ�Ľ�λ�������128λ�ļӷ�Ҳ��ͬ���
	adc dword ptr [eax+4], ecx
	
	pop ebx
	pop ebp
	ret

AddQuadWord_ endp
	end