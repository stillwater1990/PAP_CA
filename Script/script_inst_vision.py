#!/usr/bin/python

# ----- Parameters passed to the cluster -------
#$ -S /usr/bin/python
#$ -l h_rt=1:15:00
#$ -l h_vmem=16G
#$ -o /scratch_net/neo/jpont/logs_cplex/
#$ -e /scratch_net/neo/jpont/logs_cplex/
#$ -j y


import subprocess
import os
import shutil
import time
import sys
import os.path

#My second python script

os.chdir("/srv/glusterfs/jpont/dev/mireia/PAP_Assign/Script/")

print 'Hello Python'
my_env = os.environ.copy()
my_env["LD_LIBRARY_PATH"] = "/srv/glusterfs/jpont/dev/libs/cplex_12.6.2/opl/bin/x86-64_linux/"

mod =  sys.argv[1]
dir_results = 'res'+mod

if mod in {'0'}:
    dataux=0
elif mod in {'4'}:
    dataux=4
else: 
    dataux=1

dat = int(os.getenv("SGE_TASK_ID", "0"))

#if not os.path.exists(dir_results):
#    os.makedirs(dir_results)


mod_file = 'mod/PAP_'+mod+'.mod'
print mod_file
data_file = 'dat/a'+str(dataux)+'stw'+str(dat)+'.dat'
out_file = dir_results+'/out'+str(dat)+'.txt'
res_file = dir_results+'/res'+str(dat)+'.txt'
plot_file = dir_results+'/plot'+str(dat)+'.txt'
glob_file = dir_results+'/global'+str(dat)+'.txt'
print data_file
with open(res_file,'w') as output_f:
    f = open(dir_results+'/ptime_'+str(dat)+'.txt','w')
    f.write('Time Model\n');
    f.write('VRPS_'+mod+'.mod\n')
    start = time.time() 
    p = subprocess.Popen(["./PAP_CA", mod_file, data_file, out_file, plot_file, glob_file],stdout=output_f, env=my_env)
    p.wait()
    elapsed = (time.time()-start)
    f.write(str(dat)+' '+"%0.2f" % elapsed+'\n')
    f.close()

print "Goodbye Python"

#with open(res_file,'w') as output_f:
#subprocess.call(["./VPR_Shared", mod_file, data_file, out_file, glob_file, plot_file], env=my_env)

