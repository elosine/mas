int aix, float aradius, float asize, String atclr

a = NetAddr("127.0.0.1",12321);

a.sendMsg("/mktrigger", 0, 0.5, 7.0, "limegreen");

OSCdef(\gettgkdata, {|msg| msg.postln}, "/gettgkdata");
OSCdef(\gettgkdata).free

OSCdef( \gettgkdata, {
	arg msg;
	var kbus = msg[1].asInteger;
	s.sendMsg(\c_get, kbus);
}, "/gettgkdata");

OSCdef( \tgkdat, {
	arg msg;
	var bnum=msg[1].asInteger;
	var val=msg[2].asFloat;
	val.postln;
}, \c_set);

OSCdef(\tgkdat).free

s.sendMsg(\c_set, 100,0.99);