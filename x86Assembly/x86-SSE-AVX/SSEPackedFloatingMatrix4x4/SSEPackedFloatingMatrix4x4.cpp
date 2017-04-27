// SSEPackedFloatingMatrix4x4.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "Mat4x4.h"
#include <stdlib.h>

extern "C" void SsePfpMatrix4x4Multiply(Mat4x4 pDest, Mat4x4 pSrc1, Mat4x4 pSrc2);

int main()
{
    __declspec(align(16)) Mat4x4 m_src1;
    __declspec(align(16)) Mat4x4 m_src2;
    __declspec(align(16)) Mat4x4 m_dest1;
    __declspec(align(16)) Mat4x4 m_dest2;

    Mat4x4SetRow(m_src1, 0, 3.0, 3.4, 2.3, 7.4);
    Mat4x4SetRow(m_src1, 1, 5.0, 3.6, 5.6, 3.5);
    Mat4x4SetRow(m_src1, 2, 2.0, 2.4, 2.3, 4.4);
    Mat4x4SetRow(m_src1, 3, 7.0, 8.4, 6.8, 8.4);

    Mat4x4SetRow(m_src2, 0, 2.0, 2.4, 2.3, 4.4);
    Mat4x4SetRow(m_src2, 1, 7.0, 8.4, 6.8, 8.4);
    Mat4x4SetRow(m_src2, 2, 3.0, 3.4, 2.3, 7.4);
    Mat4x4SetRow(m_src2, 3, 5.0, 3.6, 5.6, 3.5);

    Mat4x4Mul(m_dest1, m_src1, m_src2);
    SsePfpMatrix4x4Multiply(m_dest2, m_src1, m_src2);

    Mat4x4Printf(m_src1, "\nsrc1\n");
    Mat4x4Printf(m_src2, "\nsrc2\n");
    Mat4x4Printf(m_dest1, "\ndest1\n");
    Mat4x4Printf(m_dest2, "\ndest2\n");

    system("pause");
    return 0;
}

