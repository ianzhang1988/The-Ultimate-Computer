// AVXScalarFloatingPoint.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "stdlib.h"
#define _USE_MATH_DEFINES
#include <math.h>

// 计算平行四边形的面积

struct Parallelogram
{
    double A;		// 左右两边
    double B;		// 上下两边
    double Alpha;   // 左下角
    double Beta;	// 右下角
    double H;		// 高
    double Area;	// 面积
    bool BadValue;	// A,B,或者Alpha非法
    char Pad[7];	// 保留
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

