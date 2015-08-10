//open("C:\\Users\\Dennis\\My Science\\research data\\Gap closure\\iLas TIRF\\20130904_MDCK_GFP_Talin_Octopus\\20130904_MDCK_GFP_Talin_Octopus_w1TIRFM Dual GFP_s1_t1.TIF");
pathname="C:\\Users\\Dennis\\My Science\\research data\\Gap closure\\iLas TIRF\\20130904_MDCK_GFP_Talin_Octopus\\"
filename="20130904_MDCK_GFP_Talin_Octopus_w1TIRFM Dual GFP_s1_t"
//newpath="C:\\Users\\Dennis\\My Science\\research data\\Gap closure\\iLas TIRF\\20130904_MDCK_GFP_Talin_Octopus\\focused\\"
newpath="C:\\Users\\Dennis\\Desktop\\"
for (m=1;m<=3;m++)
{
	open(pathname+filename+m+".TIF");
	n=nSlices;
	/*
	for (i=1;i<=n;i++)
	{
		slice=getSliceNumber();
		getStatistics(area,mean,min,max,std);
		tempstd=std;
		if (i==1)
		{
			minstd=tempstd;
			fi=1;
		}
		if (tempstd<minstd)
		{
			minstd=tempstd;
			fi=i;
		}
		print(std, slice);
		run("Next Slice [>]");
	}
	*/
	maxstd=0;
	fi=1;
	waitForUser;
	for (i=1;i<=n;i++)
	{
		slice=getSliceNumber();
		getStatistics(area,mean,min,max,std);
		tempstd=std;
		print(tempstd,i);
		if (tempstd>maxstd)
		{
			maxstd=tempstd;
			fi=i;
		}
		run("Next Slice [>]");
	}
	print("maxstd="+maxstd, fi);
	setSlice(fi);
	run("Duplicate...", "title=focused+m");
	selectWindow("focused+m");
	saveAs("Tiff", newpath+"focused\\"+m+".tif");
	close();
	run("Close");
}


