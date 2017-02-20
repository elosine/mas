//Audio Rate Phasor-Driven Clock Object
SynthDef(\phasorclock, {
	arg abus1, abus2, kbus1,kbus2, stbpm=60.0, endbpm=60.0, rampdur=0.05, bpc=16.0, dur=0.25, t_tr=1;
	var tempo = ( EnvGen.ar(Env.new([1.0, 0.0, 1.0], [0.0, rampdur]), t_tr).linexp(0.0, 1.0, stbpm, endbpm) / 60.0) / (SampleRate.ir*bpc);
	var clk1 = Phasor.ar(0, tempo);
	var clk2 = Phasor.ar(0, tempo) + dur;
	Out.ar(abus1, clk1);
	Out.ar(abus2, clk2);
	Out.kr(kbus1, clk1);
	Out.kr(kbus2, clk2);
}).add;

SynthDef(\triggeredtimer, {
	arg clkibs, trigphasebus, obs, durphase=0.5;
	//audio rate signal in from one of the phasor clocks (audio busses 100-199)
	var clk = In.ar(clkibs);
	//trigger's phase comes from control bus so phase can be dynamic and
	//you can dynamically move triggers with lfos etc...
	var trigphase = In.kr(trigphasebus);
	// Signal-Rate if control statement, creates a trigger at set phase
	var tr = (clk<trigphase) * ( (clk+durphase)>trigphase );
	tr.poll;
	Out.kr(obs, tr);
}).add;

c = Synth(\phasorclock, [\abus1, 170, \abus2, 171, \kbus1, 2000, \kbus2, 701], 2002);
d = Synth(\triggeredtimer, [\clkibs, 170, \trigphasebus, 1000, \obs, 813], 2003)
c.free;
d.free;


SynthDef(\greyhole, {
	arg ibs=0, obs=0, gateibs;
	var in = In.ar(ibs);
	var fx = Greyhole.ar(in, LFTri.kr(0.01).range(0.1, 3.0), LFSaw.kr(0.1).range(0.0, 1.0), LFTri.kr(0.05).range(0.5, 2.5), SinOsc.kr(0.08).range(0.01, 1.0), LFTri.kr(0.005).range(0.1, 1.0));
	var gate = In.kr(gateibs);
	var env = EnvGen.ar(Env.asr(2.25,1,2.25,0),gate);
	Out.ar(obs, fx*env);
}).add;




//These are for Processing to retreive phase data of individual targets
//This one is polled by processing and requests control bus data from server
OSCdef( \getTimerDat, {
	arg msg;
	var kbus = msg[1].asInteger;
	s.sendMsg(\c_get, kbus+2000);
}, "/getTimerDat");

//// This one responds to server request, and sends control bus data to processing
//// Trigger phase control busses are 1000-1999
OSCdef( \timerkdat, {
	arg msg;
	var bnum=msg[1].asInteger;
	var val=msg[2].asFloat;
	if(bnum>=2000,{~proc.sendMsg("/timerkdat", bnum-2000, val)});
}, \c_set);



e = Synth(\greyhole, [\ibs, 0, \gateibs, 813]);
e.free;
s.meter
//

fx greyhole, bitcrush, spectral vocoder

//display in processing
way to create and destroy fxs
  void mk(int aix, float arad, float adur, String asclr, int awt) {


	~proc.sendMsg( "/mktimetrig", 0, 0.5, 0.5, "goldenrod", 15);