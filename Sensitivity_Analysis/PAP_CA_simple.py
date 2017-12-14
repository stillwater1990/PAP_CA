import subprocess
import os
import shutil
import time
import sys
import os
import math
import copy
Time = 1440
TimeStep = 2
TimeNum = Time/TimeStep
valuePath = 'dat/c=%d/td=%d/value%d_%s.dat'
inputPath = 'dat/c=%d/td=%d/input%d_%s.dat'
initPath = 'dat/c=%d/td=%d/init%d_%s.dat'
modPath = 'mod/main_%s.mod'

def sortValue(num,type,value):
    vS = list()
    for v in value:
        vS.append(sorted(range(len(v)), key=lambda k: v[k],reverse=True))

    return vS
	
def str2num(num,st):
    if(st=="float"):
        return float(num.strip("]").strip(" ["))
    elif (st == "int"):
        return int(float(num))

def str2mat(content,dim,stt):
    matr = list()
    if dim ==2:
        valuestring = content.strip("[").strip("]").split(";")
        if("" in valuestring):
            valuestring.remove("")
        for vstring in valuestring:
            matr.append([str2num(i,stt) for i in vstring.strip("[").strip("]").split(",")])
    elif dim == 1:
        valuestring = content.strip("[").strip("]").split(",")
        if("" in valuestring):
            valuestring.remove("")
        matr = [str2num(item,stt) for item in valuestring]
    elif dim == 3:
        valuestring = content.split(";")
        if("" in valuestring):
            valuestring.remove("")
        for vstring in valuestring:
            vs = vstring.strip("[").strip("]").split(",")
            if("" in vs):
                vs.remove("")
            sflow = list()
            for vss in vs:
                sflow.append([str2num(i,stt) for i in vss.strip("[").strip("]").split()])
            matr.append(sflow)
    return matr

def solve(dat,mod,method,ifdelete,c,td):
    if mod == 1:
        path = 'uniform'
    else:
        path = 'peak'
    my_env = os.environ.copy()
    my_env["LD_LIBRARY_PATH"] = "/nas/ykaidi/CPLEX_Studio1263/opl/bin/x86-64_linux/"
    #my_env["LD_LIBRARY_PATH"] = "C:/Program Files/IBM/ILOG/CPLEX_Studio1263/opl/bin/x64_win64/"
    data_file1 = inputPath  %(c,td,dat,path)
    data_file3 = valuePath %(c,td,dat,path)
    data_file4 = initPath %(c,td,dat,path)
    if method == 0:
        mod_file = modPath %'fast_polish'
    elif method == 1:
        mod_file = modPath %'fast'
    elif method ==2:
        mod_file = modPath %'lazy'
    elif method == 3:
        mod_file = modPath %'lazy_pure'
    elif method == 4:
        mod_file = modPath %'polish'
    elif method == 5:
        mod_file = modPath %'initial'
    elif method == 6:
        mod_file = modPath %'normal'	
    if not os.path.exists('res/'):
		os.makedirs('res/')
    res_file = 'res/res'+str(dat)+'_'+path+'.txt'
    
    with open(res_file,'w') as output_f:
        subprocess.check_call([my_env["LD_LIBRARY_PATH"]+"oplrun",  mod_file,data_file1,data_file3,data_file4],stdout=output_f,env=my_env)

        #p.wait()
    output_f.close()

def initWrite(dat,mod,z,value,sortValueIndex,c,td):
    zinit = []	
    if mod == 1:
		path = 'uniform' 		
    else:
		path = 'peak'
    for i in range(len(z)):
        zz = [0]*(TimeNum+50)
        zinit.append(zz)
    assignTime = [-1]*n
    flag =True
    while flag:
        flag = False
        for i in range(0,len(z)):
            for t in range(0,TimeNum):
                if assignTime[i]>=0 and value[i][sortValueIndex[i][t]]<=value[i][assignTime[i]]:
                    break
                else:
                    cnt = 0
                    for ii in range(0,len(z)):
                        if ii == i:
                            continue
                        #print assignTime[ii],td[i],i,t,len(sortValueIndex),sortValueIndex[i][t],assignTime[ii],td[ii]							
                        if(assignTime[ii]<sortValueIndex[i][t] + td[i]/TimeStep	and sortValueIndex[i][t]< assignTime[ii]+td[ii]/TimeStep):
                            cnt = cnt + 1
                    if(cnt<c):
                        assignTime[i] = sortValueIndex[i][t]
    print assignTime
    for i in range(0,len(z)):
        if assignTime[i]>=0:
            zinit[i][assignTime[i]+50] = 1
    with open(initPath %(c,td[0],dat,path),'w') as initFile:
		initFile.write("zinit="+str(zinit)+";")

def calculatePrice(value,z,req,dat,mod,option):
    print 'Processing request: '+str(req)
    withReq = sum([sum([value[i][t]*z[i][t] for t in range(0,len(value[i]))]) for i in range(0,len(value)) if i != req])
    t1 = time.time()
    (zs,zreq,obj,status) = solve(dat, mod, req, option)
    t2 = time.time()
    withoutReq = obj
    print withReq,withoutReq,withoutReq - withReq
    print "Processing time: " + str(t2-t1) + "s"
    return withoutReq - withReq

def valueRead(dat,mod,c,td):
    matr = list()	
    if mod == 1:
		path = 'uniform' 		
    else:
		path = 'peak'
 		
    with open(valuePath %(c,td,dat,path),'r') as prob_file:
        for line in prob_file:
            var = line.split("=")[0].strip()
            content = line.split("=")[1].strip().strip(";")
            if(var=='value'):
                valuestring = content.strip("[").strip("]").split("], [")
                if("" in valuestring):
                    valuestring.remove("")
                #print len(valuestring)					
                for vstring in valuestring:			
                    matr.append([str2num(i.strip("]").strip("["),'float') for i in vstring.strip("[").strip("]").split(",")])
    return matr
	
def readData(dat,mod,c,td):
    if mod == 1:
		path = 'uniform' 		
    else:
		path = 'peak'
 		
    with open(inputPath %(c,td,dat,path),'r') as prob_file:
        for line in prob_file:
            var = line.split("=")[0].strip()
            content = line.split("=")[1].strip().strip(";")
            if(var=='n'):	
				n = str2num(content,'int')		
				
    return n
				
if __name__=="__main__":
 	
    c = 6
    td = 30
    for c in [3,6]:
        for td in [10,20,30]:
            for dat in range(2000,2007):
                for mod in [2]:
                    price = list()
                    n = readData(dat,mod,c,td)
                    print n,mod
                    print "Writing value and assignment files"
                    value = valueRead(dat,mod,c,td)
                    sortValueIndex = sortValue(dat,mod,value)
                    print len(value)
                    initWrite(dat,mod,[[0]*(TimeNum+50)]*n,value,sortValueIndex,c,[td]*n)
                    print "Start solving the problem"
                    start = time.time()
                    solve(dat,mod,1,False,c,td)
                    elapsed = (time.time()-start)
                    print "Solved in "+"%0.2f" % elapsed+"s"
