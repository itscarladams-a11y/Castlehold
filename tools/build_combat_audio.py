"""Castlehold 0.4.9 premium combat-impact audio.
Original procedural synthesis only. No samples, soundfonts, or recordings.
"""
from pathlib import Path
import math, random, struct, wave

RATE=22050
ROOT=Path(__file__).resolve().parents[1]/"project/assets/audio"
ROOT.mkdir(parents=True, exist_ok=True)

def write(name, data):
    peak=max(1e-6,max(abs(x) for x in data))
    gain=min(0.94/peak,1.0)
    vals=[int(max(-1,min(1,x*gain))*32767) for x in data]
    with wave.open(str(ROOT/(name+".wav")),"wb") as w:
        w.setparams((1,2,RATE,0,"NONE","not compressed"))
        w.writeframes(struct.pack("<"+"h"*len(vals),*vals))

def envelope(t,d,a=.004,p=3.0):
    return min(1.0,t/max(a,1e-4))*max(0.0,1-t/d)**p

def metal(seed, variant):
    r=random.Random(seed);d=.18+.015*variant;out=[]
    base=[620,780,940][variant%3]
    for i in range(int(RATE*d)):
        t=i/RATE;e=envelope(t,d,.002,2.5)
        ring=(math.sin(2*math.pi*base*t)+.55*math.sin(2*math.pi*(base*1.62)*t)+.27*math.sin(2*math.pi*(base*2.41)*t))
        scrape=r.uniform(-1,1)*math.exp(-t*31)
        out.append((ring*.42+scrape*.32)*e)
    return out

def body(seed, variant):
    r=random.Random(seed);d=.145+.012*variant;out=[]
    f=[122,145,108][variant%3]
    smooth=0.0
    for i in range(int(RATE*d)):
        t=i/RATE;e=envelope(t,d,.002,3.2)
        smooth=smooth*.72+r.uniform(-1,1)*.28
        thud=math.sin(2*math.pi*(f*(1-.28*t/d))*t)*math.exp(-t*19)
        out.append((thud*.60+smooth*.44)*e)
    return out

def bone(seed, variant):
    r=random.Random(seed);d=.16+.01*variant;out=[]
    f=[980,1160,1320][variant%3]
    for i in range(int(RATE*d)):
        t=i/RATE;e=envelope(t,d,.0015,3.1)
        click=(math.sin(2*math.pi*f*t)+.32*math.sin(2*math.pi*f*2.14*t))*math.exp(-t*27)
        grit=r.uniform(-1,1)*math.exp(-t*42)
        out.append((click*.38+grit*.37)*e)
    return out

def heavy(seed, variant):
    r=random.Random(seed);d=.44+.04*variant;out=[]
    smooth=0.0
    for i in range(int(RATE*d)):
        t=i/RATE;e=envelope(t,d,.002,2.0)
        f=(58+variant*9)*(1-.35*t/d)
        boom=math.sin(2*math.pi*f*t)+.35*math.sin(2*math.pi*f*2.07*t)
        smooth=smooth*.83+r.uniform(-1,1)*.17
        out.append((boom*.48*math.exp(-t*5.3)+smooth*.66*math.exp(-t*11))*e)
    return out

def step(seed, heavy_step=False):
    r=random.Random(seed);d=.13 if not heavy_step else .21;out=[];smooth=0.0
    for i in range(int(RATE*d)):
        t=i/RATE;e=envelope(t,d,.0015,3.4)
        smooth=smooth*.78+r.uniform(-1,1)*.22
        f=82 if heavy_step else 135
        low=math.sin(2*math.pi*f*t)*math.exp(-t*(14 if heavy_step else 22))
        out.append((low*(.55 if heavy_step else .30)+smooth*(.42 if heavy_step else .24))*e)
    return out

for v in range(3):
    write(f"impact_metal_{v+1}",metal(940+v,v))
    write(f"impact_body_{v+1}",body(960+v,v))
    write(f"impact_bone_{v+1}",bone(980+v,v))
for v in range(2):
    write(f"impact_heavy_{v+1}",heavy(1020+v,v))
write("step_light",step(1051,False))
write("step_heavy",step(1052,True))
