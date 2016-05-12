/*********************************************
 * OPL 12.2 Model
 * Author: mireia.roca
 * Creation Date: 23/08/2015
 * PAP_1.mod
 *********************************************/
 /************************/
 /* Problem Description:
 * Scheduling Tasks with Time Windows to Solve the Scheduling of Booked Parking
 * Objective Function: (1) 1 Earliness tardiness penalties 
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
 int et[RQ][TimeE]=...; // Penalty of the Model on the objective function 
			// Penalty in MOD1 is earliness/tardiness, depending if the time task is sheduled regarding their TW
  
  //  Variables 
 
 dvar boolean z[RQ][TimeE];   // Assignment of request to time slot service beginning

 // Objective
 minimize sum(j in RQ,t in TimeE) et[j][t]*z[j][t];

 
 // Constraints
 subject to{ 
 
	forall(j in RQ)
    	Assign:
        sum(t in Time) z[j][t]==1;
	
	forall(t in Time)
	Places:
	sum(j in RQ, tb in (t-td[j]+1..t)) z[j][tb]<=c;

       forall(t in Ext,i in RQ)
	Extern:
	z[i][t]==0;
} 
