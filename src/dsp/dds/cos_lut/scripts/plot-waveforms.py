# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt

R = 32                   # RAM size

# full wave
xr = np.linspace(0, 1.0, R+1)
xr = xr[0:-1]
yr = np.sin(2*np.pi*xr)

fin = np.linspace(0,len(yr)-1,1000)
stp = np.floor(fin)
stp = yr[stp.astype('int')]

# half wave
xh = np.linspace(0, 0.5, int(R/2)+1)
xh = xh[0:-1]
yh = np.sin(2*np.pi*xh)
yh = np.append(yh, -(yh))

# quarter wave
xq = np.linspace(0, 0.25, int(R/4)+1)
xq = xq[0:-1]
yqq = np.sin(2*np.pi*xq)
yq = yqq
yq = np.append(yq, 0)
yq = np.append(yq, np.flip(yqq))
yq = np.append(yq, -(yqq[1:]))
yq = np.append(yq, 0)
yq = np.append(yq, -np.flip(yqq)[0:-1])

plt.figure(figsize=(8,5))
plt.plot(yr, marker='o', linestyle='solid', color='cornflowerblue')
plt.plot(yh, marker='o', linestyle='solid', color='red')
plt.plot(yq, marker='o', linestyle='solid', color='green')
plt.plot(fin, stp, marker='', linestyle='solid')
plt.grid()
