#include <os.h>
#include "touchpad.h"

touchpad_report_t* tpreport = 0;
touchpad_info_t* tpinfo = 0;

void initTP()
{	
	tpinfo = touchpad_getinfo();
	tpreport = (touchpad_report_t*) malloc(sizeof(touchpad_report_t));
	memset(tpreport,0,sizeof(touchpad_report_t));
}

void endTP()
{
	if(tpreport)
	{	free(tpreport);
		tpreport = 0;
	}
}

void readTP()
{
	touchpad_scan(tpreport);
}

void readFullTP()
{
	wait(TOUCHPAD_DELAY); // lets the time to compute velocity
	readTP();
}

int getX_Velocity()
{
	if(!is_touchpad) return 0;
	if(!tpreport->contact) return 0;
	int t = tpreport->x_velocity;
	if(t<=127) return t;
	return t-256;
}

int getY_Velocity()
{
	if(!is_touchpad) return 0;
	if(!tpreport->contact) return 0;
	int t = tpreport->y_velocity;
	if(t<=127) return t;
	return t-256;
}

/* 8
  456
   2
*/
int getTouchedZone5()
{
	if(!is_touchpad) return 0;
	if(!tpreport->contact) return 0;
	if(tpreport->x>tpinfo->width/3 && tpreport->x<2*tpinfo->width/3 && tpreport->y>tpinfo->height/3 && tpreport->y<2*tpinfo->height/3)
		return 5;
	float m = (float)tpinfo->height/tpinfo->width;
	float ac,ad;
	if(tpreport->x==0)
		if(tpreport->y==0)	ac=m;
		else			ac=tpinfo->height;
	else	ac=(float)tpreport->y/tpreport->x;
	if(tpreport->x==0)
		if(tpreport->y==tpinfo->height)	ad=-m;
		else			ad=-tpinfo->height;
	else	ad=(float)(tpreport->y-tpinfo->height)/tpreport->x;
	if(ac<=m)
		if(ad<=-m)	return 2;
		else 		return 6;
	else 
		if(ad<-m)	return 4;
		else		return 8;
}

/* 8
  4 6
   2
*/
int getTouchedZone4()
{
	if(!is_touchpad) return 0;
	if(!tpreport->contact) return 0;
	float m = (float)tpinfo->height/tpinfo->width;
	float ac,ad;
	if(tpreport->x==0)
		if(tpreport->y==0)	ac=m;
		else			ac=tpinfo->height;
	else	ac=(float)tpreport->y/tpreport->x;
	if(tpreport->x==0)
		if(tpreport->y==tpinfo->height)	ad=-m;
		else			ad=-tpinfo->height;
	else	ad=(float)(tpreport->y-tpinfo->height)/tpreport->x;
	if(ac<=m)
		if(ad<=-m)	return 2;
		else 		return 6;
	else 
		if(ad<-m)	return 4;
		else		return 8;
}

/* 789
   456
   123
*/
int getTouchedZone9()
{
	if(!is_touchpad) return 0;
	if(!tpreport->contact) return 0;
	if(tpreport->x<=tpinfo->width/3)
		if(tpreport->y<=tpinfo->height/3)		return 1;
		else if(tpreport->y<=2*tpinfo->height/3)	return 4;
		else						return 7;
	else if(tpreport->x<2*tpinfo->width/3)
		if(tpreport->y<=tpinfo->height/3)		return 2;
		else if(tpreport->y<2*tpinfo->height/3)		return 5;
		else						return 8;
	else
		if(tpreport->y<=tpinfo->height/3)		return 3;
		else if(tpreport->y<2*tpinfo->height/3)		return 6;
		else						return 9;
}


int isTPTouched()
{
	return tpreport->contact;
}

int isTPPressed()
{
	return tpreport->pressed;
}

int isTouchpad()
{
	return is_touchpad;
}