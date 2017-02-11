a = NetAddr("127.0.0.1", 12321);

//// "/mktrigger", ix, radius (from trk), size, string soundcolor
a.sendMsg( "/mktrigger", 0, 0.5, 15, "limegreen");

OSCdef( \gettgkdata, {
	arg msg;
	var kbus = msg[1].asInteger;
	msg.postln;
	s.sendMsg(\c_get, kbus);
}, "/gettgkdata");
//// This one responds to server request, and sends control bus data to processing
//// Trigger phase control busses are 1000-1999
OSCdef( \tgkdat, {
	arg msg;
	var bnum=msg[1].asInteger;
	var val=msg[2].asFloat;
	if(bnum>=100,{~proc.sendMsg("/tgkdat", bnum-1000, val)});
}, \c_set);
