
CPLEXROOT=/nas/mrocariu/CPLEX_Studio1263
g++ -m64 -O -fPIC -fno-strict-aliasing -fexceptions -DNDEBUG -DIL_STD -DILOUSESTL -I.. -I$CPLEXROOT/opl/include/ ../src/pap_ca.cpp -L$CPLEXROOT/cplex/lib/x86-64_linux/static_pic/ -L$CPLEXROOT/opl/lib/x86-64_linux/static_pic/ -L$CPLEXROOT/concert/lib/x86-64_linux/static_pic/ -L$CPLEXROOT/opl/bin/x86-64_linux/ -lopl -liljs -loplnl1 -lilocplex -lcp -lconcert -ldbkernel -ldblnkdyn -lilog -ldl -licuuc -licui18n -licuio -licudata -lpthread -lcplex1263 -oPAP_CA
