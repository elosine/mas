(
//Make more audio busses (need them)
s.options.numAudioBusChannels = 300;

s.sendMsg(\g_new, 2000);
s.sendMsg(\g_new, 2001, 3, 2000);
s.sendMsg(\g_new, 2002, 3, 2001);
s.sendMsg(\g_new, 2003, 3, 2002);
~proc = NetAddr("127.0.0.1", 12321);

//Audio Rate Phasor-Driven Clock Object
SynthDef(\phasorclock, {
	arg abus, kbus, stbpm=60.0, endbpm=120.0, dur=60.0, bpc=4.0, t_tr=1;
	var tempo = ( EnvGen.ar(Env.new([1.0, 0.0, 1.0], [0.0, dur]), t_tr).linexp(0.0, 1.0, stbpm, endbpm) / 60.0) / (SampleRate.ir*bpc);
	var clk = Phasor.ar(0, tempo);
	Out.ar(abus, clk);
	Out.kr(kbus, clk);
}).add;

//Object to create signal-rate triggers
SynthDef(\timedtrig, {
	arg ibs, obs, phasebus, phase=0.5;
	var clk = In.ar(ibs);
	var tr = (clk>phase) * (clk<(phase+0.0001));
	Out.ar(obs, tr);
	Out.kr(phasebus, phase);
}).add;

//Test sound
SynthDef(\testsound, {
	arg ibs, freq=600;
	var tr = In.ar(ibs);
	var env = EnvGen.ar(Env.perc(0.01, 0.05, curve:0), tr);
	Out.ar(0, SinOsc.ar(freq)*env);
}).add;

////////////////////////////////////////////////////
////Mechanism for Processing to grab control data //
////////////////////////////////////////////////////
//////This one receives msgs from Processing and queries the server
//////for the value of a particular control bus, bus corresponds
//////to the index number of the Dial in Processing
OSCdef( \getkdata, {
	arg msg;
	var kbus = msg[1].asInteger;
	s.sendMsg(\c_get, kbus);
}, "/getkdata");
//////This one receives the response from the server and sends a
//////message to processing with the Dial number, and the value of
//////the control bus which is the current phase of the phasorclock (0-1)
OSCdef( \kdat, {
	arg msg;
	var bnum=msg[1].asInteger;
	var val=msg[2].asFloat;
	msg.postln;
	~proc.sendMsg("/kdat", bnum, val);
}, \c_set);



OSCdef( \gettgkdata, {
	arg msg;
	var kbus = msg[1].asInteger;
	s.sendMsg(\c_get, kbus);
}, "/gettgkdata");

OSCdef( \tgkdat, {
	arg msg;
	var bnum=msg[1].asInteger;
	var val=msg[2].asFloat;
	if(bnum>=100,{~proc.sendMsg("/tgkdat", bnum, val)});
}, \c_set);


////////////////////////////////////////////////////
////Mechanism to create timed triggers /////////////
////////////////////////////////////////////////////
//////This OSCdef receives a command to create a trigger
//////The spec is clock time (0-60.0) as this is a familiar
//////metaphor to most folks
//////In SC we'll use nodes 10000 - 20000, maybe a dict later
OSCdef( \mktr, {
	arg msg;
	var ix = msg[1].asInteger; //index of the trigger
	var trk = msg[2].asInteger; //0-7 alla bullseye 0=master track
	var sndix = msg[3].asInteger; //which sound, probably by color
	var clktime = msg[4].asFloat;
	var phase = clktime.linlin(0.0, 60.0, 0.0, 1.0);
	s.sendMsg(\s_new, \timedtrig, 10000+ix, 0, 2002, \ibs, 100+trk, \obs, 100+sndix, \phase, phase, \phaseobs, 100+ix);
	///mktimetrig(int aix, int clkix, float aradiusnorm, float st, float aend, String asclr, int awt)
}, "/mktr");
)

////Initial Clock at 60bpm, with one clock having 16 beats
////It goes to audio bus 100 abd control bus 0, at node 5000
////All clocks will be nodes 5000-5099
s.sendMsg(\s_new, \phasorclock, 5000, 0, 2001, \abus, 100, \kbus, 0, \bpc, 16, \stbpm, 60, \endbpm, 60, \dur, 0.1, \t_tr, 1);
////Sounds at nodes 6000-6999
s.sendMsg(\s_new, \testsound, 6000, 0, 2003, \ibs, 200);

b = NetAddr("127.0.0.1", 57120);
b.sendMsg("/mktr", 0, 0, 0, 24.0);

~proc.sendMsg("/mktrigger", 1, 0.5, 10.0, "limegreen")

s.queryAllNodes

3.4.round

s.sendMsg(\c_get, 0);
