# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt

N = 16                  # resolution
R = 32                  # RAM size
waveform = "cos"        # [ cos | sin ]
datatype = "signed"     # [ signed | unsigned ]
offset = 0.0            # DC offset
amplitude = 0.99         # waveform scale
compression = "quart" # [ full | half | quart ]

if datatype == "signed":
    datatype= "sfix"
if datatype == "unsigned":
    datatype = "ufix"

# lut-cos-2048x-sfix16-quart.vhd
filename = f'lut-{waveform}-{R}x-{datatype}{N}-{compression}.vho'

linend = 1.0
if compression == "half":
    linend = 0.5
if compression == "quart":
    linend = 0.25

x = np.linspace(0, linend, R+1)
x = x[0:-1]

if waveform == "cos":
    y = np.power(2, N-1) * (offset + amplitude * np.cos(2*np.pi*x) )
if waveform == "sin":
    y = np.power(2, N-1) * (offset + amplitude * np.cos(2*np.pi*x) )
y = y.astype('int64')

with open(filename, 'w') as f:
    f.write(f'-- -------------------------------------------------------------\n')
    f.write(f'-- \n')
    f.write(f'-- File Name: {filename} \n')
    f.write(f'-- Generated by Python Script \n')
    f.write(f'-- \n')
    f.write(f'-- -------------------------------------------------------------\n')
    
    f.write(f'constant lut_data : vector_of_signed{N}(0 to {R-1}) := (\n')
    
    for k in range(int(len(y)/4)-1):
        f.write(f'  ')
        for j in range(4):
            if(y[4*k+j] >= 0):
                f.write(f'to_signed( 16#{y[4*k+j]:04X}#,{N}), ')
            else:
                f.write(f'to_signed(-16#{-y[4*k+j]:04X}#,{N}), ')
        f.write(f'\n')
    
    k = int(len(y)/4)-1
    f.write(f'  ')
    for j in range(3):
        if(y[4*k+j] >= 0):
            f.write(f'to_signed( 16#{y[4*k+j]:04X}#,{N}), ')
        else:
            f.write(f'to_signed(-16#{-y[4*k+j]:04X}#,{N}), ')
    j=3
    if(y[4*k+j] >= 0):
        f.write(f'to_signed( 16#{y[4*k+j]:04X}#,{N})')
    else:
        f.write(f'to_signed(-16#{-y[4*k+j]:04X}#,{N})')
    f.write(f'\n);\n')



