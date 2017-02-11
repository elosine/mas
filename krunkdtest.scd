
(
SynthDef(\krunkd, {
	arg obs=0, rate=0.7, res=9.8, igain=0.01, type=0, nl=0.33, f1=200, f2=210, decay=0.9, amp=0.5, rq=0.006, atk=0.001, rel=0.5, crv = -4, pan=0;
	var filter, impulse, ftrig, filter2, output, f1b, f2b, freq, oenv;
	oenv = EnvGen.ar(Env.perc(atk, rel, crv), \t_tr.kr(0, 0.0001), doneAction:2);
	f1b = (f1.cpsmidi-1).midicps;
	f2b = (f2.cpsmidi-1).midicps;
	ftrig = Impulse.kr(rate);
	freq = TRand.kr(f1, f2, ftrig);
	impulse = K2A.ar(1);
	filter = DFM1.ar( impulse, TRand.kr(f1, f2, ftrig), res, igain, type, nl );
	filter2 = DFM1.ar( impulse, TRand.kr(f1b, f2b, ftrig), res, igain, type, nl );
	output = Mix.ar([filter, filter2]) * 0.2;
	output = Decay2.ar(output, 0.001, decay, output);
	output = output*0.02;
	//output = Pan2.ar(output, pan);
	Out.ar(obs, output*amp*oenv);
}).add;
)
(
~freq = rrand(30, 80); ~dur = rrand(0.85, 2.3);
a=Synth(\krunkd, [\t_tr, 1, \f1, ~freq.midicps, \f2, (~freq+1).midicps, \decay, ~dur, \rel, ~dur, \amp, 0.85, \t_tr, 1]);
)
s.meter