#!/usr/bin/env python3
"""Build Castlehold's original synthesized final-victory fanfare."""
from pathlib import Path
import math, wave, struct
SR=24000
DURATION=5.2
CHORDS=[
    (0.0,1.25,[261.63,329.63,392.00],523.25),
    (1.25,2.45,[349.23,440.00,523.25],698.46),
    (2.45,3.65,[392.00,493.88,587.33],783.99),
    (3.65,5.2,[261.63,392.00,523.25,659.25],1046.50),
]
DRUM_HITS=[0.0,.62,1.25,1.87,2.45,3.08,3.65,4.3,4.72]

def build(path: Path):
    samples=[]
    for n in range(int(SR*DURATION)):
        t=n/SR;y=0.0
        for a,b,notes,mel in CHORDS:
            if a<=t<b:
                local=t-a;env=min(1.0,local/.045)*min(1.0,(b-t)/.22)
                for f in notes:
                    phase=2*math.pi*f*t
                    y+=env*(.085*math.sin(phase)+.035*math.sin(2*phase)+.015*math.sin(3*phase))
                phase=2*math.pi*mel*t
                y+=env*(.11*math.sin(phase)+.045*math.sin(2*phase))
                break
        for hit in DRUM_HITS:
            dt=t-hit
            if 0<=dt<.34:
                y+=.14*math.exp(-dt*10)*math.sin(2*math.pi*(82-18*dt)*dt)
        if t>3.65:
            dt=t-3.65;y+=.035*math.exp(-dt*.6)*math.sin(2*math.pi*1567.98*t)
        y=math.tanh(y*1.45)*.88
        samples.append(int(max(-1,min(1,y))*32767))
    path.parent.mkdir(parents=True,exist_ok=True)
    with wave.open(str(path),'wb') as out:
        out.setnchannels(1);out.setsampwidth(2);out.setframerate(SR)
        out.writeframes(b''.join(struct.pack('<h',v) for v in samples))

if __name__=='__main__':
    root=Path(__file__).resolve().parents[1]
    output=root/'project/assets/audio/victory_fanfare.wav'
    build(output)
    print(output)
