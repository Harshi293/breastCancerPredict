/*
BIA 652 : Final Project
Developers :

Rini Basu
Harshitha Raghavendra
Shruti Shete


*/

data new_bc;
 set Work.wisc;
 if diagnosis ="M" then diag_ind=1;else diag_ind=0;
  run;
  /* descriptive analysys :
  so we start out with a data set that has 63% B case and rest M case*/
proc freq data=new_bc;
     table diagnosis;
	 run;
	 /* univariate analysis descriptive */
proc means data = new_bc;
run;
title 'scatter plot for area_se as independant and id as dependant value because our proc means gave usa hint of outliers
in area_se';
run;
/*scatter plot for outlier */
proc sgplot data = new_bc;
scatter x=id y=area_se/MARKERCHAR=area_se;
run;
/* removing outliers */
data final_bc;
 set Work.new_bc;
 if area_se = 542.2 then delete;
 if area_se = 525.6 then delete;
  run;
title 'again checking the basic stats after outliers removed';
run;
proc means data = final_bc;
run;
/* logistic reg with all variables */
title 'Checking all variables logistic regression';
run;
proc logistic data = final_bc Plots = all descending  ;
  model diag_ind = texture_mean perimeter_mean area_mean smoothness_mean compactness_mean compactness_mean 
     concave_points_mean symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se area_se smoothness_se 
     compactness_se concavity_se concave_points_se symmetry_se fractal_dimension_se radius_worst texture_worst 
     perimeter_worst area_worst smoothness_worst compactness_worst concavity_worst 
     concave_points_worst symmetry_worst fractal_dimension_worst /ctable;
	 run;

/* checking stepwise regression for a better variable sleection */
title 'Checking stepwise logistic regression';
run;
	 proc logistic data = final_bc Plots = all descending  ;
  model diag_ind = texture_mean perimeter_mean area_mean smoothness_mean compactness_mean compactness_mean 
     concave_points_mean symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se area_se smoothness_se 
     compactness_se concavity_se concave_points_se symmetry_se fractal_dimension_se radius_worst texture_worst 
     perimeter_worst area_worst smoothness_worst compactness_worst concavity_worst 
     concave_points_worst symmetry_worst fractal_dimension_worst /ctable selection = stepwise;
OUTPUT out = bc_out_step p=p lower = lcl upper =ucl ;
	 run;
	title 'Checking forward logistic regression';
run;
	 proc logistic data = final_bc Plots = all descending  ;
  model diag_ind = texture_mean perimeter_mean area_mean smoothness_mean compactness_mean compactness_mean 
     concave_points_mean symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se area_se smoothness_se 
     compactness_se concavity_se concave_points_se symmetry_se fractal_dimension_se radius_worst texture_worst 
     perimeter_worst area_worst smoothness_worst compactness_worst concavity_worst 
     concave_points_worst symmetry_worst fractal_dimension_worst /ctable selection = forward;
OUTPUT out = bc_out_fwd p=p lower = lcl upper =ucl ;
	 run;
title 'Checking backward logistic regression';
run;
proc logistic data = final_bc Plots = all descending  ;
  model diag_ind = texture_mean perimeter_mean area_mean smoothness_mean compactness_mean compactness_mean 
     concave_points_mean symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se area_se smoothness_se 
     compactness_se concavity_se concave_points_se symmetry_se fractal_dimension_se radius_worst texture_worst 
     perimeter_worst area_worst smoothness_worst compactness_worst concavity_worst 
     concave_points_worst symmetry_worst fractal_dimension_worst /ctable selection = backward;
OUTPUT out = bc_out_back p=p lower = lcl upper =ucl ;
	 run;

/* PCA  */

%let varlist= radius_mean texture_mean perimeter_mean area_mean smoothness_mean compactness_mean concavity_mean concave_points_mean symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se area_se smoothness_se compactness_se concavity_se concave_points_se symmetry_se fractal_dimension_se radius_worst 
              texture_worst perimeter_worst area_worst smoothness_worst compactness_worst concavity_worst concave_points_worst symmetry_worst fractal_dimension_worst       ;
     
title "Principal Component Analysis"; 
title2 " Univariate Analysis"; 
proc univariate data=final_bc;
   var &varlist;
run;

/* Correlations of all variables*/

proc corr data=final_bc cov; 
var  &varlist  ;
run;

/* PCA Analysis*/
proc princomp data=final_bc out=wisc_PCA;
 var &varlist;
run;

/* Correlating PCA componenets*/
proc corr data=wisc_PCA cov;
var  Prin1 Prin2 Prin3 Prin4 Prin5 Prin6 Prin7 Prin8 Prin9 Prin10  ;
run;

/* Logistics on PCA */

 proc princomp data=final_bc out=pca_wisc; 
var radius_mean texture_mean perimeter_mean area_mean smoothness_mean compactness_mean concavity_mean
concave_points_mean symmetry_mean fractal_dimension_mean
radius_se texture_se perimeter_se area_se smoothness_se compactness_se concavity_se concave_points_se symmetry_se 
fractal_dimension_se
radius_worst texture_worst perimeter_worst area_worst smoothness_worst compactness_worst concavity_worst
concave_points_worst symmetry_worst fractal_dimension_worst;
run;

ods html close;
 ods rtf body='O:\Multivariate\SAS_OUTPUT\FinalProjectPCALogisticReg.rtf' ;
proc logistic data=pca_wisc descending;
  model   diag_ind=Prin1 Prin2 Prin3 Prin4 Prin5 Prin6 Prin7 Prin8 Prin9 Prin10/ctable;
  output out=regPCAout p=p lower=lcl upper=ucl;
quit;
 ods rtf close;
ods html;
