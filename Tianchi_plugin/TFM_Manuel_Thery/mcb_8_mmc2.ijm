run("Close All");
// set logOutput=1 to print details in the Log window.
logOutput=1;


//open the analysis folder
showMessage("<html>"+"<big>"+"<font color=red>Open analysis folder containing the bead images.");


dirAnalysis=getDirectory("Open analysis folder");

// open the Log window
print(" ");
print("\\Clear");
print("target root: "+dirAnalysis);
//------------------------------------------------------------------------------------------------
//open a typical bead image: estimate the bead density
showMessage("<html>"+"<big>"+"<font color=red>Open a typical bead image (measure bead density).");
open();
imageId= getImageID();

selectImage(imageId);
setSlice(1);
run("Duplicate...", "title=1");
imageId1= getImageID();

selectImage(imageId);close();
getDimensions(width, height, channels, slices, frames);
print("Image size (pixels):    "+width+", "+height);

//=====================================================================================================
run("8-bit");
run("Threshold...");
setAutoThreshold("Default dark");
//run("Clear Results");
//run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display slice");

waitForUser("set the threshold");
run("Clear Results");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display slice");

selectImage(imageId1);close();



setOption("ShowRowNumbers", false);
updateResults;
selectWindow("Results");

nbrBead=nResults;
areaBead=0;minBead=0;maxBead=0;meanBead=0;
for (k=0;k<nbrBead;k++){
	areaBead+=getResult("Area",k);
	minBead+=getResult("Min",k);
	maxBead+=getResult("Max",k);
}
densityPix=nbrBead/width/height;
fractionArea=areaBead/width/height;
print("NumberOfBeads TotalBeadArea AreaFraction BeadDensity");
print(nbrBead+"  "+areaBead+"   "+fractionArea+"   "+densityPix);
//--------------------------------------------------------------------------------------------------
//close Results window
selectWindow("Results");
run("Close")


//=====================================================================================================================
//get list of files in Analysis folder
list0=getFileList(dirAnalysis);
//create parameter folder
dirP=dirAnalysis+"ParameterData/";if (File.exists(dirP)){} else {File.makeDirectory(dirP);}
//=================================================================================================================
imageSize=minOf(width,height);
Dialog.create("Parameters for elasticity and PIV method");

s0="-> Image data: "+nbrBead+" beads, width: "+width+" pixels, height "+height+" pixels, BeadDensity: "+densityPix;
s1="-> You can edit each item in the  window and change the default value.";
s2="-> Note that the optimal number of beads in last PIV-window in PIV should be >=4";

Dialog.addMessage(s0);
Dialog.addMessage(s1);
Dialog.addMessage(s2);

Dialog.addNumber("Pixel to microns:",0.222);
Dialog.addNumber("Young modulus (Pa):", 35000);
Dialog.addNumber("Poisson ratio:", 0.5);
Dialog.addNumber("Regularisation factor:",8.0e-11);
Dialog.addNumber("Bead number (last PIV window):",4);
Dialog.show();
pix2um= Dialog.getNumber();
young= Dialog.getNumber();
poisson= Dialog.getNumber();
regularisation=Dialog.getNumber();
beadNumberVs3=Dialog.getNumber();


//=================================================================================================================

//densityPix=nbrBead/width/height;
densityMicron=nbrBead/width/height/pix2um/pix2um;
fractionArea=areaBead/width/height;
print("density: "+densityPix+"  "+densityMicron+"  "+fractionArea);

//get the actual window size using the beadDensity and the beadNumberVs3
guessVs3=floor(sqrt(beadNumberVs3/densityPix));
print("Guess vs3: "+guessVs3);

//=================================================================================================================
//update the other windows for PIV
guessPiv3=2*guessVs3;
guessSw3=4*guessVs3;

guessVs2=guessPiv3;
guessPiv2=2*guessVs2;
guessSw2=4*guessVs2;

guessVs1=guessPiv2;
guessPiv1=2*guessVs1;
guessSw1=4*guessVs1;
matchingFactor=floor((imageSize/guessVs1));
/*
if(matchingFactor<8){
	guessVs1=floor(imageSize/10);
	guessPiv1=2*guessVs1;
	guessSw1=4*guessVs1;

	guessPiv2=guessVs1;
	guessSw2=2*guessPiv2;
	guessVs2=floor(guessPiv2/2);
	
	guessPiv3=guessVs2;
	guessSw3=2*guessPiv3;
	guessVs3=floor(guessPiv3/2);	

}*/
matchingFactor=floor((imageSize/guessVs1));

s0="-> The initial window (PIV) is contained "+matchingFactor+"-time(s) in the original image";
s1="-> The vs3 window contains ~ "+densityPix*guessVs3*guessVs3+" beads (average)";
s2="-> You might change  the value of any parameter.";

Dialog.create("Optimal parameter set for PIV method");
Dialog.addMessage(s0);
Dialog.addMessage(s1);
Dialog.addMessage(s2);
Dialog.addNumber("piv1:",guessPiv1);
Dialog.addNumber("sw1:",guessSw1);
Dialog.addNumber("vs1:",guessVs1);

Dialog.addNumber("piv2:",guessPiv2);
Dialog.addNumber("sw2:",guessSw2);
Dialog.addNumber("vs2:",guessVs2);

Dialog.addNumber("piv3:",guessPiv3);
Dialog.addNumber("sw3:",guessSw3);
Dialog.addNumber("vs3:",guessVs3);

Dialog.show();
piv1= Dialog.getNumber();
sw1= Dialog.getNumber();
vs1= Dialog.getNumber();
piv2= Dialog.getNumber();
sw2= Dialog.getNumber();
vs2= Dialog.getNumber();

piv3= Dialog.getNumber();
sw3= Dialog.getNumber();
vs3= Dialog.getNumber();

matchingFactor=floor((imageSize/vs1));

if(matchingFactor<0){
	s0="The initial window (PIV) is contained "+matchingFactor+"-time(s) in the original image. ";
	Dialog.create("Parameters for PIV method");
	Dialog.addMessage(s0);
	Dialog.addNumber("piv1:",guessPiv1);
	Dialog.addNumber("sw1:",guessSw1);
	Dialog.addNumber("vs1:",guessVs1);

	Dialog.addNumber("piv2:",guessPiv2);
	Dialog.addNumber("sw2:",guessSw2);
	Dialog.addNumber("vs2:",guessVs2);

	Dialog.addNumber("piv3:",guessPiv3);
	Dialog.addNumber("sw3:",guessPiv3);
	Dialog.addNumber("vs4:",guessVs3);
	
	Dialog.show();
	piv1= Dialog.getNumber();
	sw1= Dialog.getNumber();
	vs1= Dialog.getNumber();

	piv2= Dialog.getNumber();
	sw2= Dialog.getNumber();
	vs2= Dialog.getNumber();

	piv3= Dialog.getNumber();
	sw3= Dialog.getNumber();
	vs3= Dialog.getNumber();
}


//=================================================================================================================


showMessage("<html>"+"<h1><font color=red>Channel tags and names. </h1>"+
"<ol>"+
"<font color=black><li>associate channel tag (eg <font color=red>'TxRed'<font color=black>) and channel type (eg <font color=red>'Bead'<font color=black>),"+
"<li> there should be at least one channel for beads,"+
"<li> use only <font color=red>'.tif'<font color=black> images,"+
"<li> use <font color=red>'_' '-'<font color=black> as tag separators in image name,"+
"<li> the tag channel is part of the image name (eg.  XXXX_<font color=red>TxRed<font color=black>_YYY.<font color=red>tif<font color=black>),"+
"<li> if the channel tag or type is not listed click on 'other' to provide the correct information."+
"</ol>");

Dialog.create("Channel information");
Dialog.addNumber("number of pairs (ChannelType/ChannelTag) :",1);
Dialog.show();
nbr= Dialog.getNumber();
folderT=newArray();
folderT=Array.concat(folderT,"Bead");
folderT=Array.concat(folderT,"Pattern");
folderT=Array.concat(folderT,"Cell");
folderT=Array.concat(folderT,"Nucleus");
folderT=Array.concat(folderT,"other");

folderN=newArray();
folderN=Array.concat(folderN,"TxRed");
folderN=Array.concat(folderN,"CY5");
folderN=Array.concat(folderN,"GFP");
folderN=Array.concat(folderN,"DAPI");
folderN=Array.concat(folderN,"other");

ChannelName=newArray();
ChannelType=newArray();
for (k=0;k<nbr;k++){
	Dialog.create("Channel "+(k+1));
	
	Dialog.addChoice("Channel name",folderN);
	Dialog.addChoice("Channel type",folderT);
	Dialog.show();
	s0=Dialog.getChoice();
	s1=Dialog.getChoice();

	if((startsWith(s0,"other")==false) && (startsWith(s1,"other")==false)){
		ChannelName=Array.concat(ChannelName,s0);
		ChannelType=Array.concat(ChannelType,s1);
	}else if((startsWith(s0,"other")==false) && (startsWith(s1,"other")==true)){
		Dialog.create("Channel name "+(k+1));
		Dialog.addString("Channel name is ",s0);
		Dialog.addString("Enter new channel type (other)","");
		Dialog.show();
		s3=Dialog.getString();
		s4=Dialog.getString();
		ChannelName=Array.concat(ChannelName,s0);
		ChannelType=Array.concat(ChannelType,s4);
	}else if((startsWith(s0,"other")==true) && (startsWith(s1,"other")==false)){
		Dialog.create("Channel name "+(k+1));
		Dialog.addString("Enter new channel name (other)","");
		Dialog.addString("Channel type is ",s1);
		Dialog.show();
		s3=Dialog.getString();
		s4=Dialog.getString();
		ChannelName=Array.concat(ChannelName,s3);
		ChannelType=Array.concat(ChannelType,s1);
	}else if((startsWith(s0,"other")==true) && (startsWith(s1,"other")==true)){
		Dialog.create("Channel name "+(k+1));
		Dialog.addString("Enter new channel name (other)","");
		Dialog.addString("Enter new channel type (other)","");
		Dialog.show();
		s3=Dialog.getString();
		s4=Dialog.getString();
		ChannelName=Array.concat(ChannelName,s3);
		ChannelType=Array.concat(ChannelType,s4);
	}
}


//===============================================
// generate the parameter file in ParameterData folder


title1="Parameters";
title2 = "["+"Parameters"+"]";
f=title2;
if (isOpen(title1)){
	print(f, "\\Update:");
}else{
	run("Text Window...", "name="+title1+" width=72 height=8 menu");
}
selectWindow(title1);
print(f, "\\Update:");
print(f,"pixel2um "+pix2um+"\n");
print(f,"YoungModulus "+young+"\n");
print(f,"PoissonRatio "+poisson+"\n");
print(f,"Regularization "+regularisation+"\n");
print(f,"vector 0.01\n");
print(f,"max 1000\n");

print(f,"piv1 "+piv1+"\n");
print(f,"sw1 "+sw1+"\n");
print(f,"vs1 "+vs1+"\n");

print(f,"piv2 "+piv2+"\n");
print(f,"sw2 "+sw2+"\n");
print(f,"vs2 "+vs2+"\n");

print(f,"piv3 "+piv3+"\n");
print(f,"sw3 "+sw3+"\n");
print(f,"vs3 "+vs3+"\n");
print(f,"//-----------------------------------------------\n");
for (k=0;k<ChannelName.length;k++){
	print(f,"channel "+ChannelType[k]+" "+ChannelName[k]+"\n");
}
print(f,"//-----------------------------------------------\n");

saveAs("text", dirP+"/"+title1);
run("Close","title1");

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
print("done");
selectWindow("Log");




