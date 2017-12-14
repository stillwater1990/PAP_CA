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
	//process file (keep track of where the program goes)
	var pfile = new IloOplOutputFile("process_lazy"+thisOplModel.Id.toString()+"_"+thisOplModel.model.toString()+"_"+thisOplModel.T.toString()+".txt");
	//output result file
	var ofile = new IloOplOutputFile("result_lazy"+thisOplModel.Id.toString()+"_"+thisOplModel.model.toString()+"_"+thisOplModel.T.toString()+".txt");
	
	/*****************************
	** Solving the assignment problem
	******************************/	
	// Defining the data files for the assignment problem
	var mdata = new IloOplDataElements();
	mdata.Id = thisOplModel.Id;
	mdata.c = thisOplModel.c;
	mdata.n = thisOplModel.n;
	mdata.c = thisOplModel.c;
	mdata.td = thisOplModel.td;	
	mdata.T = thisOplModel.T;
	mdata.value = thisOplModel.value;
	mdata.assign = thisOplModel.assign;
	mdata.TimeI = thisOplModel.TimeI;
	var mvectors = new IloOplCplexVectors();
	
	// variable for checking if a capacity constraint is violated
	var supply = new Array(1440); 

	// Determining the initial set of constraints using the initial solution
	for(var i in thisOplModel.RQ)
        for(var t in thisOplModel.Time)
        	if(thisOplModel.zinit[i][t]>1-1e-3 && thisOplModel.value[i][t]>1e-3)
        	{
        		for(var tt=t;tt<t+thisOplModel.td[i];tt++)  
        		    supply[tt]++;        		     		
        		break;
        	}          
	    
	for(var t in thisOplModel.Time)
		if(supply[t]>=thisOplModel.c)    	    
		    mdata.TimeI.add(t);   	    	 
	
	// Dynamically adding constraints to the assignment problem	
	var count = 1;
	var mstatus = 0;
	var assignObj = 0;
	var start  = new Date();
	pfile.writeln("solving assignment problem");
	while(count>0){ // if there are capacity constraints violated, do the following		
		var intermediate  = new Date();
		//writeln(mdata.TimeI);	
		//if(intermediate-start>3600000) // if the running time exceeds one hour, return fail
		//{ 
		//	mstatus = -1;
		//	break;
		//}
		
		// Constructing the model			
		var m1Source = new IloOplModelSource("PAP_CA_con.mod");
		var m1Cplex = new IloCplex();
		m1Cplex.epagap = 1e-6; 
		m1Cplex.epgap  = 1e-6;
		m1Cplex.threads = 1; // with only one thread
		//m1Cplex.tilim = 3600;
		var m1Def = new IloOplModelDefinition(m1Source);
		var m1Opl = new IloOplModel(m1Def,m1Cplex);	  
		m1Opl.addDataSource(mdata);
		m1Opl.generate();
		m1Cplex.solve();
		assignObj = m1Cplex.getObjValue();
		mrecordObjAssign = m1Cplex.getObjValue();
		mstatus = m1Cplex.getCplexStatus();
		
		//Checking the constraints
		for(var t in m1Opl.Time)
			supply[t] = 0;
			
		for(var i in m1Opl.RQ)
	        for(var t in m1Opl.Time)
	        	if(m1Opl.z[i][t]>1-1e-3 && mdata.value[i][t]>1e-3)
	        	{
	        		for(var tt=t;tt<t+m1Opl.td[i];tt++)  
	        		    supply[tt]++;        		     		
	        		break;
	        	}      
	        	
	    count = 0;
	    tlast = 0;
	    for(var t in m1Opl.Time)
	    	if(supply[t]>=m1Opl.c-1)
	    	{	    	    
	    	    if(t-tlast<=5)
	    	    	for(var tt=tlast+1;tt<=t;tt++)
	    	    	{
    	    			mdata.TimeI.add(tt);
	    	    			    	    	
	    	    	}	
	    	    else  {
	    	    	mdata.TimeI.add(t);
         		}
         		tlast = t;	    	    	
	    	    if(supply[t]>m1Opl.c)
	    	    {
	    	    	count ++;	
	    	    	//writeln(t);    	    
	    	    }	    	    	
	    	}
	    	  	 
   }	   
   var end = new Date() 
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
	ofile.writeln("assignStatus="+mstatus.toString()+";");
   
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
	
	pdata.TimeI = m1Opl.TimeI;
	var price = new Array(thisOplModel.n);
	var priceObj = new Array(thisOplModel.n);
	var time = new Array(thisOplModel.n);
	var status = new Array(thisOplModel.n);
   for(var i in thisOplModel.RQ)
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
   	      	   pzinit[i][t] = 0;
   	      	   zi = t;	      	
   	      	  
   	      	}   
   	   }		
   	   	var count = 1;
   	   	start = new Date();
		while(count>0){
			temp = new Date();
			if(temp - start>3600000)
			{
				price[i] = -1;
				priceObj[i] = -1;
				status[i] = -100;
				break;
			}
	   	   	var p1Source = new IloOplModelSource("PAP_CA_con.mod");
			var p1Cplex = new IloCplex();
			p1Cplex.epagap = 1e-6; 
			p1Cplex.epgap  = 1e-6;
			p1Cplex.threads = 1;
			p1Cplex.tilim=1200;
			var p1Def = new IloOplModelDefinition(p1Source);
			var p1Opl = new IloOplModel(p1Def,p1Cplex);	  
			p1Opl.addDataSource(pdata);
			p1Opl.generate();
			p1Cplex.solve();
			priceObj[i] = p1Cplex.getObjValue();
			//writeln(p1Cplex.getObjValue());
			status[i]=p1Cplex.getCplexStatus();
			//Checking the constraints
			for(var t in p1Opl.Time)
				supply[t] = 0;
				
			for(var j in p1Opl.RQ)
				if(j!=i)
			        for(var t in p1Opl.Time)
			        	if(p1Opl.z[j][t]>1-1e-3 && p1Opl.value[j][t]>1e-3)
			        	{
			        		for(var tt=t;tt<t+p1Opl.td[j];tt++)  
			        		    supply[tt]++;        		     		
			        		break;
			        	}      
		        	
		    count = 0;
		    tlast = 0;
		    for(var t in p1Opl.Time)
		    	if(supply[t]>=p1Opl.c-1)
		    	{	    	    
		    	     if(t-tlast<=5)
		    	    	for(var tt=tlast+1;tt<=t;tt++)
		    	    	{
	    	    			pdata.TimeI.add(tt);
		    	    			    	    	
		    	    	}	
		    	    else  {
		    	    	pdata.TimeI.add(t);
	         		}
	         		tlast = t;	    
		    	    if(supply[t]>p1Opl.c)
		    	    {
		    	    	count ++;	   	    
		    	    }	    	    	
		    	}	 
		    	
		    //writeln(p1Opl.TimeI);
	 	}			
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
 