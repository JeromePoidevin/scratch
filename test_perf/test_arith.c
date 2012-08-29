#include <stdio.h>

#define MAX 100
#define MAX2 200

int i,j,ii,jj,a,b,c;
float d;
int ta[MAX2][MAX2];
int tb[MAX2][MAX2];
int tc[MAX2][MAX2];
float td[MAX2][MAX2];

int main()
{
for (i=-MAX;i<MAX;i++)
{
    ii=i+MAX;
    for (j=-MAX;j<MAX;j++)
    {
        jj=j+MAX;
        a = i+j ; ta[ii][jj] = a ;
        b = i-j ; tb[ii][jj] = b ;
        c = i*j ; tc[ii][jj] = c ;
        if (j!=0) d = (float) i/ (float) j ;
        else      d = 123.789 ;
        td[ii][jj] = d ;
        printf( "%d %d : %d %d %d %.1f\n" , i,j,a,b,c,d ) ;
    }
}
return 0;
}

