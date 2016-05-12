import subprocess
import os
import shutil
import time
import sys
import os.path

#My second python script

print 'Hello Python'
my_env = os.environ.copy()
my_env["LD_LIBRARY_PATH"] = "/opt/ibm/ILOG/CPLEX_Studio126/opl/bin/x86-64_linux/"

mod =  sys.argv[1]
dir_results = 'res'+mod

if mod in {'0'}:
    dataux=0
elif mod in {'4'}:
    dataux=4
else: 
    dataux=1

dir_results = 'res'+mod

if not os.path.exists(dir_results):
    os.makedirs(dir_results)

f = open('ptime_'+mod+'.txt','w')
f.write('Time Model\n');
f.write('PAP_Assign_'+mod+'.mod\n')
for dat in range(201,203):
    mod_file = 'mod/PAP_'+mod+'.mod'
    print mod_file
    data_file = 'dat/a'+str(dataux)+'stw'+str(dat)+'.dat'
    print data_file
    out_file = dir_results+'/out'+str(dat)+'.txt'
    res_file = dir_results+'/res'+str(dat)+'.txt'
    plot_file = dir_results+'/plot'+str(dat)+'.txt'
    glob_file = dir_results+'/global'+str(dat)+'.txt'

    with open(res_file,'w') as output_f:
        print "Middle Python"
        start = time.time()
        p = subprocess.Popen(["./PAP_CA", mod_file, data_file, out_file, plot_file, glob_file],stdout=output_f, env=my_env)
        p.wait()
        elapsed = (time.time()-start)
        f.write(str(dat)+' '+"%0.2f" % elapsed+'\n')
f.close()

print "Goodbye Python"

