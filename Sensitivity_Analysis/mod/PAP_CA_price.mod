/*********************************************
 * OPL 12.2 Model
 * Author: kaidi yang
 * Creation Date: 10/07/2016
 * PAP_Value.mod
 *********************************************/
 /************************/
 /* Problem Description:
 * Scheduling Tasks with Time Windows to Solve the Scheduling of Booked Parking
 * Objective Function: Maximize total value
 * ASSIGNMENT FORMULATION
 * TIME DISCRETE */
 

 // Parameters & Sets (DATA)
 
 int Id = ...; // Identifier of the data
 int c = ...; // number of loading areas
 int n = ...; // number of total requests
 range RQ=1..n; // set of requests
 int td[RQ]=...; //Aproximated time of Service for each RQ
 int a[RQ]=...; // Begining of TW
 int b[RQ]=...; // Ending of TW
 int T = 1440; // number of Time Intervals
 {int} Time = asSet(0..T-1); // set of time intervals
 {int} Ext = asSet(-50..-1); // set of extension
 {int} TimeE = Ext union Time; // Extension of time intervals
 float value[RQ][Time]=...;// Value function of the requests
 int assign[RQ]=...;// controls constraint assign
  //  Variables 
int zinit[RQ][TimeE] = ...;
{int} TimeI = ...;

 dvar boolean z[RQ][TimeE];   // Assignment of request to time slot service beginning


 // Objective
 maximize sum(j in RQ, t in Time) (z[j][t]*value[j][t]);


 
 // Constraints
 subject to{ 
 
	forall(j in RQ)
    	Assign:
        sum(t in Time) z[j][t]<=assign[j];
	
	forall(t in TimeI)
	Places:
	sum(j in RQ, tb in (t-td[j]+1..t)) z[j][tb]<=c;

       forall(t in Ext,i in RQ)
	Extern:
	z[i][t]==0;

} 

main
{
	thisOplModel.generate();
	writeln("Setting initial solution");
	var vectors = new IloOplCplexVectors();
	vectors.attach(thisOplModel.z,thisOplModel.zinit);
	vectors.setVectors(cplex);
	cplex.solve();
	writeln("done");
}