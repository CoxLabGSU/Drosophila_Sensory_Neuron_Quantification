setBatchMode(true);
setBatchMode("hide");
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness area_fraction display redirect=None decimal=3");

run("Point Tool...", "type=Hybrid color=Green size=[Extra Large] label");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
  Dialog.create("Instructions for running this macro.");
  Dialog.addMessage("Select a folder that contains '.jpg' files. \n'.jpg' files need to be thresholded with white neurons and black background. \n \n NOTE: The macro determines genotype based on the first underscore. \n \nThere CANNOT be another underscore in the name. \n \nThere cannot be dashes or other special characters in the name.\n For example, actinKD_larva_1_segment_2. \n Here, the macro will determine the genotype as actinKD.", 14);
  Dialog.show;

  Dialog.create("Functions of this macro.");
  Dialog.addMessage("This macro will perform the following analyses each neuron: \n \n analyze skeleton 2d/3d \n sholl analysis \n modified area coverage analysis along with end point voxels, branches, tdl and density for each box, \n convex hull aera of neuron \n Inside/Outside neuron skeleton analysis ", 14);
  Dialog.show;
  
Dialog.create("NOTE: If macro fails.");
  Dialog.addMessage("This macro automatically detects the cell body for sholl analysis. \n If the cell body is too tiny, then the macro will fail. There are two solutions. \n First, artificially enlarge the cell body. \n Second, change the code at line 78 and 178, where it says '300-infinity'. Change the 300 to a lower number i.e. 100.", 14);
  Dialog.show;

Dialog.create("Area coverage box size.");

Dialog.addMessage("Select the area coverage box size.", 14);
Dialog.addMessage(" ", 14);
 
Dialog.addSlider("Pixels", 1, 100, 20);
Dialog.show();

box_size=Dialog.getNumber();

Dialog.create("Dendrite coverage occupation box size.");

Dialog.addMessage("Select the dendrite coverage occupation box size. \n \n It is recommended to use a minimum of 100 pixel. \n Smaller boxes will take a long time", 14);
Dialog.addMessage(" ", 14);
 
Dialog.addSlider("Pixels", 1, 300, 100);
Dialog.show();

dendrite_coverage_occupation_box_size=Dialog.getNumber();


Dialog.create("Inside/Outside Neurite Analysis.");

Dialog.addMessage("Select the diameter in pixels for inside.", 14);
Dialog.addMessage(" ", 14);
 
Dialog.addSlider("Pixels", 1, 800, 400);
Dialog.show();

Two_parts_box_size=Dialog.getNumber();







dire=getDirectory("Choose folder with clean neurons"); 
  list = getFileList(dire);

requires("1.33s"); 
   
   
   count = 0;
   countFiles(dire);
   n = 0;
   processFiles(dire);
   //print(count+" files processed");
   
   function countFiles(dire) {
      list = getFileList(dire);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dire+list[i]);
          else
              count++;
      }
  }

   function processFiles(dire) {
      list = getFileList(dire);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dire+list[i]);
          else {
             showProgress(n++, count);
             path = dire+list[i];
             processFile(path);
          }
      }
  }





//
//
//Dendrite_coverage_occupation

   
  function processFile(path) {
       //if (endsWith(path, ".tif")) 
    print(i);
       started=getTime();
           open(path);
      named=getTitle();
			print(named);
 rename("original");
run("Collect Garbage");
//run("Smooth");
setOption("BlackBackground", false);
run("Convert to Mask");

run("Create Selection");
run("Convex Hull");
run("Crop");

run("Select None");

run("Duplicate...", " ");
run("Erode");
run("Erode");

run("Remove Outliers...", "radius=3 threshold=50 which=Dark");
run("Erode");

run("Dilate");
run("Dilate");
run("Dilate");

		
run("Analyze Particles...", "size=150-Infinity display exclude clear include add");
close("original-1");
wait(50);
selectWindow("Results");
if (nResults>1){

Table.sort("Area");
}
sdes=nResults-1;
//print(sdes);
xpoint=getResult("XM",sdes);
ypoint=getResult("YM",sdes);
close("original");
	close("Results");	
		
		
		roiManager("Show None");
close("ROI Manager");
		open(path);
		

setOption("BlackBackground", false);
run("Convert to Mask");

 rename("original");
		
run("Create Selection");
run("Convex Hull");
run("Crop");


image_width=getWidth();
image_height=getHeight();
bfx=dendrite_coverage_occupation_box_size;
bfxx=bfx+image_width;
bfy=dendrite_coverage_occupation_box_size;
bfyy=bfy+image_height;




for (ye = bfx; ye < bfxx; ye++) {

for (xe = bfy; xe < bfyy; xe++){
wxe=xe;
makeRectangle(ye-dendrite_coverage_occupation_box_size, wxe-dendrite_coverage_occupation_box_size, dendrite_coverage_occupation_box_size, dendrite_coverage_occupation_box_size);
roiManager("Add");
xe=xe+dendrite_coverage_occupation_box_size-1;
}
ye=ye+dendrite_coverage_occupation_box_size-1;

}

nROI=roiManager("count");



 columns = 1;
  rows = nROI;
 for (ey=0; ey<rows; ey++) {
        
setResult("Neuron", ey, 1);
       setResult("Total dendritic length", ey, 0);
    setResult("End point voxels", ey, 0);
     setResult("EPV divided by TDL", ey, 0);
       setResult("Branches", ey, 0);
     setResult("Branches divided by TDL", ey, 0);
     
     
      setResult("Distance from soma", ey, 0);
     setResult("x_coordinate from soma", ey, 0);
     setResult("y_coordinate from soma", ey, 0);
     
     
     }
Table.setLocationAndSize(100, 400, 300, 200);








 Table.rename("Results", "Results_1");


	

	



for (ni = 0; ni < nROI; ni++) {
//print(ni);
selectWindow("original");
roiManager("Select", ni);



run("Measure");
isthereabranch=getResult("Mean", 0);

xpointroi=getResult("XM",0);
ypointroi=getResult("YM",0);

makeLine(xpoint, ypoint, xpointroi, xpointroi);
run("Measure");
isthereabranch=getResult("Mean", 0);
distancefromsoma=getResult("Area", 1);

x_coordinate_frm_soma=xpointroi-xpoint;
y_coordinate_frm_soma=ypoint-ypointroi;


close("Results");
if(isthereabranch>0){
	
	//print("It's not empty");
selectWindow("original");
roiManager("Select", ni);

run("Duplicate...", "title=roi_crop");
run("Skeletonize (2D/3D)");
run("Analyze Skeleton (2D/3D)", "prune=none calculate");
  
  close("roi_crop");
  close("Tagged skeleton");
close("Longest shortest paths");
result_row=nResults;
tdl_sum=0;
epv_sum=0;
branch_sum=0;
for (res_row = 0; res_row < result_row; res_row++) {
branch_row=getResult("# Branches", res_row);
branch_sum=branch_sum+branch_row;
epv_row=getResult("# End-point voxels", res_row);
epv_sum=epv_sum+epv_row;
tdl_row=getResult("# Slab voxels", res_row);
tdl_sum=tdl_sum+tdl_row;

}

close("Results");
Table.rename("Results_1", "Results");


  setResult("Neuron", ni+1, replace(named,".j.*",""));
 setResult("Total dendritic length", ni+1, tdl_sum);
 setResult("End point voxels", ni+1, epv_sum);
 setResult("EPV divided by TDL", ni+1, epv_sum/tdl_sum);

 setResult("Branches", ni+1, branch_sum);
 setResult("Branches divided by TDL", ni+1, branch_sum/tdl_sum);

setResult("Distance from soma", ni+1, distancefromsoma);
  setResult("x_coordinate from soma", ni+1, x_coordinate_frm_soma);
 setResult("y_coordinate from soma", ni+1, y_coordinate_frm_soma);

 
 Table.rename("Results", "Results_1");
}

}
    
roiManager("Show None");
close("ROI Manager");

		close("original");
	
Table.rename("Results_1", "Results");
ro=replace(named,".j.*","_dendrite_coverage_occupation.csv");
saveAs("Results", dire +ro);

	close("Results");
	
	ended=getTime();
	elasped= (list.length-i)*(ended-started)/1000/60/60;
	
	print("Time left till completion: " + elasped + " hours");
	neu=list.length-i;
	print("Neurons left to analyze: " + neu);
	run("Collect Garbage");
  }

//
close("Results");

//Inside and outside analysis
//
//
//
//

  for(e=0; e<list.length; e++){
open(dire+list[e]);
print(list[e]);
neu=list.length-e;
	print("Neurons left to analyze: " + neu);
run("Collect Garbage");
rename("original");
 

setOption("BlackBackground", false);
run("Convert to Mask");
run("Duplicate...", " ");
run("Erode");
run("Erode");

run("Remove Outliers...", "radius=3 threshold=50 which=Dark");
run("Erode");

run("Dilate");
run("Dilate");
run("Dilate");
run("Analyze Particles...", "size=150-Infinity display exclude clear include add in_situ");
close("original-1");
selectWindow("Results");
if (nResults>1){

Table.sort("Area");
}
sdes=nResults-1;
print(sdes);
point_x=getResult("XM",sdes);
point_y=getResult("YM",sdes);

run("Duplicate...", "title=Cell_crop");	
makePoint(point_x,point_y);

makeOval(point_x-(Two_parts_box_size/2), point_y-(Two_parts_box_size/2), Two_parts_box_size, Two_parts_box_size);
run("Make Inverse");
setBackgroundColor(0, 0, 0);
run("Clear", "slice");
run("Invert");
close("Results");

run("Skeletonize (2D/3D)");
run("Analyze Skeleton (2D/3D)", "prune=none calculate");
  
  close("Cell_crop");
  close("Tagged skeleton");
close("Longest shortest paths");
		 ro=replace(list[e],".j.*","_Inside_skeleton.csv");
saveAs("Results", dire +ro);

makeOval(point_x-(Two_parts_box_size/2), point_y-(Two_parts_box_size/2), Two_parts_box_size, Two_parts_box_size);

run("Clear", "slice");
run("Invert");


run("Skeletonize (2D/3D)");
run("Analyze Skeleton (2D/3D)", "prune=none calculate");
  
 close("original");
  close("Tagged skeleton");
close("Longest shortest paths");
			 ro=replace(list[e],".j.*","_Outside_skeleton.csv");
saveAs("Results", dire +ro);
close("Roi Manager");
open(dire+list[e]);
rename("original");

run("Duplicate...", "title=Cell_crop");	

setOption("BlackBackground", false);
run("Convert to Mask");
makePoint(point_x,point_y);

makeOval(point_x-(Two_parts_box_size/2), point_y-(Two_parts_box_size/2), Two_parts_box_size, Two_parts_box_size);
run("Make Inverse");
setBackgroundColor(0, 0, 0);
run("Clear", "slice");
run("Invert");

selectWindow("original");
setOption("BlackBackground", false);
run("Convert to Mask");
setBackgroundColor(0, 0, 0);


makeOval(point_x-(Two_parts_box_size/2), point_y-(Two_parts_box_size/2), Two_parts_box_size, Two_parts_box_size);

run("Clear", "slice");
run("Invert");

run("Merge Channels...", "c2=Cell_crop c6=original");
saveAs("Jpeg", dire+replace(list[e],".j.*","_inside_out.jpg"));

close();
run("Collect Garbage");
  }
close("Roi Manager");
close("Log");
close("Results");
//

//

//
//

//
//Area coverage analysis




 columns = 1;
  rows = list.length;
 for (e=0; e<rows; e++) {
        
        setResult("Neuron", e, 1);
       setResult("Area_coverage", e, 0);
   
    
     }
Table.setLocationAndSize(100, 400, 300, 200);

Table.rename("Results", "Results_1");



  for(e=0; e<list.length; e++){
{
 	//print(list[e]);       
		run("Collect Garbage");
		open(dire+list[e]);
neu=list.length-e;
	print("Neurons left to analyze: " + neu);
setOption("BlackBackground", false);
run("Convert to Mask");

 rename("original");
		
run("Create Selection");
run("Convex Hull");
run("Crop");



image_width=getWidth();
image_height=getHeight();
bfx=box_size;
bfxx=bfx+image_width;
bfy=box_size;
bfyy=bfy+image_height;




for (ye = bfx; ye < bfxx; ye++) {

for (xe = bfy; xe < bfyy; xe++){
wxe=xe;
makeRectangle(ye-box_size, wxe-box_size, box_size, box_size);
roiManager("Add");
xe=xe+box_size-1;
}
ye=ye+box_size-1;

}

nROI=roiManager("count");

for (ni = 0; ni < nROI; ni++) {

roiManager("Select", ni);
run("Measure");

}


result_row=nResults;
boxed_dendrite=0;
for (res_row = 0; res_row < result_row; res_row++) {
mean_row=getResult("Mean", res_row);
if(mean_row>0){
boxed_dendrite=boxed_dendrite+1;

}
}
print(boxed_dendrite);
area_cov_final=((boxed_dendrite/result_row)*100);
close("Results");
Table.rename("Results_1", "Results");
print(area_cov_final);

 setResult("Neuron", e, replace(list[e],".j.*",""));

 setResult("Area_coverage", e, area_cov_final);
print(replace(list[e],".j.*","	") +"	"+ (boxed_dendrite/result_row)*100);
close("ROI Manager");
		close("original");
		Table.rename("Results", "Results_1");


		}
  }

Table.rename("Results_1", "Results");
saveAs("Results", dire+"Area_coverage.csv");
close("Results");
//
//

//
//
//
//
//
// Convex Hull area





  for(e=0; e<list.length; e++){
run("Collect Garbage");
 	//print(list[e]);       
		neu=list.length-e;
	print("Neurons left to analyze: " + neu);
		open(dire+list[e]);

setOption("BlackBackground", false);
run("Convert to Mask");


		
run("Create Selection");
run("Convex Hull");
run("Measure");

close(list[e]);
		run("Collect Garbage");
  }


saveAs("Results", dire+"Convex_hull_Area.csv");
close("Results");
close("Log");
//

//Whole neuron sholl and skeleton analysis

  for(e=0; e<list.length; e++){
{
 	print(list[e]);       
open(dire+list[e]);
neu=list.length-e;
	print("Neurons left to analyze: " + neu);
       rename("original");
       run("Collect Garbage");
          //  run("Smooth");
setOption("BlackBackground", false);
run("Convert to Mask"); // This filter works better for the Skeletonize program
			run("Skeletonize (2D/3D)");

             run("Analyze Skeleton (2D/3D)", "prune=none calculate");
  
			
			 ro=replace(list[e],".j.*","_whole_skeleton.csv");
saveAs("Results", dire +ro);

close("Results");
 close("Longest shortest paths");
 close("Tagged skeleton");
 close("original");
 
open(dire+list[e]);



 rename("original");
 
//run("Smooth");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Duplicate...", " ");
run("Erode");
run("Erode");

run("Remove Outliers...", "radius=3 threshold=50 which=Dark");
run("Erode");

run("Dilate");
run("Dilate");
run("Dilate");
run("Analyze Particles...", "size=150-Infinity display exclude clear include add in_situ");
close("original-1");
selectWindow("Results");
if (nResults>1){

Table.sort("Area");
}
sdes=nResults-1;
print(sdes);
makePoint(getResult("XM",sdes),getResult("YM",sdes));

run("Flatten");
makePoint(getResult("XM",sdes),getResult("YM",sdes));
makeRectangle(getResult("XM",sdes)-75, getResult("YM",sdes)-75, 150, 150);
run("Crop");
//run("Canvas Size...", "width=3000 height=3000 position=Center");
saveAs("Jpeg", dire+replace(list[e],".j.*","_roi.jpg"));
close("original-1");
close("Results");
rename(list[e]);

run("Legacy: Sholl Analysis (From Image)...", "starting=1 ending=6000 radius_step=0 #_samples=1 integration=Mean enclosing=1 #_primary=0 infer fit linear polynomial=[Best fitting degree] normalizer=Area overlay directory=[]");

rom=replace(list[e],".j.*","");

selectWindow(rom+"_Sholl-Profiles");

			 ros=replace(list[e],".j.*","_sholl.csv");


saveAs("Results", dire+ros);
close(list[e]);
close(ros);
close("Sholl profile (linear) for "+rom);
close("ROI Manager");

	
		
		
  }
  }
sr=dire+"sholl_stats.csv";
//rename("Results");
saveAs("Results", sr);
//close("Sholl Results");
//run("Image Sequence...");
Table.rename("Sholl Results", "Results");
saveAs("Results", dire+"Sholl Results.csv");
close("Results");

close("Log");
//
//

//
//



beep();

seq="open=["+dire+list[1]+"] file=roi sort";

run("Image Sequence...", seq);
beep();
