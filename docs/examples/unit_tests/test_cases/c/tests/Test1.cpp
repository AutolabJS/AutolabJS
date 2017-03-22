#include <stdio.h>
#include "add.c"

int test()
{
	if(add(3,4,5)==12) return 1;
	else return 0;
}