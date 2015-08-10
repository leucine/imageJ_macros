/*macro "Abort Macro or Plugin (or press Esc key) Action Tool - CbooP51b1f5fbbf5f1b15510T5c10X" {
      setKeyDown("Esc");
}
*/
  
run("Close All");
// set logOutput=1 to print details in the Log window.
logOutput=1;
// get the folder root (dir0); it is assumed that the root folder contains (1) RawData folder and ParameterData folder. 
// ParameterData folder contains a "Parameter.txt" file

     
showMessage("<html>"+"<h1><font color=red>Open analysis folder containing the bead images.</h1>"+
" <font color=black>This folder contains:"+
"<ol>"+
"<li> a subfolder 'ParameterData/Parameter.txt'"+
"<li> a set of 2-slices (<font color=red>.tif<font color=black>) stacks (first slice:  without_force, second slice: with_force)."+
"</ol>");

dirAnalysis=getDirectory("Open analysis folder");

listAnalysis=getFileList(dirAnalysis);
// prepare the Log window
print(" ");
print("\\Clear");

// get the ParameterData subfolder and the Parameter.txt path.
//setBatchMode(true);
for(i=0;i<listAnalysis.length;i++){
	if(startsWith(listAnalysis[i],"ParameterData")){
		dirP=dirAnalysis+listAnalysis[i];
	}
}

listP=getFileList(dirP);
// get the Parameters.txt index
ParFile=-1;
for (i=0;i<listP.length;i++){
	if (startsWith(listP[i],"Parameters.txt")==true){ParFile=i;}
}

if (ParFile<0){
	showMessage("<html>"+"<big>"+"<font color=red>There is no 'ParameterData' folder and/or 'Parameter.txt' file. Abort macro (press escape button).");
	setKeyDown("Esc");
}

//open parameter file; get information (mechanical parameters; channels parameters)
filestring=File.openAsString(dirP+listP[ParFile]); 
rows=split(filestring, "\n"); 
ChannelName=newArray();
ChannelType=newArray();
for(i=0; i<rows.length; i++){ 
	locRow=split(rows[i]," \t,;");
	if (locRow[0]=="pixel2um"){pixel2um=parseFloat(locRow[1]);}
	if (locRow[0]=="YoungModulus"){YoungModulus=parseFloat(locRow[1]);}
	if (locRow[0]=="PoissonRatio"){PoissonRatio=parseFloat(locRow[1]);}
	if (locRow[0]=="Regularization"){Regularization=parseFloat(locRow[1]);}
	if (locRow[0]=="vector"){vector=parseFloat(locRow[1]);}
	if (locRow[0]=="max"){max=parseFloat(locRow[1]);}
	if (locRow[0]=="piv1"){piv1=parseFloat(locRow[1]);}
	if (locRow[0]=="sw1"){sw1=parseFloat(locRow[1]);}
	if (locRow[0]=="vs1"){vs1=parseFloat(locRow[1]);}
	if (locRow[0]=="piv2"){piv2=parseFloat(locRow[1]);}
	if (locRow[0]=="sw2"){sw2=parseFloat(locRow[1]);}
	if (locRow[0]=="vs2"){vs2=parseFloat(locRow[1]);}
	if (locRow[0]=="piv3"){piv3=parseFloat(locRow[1]);}
	if (locRow[0]=="sw3"){sw3=parseFloat(locRow[1]);}
	if (locRow[0]=="vs3"){vs3=parseFloat(locRow[1]);}
	
	if (locRow[0]=="channel"){
		ChannelType=Array.concat(ChannelType,locRow[1]);
		ChannelName=Array.concat(ChannelName,locRow[2]);
	}
}

//get channel indexes
channelBead=-1;
for (i=0;i<ChannelType.length;i++){
	kk=-1;kk=indexOf(ChannelType[i],"Bead");if(kk>=0){channelBead=i;}
}
if (channelBead<0){
	showMessage("<html>"+"<big>"+"<font color=red>There is no Bead channel tag. Abort macro.");
	setKeyDown("Esc");
}

if (logOutput==1){
	print("Parameters:");
	print(" \n");
	print("pixel2um is :"+pixel2um);
	print("YoungModulus is :"+YoungModulus);
	print("PoissonRatio is :"+PoissonRatio);
	print("Regularization is :"+Regularization);
	print(" \n");
	print("Channels:");
	for (i=0;i<ChannelName.length;i++){
		print(i+"     "+ChannelType[i]+"  "+ChannelName[i]);
	}
	print("\\======================================================");
}
//==========================================================================
// get the list of images (contains the bead tag and ends with 'tif'). 
// Each image is a stack of two slices. First slice: whitoutForce, second slice: withForce
listImages=newArray();
for (k=0;k<listAnalysis.length;k++){
	s0=listAnalysis[k];
	kk=-1;kk=indexOf(s0,ChannelName[channelBead]);
	if ((kk>=0) && (endsWith(s0,".tif")==true)){
		listImages=Array.concat(listImages,listAnalysis[k]);
	}
}
//===========================================================================
// Align, crop images. First, create a directory for aligned/copped pairs
dirPairs=dirAnalysis+"AlignedCroppedPairs/";if (File.exists(dirPairs)){} else {File.makeDirectory(dirPairs);}


showMessage("<html>"+"<big>"+"<font color=red>Bead alignment.");

//get the first image, draw the roi that will be used to align slices.
// Note that the rectange used (parameters x0, y0, w0 h0 below) will bet used for
// all images. However, there is the possibility to change the roi for each image.

open(listImages[0]);
roiManager("reset");
setTool("rectangle");

waitForUser("Bead alignment. Select the roi in image 1 (stack 1). This roi will be used thoughtout all stacks.");
getBoundingRect(x, y, width, height);
x0=x;y0=y;w0=width;h0=height;
roiManager("Add");
roiManager("Save",dirP+"AlignWindow.zip")
run("Close All");


//Extract the bead stacks, align them using the roiWindow


setOption("ShowRowNumbers", false);
okRoi=true;
run("Clear Results");
dx=newArray();dy=newArray();
for (i=0; i<listImages.length; i++){
		okAlign=false;
		open(dirAnalysis+listImages[i]);
		
		makeRectangle(x0, y0, w0, h0);
		getBoundingRect(x, y, width, height);
		roiManager("Add");
		nbrA=1;
		while(okAlign==false){
			updateResults;
			selectWindow("Results");
			run("Align slices in stack...","method=5 windowsizex="+width+" windowsizey="+height+" x0="+x+" y0="+y+" swindow=0 ref.slice=1 show=true");
			waitForUser("Check the alignement for stack "+i+1+" after "+nbrA+"-th run");
			okAlign2=getBoolean("Are you happy with this alignment?");
	 		updateResults;
 			selectWindow("Results");
			if (okAlign2==true){
				run("Select None");
				s0=listImages[i];ns0=lengthOf(s0);
				run("Enhance Contrast", "saturated=0.35");
				saveAs("Tiff",dirPairs+"/"+substring(s0,0,ns0-4));
				run("Close All");
				xshift=getResult("dX",0);dx=Array.concat(dx,parseFloat(xshift));
				yshift=getResult("dY",0);dy=Array.concat(dy,parseFloat(yshift));
				okAlign=true;
				roiManager("Delete");
			}
			
			if (okAlign2==false){
				// get a new roi
				nbrA=nbrA+1;
				run("Select None");
				setTool("rectangle");
				waitForUser("select a better alignment window for stack: "+i+1+" after "+nbrA+"-th run");
				getBoundingRect(x, y, width, height);
				x0=x;y0=y;w0=width;h0=height;
				roiManager("Add");
			}
		}
}
run("Close All");
f=File.open(dirP+"AlignementData.txt");
for (k=0;k<dx.length;k++){
	print(f,k+"  "+dx[k]+"   "+dy[k]);
}
File.close(f);
selectWindow("Results");run("Close");

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//crop aligned pairs, save the crop window
listPairs=getFileList(dirPairs);

// open the first stack, draw a crop window, save the roi in the parameter folder
open(dirPairs+"/"+listPairs[0]);
getDimensions(width, height, channels, slices, frames);
showMessage("<html>"+"<big>"+"<font color=red>crop roi.");
roiManager("Reset");
setTool("rectangle");
waitForUser("Select cropping window");
getBoundingRect(x, y, width, height);
roiManager("Add");
roiManager("Save",dirP+"CropWindow.zip")
run("Close All");
	

for (i=0;i<listPairs.length;i++){
	open(dirPairs+"/"+listPairs[i]);
	roiManager("Select", 0);
	run("Crop");
	s0=listPairs[i];ns0=lengthOf(s0);
	saveAs("tiff",dirPairs+"/"+substring(s0,0,ns0-4));
	run("Close All");
}

print("done for aligning and cropping");
selectWindow("Log");


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//=================================================================================
// get listFile of bead and pattern channels for withCell conditions

listPairs=getFileList(dirPairs);
dirPIV=dirAnalysis+"PIV_Force";
if (File.exists(dirPIV)){} else {File.makeDirectory(dirPIV);}



// set the parameters for PIV
sparamPIV="piv1="+piv1+" sw1="+sw1+" vs1="+vs1+" piv2="+piv2+" sw2="+sw2+" vs2="+vs2+" piv3="+piv3+" sw3="+sw3+" vs3="+vs3+" correlation=0.60 debug debug_x=-1 debug_y=-1 batch path="+dirPIV+"/";

//get tag and information from images.
startS=newArray();widthS=newArray();heightS=newArray();
listTextDisp=newArray();
listTextForce=newArray();
for (k=0;k<listPairs.length;k++){
	print("processing:  "+listPairs[k]);
	open(dirPairs+"/"+listPairs[k]);
	getDimensions(width, height, channels, slices, frames);
	widthS=Array.concat(widthS,width);
	heightS=Array.concat(heightS,height);
	qq=split(listPairs[k],"_-. ");
	startS=Array.concat(startS,qq[0]);

	//run piv
	run("iterative PIV(Advanced)...",sparamPIV);
	run("Close All");

	//run traction force measurement
	textDispFile=listPairs[k]+"_PIV3_disp.txt";
	sparamF="pixel="+pixel2um+" poisson="+PoissonRatio+" young's="+YoungModulus+" regularization="+Regularization+" plot plot="+width+" plot="+height+" select="+dirPIV+"/"+textDispFile+" select="+dirPIV+"/"+textDispFile;
	run("FTTC ",sparamF);
	listTextDisp=Array.concat(listTextDisp,textDispFile);
	
	//run plot forces
	textForceFile="Traction_"+textDispFile;
	sparamF="select="+dirPIV+"/"+textForceFile+" select="+dirPIV+"/"+textForceFile +" vector_scale="+vector+" max="+max+" plot_width="+width+" plot_height="+height+" show draw lut=S_Pet";
	run("plot FTTC",sparamF);
	s0=listPairs[k];ns0=lengthOf(s0);
	saveAs("tiff", dirPIV + "/ColorBar_"+substring(s0,0,ns0-4));
	close();
	saveAs("tiff", dirPIV + "/VectorMap_"+substring(s0,0,ns0-4));
	close();
	saveAs("tiff", dirPIV + "/MagnitudeMap_"+substring(s0,0,ns0-4));
	close();
	run("Close All");
	listTextForce=Array.concat(listTextForce,textForceFile);
}

/////////////////////////////////////////////////////////////////////////////////////////
// supress useless files in dirPIV
listPIV=getFileList(dirPIV);
for (kf=0;kf<listPIV.length;kf++){
	if ((endsWith(listPIV[kf],"_PIV2_disp.txt")==true)){
		File.delete(dirPIV+"/"+listPIV[kf]);
	}
	if ((endsWith(listPIV[kf],"_PIV1_disp.txt")==true)){
		File.delete(dirPIV+"/"+listPIV[kf]);
	}
	if ((endsWith(listPIV[kf],"_PIV2_vPlot.tif")==true)){
		File.delete(dirPIV+"/"+listPIV[kf]);
	}
	if ((endsWith(listPIV[kf],"_PIV1_vPlot.tif")==true)){
		File.delete(dirPIV+"/"+listPIV[kf]);
	}	
	if ((startsWith(listPIV[kf],"FTTCparameters_")==true) && (endsWith(listPIV[kf],"_PIV3_disp.txt")==true)){
		File.delete(dirPIV+"/"+listPIV[kf]);
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////
// Post processing. Compute elastic energy (whole image and mask energy)
listPIV=getFileList(dirPIV);
// get force vector maps
nImage=0;
for (kf=0;kf<listPIV.length;kf++){
	if ((startsWith(listPIV[kf],"VectorMap_")==true) && (endsWith(listPIV[kf],".tif")==true)){
		open(dirPIV+"/"+listPIV[kf]);
		imageId1 = getImageID();
		run("Duplicate...", "title="+i);
		selectImage(imageId1);
		nImage+=1;
		close();		
	}
}
if (nImage>1){
	run("Images to Stack", "name=Stack title=[] use");
	run("Brightness/Contrast...");
	run("Enhance Contrast", "saturated=0.35");
	run("RGB Color");
	saveAs("Tiff",dirAnalysis+"Stack_ForceVectors.tif");
	imageId3 = getImageID();
	
	//get the average of the force maps
	nsF=nSlices;
	run("Z Project...", "start=1 stop="+nsF+" projection=[Max Intensity]");
	imageId2 = getImageID();
}else{
	imageId2 = getImageID();
}

//get the mask
roiManager("reset");
setTool("rectangle");setTool("Oval");
waitForUser("Bead alignment. Determine mask (used for elastic energy.)");
run("Create Mask");
run("Duplicate...", "title=mask");
imageMask= getImageID();
if (nImage>1){
	selectImage(imageId2);close();
	selectImage(imageId3);close();
}else{
	selectImage(imageId2);close();
}
selectImage(imageMask);
saveAs("Tiff",dirAnalysis+"MaskEnergy");
getRawStatistics(nPixels, mean, min, max); 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wsizeErg=vs3;
print(wsizeErg);
//convert pixel_to_micron into pixel_to_meters
pixel2um=pixel2um*1e-6;
// convert the force data into actual forces (in N)
factF=pixel2um*wsizeErg*pixel2um*wsizeErg*pixel2um;
// convert the window area into meter-square
factF1=pixel2um*wsizeErg*pixel2um*wsizeErg;

erg=newArray();ergMask=newArray();

forceMag=newArray();dispMag=newArray();
forceMagMask=newArray();dispMagMask=newArray();

AvforceMag=newArray();
AvdispMag=newArray();

AvforceMagMask=newArray();
AvdispMagMask=newArray();

for (i=0;i<listTextDisp.length;i++){
	erg0=0;fmag=0;dmag=0;
	erg0Mask=0;fmagMask=0;dmagMask=0;
	filestringD=File.openAsString(dirPIV+"/"+listTextDisp[i]);
	rowD=split(filestringD, "\n");
	filestringF=File.openAsString(dirPIV+"/"+listTextForce[i]);
	rowF=split(filestringF, "\n");
	selectImage(imageMask);
	nMask=0;
	for (k=0;k<rowD.length;k++){
		rowDD=split(rowD[k]," \t");
		rowFF=split(rowF[k]," \t");
		v=getPixel(rowDD[0], rowDD[1]);
		erg0=erg0+parseFloat(rowDD[2])*parseFloat(rowFF[2])+parseFloat(rowDD[3])*parseFloat(rowFF[3]);
		erg0Mask=erg0Mask+v*(parseFloat(rowDD[2])*parseFloat(rowFF[2])+parseFloat(rowDD[3])*parseFloat(rowFF[3]))/max;
		fmag=fmag+sqrt(parseFloat(rowFF[2])*parseFloat(rowFF[2])+parseFloat(rowFF[3])*parseFloat(rowFF[3]));
		dmag=dmag+sqrt(parseFloat(rowDD[2])*parseFloat(rowDD[2])+parseFloat(rowDD[3])*parseFloat(rowDD[3]));
		fmagMask=fmagMask+v*sqrt(parseFloat(rowFF[2])*parseFloat(rowFF[2])+parseFloat(rowFF[3])*parseFloat(rowFF[3]))/max;
		dmagMask=dmagMask+v*sqrt(parseFloat(rowDD[2])*parseFloat(rowDD[2])+parseFloat(rowDD[3])*parseFloat(rowDD[3]))/max;
		nMask=nMask+v/max;	
	}
	erg0=erg0*factF;erg=Array.concat(erg,erg0);
	erg0Mask=erg0Mask*factF;ergMask=Array.concat(ergMask,erg0Mask);

	forceMag=Array.concat(forceMag,fmag*factF1);dispMag=Array.concat(dispMag,dmag*pixel2um);
	forceMagMask=Array.concat(forceMagMask,fmagMask*factF1);dispMagMask=Array.concat(dispMagMask,dmagMask*pixel2um);
}
Array.print(erg);
Array.print(ergMask);


f=File.open(dirAnalysis+"Energy_forces.txt");
print(f,"time\t Energy\t TotalForceMagnitude\t TotalDispMagnitude");
for (kp=0;kp<erg.length;kp++){
	print(f,kp+"\t "+erg[kp]+"\t "+forceMag[kp]+"\t "+dispMag[kp]);

}
File.close(f);

f=File.open(dirAnalysis+"Energy_forces_Mask.txt");
print(f,"time\t EnergyMask\t TotalForceMagnitudeMask\t TotalDispMagnitudeMask");
for (kp=0;kp<erg.length;kp++){
	print(f,kp+"\t "+ergMask[kp]+"\t "+forceMagMask[kp]+"\t "+dispMagMask[kp]);

}
File.close(f);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
print("done");
selectWindow("Log");
