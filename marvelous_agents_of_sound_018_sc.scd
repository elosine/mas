(
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//LEGEND

////PatchBay
/////// Sounds Go Out Audio Busses 50-57
/////// Patch Bay sends them back out Audio Channels depending on speaker config

//// Phasorclocks
////// nodes 3000-3099; Control Busses 0-99; Audio Busses 100-199; Group 2001

//// Timedtriggers
////// nodes 4000-9999; Group 2003

//// Phasectl
////// nodes 5000-5999; Group 2002; Control Busses 1000-1999

//// fx
////// nodes 6000-6999; Group 2002; Control Busses 2000-2999


//// Sounds

////// Toy Piano
//////// nodes 10000-19999; Group 2004

////// Puff Daddy
//////// nodes 200000-299999; Group 2004

////// Janus
//////// nodes 300000-399999; Group 2004

////// Stochsynth
//////// nodes 400000-499999; Group 2004

////// Krunkd
//////// nodes 500000-599999; Group 2004

////// Tbone
//////// nodes 600000-599999; Group 2004


/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//Adjust Server Options before boot
s.options.numAudioBusChannels = 500;
s.options.memSize = 163840;
s.waitForBoot{ fork{
	var toypianotrix = 0;
	var puffdaddyix = 0;
	var janusix = 0;
	var stochsynthix = 0;
	var krunkdix = 0;
	var tboneix = 0;
	//Make Groups
	//1999 for monitoring incomming signals
	//2000-2010 for dsp
	//2999 for monitoring out signals
	s.sendMsg(\g_new, 1999); s.sendMsg(\g_new, 2000);
	10.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
	s.sendMsg(\g_new, 2999, 3, 2010);
	//Processing OSC Client
	~proc = NetAddr("127.0.0.1", 12321);

	//Audio Rate Phasor-Driven Clock Object
	SynthDef(\phasorclock, {
		arg abus, kbus, stbpm=60.0, endbpm=60.0, rampdur=0.05, bpc=16.0, t_tr=1;
		var tempo = ( EnvGen.ar(Env.new([1.0, 0.0, 1.0], [0.0, rampdur]), t_tr).linexp(0.0, 1.0, stbpm, endbpm) / 60.0) / (SampleRate.ir*bpc);
		var clk = Phasor.ar(0, tempo);
		Out.ar(abus, clk);
		Out.kr(kbus, clk);
	}).add;

	//Object to create signal-rate triggers
	SynthDef(\timedtrig, {
		arg clkibs, ix, phasebus;
		//audio rate signal in from one of the phasor clocks (audio busses 100-199)
		var clk = In.ar(clkibs);
		//phase comes from control bus so phase can be dynamic and
		//you can dynamically move triggers with lfos etc...
		var phase = In.kr(phasebus);
		// Signal-Rate if control statement, creates a trigger at set phase
		var tr = (clk>phase) * (clk<(phase+0.0001));
		//Send Trigger from server to lang registered on OSCFunc below
		SendTrig.ar(tr, ix, phase);
	}).add;

	SynthDef(\triggeredtimer, {
		arg clkibs, trigphasebus, obs, durphase=0.25;
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

	//LFSaw to control trigger phase
	SynthDef(\phasectl, {
		arg kobs=1000,dur=5;
		var freq = 1.0/dur;
		var lo = \lo.kr(0.0,0.01);
		var hi = \hi.kr(0.0,0.01);
		var sig = LFSaw.ar(freq).range(lo,hi);
		Out.kr(kobs, sig);
	}).add;

	// OSCFunc to receive triggers from server and launch sounds
	~soundlauncher = OSCFunc({
		arg msg, time;
		var trignum = (msg[1].asInteger - 4000)%10;
		var sndnum = msg[2].asInteger;
		var trigphase = msg[3].asFloat;

		//map trigphase to 0-2 to feed to PanA
		trigphase = trigphase.linlin(0.0,1.0,0.0,2.0);

		//Switch sounds on sndnum
		switch(sndnum,
			0,  { //TOY PIANO
				var pitch = rrand(39, 90).round;
				//randomly select mode 0=single pitch, 1=m3, 2=P4, 3=M7, 4=m2
				var mode = rand(5).round.asInteger;

				switch(mode,

					0, { //single pitch
						s.sendMsg(\s_new, \toypiano, 10000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 0 );
						toypianotrix=toypianotrix+1;
					}, //end case 0-singlepitch

					1, { //m3
						s.sendMsg(\s_new, \toypiano, 12000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 0 );
						s.sendMsg(\s_new, \toypiano, 11000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+3, \lfospd, 0.44, \pos, trigphase, \obs, 0 );
						toypianotrix=toypianotrix+1;
					}, //end case 1-m3

					2, { //P4
						s.sendMsg(\s_new, \toypiano, 14000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 0 );
						s.sendMsg(\s_new, \toypiano, 13000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+5, \lfospd, 0.52, \pos, trigphase, \obs, 0 );
						toypianotrix=toypianotrix+1;
					}, //end case 2-P4

					3, { //M7
						s.sendMsg(\s_new, \toypiano, 16000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 0 );
						s.sendMsg(\s_new, \toypiano, 15000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+11, \lfospd, 0.61, \pos, trigphase, \obs, 0 );
						toypianotrix=toypianotrix+1;
					}, //end case 3-M7

					4, { //m2
						s.sendMsg(\s_new, \toypiano, 18000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 0 );
						s.sendMsg(\s_new, \toypiano, 17000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+1, \lfospd, 0.27, \pos, trigphase, \obs, 0 );
						toypianotrix=toypianotrix+1;
					}, //end case 4-m2

				); //end switch on mode

			}, //end case 0 toy piano

			1, { //PUFFDADDY
				s.sendMsg(\s_new, \puffdaddy, 200000+(trignum*1000)+puffdaddyix, 0, 2004, \t_tr, 1, \pos, trigphase, \obs, 0 );
				puffdaddyix=puffdaddyix+1;
			}, //end case 1 puffdaddy

			2, {  //JANUS
				s.sendMsg(\s_new, \janus, 300000+(trignum*1000)+janusix, 0, 2004, \t_tr, 1, \pos, trigphase, \obs, 0 );
				janusix=janusix+1;
			}, //end case 2 janus

			3, { //STOCHSYNTH
				s.sendMsg(\s_new, \stochsynth, 400000+(trignum*1000)+stochsynthix, 0, 2004, \t_tr, 1, \pos, trigphase, \obs, 0 );
				janusix=janusix+1;
			}, //end case 3 stochsynth

			4, { //KRUNKD
				~krunkdfreq = rrand(30, 88); ~krunkddur = rrand(0.85, 2.3);
				s.sendMsg(\s_new, \krunkd, 500000+(trignum*1000)+krunkdix, 0, 2004, \f1, ~krunkdfreq.midicps, \f2, (~krunkdfreq+1).midicps, \decay, ~krunkddur, \rel, ~krunkddur, \amp, 0.85,\t_tr, 1, \pos, trigphase, \obs, 0 );
				krunkdix=krunkdix+1;
			}, //end case 4 krunkd

			5, { //TBONE
				~tbonepitch = rrand(30, 50); ~tboneddur = rrand(0.15, 0.5);
				s.sendMsg(\s_new, \tbone, 600000+(trignum*1000)+tboneix, 0, 2004, \pitch, ~tbonepitch, \dur, ~tboneddur, \t_tr, 1, \pos, trigphase, \obs, 0 );
				tboneix=tboneix+1;
			}, //end case 5 tbone


		); //end switch on sndnum



	},'/tr', s.addr);


	////////////////////////////////////////////////////
	////Mechanism to create timed triggers /////////////
	////////////////////////////////////////////////////
	//////This OSCdef receives a command to create a trigger
	//////The spec is clock time (0-60.0) as this is a familiar
	//////metaphor to most folks
	//////In SC we'll use nodes 10000 - 20000, maybe a dict later
	OSCdef( \mktr, {
		//// Msg args:
		////// 1: index of the trigger
		////// 2: track number which will determine radius
		////// 3: sound number
		////// 4: phase in clocktime minutes
		arg msg;
		var ix = msg[1].asInteger; //index of the trigger
		var trk = msg[2].asInteger; //0-7 alla bullseye 0=master track
		var sndix = msg[3].asInteger; //which sound, probably by color
		var clktime = msg[4].asFloat;
		var phase = clktime.linlin(0.0, 60.0, 0.0, 1.0);
		var soundcolor = [ "limegreen", "purple", "goldenrod", "dodgerblue", "seagreen" ];


		fork{
			// 1) Create a phasectl for trigger's phase
			////// kobs=1000+ix (which control bus to use for trigger's phase
			////// lo&hi=phase (set lo and hi to current phase; later use these args to move triggers);
			////// Phasectls are Nodes 5000-5999, Group 2002
			s.sendMsg(\s_new, \phasectl, 5000+ix, 0, 2002, \kobs, 1000+ix, \lo, phase, \hi, phase);
			0.03.wait;

			// 2) Create an audio rate trigger with args:
			////// clkibs=ix+100 (which phasor to get clock info from, audio busses 100-199)
			////// ix=sndix (Number of sound 0-toypiano, 1-puffdaddy, 2...
			////// phasebus=1000+ix from (phasectl above)
			////// Timedtrigs are Nodes 4000-4999, Group 2003
			s.sendMsg(\s_new, \timedtrig, 4000+ix, 0, 2003, \clkibs, 100, \ix, sndix, \phasebus, 1000+ix);
			s.sendMsg(\s_new, \timedtrig, 4010+ix, 0, 2003, \clkibs, 101, \ix, sndix, \phasebus, 1000+ix);
			s.sendMsg(\s_new, \timedtrig, 4020+ix, 0, 2003, \clkibs, 102, \ix, sndix, \phasebus, 1000+ix);
			s.sendMsg(\s_new, \timedtrig, 4030+ix, 0, 2003, \clkibs, 103, \ix, sndix, \phasebus, 1000+ix);



			// 3) Send Msg to Processing to create graphical representation
			//// "/mktrigger", ix, radius (from trk), size, string soundcolor
			~proc.sendMsg( "/mktrigger", ix, 0.667, clktime, soundcolor[sndix] );

		}//end fork

	}, "/mktr");



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

	////SOUNDS SYNTH DEFS
	SynthDef( \puffdaddy, {
		//add a freq arg
		arg obs=0, t_tr=0, ivc = #[3,10,14,23,28,31,32], il1=1.27,d1=0.17, il2=1.2,d2=0.14, il3=1.3,d3=0.22, il4=1.12,d4=0.11, il5=1.24,d5=0.25, il6=1.14,d6=0.19, il7=1.3,d7=0.22, pos=0, wd=2, rq=0.08, rq2=0.5, amp=0.87, rt=0.1, dp=0.5;
		var iv1 = [3,10,2,11,4,7,8], iv2= [1,4,5,6,7,10,11], iv3= [1,6,11,5,7, 12,18], iv4= [4,6,8,10,11,2,5];
		var imp, p1,p2,p3,p4,p5,p6,p7, ivs, iv, pd1,pd2,pd3,pd4,pd5,pd6,pd7, c1,c1d, c2,c2d, c3,c3d, c4,c4d, c5,c5d, c6,c6d, c7,c7d, sig;
		var st2,st3,st4,st5,st6,st7;
		var lfo1;
		var hp;
		var pd1b;
		var env = EnvGen.ar(Env.perc(0.01,2.0),t_tr, doneAction:2);
		imp = T2A.ar(t_tr);
		p1 = TIRand.kr(43, 79, imp);
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
		//c3 = DelayC.ar(c3, 0.2, st3);
		c3d = CombC.ar(c3, 0.2, TRand.kr(0.09, 0.1, imp), SinOsc.kr( 0.09 ).range(1.5, 1.8));
		c4 = CombC.ar(imp, 0.2, pd4, il4);
		st4 = TRand.kr(0.7, 0.1);
		c4 = DelayC.ar(c4, 0.4, st4);
		c4d = CombC.ar(c4, 0.2, TRand.kr(0.11, 0.5, imp), SinOsc.kr( 0.05 ).range(1.6, 2.1));
		c5 = CombC.ar(imp, 0.2, pd5, il5);
		st5 = TRand.kr(0.7, 0.1);
		c5 = DelayC.ar(c5, 0.4, st5);
		c5d = CombC.ar(c5, 0.2, TRand.kr(0.08, 0.12, imp), SinOsc.kr( 0.02 ).range(0.7, 3.1));
		c6 = CombC.ar(imp, 0.2, pd6, il6);
		st6 = TRand.kr(0.7, 0.1);
		c6 = DelayC.ar(c6, 0.4, st2+st3+st4+st5+st6);
		c6d = CombC.ar(c6, 0.2, TRand.kr(0.098, 0.2, imp), SinOsc.kr( 0.07 ).range(1.1, 1.8));
		c7 = CombC.ar(imp, 0.2, pd7, il7);
		st7 = TRand.kr(0.7, 0.1);
		//c7 = DelayC.ar(c7, 0.6, st7);
		c7d = CombC.ar(c7, 0.2, TRand.kr(0.12, 0.3, imp), SinOsc.kr( 0.03 ).range(0.75, 2.5));
		sig = Mix.ar([c1, c1d, c2, c2d, c3, c3d, c4, c4d, c5, c5d, c6, c6d, c7, c7d]*0.75);

		hp = RHPF.ar(sig, SinOsc.kr(0.03).range(3000, 12000), rq);
		hp = JPverb.ar(hp, rt, dp);
		hp = Mix.ar(hp);

		sig = RLPF.ar(sig, SinOsc.kr(0.03).range(800, 12000), rq2);
		sig = Mix.ar([sig, hp*0.03]);

		//sig = PanAz.ar(8, Mix.ar([sig, hp*0.33]), pos, 1, wd, 0.5);
		//sig = PanAz.ar(8, sig, pos, 1, wd, 0.5);
		//sig = PanAz.ar(8, sig, SinOsc.kr(0.03), 1, wd, 0.5);
		//sig = PanAz.ar(8, Mix.ar([sig, JPverb.ar(hp, rt, dp)*0.33]), SinOsc.kr(0.03), 1, wd, 0.5);
		//sig = Mix.ar([sig, hp*0.02]);
		Out.ar(obs, sig*amp*env);
	}).add;

	//Toy Piano
	SynthDef(\toypiano, {
		arg obs=0, pitch=60, lfospd=0.5, pos, t_tr=0;
		var amp = \amp.kr(0.85, 0.01);
		var env = EnvGen.ar(Env.perc(0.01, 6.0, curve: -6), t_tr, doneAction:2);
		var imp = T2A.ar(t_tr);
		var freq = pitch.midicps;
		var sig = DynKlank.ar(
			`[
				[
					1*freq,
					1.0526645678458*freq,
					1.0722177540716*freq,
					1.1173842322068*freq,
					3.2137255202035*freq,
					6.4619017331061*freq,
					( (6.523014752975*freq).cpsmidi + SinOsc.kr(0.05*lfospd) ).midicps,
					10.754460040742*freq,
					( (10.872643827698*freq).cpsmidi + SinOsc.kr(0.03*lfospd) ).midicps,
					22.34655484674*freq
				],
				[
					0.18875469647576,
					0.58145809091593,
					0.69866162462817,
					0.13283592569299,
					1,
					0.88929800059361+LFTri.kr(0.05*lfospd).range(-0.2, 0.2),
					0.46474200944761+LFTri.kr(0.03*lfospd).range(-0.2, 0.2),
					0.4771785852636+LFTri.kr(0.08*lfospd).range(-0.2, 0.2),
					0.44083819263811+LFTri.kr(0.1*lfospd).range(-0.2, 0.2),
					0.1543129814717+LFTri.kr(0.04*lfospd).range(-0.05, 0.05)
				]*0.1,
				[
					2.7874822816943,
					3.0044616469429,
					3.0818892662019,
					2.7804810119127,
					1.3462578280856,
					2.6210993045158,
					2.3655306128538,
					1.5798209670323,
					2.4811880715523,
					1.4092510528673
				]
			],
			imp);
		//sig = PanAz.ar(8, sig, pos, 1, 2, 0.5);
		Out.ar(obs, sig*amp*env);
	}).add;

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

	SynthDef(\stochsynth, {
		arg obs=0,ampdist = 4.5, durdist = 1.5, adparam = 1, ddparam = 1, minfreq = 50, maxfreq = 6580, ampscale = 1.0, durscale = 0.5, initCPs = 12, knum, mul = 0.5, add = 0, envdur = 2, envdens = 7, atk=0.001, amp = 4.1, rel = 0.5;
		//'one-slider' variables
		//var dur = \dur.kr(0.0).linexp(0.0, 1.0, 0.02, 3.02);
		//var dens = \dens.kr(0.0).linlin(0.0, 1.0, 37.0, 9.02);
		//var crv = \crv.kr(0.0).linexp(0.0, 1.0, 6.0, 4.0);
		//var res = \res.kr(0.0).linlin(0.0, 1.0, 0.0, 0.6);
		//'one-slider' variables
		var lfo = LFTri.kr(0.1).range(0.0, 1.0);
		var dur = lfo.linexp(0.0, 1.0, 0.02, 3.02);
		var dens = lfo.linlin(0.0, 1.0, 37.0, 9.02);
		var crv = lfo.linexp(0.0, 1.0, 6.0, 4.0);
		var res = lfo.linlin(0.0, 1.0, 0.0, 0.6);

		var env = Env.perc(0.0001, dur, 0.25, -32);
		var gate = Dust.kr(dens);
		var env_gen = EnvGen.kr(env, gate);
		var envgate = Dust.kr(envdens);
		//var ampenv = EnvGen.kr(Env.perc(0.001, envdur, curve: crv), envgate);
		//var ampenv = EnvGen.kr(Env.perc(atk, TRand.kr(0.08, 1.2, Dust.kr(1)), curve: crv), envgate);
		var ampenv = EnvGen.kr(Env.perc(atk, rel, curve: crv), \t_tr.kr(0, 0.0), doneAction:2);
		var gd = Gendy1.ar( ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, env_gen, add );
		var moog = MoogLadder.ar(gd, TIRand.kr(200, 10000, envgate),res);
		var ring = Ringz.ar(gd, TRand.kr(80, 1500, Dust.kr(1.4)), TRand.kr(0.2, 3, Dust.kr(1.4)));
		var mix = Mix.ar([gd, ring*0.01]);
		var rmod = SinOsc.ar(SinOsc.kr(0.03, 0, 400, 600));
		var pan = Pan2.ar([moog, DelayC.ar(moog, delaytime:0.008)], SinOsc.kr(TIRand.kr(0.5, 2.5,Dust.kr(1.0) )));//spatialize
		Out.ar(obs, moog*ampenv*amp);
	}).add;


	SynthDef(\drumline, {
		arg rate1=11.0, rate2=10.0, rate3=12.0, gdur=0.03, ffreq=5000, frez=0.5, fr1=300, fr2=12000, amp=1.5, gate=0, dur=0.01, crv=0, pan=0;
		var noise, grainrate1, grainrate2, grainrate3, grainenv1, grainenv2, grainenv3, filterednoise1, filterednoise2, filterednoise3, freqchgrate1, freqchgrate2, freqchgrate3, s1, s2, s3, output, oenv, envtrig, atk;
		atk = PinkNoise.ar()*EnvGen.ar(Env.perc(attackTime:0.005, releaseTime:0.01));
		envtrig = \t_tr.kr(0,0);
		oenv = EnvGen.ar( Env.perc(attackTime:0.005, releaseTime:dur, curve:crv), envtrig, doneAction:2);
		grainrate1 = Impulse.kr(rate1);
		grainrate2 = Impulse.kr(rate2);
		grainrate3 = Impulse.kr(rate3);
		freqchgrate1 = Impulse.kr(rate1*2);
		freqchgrate2 = Impulse.kr(rate2*3);
		freqchgrate3 = Impulse.kr(rate3*4);
		grainenv1 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate1 );
		grainenv2 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate2 );
		grainenv3 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate3 );
		noise = Crackle.ar(chaosParam:1.95);
		filterednoise1 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate1), res:frez, mul:3 );
		filterednoise2 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate2), res:frez, mul:3 );
		filterednoise3 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate3), res:frez, mul:3 );
		s1 = filterednoise1*grainenv1;
		s2 = filterednoise2*grainenv2;
		s3 = filterednoise3*grainenv3;
		output = Mix.ar( [s1, s2, s3, atk] );
		//output = Pan2.ar(output, pan);
		Out.ar(0, output*amp*oenv);
	}).add;

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

	SynthDef( \tbone, {
		arg obs=0, pitch=60, amp=0.87, dur=3, t_tr=1, ffreq1=500, ffreq2=5000, q1=0.1, q2=0.7, sigamp=0.85, filtersigamp=0.3, fatk=0.3, fsus=0.3, frel=0.4, mq=0.7, mflo=500, mfhi=10000, t60=1, damp=0.5, sz=1;
		var freq = pitch.midicps;
		var osc1, osc2, osc3, osc4;
		var sig, filtersig, sig1, sig2, env, fenv;
		env = EnvGen.ar(Env.perc(0.01, dur), t_tr, donAction:2);
		osc1 = Saw.ar(pitch.midicps);
		osc2 = Saw.ar( ( pitch + LFTri.kr(0.01).range(-0.05, 0.05) ).midicps );
		osc3 = Saw.ar( ( pitch + LFTri.kr(0.024).range(-0.04, 0.04) ).midicps );
		osc4 = Pulse.ar( pitch.midicps, LFTri.kr(0.03).range(0.334, 0.667) );
		sig1 = Mix.ar([osc1,osc2]*0.5);
		sig1 = RLPF.ar(sig1, ffreq1, q1);
		sig2 = Mix.ar([osc3,osc4]*0.5);
		sig2 = RLPF.ar(sig2, ffreq2, q2);
		sig = Mix.ar([sig1, sig2]*0.5);
		filtersig = DynKlank.ar(`[ [(3*freq), (5*freq), (7*freq)], [0.002, 0.003, 0.005], [ (0.5*dur), (0.7*dur), (0.9*dur) ] ], sig);
		sig = Mix.ar([sig*sigamp, filtersig*filtersigamp]);
		fenv =   (EnvGen.kr(Env.linen(fatk*dur, fsus*dur, frel*dur,), t_tr)*mfhi)+mflo   ;
		sig = RLPF.ar(sig, fenv, mq);
		sig = JPverb.ar(sig,10,0,0.3);
		sig = Mix.ar(sig*0.5);
		Out.ar(obs,sig*amp*env);
	}).add;

	0.1.wait;

	////Initial Clock at 60bpm, with one clock having 16 beats
	s.sendMsg(\s_new, \phasorclock, 3000, 0, 2001, \abus, 100, \kbus, 0, \bpc, 16, \stbpm, 60, \endbpm, 60, \rampdur, 0.01, \t_tr, 1);
	////3 More Clocks to move later
	s.sendMsg(\s_new, \phasorclock, 3001, 0, 2001, \abus, 101, \kbus, 1, \bpc, 16, \stbpm, 80, \endbpm, 80, \rampdur, 0.01, \t_tr, 1);
	s.sendMsg(\s_new, \phasorclock, 3002, 0, 2001, \abus, 102, \kbus, 2, \bpc, 16, \stbpm, 100, \endbpm, 100, \rampdur, 0.01, \t_tr, 1);
	s.sendMsg(\s_new, \phasorclock, 3003, 0, 2001, \abus, 103, \kbus, 3, \bpc, 16, \stbpm, 40, \endbpm, 40, \rampdur, 0.01, \t_tr, 1);

}}//end fork and s.waitForBoot
)
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


//// Msg args:
////// 1: index of the trigger
////// 2: track number which will determine radius
////// 3: sound number
////// 4: phase in clocktime minutes
b = NetAddr("127.0.0.1", 57120);
(
b.sendMsg("/mktr", 0, 0, 0, 24.0);
b.sendMsg("/mktr", 1, 0, 0, 45.0);
b.sendMsg("/mktr", 2, 0, 0, 10.0);
b.sendMsg("/mktr", 3, 0, 0, 0.0);
b.sendMsg("/mktr", 4, 0, 0, 37.0);
b.sendMsg("/mktr", 5, 0, 0, 51.0);
b.sendMsg("/mktr", 6, 0, 0, 18.0);
b.sendMsg("/mktr", 7, 0, 0, 2.0);
b.sendMsg("/mktr", 8, 0, 0, 32.0);
b.sendMsg("/mktr", 9, 0, 0, 40.0);
b.sendMsg("/mktr", 10, 0, 0, 46.0);
b.sendMsg("/mktr", 11, 0, 0, 8.0);
b.sendMsg("/mktr", 12, 0, 0, 2.5);
b.sendMsg("/mktr", 13, 0, 0, 2.9);
b.sendMsg("/mktr", 14, 0, 0, 3.3);
b.sendMsg("/mktr", 15, 0, 0, 3.8);


b.sendMsg("/mktr", 1, 0, 1, 32.0);
b.sendMsg("/mktr", 17, 0, 1, 32.7);
b.sendMsg("/mktr", 18, 0, 1, 34.6);
b.sendMsg("/mktr", 19, 0, 1, 36.2);
b.sendMsg("/mktr", 20, 0, 1, 37.0);
b.sendMsg("/mktr", 21, 0, 1, 58.0);
b.sendMsg("/mktr", 22, 0, 1, 3.3);
b.sendMsg("/mktr", 23, 0, 1, 14.0);
b.sendMsg("/mktr", 24, 0, 1, 32.0);
b.sendMsg("/mktr", 25, 0, 1, 46.5);


b.sendMsg("/mktr", 26, 0, 2, 57.3);
b.sendMsg("/mktr", 27, 0, 2, 12.0);
b.sendMsg("/mktr", 2, 0, 2, 13.0);
b.sendMsg("/mktr", 29, 0, 2, 13.5);
b.sendMsg("/mktr", 30, 0, 2, 32.23);


b.sendMsg("/mktr", 31, 0, 3, 41);
b.sendMsg("/mktr", 32, 0, 3, 41.3);
b.sendMsg("/mktr", 33, 0, 3, 41.7);
b.sendMsg("/mktr", 34, 0, 3, 42.1);
b.sendMsg("/mktr", 35, 0, 3, 50.0);
b.sendMsg("/mktr", 36, 0, 3, 51.2);
b.sendMsg("/mktr", 37, 0, 3, 51.4);
b.sendMsg("/mktr", 3, 0, 3, 13.0);
b.sendMsg("/mktr", 39, 0, 3, 22.0);



b.sendMsg("/mktr", 40, 0, 4, 1.1);
b.sendMsg("/mktr", 4, 0, 4, 11.1);
b.sendMsg("/mktr", 42, 0, 4, 30.0);
b.sendMsg("/mktr", 43, 0, 4, 46.1);
b.sendMsg("/mktr", 44, 0, 4, 59.0);
)

//move targets
s.sendMsg(\n_set, 5000, \lo, 1.0, \hi, 0.0, \dur, 13);
s.sendMsg(\n_set, 5001, \lo, 0.0, \hi, 1.0, \dur, 9);
s.sendMsg(\n_set, 5002, \lo, 0.0, \hi, 1.0, \dur, 18);
s.sendMsg(\n_set, 5003, \lo, 0.0, \hi, 0.7, \dur, 21);
s.sendMsg(\n_set, 5004, \lo, 0.4, \hi, 0.9, \dur, 5);


s.queryAllNodes
s.meter;

//multiple wands
//effects/tracks
//control gui
//numbers
