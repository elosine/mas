(
SynthDef( \janus, {
	arg obs=0, t_tr=0, amp=0.5;
	var imp = T2A.ar(t_tr);
	var o1 = SinOsc.kr(0.311).range(0.0, 0.25);
	var o2 = SinOsc.kr(0.07).range(0.0, 0.25);
	var o3 = SinOsc.kr(0.11).range(0.0, 0.25);
	var o4 = SinOsc.kr(0.085).range(0.0, 0.25);
	var o5 = SinOsc.kr(0.23).range(0.0, 0.25);
	var dur = TRand.kr(3.0, 9.0,imp);
	var p1 = TIRand.kr(40, 80, imp);
	var p2 = p1 + TIRand.kr(1, 10, imp);
	var p3 = p1 + TIRand.kr(1, 10, imp);
	var f1 = p1.midicps;
	var f2 = p2.midicps;
	var f3 = p3.midicps;
	var h = [2,3,4,5,6,7,8,9,10,11,12,13,14];
	var j1 = TIRand.kr(0,10,imp);
	var j2 = TIRand.kr(0,10,imp);
	var j3 = TIRand.kr(0,10,imp);
	var h1 = h.scramble.copyRange(3,5).addFirst(1);
	var h2 = h.scramble.copyRange(7,9).addFirst(1);
	var h3 = h.scramble.copyRange(0,2).addFirst(1);
	var s1 = Ringz.ar( imp, f1*h1, dur,[o5, o1, o2, o3] );
	var s2 = Ringz.ar( imp, f2*h2, dur,[o3, o5, o4, o2]);
	var s3 = Ringz.ar( imp, f3*h3, dur,[o2, o1, o5, o3]);
	var fe = EnvGen.ar(Env.perc(0.002, dur+(dur*0.7), 1, 0),imp,doneAction:2);
	var f1b = (p1+1).midicps;
	var s1b = Ringz.ar( imp, f1b, dur,[o5, o1, o2, o3]);
	var f2b = (p2+1).midicps;
	var s2b = Ringz.ar( imp, f2b, dur,[o3, o5, o4, o2]);
	var f3b = (p3+1).midicps;
	var s3b = Ringz.ar( imp, f3b, dur,[o2, o1, o5, o3]);
	s1 = Mix.ar(s1);
	s2 = Mix.ar(s2);
	s3 = Mix.ar(s3);
	//Out.ar(och, Mix.ar([s1*(1.0/6.0), s2*(1.0/6.0), s3*(1.0/6.0), s1b*(1.0/6.0), s2b*(1.0/6.0), s3b*(1.0/6.0)])*fe);
	Out.ar(obs, (Mix.ar([s1*0.3, s2*0.3, s3*0.3])*fe) * amp);
	//Out.ar(0, Mix.ar([s1*(1.0/6.0), s1b*(1.0/6.0)])*fe);
}).add;
)
a = Synth(\janus, [\t_tr, 1]);