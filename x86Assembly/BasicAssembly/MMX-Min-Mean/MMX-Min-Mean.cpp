// MMX-Min-Mean.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdlib.h>

extern "C" unsigned char MMXMin_(unsigned char* src, int num );
extern "C" bool MMXMean_(unsigned char* src, int num, double *mean);

bool MeanCpp(unsigned char* src, int num, double *mean)
{
	int sum = 0;

	for (int i = 0; i < num; ++i)
	{
		sum += src[i];
	}

	*mean = (double)sum / num;

	return true;
}

int main()
{
	const int arrnum = 100 * 32;
	unsigned char array[arrnum] = {0};

	srand(13);

	for ( auto &i : array )
	{
		i = (unsigned char)(rand() % 240 + 5);
	}

	array[arrnum / 2] = 2;  // min

	printf("min should be 2\r\n");
	unsigned char result = 0;
	result = MMXMin_( array, arrnum );

	printf("MMXMin_ gives %u\r\n", result);

	printf("-------------round 2----------------\r\n");

	array[arrnum - 2] = 0;  // min

	printf("min should be 0\r\n");

	result = MMXMin_(array, arrnum);

	printf("MMXMin_ gives %u\r\n", result);

	printf("-------------mean----------------\r\n");

	double mean = 0.0;

	MeanCpp(array, arrnum, &mean);

	printf("mean should be %f\r\n", mean);

	mean = 0.0;

	MMXMean_(array, arrnum, &mean);

	printf("MMXMean_ gives %f\r\n", mean);

	system("pause");

    return 0;
}

