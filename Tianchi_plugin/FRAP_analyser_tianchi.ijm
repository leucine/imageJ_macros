//This macro measures the flruorescence from a FRAPped ROI 
//then correct for background and photobleaching

macro "FRAP_analyser_tianchi" {
	run("Set Measurements..."," mean redirect=None decimal=3");
	waitForUser("Open a FRAP image stack and click OK");
	defaultpath="C:"+File.separator+"Users"+File.separator+"Administrator"+File.separator+"Desktop"+File.separator+"FRAP_analysis"+File.separator;
	
	//get image info
	name=getInfo("image.filename");
	nickname="FRAP";
	rename(nickname);
	Dialog.create("New FRAP measurement");
	Dialog.addNumber("interval in sec", 3);
	Dialog.addNumber("first slice No. after bleach", 21)
	Dialog.addString("savepath:", defaultpath);
	Dialog.show;
	interval=Dialog.getNumber();
	scliceFRAP=Dialog.getNumber();
	path=Dialog.getString();
	savepath=path+name+File.separator;
	File.makeDirectory(savepath);

	//get ROI measurement
	waitForUser("Draw an ROI on bleached area and click OK."); 
	run("Plot Z-axis Profile");
	FRAProi = newArray(nResults);
	numResult=nResults;
	for(i=0; i<nResults; ++i) {
		FRAProi[i] = getResult("Mean",i); 
	}
	run("Close");
	
	//get background
	selectWindow(nickname);
	waitForUser("Draw a background ROI click OK.");
	run("Plot Z-axis Profile");
	BackRoi = newArray(nResults);
	for(i=0; i<nResults; ++i){
		BackRoi[i] = getResult("Mean",i);
	}
	run("Close");
	
	//get reference ROI for photo bleaching
	selectWindow(nickname);
	waitForUser("Draw a reference ROI click OK.");
	run("Plot Z-axis Profile");
	RefRoi = newArray(nResults);
	for(i=0; i<nResults; ++i){
		RefRoi[i] = getResult("Mean",i);
	}
	run("Close");

	//calculate normalized FRAP data
	nor = newArray(numResult);
	for(i=0; i<numResult; ++i){
		nor[i] = ((FRAProi[i]-BackRoi[i]) / (RefRoi[i]-BackRoi[i])) * ((RefRoi[0]-BackRoi[0]) / (FRAProi[0]-BackRoi[0]));
	}
	
	//save results
	time=newArray(numResult);
	for(i=0; i<numResult; ++i){
		time[i] = (i+1-scliceFRAP)*interval;
	}
	savedata(savepath);
}

function savedata(savepath) {
	f1 = File.open(savepath+"NormalizedData.txt");
	print(f1, "time(min)\tIntesity(A.U.)");
	for (i=0; i<numResult; i++) {
		print(f1, time[i]+"\t"+nor[i]);
	}
	File.close(f1);
}