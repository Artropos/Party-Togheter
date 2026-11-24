#!/usr/bin/env python3
"""Genereert QuestSync TGA type 2 RGBA artwork met bottom-left origin."""
import math, random, struct
from pathlib import Path
OUT=Path(__file__).parent

def make(name,w,h,kind):
    random.seed(name); rows=[]
    for y in range(h):
        row=[]
        for x in range(w):
            if kind in ('panel','plain','border','button','title'):
                grain=math.sin(y*.19+x*.015)*2.0 + random.random()*1.3
                base=(58,40,28) if kind=='panel' else (68,48,33)
                if kind=='border': base=(122,88,54)
                if kind=='button': base=(92,64,42)
                if kind=='title': base=(77,53,35)
                if kind=='panel': grain=max(-3,min(3,grain))
                rgba=tuple(max(0,min(255,int(c+grain))) for c in base)+(255,)
            elif kind=='parchment':
                n=random.randint(-3,3); rgba=(232+n,216+n,178+n,255)
            elif kind=='inset': rgba=(49,34,24,220)
            else:
                edge=(x<2 or y<2 or x>=w-2 or y>=h-2)
                rgba=(168,128,74,255) if edge else (0,0,0,0)
                if kind=='icon': rgba=(168,128,74,255) if (x-w/2)**2+(y-h/2)**2<(w*.43)**2 else (0,0,0,0)
                if kind=='close' and (abs(x-y)<3 or abs((w-1-x)-y)<3): rgba=(168,128,74,255)
                if kind=='check' and ((x>8 and x<15 and abs(y-(x-7))<2) or (x>=13 and abs(y-(27-x))<2)): rgba=(168,128,74,255)
                if kind=='dot' and (x-7.5)**2+(y-7.5)**2<25: rgba=(235,195,95,255)
                if kind in ('blip','marker') and (x-w/2)**2+(y-h/2)**2<(w*.35)**2: rgba=(224,165,72,255)
            row.append(rgba)
        rows.append(row)
    # TGA origin bottom-left; each pixel stored BGRA.
    with open(OUT/(name+'.tga'),'wb') as f:
        f.write(struct.pack('<BBBHHBHHHHBB',0,0,2,0,0,0,0,0,w,h,32,8))
        for row in rows:
            for r,g,b,a in row: f.write(bytes((b,g,r,a)))

assets=[('panel',256,256,'panel'),('panel_plain',256,256,'plain'),('border',64,64,'border'),('inset',128,128,'inset'),('parchment',256,256,'parchment'),('button',128,32,'button'),('button_hi',128,32,'button'),('button_down',128,32,'button'),('highlight',128,32,'border'),('check',32,32,'check'),('dot',16,16,'dot'),('icon',64,64,'icon'),('titlebar',256,32,'title'),('progress',128,16,'border'),('progress_bg',128,16,'plain'),('close',32,32,'close'),('blip',32,32,'blip'),('marker',32,32,'marker')]
for a in assets: make(*a)
