#include <os.h>
#include "nand.h"
#include "screen.h"
#include "console.h"
#include "config.h"

extern unsigned char back[320*240*3];
unsigned char sscreen[320*240*2];

int nand_page_size=0x200;
#define NPARTS 5

long int offsets_offsets[NPARTS]={0,BOOT2_OFFSET_OFFSET,BOOTD_OFFSET_OFFSET,DIAGS_OFFSET_OFFSET,FILES_OFFSET_OFFSET};
long int pgoffsets[NPARTS]={MANUF_PAGE_OFFSET,BOOT2_PAGE_OFFSET,BOOTD_PAGE_OFFSET,DIAGS_PAGE_OFFSET,FILES_PAGE_OFFSET};

int manuf_nand_offset() { return pgoffsets[0]*nand_page_size; }
int boot2_nand_offset() { return pgoffsets[1]*nand_page_size; }
int bootd_nand_offset() { return pgoffsets[2]*nand_page_size; }
int diags_nand_offset() { return pgoffsets[3]*nand_page_size; }

int manuf_pages_num() { return pgoffsets[1]-pgoffsets[0]; }
int boot2_pages_num() { return pgoffsets[2]-pgoffsets[1]; }
int bootd_pages_num() { return pgoffsets[3]-pgoffsets[2]; }
int diags_pages_num() { return pgoffsets[4]-pgoffsets[3]; }

int manuf_size() { return manuf_pages_num()*nand_page_size; }
int boot2_size() { return boot2_pages_num()*nand_page_size; }
int bootd_size() { return bootd_pages_num()*nand_page_size; }
int diags_size() { return diags_pages_num()*nand_page_size; }

int manuf_nand_endoffset() { return manuf_nand_offset()+manuf_size()-1; }
int boot2_nand_endoffset() { return boot2_nand_offset()+boot2_size()-1; }
int bootd_nand_endoffset() { return bootd_nand_offset()+bootd_size()-1; }
int diags_nand_endoffset() { return diags_nand_offset()+diags_size()-1; }

int main(int argc, char** argv) {
	char* manufflashdata=malloc(FILES_OFFSET_OFFSET+4);
	int i;
	bc_read_nand(manufflashdata,FILES_OFFSET_OFFSET+4,manuf_nand_offset(),0,0,NULL);
	// TI-Nspire CX/CM partition table
	if(!memcmp(manufflashdata+PART_TABLE_OFFSET,PART_TABLE_ID,PART_TABLE_SIZE))
	{	nand_page_size=0x800;
		pgoffsets[0]=0;
		for(i=1;i<NPARTS;i++)
			pgoffsets[i]=*((long int*)(manufflashdata+offsets_offsets[i]))/nand_page_size;
		pgoffsets[5]=0x10000;
		
	}
	free(manufflashdata);
	char* path = argv[0];
	i = strlen(path)-1;
	while(path[i]!='/')
		i--;
	path[i+1]=0;
	initScr();
	char filepath[512];
	strcpy(filepath,path);
	char* filename=filepath+i+1;
	clrScr();
	resetConsole();
	int size = 320*240/2;
	if(is_cx) size=320*240*2;
	dispBufImgRGB(sscreen,0,0,back,320,240);
	memcpy(SCREEN_BASE_ADDR,sscreen,size);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	displn("",0,1);
	disp("Dumping Boot1... ",0,1);
	strcpy(filename,"boot1.img.tns");
	FILE *ofile = fopen(filepath, "wb");
	if(ofile)
	{	asm("ldr r1,=0x00000C12");
		asm("mrc p15,0,r0,c2,c0,0");
		asm("str r1,[r0,#4]");
		asm("ldr r0,=0x00100000");
		asm("mcr p15,0,r0,c8,c7,1");
		if(512*1024==fwrite((volatile void*)0x00100000, 1, 512*1024, ofile))
			displn("Done!",0,1);
		else
			displn("Error writing file...",0,1);
		fclose(ofile);

	}
	else
		displn("Error creating file...",0,1);
      void *buf = malloc(boot2_size());

	disp("Dumping Diags... ",0,1);
	strcpy(filename,"diags.img.tns");
	ofile = fopen(filepath, "wb");
	if(ofile)
	{	bc_read_nand(buf, diags_size(), diags_nand_offset(), 0, 0, NULL);
		if(diags_size()==fwrite(buf, 1, diags_size(), ofile))
			displn("Done!",0,1);
		else
			displn("Error writing file...",0,1);
		fclose(ofile);
	}
	else
		displn("Error creating file...",0,1);

	disp("Dumping Boot2... ",0,1);
	strcpy(filename,"boot2.img.tns");
	ofile = fopen(filepath, "wb");
	if(ofile)
	{	bc_read_nand(buf, boot2_size(), boot2_nand_offset(), 0, 0, NULL);
		if(boot2_size()==fwrite(buf, 1, boot2_size(), ofile))
			displn("Done!",0,1);
		else
			displn("Error writing file...",0,1);
		fclose(ofile);
	}
	else
		displn("Error creating file...",0,1);

		disp("Dumping Manuf... ",0,1);
	strcpy(filename,"manuf.img.tns");
	ofile = fopen(filepath, "wb");
	if(ofile)
	{	bc_read_nand(buf, manuf_size(), manuf_nand_offset(), 0, 0, NULL);
		if(manuf_size()==fwrite(buf, 1, manuf_size(), ofile))
			displn("Done!",0,1);
		else
			displn("Error writing file...",0,1);
		fclose(ofile);
	}
	else
		displn("Error creating file...",0,1);


	free(buf);

	displn("",0,1);
	displn("",0,1);
	pause("",0,1);
	return 0;
}
