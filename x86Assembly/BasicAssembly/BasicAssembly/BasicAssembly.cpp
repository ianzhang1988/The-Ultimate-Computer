// BasicAssembly.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

extern "C" int CalcSum_(int a, int b, int c);

int main()
{
	int a = 17, b = 11, c = 14;
	int sum = CalcSum_(a, b, c);

	printf("  a:   %d\r\n", a);
	printf("  b:   %d\r\n", b);
	printf("  c:   %d\r\n", c);
	printf("  sum: %d\r\n", sum);

    return 0;
}

