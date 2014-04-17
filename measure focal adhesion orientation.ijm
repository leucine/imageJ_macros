/*
 * This macro operates on an opened image to mannually analyse the directionality and length of focal adhesions.
 * The outputs are two text files containning respectively the angles and lengths of focal adhesions measuered as well as an annotated tiff image.
 * This macro is written by Tianchi in April 2014.
 */
macro "Measure Focal Adhesion Orientation" {
name=getInfo("image.filename");
getPixelSize(unit, pixelWidth, pixelHeight);

//decide whether to measure the lenth of focal adhesions, and whether to draw a contour as a reference

Dialog.create("Measure Focal Adhesion Orientation");
label1=newArray("measure focal adhesion lenth", "draw contour of epithelium", "set scalebar for reference");
label2= "enter the path for saving the results:";
defaultchoice1=newArray("true", "true", "true");
defaultpath="C:\\Users\\Administrator\\Desktop\\FA orientation measurement\\";
choice1=newArray(3);
Dialog.addCheckboxGroup(1, 3, label1, defaultchoice1);
Dialog.addNumber("scale bar length in um", 1);
Dialog.addString(label2, defaultpath);
Dialog.show;
FAmaxilength=Dialog.getNumber();
for (i=0; i<3; i++) {
	choice1[i]=Dialog.getCheckbox();
}
path=Dialog.getString();

//draw the contour
if (choice1[1]==1) {
	setTool("freeline");
	run("Line Width...", "line=10");
	run("Colors...", "foreground=white background=black selection=blue");
	waitForUser("draw contour", "use freeline tool to draw the contour of the epithelium");
	run("Overlay Options...", "stroke=blue width=0 fill=none set");
	run("Add Selection...");
}

//set a scale bar as a reference
if (choice1[2]==1) {
	run("Scale Bar...", "width=FAmaxilength height=5 font=18 color=White background=None location=[Lower Right] bold overlay");
}

//ask user to draw all the FAs and orientations angles, first line of angle corrisponds to the FA, measure each focal adhesion

run("Overlay Options...", "stroke=yellow width=0 fill=none set");
setTool("angle");
waitForUser("before you go...", "draw all the FAs with the angle tool, first line of angle should corrispond to the FA in length, press \"OK\" after finish.\n");
run("To ROI Manager");
roiManager("Show All with labels");
nROI=roiManager("count");
nFAminus=0;
if (choice1[1]==1) {
	nFAminus++;
}
if (choice1[2]==1) {
	nFAminus=nFAminus+2;
}
FAcoordx1=newArray(nROI-nFAminus);
FAcoordy1=newArray(nROI-nFAminus);
FAcoordx2=newArray(nROI-nFAminus);
FAcoordy2=newArray(nROI-nFAminus);
FAlength=newArray(nROI-nFAminus);
//FAangle=newArray(nROI-nFAminus);
for (nFA=1; nFA<=nROI-nFAminus; nFA++) {
	roiManager("Select", nFA+nFAminus-1);
	run("Set Measurements...", "  redirect=None decimal=9");
	roiManager("Measure");
	coord=Roi.getCoordinates(xpoints, ypoints);
	FAcoordx1[nFA-1]=xpoints[0];
	FAcoordy1[nFA-1]=ypoints[0];
	FAcoordx2[nFA-1]=xpoints[1];
	FAcoordy2[nFA-1]=xpoints[1];
	FAlength[nFA-1]=pixelWidth*sqrt((xpoints[0]-xpoints[1])*(xpoints[0]-xpoints[1])+(ypoints[0]-ypoints[1])*(ypoints[0]-ypoints[1]));
}

//sumerize the result and output to a text file, save the annotated image as TIFF file
IJ.renameResults("FA angle");
saveAs("Results", path+"FA angle.txt");
if (choice1[0]==1) {
	f = File.open(path+"FA length.txt");
	for (i=0; i<nROI-nFAminus; i++) {
		print(f, FAlength[i]);
	}
	File.close(f);
}
selectWindow(name);
saveAs("tiff",path+name+"_measurement");

}

