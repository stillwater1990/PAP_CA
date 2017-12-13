import math
import random
import subprocess
import os

valuePath = 'dat/c=%d/td=%d/value%d_%s.dat'
inputPath = 'dat/c=%d/td=%d/input%d_%s.dat'
slotPath = 'dat/c=%d/td=%d/slot%d_%s.dat'
sigma = 60.0
timeStep = 2 
timeBegin = 480
timeEnd = 840
VMAX = [10.0,15.0,20.0]
SOBOL = []
def mean(data):
    """Return the sample arithmetic mean of data."""
    n = len(data)
    if n < 1:
        raise ValueError('mean requires at least one data point')
    return sum(data)/float(n) # in Python 2 use sum(data)/float(n)

def _ss(data):
    """Return sum of square deviations of sequence data."""
    c = mean(data)
    ss = sum((x-c)**2 for x in data)
    return ss

def pstdev(data):
    """Calculates the population standard deviation."""
    n = len(data)
    if n < 2:
        raise ValueError('variance requires at least two data points')
    ss = _ss(data)
    pvar = ss/(float(n)-1) # the population variance
    return pvar**0.5
	
def sobol():
	s = [];
	with open("sobol.txt",'r') as sobol_file:
		for line in sobol_file:
			s.append(float(line))
	return s
	
def value(vmax,sigma,mu,timeStep):	
	return [max(0,math.exp(-(t-mu)**2.0/sigma**2.0/2.0)-1e-6)*vmax for t in range(0,1440,timeStep)]

def str2num(num,st): # function to read strings into numbers
    if(st=="float"):
        return float(num)
    elif (st == "int"):
        return int(num)

def str2mat(content,dim,stt): # function to read strings into matrices
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

def instance_gen(id,n,opt,pcum):
	Value = []
	mu = []
	Instance = []

	if opt == 1: # only mu, given distribution
		for i in range(0,n):
			r = SOBOL[(id%1000)*n+i]
			set2 = [j for j in range(0,n) if pcum[j]>r ]
			set1 = [j for j in range(0,n) if pcum[j]<=r ]
			if len(set2)==0:
				j2 = n-1
			else:
				j2 = min(set2)
				
			if len(set1) == 0:
				j1 = 0
			else:
				j1 = max(set1)
				
			if(j1!=j2):
				mu.append(int(timeBegin+(timeEnd-timeBegin)/n*j1+(r-pcum[j1])/(pcum[j2]-pcum[j1])*(timeEnd-timeBegin)/n))
			else:
				mu.append(int(timeBegin+(timeEnd-timeBegin)/n*j1))
		vmax = [VMAX for i in range(0,n)]
		Value = [value(vmax[i],sigma,mu[i],timeStep) for i in range(0,n)]
	elif opt == 2: # uniformed gaps, only mu
		Mu = [timeBegin+(timeEnd-timeBegin)/n*i for i in range(0,n)]
		vmax = [VMAX for i in range(0,n)]
		Value = [value(vmax[i],sigma,Mu[i],timeStep) for i in range(0,n)]
	elif opt == 4: # both mu and vmax
		Mu = range(timeBegin,timeEnd,timeStep)
		for j in range(0,len(VMAX)):
			Value+=[value(VMAX[j],sigma,Mu[i],timeStep) for i in range(0,len(Mu))]
	elif opt == 3:
		Mu = range(timeBegin,timeEnd,timeStep)
		for i in range(0,n):
			r = SOBOL[(id%1000)*n+i]
			#print r
			set = [j for j in range(0,len(pcum)) if pcum[j]>r ]
			#print set
			if len(set)==0:
				jj = n-1
			else:
				jj = min(set)
			#print jj
			j1 = jj/len(Mu)
			i1 = jj%len(Mu)
			mu = Mu[i1]
			v = VMAX[j1]
			Value.append(value(VMAX[j1],sigma,Mu[i1],timeStep))	
			Instance.append((VMAX[j1],Mu[i1]))
	return (Value,Instance)


def probCalc(id,v,p0,type):
	print id
	if type == 1: #uniform
		demand = [int(450<=t<=870)*5 for t in range(0,1440,timeStep)]	
		path = 'uniform'
	elif type == 2: # peak
		demand = value(10.47,80,660,timeStep)
		path = 'peak'
	else:
		return
	#demand = [sum(x) for x in zip(*Value)]
	with open('instance'+str(id)+'.dat','w') as file:
		file.write('n='+str(360/timeStep*len(VMAX))+';\r\n' )
		file.write('T='+str(1440/timeStep)+';\r\n')
		file.write('demand='+str(demand)+';\r\n')
		file.write('value='+str(v)+';\r\n')
		file.write('type='+str(type)+';\r\n')
		file.write('p0='+str(p0)+';\r\n')
	my_env = os.environ.copy()
	oplPath = "/nas/ykaidi/CPLEX_Studio1263/opl/bin/x86-64_linux/"
	#oplPath = "C:/Program Files/IBM/ILOG/CPLEX_Studio1263/opl/bin/x64_win64/"
	my_env["LD_LIBRARY_PATH"] = oplPath
	with open("out.txt",'w') as output_f:
		subprocess.check_call([oplPath+"oplrun",  'pap_inst_gen.mod','instance'+str(id)+'.dat'],stdout=output_f,env=my_env)
		#
	with open('demand/prob_'+path+'_'+str(360/timeStep*len(VMAX))+'.txt','r') as prob_file:
		for line in prob_file:
			var = line.split("=")[0].strip()
			content = line.split("=")[1].strip().strip(";")
			if(var=='p'):
				p = str2mat(content,1,'float')
				break;
	print sum(p)
	p = [pp/sum(p) for pp in p]
	return p


SOBOL= sobol()

count = 2000
for p0 in [0.0,0.2,0.4]:	
	step = 10
	for type in range(1,3):			
		if type == 1:
			path = 'uniform'
		else:
			path = 'peak'
		ID = 0
		v0,i0 = instance_gen(ID,1,4,[])
		#print len(v0[0])
		p = probCalc(ID,v0,p0,type)
		print len(p)
		pcum = reduce(lambda aa, x: aa + [aa[-1] + x], p, [0])[1:]
		#print pcum
		for c in [3,6]:
			n = 60/3*c
			for td in [10,20,30]:
				for ID in range(count,count+step):
					v,inst = instance_gen(ID,n,3,pcum)
					demand = map(sum,zip(*v))
					#if pstdev([d for d in demand if d > 150])>20 and type == 1:
					#	continue
					if not os.path.exists('demand/'):
						os.makedirs('demand/')
					if not os.path.exists('dat/c=%d/td=%d/' %(c,td)):
						os.makedirs('dat/c=%d/td=%d/' %(c,td))
					if not os.path.exists('demand/c=%d/td=%d/' %(c,td)):
						os.makedirs('demand/c=%d/td=%d/' %(c,td))
					with open('demand/c=%d/td=%d/demand%d_%s.txt' %(c,td,ID,path),'w') as file:
						file.write('demand='+str(demand)+';\r\n')
					with open(inputPath %(c,td,ID,path),"w") as inputFile:
						inputFile.write("T="+str(1440/timeStep)+";\r\n")
						inputFile.write("model="+str(type)+";\r\n")
						inputFile.write("Id="+str(ID)+";\r\n")
						inputFile.write("c="+str(c)+";\r\n")
						inputFile.write("n="+str(n)+";\r\n")
						inputFile.write("td="+str([ td/2]*n)+";\r\n")
					with open(valuePath %(c,td,ID,path),'w') as valueFile:
						valueFile.write('value='+str(v)+';\r\n')
					with open(slotPath %(c,td,ID,path),'w') as slotFile:
						slotFile.write(str(sorted(inst,key=lambda x:x[1])))
	count += step