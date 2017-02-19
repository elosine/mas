~proc = NetAddr.new("127.0.0.1", 12321);

a.sendMsg("/mktrigger", 0, 0.3, 15.0, "orange");

~proc =

//These are for Processing to retreive phase data of individual targets
//This one is polled by processing and requests control bus data from server
OSCdef( \gettgkdata, {
	arg msg;
	var kbus = msg[1].asInteger;
	s.sendMsg(\c_get, kbus+1000);
}, "/gettgkdata");

//// This one responds to server request, and sends control bus data to processing
//// Trigger phase control busses are 1000-1999
OSCdef( \tgkdat, {
	arg msg;
	var bnum=msg[1].asInteger;
	var val=msg[2].asFloat;
	if(bnum>=1000,{~proc.sendMsg("/tgkdat", bnum-1000, val)});
}, \c_set);

//LFSaw to control trigger phase
SynthDef(\phasectl, {
	arg kobs=1000,dur=5;
	var freq = 1.0/dur;
	var lo = \lo.kr(0.0,0.01);
	var hi = \hi.kr(0.0,0.01);
	var sig = LFSaw.ar(freq).range(lo,hi);
	Out.kr(kobs, sig);
}).add;

s.sendMsg(\g_new, 2002);
s.sendMsg(\s_new, \phasectl, 5000, 0, 2002, \kobs, 1000, \lo, 0.333, \hi, 0.333);
s.sendMsg(\n_free, 5000);
