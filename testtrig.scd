(
s.sendMsg(\g_new, 1999); s.sendMsg(\g_new, 2000);
10.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
s.sendMsg(\g_new, 2999, 3, 2010);

SynthDef(\phasorclock, {
	arg abus, kbus, stbpm=60.0, endbpm=60.0, dur=0.05, bpc=16.0, t_tr=1;
	var tempo = ( EnvGen.ar(Env.new([1.0, 0.0, 1.0], [0.0, dur]), t_tr).linexp(0.0, 1.0, stbpm, endbpm) / 60.0) / (SampleRate.ir*bpc);
	var clk = Phasor.ar(0, tempo);
	Out.ar(abus, clk);
	Out.kr(kbus, clk);
}).add;

//Object to create signal-rate triggers
SynthDef(\timedtrig, {
	arg clkibs, ix, phaseobs, phase=0.5;
	//audio rate signal in from one of the phasor clocks (audio busses 100-199)
	var clk = In.ar(clkibs);
	var tr = (clk>phase) * (clk<(phase+0.0001));
	SendTrig.ar(tr, ix, phase);
	//send
	Out.kr(phaseobs, phase);
}).add;

// register to receive this message
o = OSCFunc({
	arg msg, time;
    [time, msg].postln;
},'/tr', s.addr);
)

s.sendMsg(\s_new, \phasorclock, 3000, 0, 2002, \abus, 100, \kbus, 0, \stbpm, 60.0, \endbpm, 60.0, \dur,0.05, \bpc, 16.0, \t_tr, 1);

s.sendMsg