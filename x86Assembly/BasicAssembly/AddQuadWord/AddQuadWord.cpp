// AddQuadWord.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdlib.h>

extern "C" void AddQuadWord_( long long *a, long long *b );

int main()
{
	long long a = 0x00000000fffffffe;
	long long b = 11;

	printf("%lld + %lld", a, b);

	AddQuadWord_(&a, &b);

	printf(" = %lld\n", a);

	system("pause");

    return 0;
}

