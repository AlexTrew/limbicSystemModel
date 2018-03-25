#define c (p==1)
#define d (p==0) 

int p



active proctype p1()
{
do
::p=1;p=0
::p=0;p=5
od
}

ltl check {[](c-> <>d)}
