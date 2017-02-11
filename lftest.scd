SynthDef(\lftest, {
	arg kobs=0,freq=0.1;
	var lo = \lo.kr(0.5,0.01);
	var hi = \hi.kr(0.5,0.01);
	var sig = LFSaw.ar(freq).range(lo,hi).poll;
	Out.kr(kobs, sig);
}).add;
ServerOptions
s.sendMsg(\s_new, \lftest, 100000,0,1);
s.sendMsg(\n_set, 100000, \lo, 0.5, \hi, 0.0, \freq, 0.5);
a.free;