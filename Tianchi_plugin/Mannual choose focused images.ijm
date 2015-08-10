pathname="D:\\research data\\iLas\\iLas TIRF\\20130926_MDCK_GFP_Talin_Cshape\\s5_GFP\\";
filename="C1_w1TIRFM Dual GFP_s5_t";
newpath="C:\\Users\\Administrator\\Desktop\\focused\\";
N_Files=67;
for (i=1;i<=N_Files;i++)
{
	open(pathname+filename+i+".TIF");
	waitForUser;
	run("Duplicate...", "title=new");
	selectWindow(filename+i+".TIF");
	run("Close");
	selectWindow("new");
	if (i==1)
	{
		run("Duplicate...", "title=focused");
		selectWindow("new");
		run("Close");
	}
	if (i>1)
	{
		run("Concatenate...", "  title=[focused] image1=[focused] image2=[new] image3=[-- None --]");
	}
}
selectWindow("focused")
saveAs("Tiff", newpath+"focused.tif");
close()