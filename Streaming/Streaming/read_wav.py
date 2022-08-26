# Import
from scipy.io import wavfile
from matplotlib import pyplot as plt
import numpy as np
from pytictoc import TicToc
# import math

t = TicToc() #create instance of class
t.tic() #Start timer

# Read wav file
samplerate, data = wavfile.read('./rpsa_client_104/output/1GB.wav')
t.toc() #Time elapsed since t.tic()

# Plot
x = data[:,0]
y = data[:,1]
#samples = np.array(range(1,150000000+1))
#plt.plot(samples,x)
#plt.plot(samples,y)
#plt.xlabel("Sample or time")
#plt.ylabel("Amp")
#plt.title('Count')
#plt.show()











