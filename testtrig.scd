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
	arg clkibs, ix, phase=0.5;
	//audio rate signal in from one of the phasor clocks (audio busses 100-199)
	var clk = In.ar(clkibs);
	// Signal-Rate if control statement, creates a trigger at set phase
	var tr = (clk>phase) * (clk<(phase+0.0001));
	//Send Trigger from server to lang registered on OSCFunc below
	//ix = sound number
	SendTrig.ar(tr, ix, phase);
}).add;

// OSCFunc to receive triggers from server and launch sounds
o = OSCFunc({
	arg msg, time;
	var trignum = msg[1].asInteger - 4000;
	var sndnum = msg[2].asInteger;
	var trigphase = msg[3].asFloat;
	[trignum, sndnum, trigphase].postln;

	switch(sndnum,
		0,  {

			var pitch = rrand(39, 90).round;
			//randomly select mode 0=single pitch, 1=m3, 2=P4, 3=M7, 4=m2
			var mode = rand(5).round;

			switch(mode,
				0, {
					s.sendMsg(\s_new, \toypiano, 3000, 0, 2002, \t_tr, 1, \pitch, ~cf, \lfospd, 0.3);
					s.sendMsg(\s_new, \toypiano, 3001, 0, 2002, \t_tr, 1, \pitch, ~cf+3, \lfospd, 0.32);
				} //end case 0
			); //end switch on mode

		} //end case 0
	); //end switch on sndnum



},'/tr', s.addr);
)

s.sendMsg(\s_new, \phasorclock, 3000, 0, 2002, \abus, 100, \kbus, 0, \stbpm, 60.0, \endbpm, 60.0, \dur,0.05, \bpc, 16.0, \t_tr, 1);

s.sendMsg(\s_new, \timedtrig, 4000, 0, 2003, \clkibs, 100, \ix, 0, \phase, 0.3789);

o.free


