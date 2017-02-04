(
//Make more audio busses (need them)
s.options.numAudioBusChannels = 300;
s.waitForBoot{ fork{
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
		arg ibs, obs, phaseobs, phase=0.5;
		var clk = In.ar(ibs);
		var tr = (clk>phase) * (clk<(phase+0.0001));
		Out.ar(obs, tr);
		Out.kr(phaseobs, phase);
	}).add;

	//Test sound
	SynthDef(\testsound, {
		arg ibs, freq=600;
		var tr = In.ar(ibs).poll;
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
		if(bnum>=100,{~proc.sendMsg("/tgkdat", bnum-100, val)});
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
		phase.postln;
		s.sendMsg(\s_new, \timedtrig, 10000+ix, 0, 2002, \ibs, 100+trk, \obs, 200+sndix, \phasebus, 100+ix, \phase, phase, \phaseobs, 100+ix);
		~proc.sendMsg("/mktrigger", ix, 0.5, 13.0, "limegreen");
		///mktimetrig(int aix, int clkix, float aradiusnorm, float st, float aend, String asclr, int awt)
	}, "/mktr");

	////SOUNDS SYNTH DEFS
	SynthDef( \puffdaddy, {
	//add a freq arg
	arg tribs, obs=0,ivc = #[3,10,14,23,28,31,32], il1=0.27,d1=0.17, il2=0.2,d2=0.14, il3=0.3,d3=0.22, il4=0.12,d4=0.11, il5=0.24,d5=0.25, il6=0.14,d6=0.19, il7=0.3,d7=0.22, pos=0, wd=2, rq=0.08, amp=4, rt=0.1, dp=0.5;
	var iv1 = [3,10,14,23,28,31,32], iv2= [1,4,5,6,7,10,11], iv3= [1,6,11,17,19, 24,30], iv4= [4,6,8,10,11,14,17];
	var p1,p2,p3,p4,p5,p6,p7, ivs, iv, pd1,pd2,pd3,pd4,pd5,pd6,pd7, c1,c1d, c2,c2d, c3,c3d, c4,c4d, c5,c5d, c6,c6d, c7,c7d, sig;
	var st2,st3,st4,st5,st6,st7;
	var lfo1;
	var hp;
	var pd1b;
	var imp = In.ar(tribs);
	var env = EnvGen.ar(Env.perc(0.01, 0.05, curve:0), imp);
		Out.ar(0, SinOsc.ar(600)*env);
	//imp = T2A.ar(tr);
	p1 = TIRand.kr(43, 79, imp).poll;
	ivs = [iv1, iv2, iv3, iv4];
	iv = TChoose.kr(imp, ivs);
	p2 = p1+iv[0];
	p3 = p1+iv[1];
	p4 = p1+iv[2];
	p5 = p1+iv[3];
	p6 = p1+iv[4];
	p7 = p1+iv[5];
	pd1 = 1.0/p1.midicps;
	pd2 = 1.0/p2.midicps;
	pd3 = 1.0/p3.midicps;
	pd4 = 1.0/p4.midicps;
	pd5 = 1.0/p5.midicps;
	pd6 = 1.0/p6.midicps;
	pd7 = 1.0/p7.midicps;
	c1 = CombC.ar(imp, 0.2, pd1, il1); //il1 is going to control the length of the initial impulse
	lfo1 = SinOsc.kr( 0.07 ).range(0.3, 2.7);
	c1d = CombC.ar(c1, 0.2, TRand.kr(0.08, 0.15, imp), lfo1); //d1, controls delay time, the last argument controls length of ping pong tail
	c2 = CombC.ar(imp, 0.2, pd2, il2);
	st2 = TRand.kr(0.7, 0.1);
	c2 = DelayC.ar(c2, 0.2, st2);
	c2d = CombC.ar(c2, 0.2, TRand.kr(0.1, 0.33, imp), SinOsc.kr( 0.06 ).range(0.8, 2.9));
	c3 = CombC.ar(imp, 0.2, pd3, il3);
	st3 = TRand.kr(0.7, 0.1);
	c3 = DelayC.ar(c3, 0.2, st2+st3);
	c3d = CombC.ar(c3, 0.2, TRand.kr(0.09, 0.1, imp), SinOsc.kr( 0.09 ).range(1.5, 1.8));
	c4 = CombC.ar(imp, 0.2, pd4, il4);
	st4 = TRand.kr(0.7, 0.1);
	c4 = DelayC.ar(c4, 0.4, st2+st3+st4);
	c4d = CombC.ar(c4, 0.2, TRand.kr(0.11, 0.5, imp), SinOsc.kr( 0.05 ).range(1.6, 2.1));
	c5 = CombC.ar(imp, 0.2, pd5, il5);
	st5 = TRand.kr(0.7, 0.1);
	c5 = DelayC.ar(c5, 0.4, st2+st3+st4+st5);
	c5d = CombC.ar(c5, 0.2, TRand.kr(0.08, 0.12, imp), SinOsc.kr( 0.02 ).range(0.7, 3.1));
	c6 = CombC.ar(imp, 0.2, pd6, il6);
	st6 = TRand.kr(0.7, 0.1);
	c6 = DelayC.ar(c6, 0.4, st2+st3+st4+st5+st6);
	c6d = CombC.ar(c6, 0.2, TRand.kr(0.098, 0.2, imp), SinOsc.kr( 0.07 ).range(1.1, 1.8));
	c7 = CombC.ar(imp, 0.2, pd7, il7);
	st7 = TRand.kr(0.7, 0.1);
	c7 = DelayC.ar(c7, 0.6, st2+st3+st4+st5+st7);
	c7d = CombC.ar(c7, 0.2, TRand.kr(0.12, 0.3, imp), SinOsc.kr( 0.03 ).range(0.75, 2.5));
	sig = Mix.ar([ c1*(1.0/3.0), c1d*(1.0/3.0),  c2*(1.0/3.0),c2d*(1.0/3.0), c3*(1.0/3.0),c3d*(1.0/3.0), c4*(1.0/4.0),c4d*(1.0/3.0), c5*(1.0/3.0),c5d*(1.0/3.0), c6*(1.0/3.0),c6d*(1.0/3.0), c7*(1.0/3.0),c7d*(1.0/3.0) ]);

	hp = RHPF.ar(sig, SinOsc.kr(0.03).range(3000, 12000), rq);
	hp = JPverb.ar(hp, rt, dp);

	sig = RLPF.ar(sig, SinOsc.kr(0.03).range(1200, 12000), rq);
	sig = Mix.ar([sig, hp*0.33]);

	//sig = PanAz.ar(8, Mix.ar([sig, hp*0.33]), pos, 1, wd, 0.5);
	//sig = PanAz.ar(8, sig, pos, 1, wd, 0.5);
	//sig = PanAz.ar(8, sig, SinOsc.kr(0.03), 1, wd, 0.5);
	//sig = PanAz.ar(8, Mix.ar([sig, JPverb.ar(hp, rt, dp)*0.33]), SinOsc.kr(0.03), 1, wd, 0.5);
	Out.ar(obs, sig*amp);
}).add;
}}
)

////Initial Clock at 60bpm, with one clock having 16 beats
////It goes to audio bus 100 abd control bus 0, at node 5000
////All clocks will be nodes 5000-5099
s.sendMsg(\s_new, \phasorclock, 5000, 0, 2001, \abus, 100, \kbus, 0, \bpc, 16, \stbpm, 60, \endbpm, 60, \dur, 0.1, \t_tr, 1);
////Sounds at nodes 6000-6999
s.sendMsg(\s_new, \puffdaddy, 6000, 0, 2003, \tribs, 200, \obs, 0);
s.sendMsg(\s_new, \puffdaddy, 6001, 0, 2003, \ibs, 200);
s.sendMsg(\s_new, \testsound, 6002, 0, 2003, \ibs, 200);

b = NetAddr("127.0.0.1", 57120);
b.sendMsg("/mktr", 0, 0, 0, 24.0);
b.sendMsg("/mktr", 2, 0, 0, 36.0);
b.sendMsg("/mktr", 3, 0, 0, 10.0);
b.sendMsg("/mktr", 4, 0, 0, 13.0);
b.sendMsg("/mktr", 5, 0, 0, 14.0);
b.sendMsg("/mktr", 6, 0, 0, 50.0);
b.sendMsg("/mktr", 7, 0, 0, 59.0);
b.sendMsg("/mktr", 8, 0, 0, 20.0);
b.sendMsg("/mktr", 9, 0, 0, 27.0);
b.sendMsg("/mktr", 10, 0, 0, 31.15);
b.sendMsg("/mktr", 11, 0, 0, 1.0);
b.sendMsg("/mktr", 12, 0, 0, 2.5);
b.sendMsg("/mktr", 13, 0, 0, 2.9);
b.sendMsg("/mktr", 14, 0, 0, 3.3);
b.sendMsg("/mktr", 15, 0, 0, 3.8);

~proc.sendMsg("/mktrigger", 1, 0.5, 10.0, "limegreen")
s.sendMsg("/n_set", 10000, \phase, 0.75, \phasebus, 100);
s.sendMsg("/n_set", 6000, \ibs, 100);
s.queryAllNodes

3.4.round

s.sendMsg(\c_set, 100);
