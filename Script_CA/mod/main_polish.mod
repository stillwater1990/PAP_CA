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
	var pfile = new IloOplOutputFile("process_polish"+thisOplModel.Id.toString()+"_"+thisOplModel.model.toString()+"_"+thisOplModel.T.toString()+".txt");

	var ofile = new IloOplOutputFile("result_polish"+thisOplModel.Id.toString()+"_"+thisOplModel.model.toString()+"_"+thisOplModel.T.toString()+".txt");
	
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
	m1Cplex.threads = 1;
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
   var mresult = new Array(thisOplModel.n);
   ofile.write("assign=[");
   for(var j in thisOplModel.RQ)   { 
		mresult[j] = -50; 
		for(var t in thisOplModel.TimeE)
		{
			if(m1Opl.z[j][t]>1-1e-3){
				mresult[j] = t; 
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
	/*
	write("mresult=")
	for(var j in thisOplModel.RQ){
			write(mresult[j]);
			write(",")
	   }
	   writeln("\r\n")*/
	var priceObj = new Array(thisOplModel.n);
	var price = new Array(thisOplModel.n);
	var time = new Array(thisOplModel.n);
	var status = new Array(thisOplModel.n);
   for(var i in thisOplModel.RQ)
   {
pfile.writeln("solving pricing problem"+i.toString());
   	    var presult = new Array(thisOplModel.n);
		
		var pzinit = thisOplModel.zinit;
		for(var j in thisOplModel.RQ){
			if(j==i)
				presult[j] =-50;
			else
			{
				presult[j] = mresult[j];	

}				
			for(var t in thisOplModel.TimeE)
			{
				pzinit[j][t] = m1Opl.z[j][t];		
			}
		}
		
		var zi = mresult[i];
	   
		while(1>0)
		{
			var flag = 1>0;
			for(var j in thisOplModel.RQ)
			{
				if(j==i)
					continue;
				else
				{
					for(var tt=0;tt<thisOplModel.T;tt++)
					{
						if(presult[j]<0 && thisOplModel.value[j][tt] > 1e-3 ||  presult[j]>=0 && thisOplModel.value[j][tt]>thisOplModel.value[j][presult[j]]+1e-3 )
						{
							var tempcount = 0;
							for(jj in thisOplModel.RQ)
							{
								if(jj == i || jj==j)
									continue;
								if(tt<presult[jj]+thisOplModel.td[jj] && tt>presult[jj]-thisOplModel.td[j])
									tempcount++;
								if(tempcount>=thisOplModel.c)
									break;
							
							}
							if(tempcount<thisOplModel.c)
							{
								presult[j] = tt;
								flag = 0>1;
								/*
								write(tempcount);
								write(",");
								write(j);
								write(",");
								write(thisOplModel.value[j][tt]);
								write(",");
								write(tt);
								write("\r\n")
								*/
							}
						}
					}
				}
			}
			if(flag)
				break;
		}
		for(var j in thisOplModel.RQ)
		{
			for(t in thisOplModel.TimeE)
			{
				if(t==presult[j] && presult[j]>=0)
					pzinit[j][t] = 1;
				else
					pzinit[j][t] = 0;
			}
		}
		/*	write("presult=")
	for(var j in thisOplModel.RQ){
			write(presult[j]);
			write(",")
	   }
	   writeln("\r\n")*/
   	   priceObj[i] = 0;
   	   pdata.assign = thisOplModel.assign;
   	   pdata.assign[i] = 0;
   	   var pvectors = new IloOplCplexVectors();
   	
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
 