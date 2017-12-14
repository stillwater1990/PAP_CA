/*********************************************
 * OPL 12.6.3.0 Model
 * Author: ykaidi
 * Creation Date: 2016 11 29 at 18:42:18
 *********************************************/
 int Id = ...; // Identifier of the data
 int c = ...; // number of loading areas
 int n = ...; // number of total requests
 range RQ=1..n; // set of requests
 int td[RQ]=...; //Aproximated time of Service for each RQ
 int T = ...; // number of Time Intervals
 {int} Time = asSet(0..T-1); // set of time intervals
 {int} TimeI = asSet(0..-1); // set of time intervals
 {int} Ext = asSet(-50..-1); // set of extension
 {int} TimeE = Ext union Time; // Extension of time intervals
 float value[RQ][Time]=...;// Value function of the requests
 int assign[RQ]= [i:1|i in RQ];// controls constraint assign
 int zinit[RQ][TimeE] = ...;
 int model = ...;

main
{
	thisOplModel.generate();
	//var pfile = new IloOplOutputFile("process_no_price"+thisOplModel.Id.toString()+"_"+thisOplModel.model.toString()+"_"+thisOplModel.T.toString()+".txt");

	var ofile = new IloOplOutputFile("result_no_price"+thisOplModel.Id.toString()+"_"+thisOplModel.model.toString()+"_"+thisOplModel.T.toString()+".txt");
	
	/*****************************
	** Solving the assignment problem
	******************************/
	
	// Defining the data files
	var mdata = new IloOplDataElements();
	mdata.Id = thisOplModel.Id;
	mdata.c = thisOplModel.c;
	mdata.n = thisOplModel.n;
	mdata.c = thisOplModel.c;
	mdata.td = thisOplModel.td;
	mdata.T = thisOplModel.T;
	mdata.value = thisOplModel.value;
	mdata.assign = thisOplModel.assign;
	var assignObj = 0;
	var start  = new Date();
	//pfile.writeln("solving assignment problem");
	// Constructing the model	
	var m1Source = new IloOplModelSource("PAP_CA.mod");
	var m1Cplex = new IloCplex();
	m1Cplex.epagap = 1e-6; 
	m1Cplex.epgap  = 1e-6;
	m1Cplex.threads = 6;
	//m1Cplex.tilim = 3600;
	var m1Def = new IloOplModelDefinition(m1Source);
	var m1Opl = new IloOplModel(m1Def,m1Cplex);	  
	m1Opl.addDataSource(mdata);
	m1Opl.generate();
	m1Cplex.solve();
	assignObj = m1Cplex.getObjValue();
	mrecordObjAssign = m1Cplex.getObjValue();
	mrecordStatAssign = m1Cplex.getCplexStatus();
   var end = new Date() ;
   var mduration = end - start;
   
   ofile.write("assign=[");
   for(var j in thisOplModel.RQ)   {      
		for(var t in thisOplModel.TimeE)
		{
			if(m1Opl.z[j][t]>1-1e-3){
				ofile.write("[");
				ofile.write(j);
				ofile.write(",");
				ofile.write(t);
				ofile.write("]");
				if(j<thisOplModel.n)
					ofile.write(";");
				else
					ofile.write("];\r\n");
   			}											
				
		}
	}		
		
	ofile.writeln("assigntime="+mduration.toString()+";");	
	ofile.writeln("assignObj="+assignObj.toString()+";");
	ofile.writeln("assignStatus="+mrecordStatAssign.toString()+";");
   
}
 