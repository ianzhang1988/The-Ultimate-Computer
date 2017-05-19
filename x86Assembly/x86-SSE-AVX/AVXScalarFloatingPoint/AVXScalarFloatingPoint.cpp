// AVXScalarFloatingPoint.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "stdlib.h"
#define _USE_MATH_DEFINES
#include <math.h>

// ����ƽ���ı��ε����

struct Parallelogram
{
    double A;		// ��������
    double B;		// ��������
    double Alpha;   // ���½�
    double Beta;	// ���½�
    double H;		// ��
    double Area;	// ���
    bool BadValue;	// A,B,����Alpha�Ƿ�
    char Pad[7];	// ����
};



extern "C" bool AvxSfpParallelograms_(Parallelogram* pdata);
extern "C" double DegToRad = M_PI / 180.0;
extern "C" int SizeofParallelogramX86;

int main()
{
    Parallelogram stPlg;

    stPlg.A = 5;
    stPlg.B = 10;
    stPlg.Alpha = 45.0;

    AvxSfpParallelograms_(&stPlg);

    printf("%s BadValue\r\n", stPlg.BadValue ? "Is" : "Not");
    printf("A: %12.6lf, B: %12.6lf\r\n", stPlg.A, stPlg.B);
    printf("Alpha: %12.6lf, Beta: %12.6lf\r\n", stPlg.Alpha, stPlg.Beta);
    printf("Height: %12.6lf, Area: %12.6lf\r\n", stPlg.H, stPlg.Area);

    system("pause");
    return 0;
}

