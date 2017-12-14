import subprocess
import os
import shutil
import time
import sys
import os.path
import math
import copy
import random
Time = 1440
TimeStep = 1
TimeNum = Time/TimeStep

def value1(v,s,e,a,b):
    # s left time window of the request
    # t right time window of the request
    # a left slope of the value function
    # b right slope of the value function
    value = list()
    for t in range(0,TimeNum):
        if t*TimeStep < s:
            value.append(max(0,v+a*(t*TimeStep-s)))
        elif t*TimeStep<=e:
            value.append(v)
        else:
            value.append(max(0,v-b*(t*TimeStep-e)))
    return value

def value3(v,s,e,a,b,s0,e0):
    # s left time window of the request
    # t right time window of the request
    # a left slope of the value function
    # b right slope of the value function
    value = list()
    for t in range(0,TimeNum):
        if t*TimeStep<s0:
            value.append(0)
        elif t*TimeStep < s:
            value.append(v+a*(t*TimeStep-s))
        elif t*TimeStep<=e:
            value.append(v)
        elif t*TimeStep<=e0:
            value.append(v-b*(t*TimeStep-e))
        else:
            value.append(0)
    return value

def value4(v,s,e):
    # s left time window of the request
    # t right time window of the request
    # a left slope of the value function
    # b right slope of the value function
    value = list()
    for t in range(0,TimeNum):
        if t*TimeStep<s:
            value.append(0)
        elif t*TimeStep<=e:
            value.append(v)
        else:
            value.append(0)
    return value


	
def readData(dat):
    # read data file
    dataPath = "dat/a0stw"+str(dat)+".dat"
    n = 0 # number of requests
    a = list() # start time
    b = list() # end time
    td = list() # duration
    with open(dataPath, 'r') as dataFile:
        for line in dataFile:
            line = line.strip().strip(";").split("=")
            if(line[0]=="n"):
                n = int(line[1]);
            elif(line[0]=="b"):
                b = map(int, filter(None, line[1].strip("[").strip("]").split(" ")))
            elif(line[0]=="a"):
                a = map(int, filter(None, line[1].strip("[").strip("]").split(" ")))
            elif(line[0]=="td"):
                td = map(int, filter(None, line[1].strip("[").strip("]").split(" ")))
            elif(line[0]=="c"):
                c = int(line[1])
    dataFile.close()

    inputPath = "dat/input"+str(dat)+"_"+str(TimeNum)+".dat"
    with open(inputPath,"w") as inputFile:
        inputFile.write("T="+str(TimeNum)+";\r\n")
        inputFile.write("Id="+str(dat)+";\r\n")
        inputFile.write("c="+str(c)+";\r\n")
        inputFile.write("n="+str(n)+";\r\n")
        inputFile.write("td="+str([ int(t/TimeStep) + (t%TimeStep > 0) for t in td])+";\r\n")
    return (n,a,b,td,c)

def valueWrite(num, mod,type,n,a,b):
    valuePath = "dat/value"+str(num)+"_"+str(mod)+'_'+str(TimeNum)+".dat"
    value = []
    for i in range(0,n):
        if type[i]== 1:
            subvalue = value1(20,a[i],b[i],0.1,0.1)
        elif type[i] == 3:
            subvalue = value3(20,a[i],b[i],0.1,0.1,a[i]-60,b[i]+60)
            #print subvalue
        elif type[i] == 4:
            subvalue = value4(20,a[i],b[i])
        value.append(subvalue)
    with open(valuePath,'w') as valueFile:

        valueFile.write("value="+str(value)+";\r\n")
        valueFile.write("model="+str(mod)+";\r\n")
    return value

	
			
def sortValue(num,type,value):
    vS = list()
    for v in value:
        vS.append(sorted(range(len(v)), key=lambda k: v[k],reverse=True))

    return vS

def str2num(num,st):
    if(st=="float"):
        return float(num)
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

def solve(dat,mod,method,ifdelete):
    my_env = os.environ.copy()
    #my_env["LD_LIBRARY_PATH"] = "/opt/ibm/ILOG/CPLEX_Studio126/opl/bin/x86-64_linux/"
    my_env["LD_LIBRARY_PATH"] = "/nas/ykaidi/CPLEX_Studio1263/opl/bin/x86-64_linux/"
    #=======
    #my_env["LD_LIBRARY_PATH"] = "/nas/ykaidi/CPLEX_Studio1263/opl/bin/x86-64_linux/"
    #>>>>>>> 1cef5fdfde87c5413382a1f86403bee6efdef13d
    data_file1 = "dat/input"+str(dat)+"_"+str(TimeNum)+".dat"
    data_file3 = 'dat/value'+str(dat)+'_'+str(mod)+'_'+str(TimeNum)+'.dat'
    if method == 0:
        mod_file = 'mod/main_fast_polish.mod'
    elif method == 1:
        mod_file = 'mod/main_fast.mod'
    elif method ==2:
        mod_file = 'mod/main_lazy.mod'
    elif method == 3:
        mod_file = 'mod/main_lazy_pure.mod'
    elif method == 4:
        mod_file = 'mod/main_polish.mod'
    elif method == 5:
        mod_file = 'mod/main_initial.mod'
    elif method == 6:
        mod_file = 'mod/main_normal.mod'
    elif method == 7:
        mod_file = 'mod/main_fast_divide.mod'
    elif method == 8:
        mod_file = 'mod/main_no_price.mod'
    res_file = 'res'+str(dat)+'_'+str(mod)+'_'+str(TimeNum)+'.txt'
    data_file4 = 'dat/init'+str(dat)+'_mod'+str(mod)+'_'+str(TimeNum)+'.dat'
    with open(res_file,'w') as output_f:
        #p = subprocess.Popen(["./PAP_CA_Simple", mod_file, data_file1,data_file3, data_file4],stdout=output_f, env=my_env)
        subprocess.check_call(["/nas/ykaidi/CPLEX_Studio1263/opl/bin/x86-64_linux/oplrun",  mod_file,data_file1,data_file3,data_file4],stdout=output_f,env=my_env)

        #p.wait()
    output_f.close()

def initWrite(dat,mod,z,value,sortValueIndex,c,td):
    zinit = []	
    for i in range(len(z)):
        zz = [0]*(TimeNum+50)
        zinit.append(zz)
    initPath = 'dat/init'+str(dat)+'_mod'+str(mod)+'_'+str(TimeNum)+'.dat'

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
                        if(assignTime[ii]-td[i]<sortValueIndex[i][t] and sortValueIndex[i][t]< assignTime[ii]+td[ii]):
                            cnt = cnt + 1
                    if(cnt<c):
                        assignTime[i] = sortValueIndex[i][t]
    print assignTime
    for i in range(0,len(z)):
        if assignTime[i]>=0:
            zinit[i][assignTime[i]+50] = 1
    #print zinit            
    with open(initPath,'w') as initFile:
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

if __name__=="__main__":

    if len(sys.argv) < 2:
        mod = 1
        option = False
        TimeStep = 2
        method = 1
    elif len(sys.argv) <3:
        mod = int(sys.argv[1])
        option = False
        TimeStep = 2
        method = 1
    elif len(sys.argv) < 4:
        TimeStep = int(sys.argv[2])
        mod = int(sys.argv[1])
        option = False
        method = 1
    elif len(sys.argv) < 5:
        TimeStep = int(sys.argv[2])
        mod = int(sys.argv[1])
        option = False
        method = int(sys.argv[3])
    else:
        TimeStep = int(sys.argv[2])
        mod = int(sys.argv[1])
        option = sys.argv[4] == "True" or sys.argv[4] == "true"
        method = int(sys.argv[3])
    TimeNum = Time/TimeStep




    SET1 = [223, 230, 215, 218, 232, 235   ]
    SET2 = [201, 233, 224, 241, 239, 245 ]
    SET3 = [228, 205, 226, 203, 240, 243]
    SET4 = [238, 216, 207, 212, 236, 244, 242]
    SET5 = [202, 206]
    method = 8;			
    for dat in SET1+SET2+SET3+SET4+SET5 :
	for mod in [1,3,4,5]:
	    if mod in [1,3,4]:
		SD = 2
	    else:
		SD = 11		
	    for sd in range(1,SD):	
		print "Proceesing instance " + str(dat)
		price = list()
		(n,a,b,td,c) = readData(dat)
		print n
		print "Writing value and assignment files"
		
		if mod in [1,3,4]:
                    typ =  [mod]*n
                    value = valueWrite(dat,mod,typ,n,a,b)
                    sortValueIndex = sortValue(dat,mod,value)
                    initWrite(dat,mod,[[0]*(TimeNum+50)]*n,value,sortValueIndex,c,td)
                    print "Start solving the problem"
                    start = time.time()
                    solve(dat,mod,method,option)
                    elapsed = (time.time()-start)
                    print "Solved in "+"%0.2f" % elapsed+"s"
		elif mod == 5:	 #half 3 and half 4			
                    random.seed(sd)
                    typ = [4]*n
                    idx13 = random.sample(xrange(0,n),n*2/3)
                    idx3 = random.sample(idx13,n/3)
                    for i in idx13:
                        typ[i]=1
                    for i in idx3:
                        typ[i]=3
                    value = valueWrite(dat,mod+sd,typ,n,a,b)
                    result1 = 0
                    result3 = 0
                    result4 = 0
                    result = 0

                    with open('mod/result_no_price'+str(dat)+'_1_720.txt','r') as f:
                        for line in f:
                            line = line.strip().strip(";").split("=")
                            if line[0] == "assign":
                                assign = str2mat(line[1],2,'int')
                                print assign
                                for item in assign:
                                    result1 = result1 + value[item[0]-1][item[1]]
									
                    with open('mod/result_no_price'+str(dat)+'_3_720.txt','r') as f:
                        for line in f:
                            line = line.strip().strip(";").split("=")
                            if line[0] == "assign":
                                assign = str2mat(line[1],2,'int')
                                print assign
                                for item in assign:
                                    result3 = result3 + value[item[0]-1][item[1]]

                    with open('mod/result_no_price'+str(dat)+'_4_720.txt','r') as f:
                        for line in f:
                            line = line.strip().strip(";").split("=")
                            if line[0] == "assign":
                                assign = str2mat(line[1],2,'int')
                                for item in assign:
                                    result4 = result4 + value[item[0]-1][item[1]]
                                

                    sortValueIndex = sortValue(dat,mod+sd,value)
                    initWrite(dat,mod+sd,[[0]*(TimeNum+50)]*n,value,sortValueIndex,c,td)
                    print "Start solving the problem"
                    start = time.time()
                    solve(dat,mod+sd,method,option)
                    with open('mod/result_no_price'+str(dat)+'_'+str(sd+mod)+'_720.txt','r') as f:
                        for line in f:
                            line = line.strip().strip(";").split("=")
                            if line[0] == "assign":
                                assign = str2mat(line[1],2,'int')
                                for item in assign:
                                    result = result + value[item[0]-1][item[1]]
                    elapsed = (time.time()-start)
                    print "Solved in "+"%0.2f" % elapsed+"s"				
                    with open('type2/type'+str(dat)+'_'+str(mod+sd)+'.txt','w') as f:
                        f.write('type='+str(typ)+';\r\n')
                        f.write('result='+str(result)+';\r\n')
                        f.write('result1='+str(result1)+';\r\n')
                        f.write('result3='+str(result3)+';\r\n')
                        f.write('result4='+str(result4)+';\r\n')    #
