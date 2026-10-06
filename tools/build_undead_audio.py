"""Original wave-120 necromancy cue: low ritual drone, air pull and bone clatter."""
from pathlib import Path
import wave
import numpy as np

RATE=44100
ROOT=Path(__file__).resolve().parents[1]/'project/assets/audio'

def write(path, data):
    data=np.clip(data,-.98,.98)
    pcm=(data*32767).astype('<i2')
    with wave.open(str(path),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(pcm.tobytes())

def build():
    rng=np.random.default_rng(120047)
    dur=3.05
    t=np.arange(int(RATE*dur))/RATE
    # A descending subterranean drone, with a quieter upper resonance.
    phase=2*np.pi*(67*t-7.5*t*t)
    drone=np.sin(phase)*.23 + np.sin(phase*.5+.7)*.12 + np.sin(2*np.pi*121*t+1.1)*.045
    env=np.minimum(1,t/.24)*np.minimum(1,(dur-t)/.55)
    drone*=env
    # Reverse-wind suction into the summoning impact.
    noise=rng.normal(0,1,len(t))
    smooth=np.convolve(noise,np.ones(95)/95,mode='same')
    pull=smooth*np.clip((t-.25)/1.3,0,1)*np.clip((2.2-t)/.45,0,1)*.45
    # Bone clacks, spread across the raise sequence.
    clatter=np.zeros_like(t)
    for k,when in enumerate(np.linspace(1.12,2.55,18)):
        start=int(when*RATE);length=int((.055+(k%4)*.009)*RATE)
        tt=np.arange(length)/RATE
        freq=880+(k%5)*175+rng.uniform(-55,55)
        click=np.sin(2*np.pi*freq*tt)*np.exp(-tt*42)
        click+=rng.normal(0,1,length)*np.exp(-tt*55)*.32
        end=min(len(t),start+length)
        clatter[start:end]+=click[:end-start]*(.07+.025*(k%3))
    # Low impact as the first corpses break the soil.
    boom=np.zeros_like(t)
    start=int(1.03*RATE);length=int(.75*RATE);tt=np.arange(length)/RATE
    pulse=(np.sin(2*np.pi*(58-20*tt)*tt)+.5*np.sin(2*np.pi*31*tt))*np.exp(-tt*5.0)*.26
    boom[start:start+length]=pulse
    data=drone+pull+clatter+boom
    data=np.tanh(data*1.55)*.82
    ROOT.mkdir(parents=True,exist_ok=True)
    write(ROOT/'necromancy.wav',data)
    print('necromancy.wav',len(data)/RATE,'seconds')

if __name__=='__main__':build()
