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
 {int} TimeIB = asSet(0..-1);

main
{
	thisOplModel.generate();
	if(thisOplModel.model==1)
		var path = "uniform";
	else
		var path = "peak";
	var ttdd = thisOplModel.td[1]*2;
	var pfile = new IloOplOutputFile("/nas/ykaidi/PAP/PAP_CA/Sensitivity_Analysis/results/c="+thisOplModel.c.toString()+"/td="+ttdd.toString()+"/process_fast"+thisOplModel.Id.toString()+"_"+thisOplModel.n.toString()+"_"+path+".txt");

	var ofile = new IloOplOutputFile("/nas/ykaidi/PAP/PAP_CA/Sensitivity_Analysis/results/c="+thisOplModel.c.toString()+"/td="+ttdd.toString()+"/result_fast"+thisOplModel.Id.toString()+"_"+thisOplModel.n.toString()+"_"+path+".txt");
	
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
	pfile.writeln("solving assignment problem");
	// Constructing the model	
	var m1Source = new IloOplModelSource("PAP_CA.mod");
	var m1Cplex = new IloCplex();
	m1Cplex.epagap = 1e-9; 
	m1Cplex.epgap  = 1e-9;
	m1Cplex.threads = 4;
	m1Cplex.tilim = 3600;
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
   //writeln(mduration); 
   
//   for(var i = 0;i<100;i++)
//   {
//   	 if(recordObjAssign[i]!=-1)   
//   	 {
//   	 	write(recordObjAssign[i]);
//   	 	write(" ");  
//   	 }
//   }
//   writeln(";");
//   for(var i = 0;i<100;i++)
//   {
//   	 if(recordStatAssign[i]!=-1)   
//   	 {
//   	 	write(recordStatAssign[i]);
//   	 	write(" ");  
//   	 }
//   }
//   writeln(";");
   
   /********
   ** Solving the pricing problems
   *********/
   
   	var pdata = new IloOplDataElements();
	pdata.Id = thisOplModel.Id;
	pdata.c = thisOplModel.c;
	pdata.n = thisOplModel.n;
	pdata.c = thisOplModel.c;
	pdata.td = thisOplModel.td;
	pdata.T = thisOplModel.T;
	pdata.value = thisOplModel.value;
	
	var priceObj = new Array(thisOplModel.n);
	var price = new Array(thisOplModel.n);
	var time = new Array(thisOplModel.n);
	var status = new Array(thisOplModel.n);
   for(var i in thisOplModel.RQ)// = 55;i<56;i++)
   {
pfile.writeln("solving pricing problem"+i.toString());
   	   
		var pzinit = thisOplModel.zinit;
   	   for(var j in thisOplModel.RQ)
		for(var t in thisOplModel.TimeE)
		{
			pzinit[j][t] = m1Opl.z[j][t];		
		}		
   	   priceObj[i] = 0;
   	   pdata.assign = thisOplModel.assign;
   	   pdata.assign[i] = 0;
   	   var pvectors = new IloOplCplexVectors();
   	   var zi = -1;
   	   for(t in thisOplModel.Time)
   	   {
   	      	if(pzinit[i][t]>1-1e-3)
   	      	{
   	      	    //writeln( pzinit[i][t]);
   	      	   pzinit[i][t] = 0;
   	      	   zi = t;	      	
   	      	  
   	      	}   
   	   }		
   	   	var count = 1;
   	   	start = new Date();
   	   	var p1Source = new IloOplModelSource("PAP_CA.mod");
		var p1Cplex = new IloCplex();
		p1Cplex.epagap = 1e-9; 
		p1Cplex.epgap  = 1e-9;
		p1Cplex.threads = 1;
		p1Cplex.tilim = 1200;
		var p1Def = new IloOplModelDefinition(p1Source);
		var p1Opl = new IloOplModel(p1Def,p1Cplex);	  
		p1Opl.addDataSource(pdata);
		p1Opl.generate();
		pvectors.attach(p1Opl.z,pzinit);
		pvectors.setVectors(p1Cplex);
		p1Cplex.solve();
		priceObj[i] = p1Cplex.getObjValue();
			//writeln(p1Cplex.getObjValue());
		status[i]=p1Cplex.getCplexStatus();
			
	 	end = new Date();
	 	
	 	if(zi>=0)
   	   	{	
   	   		price[i] = priceObj[i] - assignObj + thisOplModel.value[i][zi];
      	}   	   	
   	   	else
   	   		price[i] = 0;	
   	   	time[i] = -start+end;
   	   	pdata.assign[i] = 1;
   	   	p1Cplex.end();
   }   
   ofile.write("price=[");
	for(var i in thisOplModel.RQ)
	{
		if(i<thisOplModel.n)	
		{			
			ofile.write(price[i]);
			ofile.write(",");	
		}
		else
		{
			ofile.write(price[i]);
			ofile.write("];\r\n");			
		}		
	}
	
	ofile.write("priceObj=[");
	for(var i in thisOplModel.RQ)
	{
		if(i<thisOplModel.n)	
		{			
			ofile.write(priceObj[i]);
			ofile.write(",");	
		}
		else
		{
			ofile.write(priceObj[i]);
			ofile.write("];\r\n");			
		}		
	}
	
	ofile.write("status=[");
	for(var i in thisOplModel.RQ)
	{
		if(i<thisOplModel.n)	
		{			
			ofile.write(status[i]);
			ofile.write(",");	
		}
		else
		{
			ofile.write(status[i]);
			ofile.write("];\r\n");			
		}		
	}
	ofile.write("time=[");
	for(var i in thisOplModel.RQ)
	{
		if(i<thisOplModel.n)	
		{			
			ofile.write(time[i]);
			ofile.write(",");	
		}
		else
		{
			ofile.write(time[i]);
			ofile.write("];\r\n");			
		}		
	}

}
 