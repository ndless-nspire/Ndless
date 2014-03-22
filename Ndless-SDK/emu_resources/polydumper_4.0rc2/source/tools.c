void wait(int timesec)
{	volatile i;
	for(i=0;i<timesec*10000;i++) {}
}