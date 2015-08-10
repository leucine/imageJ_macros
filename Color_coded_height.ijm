sectionlist=newArray(2,2,4,4,5,5);
numSection=3;
numFrame=11;

macro "Color Coded Height" {
	
   	ID=getImageID();
   	//group each section, MAX project, and reorganize together as stacks for each frame
	for(time=1; time<=numFrame; time++){
		for(i=1; i<=numSection; i++){
	   		selectImage(ID);
	   		section=i;
	   		bottom=sectionlist[i*2-2];
	   		top=sectionlist[i*2-1];
	   		arg1="title=z"+section+" duplicate slices="+bottom+"-"+top+" frames="+time+"-"+time;
	   		run("Duplicate...", arg1);
	   	
	   		arg2="projection=[Max Intensity]";
	   		run("Z Project...", arg2);
	
	   		close("z"+section);
	   	}
	
	   	arg3="name="+"frame"+time+" title=[] use";
	   	run("Images to Stack", arg3);

	}

	//concatenate the stacks
	argarg4="";
	for (i=1;i<=numFrame;i++){
		argarg4=argarg4+"image"+i+"="+"frame"+i+" ";
	}
	argarg4=argarg4+"image"+(numFrame+1)+"="+"[-- None --]";
	arg4=" title=[Concatenated Stacks] "+argarg4;
	run("Concatenate...", arg4);
	arg5="order=xyczt(default) channels="+numSection+" slices=1 frames="+numFrame+" display=Color";
	run("Stack to Hyperstack...", arg5);
}
