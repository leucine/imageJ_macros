numFrames=11;
thickness=8;
positionlist=newArray(4,4,4,4,4,4,4,4,4,4,4); //starting z position of each frame, length(positionlist)>=numFrames

macro "Manual stack stabilizer" {
	ID=getImageID();
	//dupicate the stacks of images at each time point according to the position list
	for (i=1;i<=numFrames;i++){
		selectImage(ID);
		time=i;
		bottom=positionlist[i-1];
		top=bottom+thickness-1;
		arg1="title=t"+time+" duplicate slices="+bottom+"-"+top+" frames="+time+"-"+time;
		//print(arg1);
		run("Duplicate...", arg1);

	}
	//concatenate the stacks
	argarg2="";
	for (i=1;i<=numFrames;i++){
		argarg2=argarg2+"image"+i+"="+"t"+i+" ";
	}
	argarg2=argarg2+"image"+(numFrames+1)+"="+"[-- None --]";
	arg2=" title=[Concatenated Stacks] "+argarg2;
	run("Concatenate...", arg2);
	//reorganize the stacks to hyperstack with frames and slices
   	arg3="order=xyczt(default) channels=1 slices="+thickness+" frames="+numFrames+" display=Grayscale";
   	run("Stack to Hyperstack...", arg3);
}

