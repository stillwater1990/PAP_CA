// -------------------------------------------------------------- -*- C++ -*---------
// File: pap_ca.cpp
// --------------------------------------------------------------------------
// Author: Mireia Roca-Riu
// Creation Date: Mai 2016
// --------------------------------------------------------------------------
// Solve a Model of Parking Slot Assignment with Assignment Model
// Include Combinatorial Auctions Formulation
// Save solution Z[][]
//
// Call Program with two files Model and Data files to construct OPLModel .mod and .dat
/////////////////////////////////////////////////////////////////////////////////////

#include <ilopl/iloopl.h>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <vector>
#include <boost/lexical_cast.hpp>
#include <set>
#include <string>

using namespace std; 


int main(int argc,char* argv[]) {

	int status = 127;
	ofstream fileo, fileg, filep;
	fileo.open (argv[3]);  						// Out file - Write Solution: Objective + Solution
	fileg.open (argv[5],std::fstream::app);		// Global file - Write Debugging & Evolution: Callbacks. Appended, all instances together
	filep.open (argv[4],std::fstream::app);		// Plot file - Write summary of each Instance. Appended, all instances together

	cout << "Id=" << endl;  // Write identification of the Instance


	// Input arguments
	// argv[1] model file
	// argv[2] dat file
	// argv[3] Output file
	// argv[4] Plot file
	// argv[5] Global file

	if (argc==6){
        //Check if the correct number of elements are parameters when calling the function. They should be 5 paths to files
		IloEnv env;

		try {

			// Construct IloOpl Model from a .mod file .mod and a .dat file external called by command line
			// argv[1] model file or use
            //IloOplModelSource modelSource(env, "/home/mroca/workspace/STW/data/Model.mod"); adapt address
			// argv[2] dat file or use
            // IloOplDataSource dataSource(env, "/home/mroca/workspace/STW/data/Data.dat"); adapt address

			IloOplErrorHandler handler(env,cout);
			IloOplModelSource modelSource(env, argv[1]);
			IloOplSettings settings(env,handler);
			IloOplModelDefinition def(modelSource,settings);
			IloCplex cplex(env);

			// Parameter Adjustment  
			cplex.setParam(IloCplex::TiLim,3600); // Time Limit given to Cplex
			cplex.setParam(IloCplex::Threads,1);  // Avoid multithreading
            // Other parameters useful when testing cplex performance
//          cplex.setParam(IloCplex::MIPDisplay,4);
//			cplex.setParam(IloCplex::PreInd,0);
//			cplex.setParam(IloCplex::RelaxPreInd,0);
//			cplex.setParam(IloCplex::PreslvNd,-1);
//			cplex.setParam(IloCplex::Reduce, 0);

			// Parameters for model exporting. In order to recognize variables
			// settings.setWithNames(IloTrue);
			// settings.setBigMapThreshold(20000000);

            IloOplModel opl(def,cplex);
            IloOplDataSource dataSource(env, argv[2]);
			opl.addDataSource(dataSource);
			opl.generate();
			// opl.getCplex().exportModel("ExportedModel.lp"); // USEFUL to CHECK formulation. Prints model+data in a file

			// Extract an IloModel from an IloOplModel
			IloModel mod;
			mod = opl.getCplex().getModel();

            cplex.setParam(IloCplex::Threads,1); //Closer to the solve function
			IloBool sol=cplex.solve(); // Solve command


            // POST PROCESSING of SOLUTION different, when solved to optimality or not
			if ( sol ) {
                
                // Screen printing
			    cout << setprecision(2);
				cout << "OBJECTIVE: " << fixed  << opl.getCplex().getObjValue() << endl;
			    IloExpr newconstraint(env);
			    opl.postProcess();

				// File Global (Can have two roles)

				// OLD ROLE OF GLOBAL
				IloOplElement idd = opl.getElement("Id");
				//fileg << "Id=" << idd.asNum() << endl;
				//fileg << "Cplex Status= "<< opl.getCplex().getCplexStatus()<<endl;
				//fileg << "Cplex ObjValue= "<< opl.getCplex().getObjValue()<<endl;
				//fileg << endl;

				// NEW ROLE OF GLOBAL , WRITE z[i][t]
				// Extract Variable z from IloOplModel
				IloIntVarMap zc = opl.getElement("z").asIntVarMap();
				IloIntVarArray zcc=zc.asNewIntVarArray(); // Extract the whole array
				IloNumArray z(env, zcc.getSize());
				cplex.getValues(z, zcc);

				IloOplElement nd = opl.getElement("n");
				IloInt id = nd.asNum();

				//fileg << "Size z: " << z.getSize() << endl;
				//fileg << "Size n: " << z.getSize()/1490 << endl;
				//fileg << "N: "<< id << endl << endl;
				//fileg << id << endl;

				fileg << "zs=#[";
				for (int u=1;u<=id;u++)
				{
					fileg << u << ": [";
					for (int t=0;t<1489;t++)
					{
						fileg <<z[1490*(u-1)+t]<<", "; 
					}
					fileg <<z[1490*(u-1)+1489]<<"]";
					if (u<(id+1))
					{
						fileg << ","<<endl;
					}					
					
				}
				fileg << "]#;";

				//fileg << z << endl;

				// Print the solution globally
				//opl.printSolution(fileg);


                // File Output
                fileo << "OBJECTIVE " << opl.getCplex().getObjValue() << endl;
				opl.printSolution(fileo);

				// File Plot
				//IloOplElement nd = opl.getElement("n");
				IloOplElement cd = opl.getElement("c");
				filep << idd.asNum() << "\t";
				filep << nd.asNum() << "\t";
				filep << cd.asNum() << "\t";
				filep << opl.getCplex().getCplexStatus() << "\t";
				filep << sol << "\t"; // Cplex.solve()
				filep << opl.getCplex().getObjValue();
				filep << endl;

				status = 0;

			} else {
                // Screen printing
				cout << "No solution!" << endl;
				status = 1;

				// File Global
				IloOplElement idd = opl.getElement("Id");
				fileg << "Id=" << idd.asNum() << endl;
				fileg << "Cplex Status= "<< opl.getCplex().getCplexStatus()<<endl;
				fileg << "Cplex ObjValue= "<< opl.getCplex().getBestObjValue()<<endl;
				fileg << endl;

			    // File Output
				fileo << "OBJECTIVE " << "No Solution Found";//opl.getCplex().getObjValue() << endl;
				//opl.printSolution(fileo);

				// File Plot
				IloOplElement nd = opl.getElement("n");
				IloOplElement cd = opl.getElement("c");
				filep << idd.asNum() << "\t";
				filep << nd.asNum() << "\t";
				filep << cd.asNum() << "\t";
				filep << opl.getCplex().getCplexStatus() << "\t";
				filep << sol <<"\t"; // Cplex.solve()
				filep << "-1\t";
				filep << endl;

			}
			fileo.close();
			fileg.close();
			filep.close();
		} catch (IloOplException & e) {
			cout << "### OPL exception: " << e.getMessage() << endl;
		} catch( IloException & e ) {
			cout << "### CONCERT exception: "<< e.getMessage() << endl;
			status = 2;
		} catch (...) {
			cout << "### UNEXPECTED ERROR ..." << endl;
			status = 3;
		}

		env.end();
		/// Write Output Files


		cout << endl << "--Goodbye--" << endl;
	} else {
		cout << endl << "Error. Input Arguments Should be 6" << endl;
	}
    return status;

}
