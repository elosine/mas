(
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

//Adjust Server Options before boot
s.options.numAudioBusChannels = 3000;
s.options.memSize = 163840;
s.options.numOutputBusChannels = 8;
s.options.numWireBufs = 512;

//// Start Server & Routine
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
s.waitForBoot{ fork{

	//////////////////////////////////////////////////////
	//// Variables
	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////

	////// Index numbers so each sound trigger has its own unique node
	var trigix = 0;

	var toypianotrix = 0;
	var puffdaddyix = 0;
	var janusix = 0;
	var stochsynthix = 0;
	var krunkdix = 0;
	var tboneix = 0;

	/////Wands
	var dialcolors = [ "yellow", "turquoiseblue", "violetred", "limegreen", "fig", "pink", "white" ];
	var wandcurrbpm = 60.0!10;

	////// Processing OSC Client
	~proc = NetAddr("127.0.0.1", 12321);

	////// SCLang OSC Client
	~sclang = NetAddr("127.0.0.1", 57120);

	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////
	//// End Variables
	//////////////////////////////////////////////////////


	//////////////////////////////////////////////////////
	////// GROUPS
	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////

	//1999 for monitoring incomming signals
	//2000-2010 for dsp
	//2999 for monitoring out signals

	s.sendMsg(\g_new, 1999); s.sendMsg(\g_new, 2000);
	10.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
	s.sendMsg(\g_new, 2999, 3, 2010);

	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////
	////// END GROUPS
	//////////////////////////////////////////////////////


	//////////////////////////////////////////////////////
	////// PATCHING
	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////
	SynthDef(\patch, {
		arg ibs, obs;
		var in = In.ar(ibs);
		Out.ar(obs, in);
	}).add;

	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////
	////// END PATCHING
	//////////////////////////////////////////////////////



	////////////////////////////////////////////////////////////////////////////
	///// PHASOR CLOCKS
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	SynthDef(\phasorclock, {
		arg abus, kbus, stbpm=60.0, endbpm=60.0, rampdur=0.05, bpc=16.0, t_tr=1, dir=1;
		var tempo = ( EnvGen.ar(Env.new([1.0, 0.0, 1.0], [0.0, rampdur]), t_tr).linexp(0.0, 1.0, stbpm, endbpm) / 60.0) / (SampleRate.ir*bpc);
		var clk = Phasor.ar(0, tempo*dir);
		Out.ar(abus, clk);
		Out.kr(kbus, clk);
	}).add;


	////// Start Initial Clock at 60bpm, with one clock having 16 beats
	////// Nodes 3000-3003
	////// Group 2001
	////// Audio rate signals out audiobusses 100-103
	////// Control rate signals out controlbusses 0-3
	OSCdef(\mkwand, {
		arg msg;
		var ix = msg[1].asInteger;
		var bpm = msg[2].asFloat;

		// 1) Make a phasor clock
		s.sendMsg(\s_new, \phasorclock, 3000+ix, 0, 2001, \abus, 100+ix, \kbus, ix, \bpc, 16, \stbpm, bpm, \endbpm, bpm, \rampdur, 0.01, \t_tr, 1);
		// 1a)
		wandcurrbpm[ix] = bpm;

		// 2) Create a patch synth per wand to go from private bus 200+ to 0
		8.do{ |ixx| s.sendMsg(\s_new, \patch, 63990+(10*ix)+ixx, 0, 2010, \ibs, 200+(ix*10)+ixx, \obs, 0+ixx);};

		// 3) Create animation in Processing
		// int ix, int clkix, float rad1, float rad2, String clr, int wt
		~proc.sendMsg("/mkdial", ix, 0, 0.0, 1.0, dialcolors[ix], 2);

	}, "/mkwand");

	//Change Wand Speed or Direction
	OSCdef(\chgwand, {
		arg msg;
		var ix = msg[1].asInteger;
		var newbpm = msg[2].asFloat;
		var rampdur = msg[3].asFloat;
		var dir = msg[4].asInteger;
		s.sendMsg(\n_set, 3000+ix, \stbpm, wandcurrbpm[ix], \endbpm, newbpm, \rampdur, rampdur, \dir, dir);
	}, "/chgwand");

	0.1.wait;

	//Create Initial Wand
	~sclang.sendMsg("/mkwand", 0, 60.0);

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////// End Phasor Clocks
	////////////////////////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////////////////////////
	////Mechanism to create timed triggers /////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	//////This OSCdef receives a command to create a trigger

	OSCdef( \mktr, {
		//// Msg args:
		////// 1: index of the trigger
		////// 2: track number which will determine radius
		////// 3: sound number
		////// 4: phase in clocktime minutes
		arg msg;
		//var ix = msg[1].asInteger; //index of the trigger
		var ix = trigix;
		var sndix = msg[1].asInteger; //which sound, probably by color
		var phase = rrand(0.0, 1.0);
		var soundcolor = [ "limegreen", "purple", "goldenrod", "dodgerblue", "seagreen"  ];

		trigix = trigix + 1;

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
			s.sendMsg(\s_new, \timedtrig, 4000+ix, 0, 2003, \clkibs0, 100, \ix, sndix, \phasebus, 1000+ix);

			// 3) Send Msg to Processing to create graphical representation
			//// "/mktrigger", ix, radius (from trk), size, string soundcolor
			~proc.sendMsg( "/mktrigger", ix, rrand(0.334, 0.8), rrand(13.0, 25.0), soundcolor[sndix] );

		}; //end fork

	}, "/mktr"); //end OSCdef \mktr


	//OSCdef to move sound targets
	OSCdef(\mvsndtr, {
		arg msg;
		var ix = msg[1].asInteger;
		var lo = msg[2].asFloat;
		var hi = msg[3].asFloat;
		var rampdur = msg[4].asFloat;
		s.sendMsg(\n_set, 5000+ix, \lo, lo, \hi, hi, \dur, rampdur);
	}, "/mvsndtr");


	//OSCdef to move remove targets
	OSCdef(\rmtrg, {
		arg msg;
		var ix = trigix;
		s.sendMsg(\n_free, 4000+ix);
		s.sendMsg(\n_free, 5000+ix);
		~proc.sendMsg("/rmvtrigger", ix.asInteger);
		trigix = trigix - 1;
	}, "/rmtrg");

	//////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////
	////// END Mechanism To Create Timed Triggers
	//////////////////////////////////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////////////////////////
	///// TRIGGERS
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	//Object to create signal-rate triggers
	SynthDef(\timedtrig, {
		arg clkibs0, ix, phasebus;
		var clkibs = Array.fill(10, {|ix| ix+clkibs0});
		//audio rate signal in from one of the phasor clocks (audio busses 100-199)
		var clk0 = In.ar(clkibs[0]);
		var clk1 = In.ar(clkibs[1]);
		var clk2 = In.ar(clkibs[2]);
		var clk3 = In.ar(clkibs[3]);
		var clk4 = In.ar(clkibs[4]);
		var clk5 = In.ar(clkibs[5]);
		var clk6 = In.ar(clkibs[6]);
		var clk7 = In.ar(clkibs[7]);
		var clk8 = In.ar(clkibs[8]);
		var clk9 = In.ar(clkibs[9]);
		//phase comes from control bus so phase can be dynamic and
		//you can dynamically move triggers with lfos etc...
		var phase = In.kr(phasebus);
		// Signal-Rate if control statement, creates a trigger at set phase
		var tr0 = (clk0>phase) * (clk0<(phase+0.0001));
		var tr1 = (clk1>phase) * (clk1<(phase+0.0001));
		var tr2 = (clk2>phase) * (clk2<(phase+0.0001));
		var tr3 = (clk3>phase) * (clk3<(phase+0.0001));
		var tr4 = (clk4>phase) * (clk4<(phase+0.0001));
		var tr5 = (clk5>phase) * (clk5<(phase+0.0001));
		var tr6 = (clk6>phase) * (clk6<(phase+0.0001));
		var tr7 = (clk7>phase) * (clk7<(phase+0.0001));
		var tr8 = (clk8>phase) * (clk8<(phase+0.0001));
		var tr9 = (clk9>phase) * (clk9<(phase+0.0001));
		//Send Trigger from server to lang registered on OSCFunc below
		SendTrig.ar(tr0, ix,  phase);
		SendTrig.ar(tr1, ix, phase+1);
		SendTrig.ar(tr2, ix, phase+2);
		SendTrig.ar(tr3, ix, phase+3);
		SendTrig.ar(tr4, ix, phase+4);
		SendTrig.ar(tr5, ix, phase+5);
		SendTrig.ar(tr6, ix, phase+6);
		SendTrig.ar(tr7, ix, phase+7);
		SendTrig.ar(tr8, ix, phase+8);
		SendTrig.ar(tr9, ix, phase+9);
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
		//
		var trignum = msg[1].asInteger - 4000;
		var sndnum = msg[2].asInteger;
		var wandphase = msg[3];
		var wandnum, trigphase;
		case
		{wandphase<1}{wandnum=0; trigphase=wandphase}
		{wandphase>=1 && wandphase<2}{wandnum=1; trigphase = wandphase-1.0}
		{wandphase>=2 && wandphase<3}{wandnum=2; trigphase = wandphase-2.0}
		{wandphase>=3 && wandphase<4}{wandnum=3; trigphase = wandphase-3.0}
		{wandphase>=4 && wandphase<5}{wandnum=4; trigphase = wandphase-4.0}
		{wandphase>=5 && wandphase<6}{wandnum=5; trigphase = wandphase-5.0}
		{wandphase>=6 && wandphase<7}{wandnum=6; trigphase = wandphase-6.0}
		{wandphase>=7 && wandphase<8}{wandnum=7; trigphase = wandphase-7.0}
		{wandphase>=8 && wandphase<9}{wandnum=8; trigphase = wandphase-8.0};

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
						s.sendMsg(\s_new, \toypiano, 10000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 200+(wandnum*10) );
						toypianotrix=toypianotrix+1;
					}, //end case 0-singlepitch

					1, { //m3
						s.sendMsg(\s_new, \toypiano, 12000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 200+(wandnum*10) );
						s.sendMsg(\s_new, \toypiano, 11000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+3, \lfospd, 0.44, \pos, trigphase, \obs, 200+(wandnum*10) );
						toypianotrix=toypianotrix+1;
					}, //end case 1-m3

					2, { //P4
						s.sendMsg(\s_new, \toypiano, 14000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 200+(wandnum*10) );
						s.sendMsg(\s_new, \toypiano, 13000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+5, \lfospd, 0.52, \pos, trigphase, \obs, 200+(wandnum*10) );
						toypianotrix=toypianotrix+1;
					}, //end case 2-P4

					3, { //M7
						s.sendMsg(\s_new, \toypiano, 16000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 200+(wandnum*10) );
						s.sendMsg(\s_new, \toypiano, 15000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+11, \lfospd, 0.61, \pos, trigphase, \obs, 200+(wandnum*10) );
						toypianotrix=toypianotrix+1;
					}, //end case 3-M7

					4, { //m2
						s.sendMsg(\s_new, \toypiano, 18000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch, \lfospd, 0.3, \pos, trigphase, \obs, 200+(wandnum*10) );
						s.sendMsg(\s_new, \toypiano, 17000+(toypianotrix*10)+trignum, 0, 2004, \t_tr, 1, \pitch, pitch+1, \lfospd, 0.27, \pos, trigphase, \obs, 200+(wandnum*10) );
						toypianotrix=toypianotrix+1;
					}, //end case 4-m2

				); //end switch on mode

			}, //end case 0 toy piano

			1, { //PUFFDADDY
				s.sendMsg(\s_new, \puffdaddy, 200000+(trignum*1000)+puffdaddyix, 0, 2004, \t_tr, 1, \pos, trigphase, \obs, 200+(wandnum*10) );
				puffdaddyix=puffdaddyix+1;
			}, //end case 1 puffdaddy

			2, {  //JANUS
				s.sendMsg(\s_new, \janus, 300000+(trignum*1000)+janusix, 0, 2004, \t_tr, 1, \pos, trigphase, \obs, 200+(wandnum*10) );
				janusix=janusix+1;
			}, //end case 2 janus

			3, { //STOCHSYNTH
				s.sendMsg(\s_new, \stochsynth, 400000+(trignum*1000)+stochsynthix, 0, 2004, \t_tr, 1, \pos, trigphase, \obs, 200+(wandnum*10) );
				janusix=janusix+1;
			}, //end case 3 stochsynth

			4, { //KRUNKD
				~krunkdfreq = rrand(30, 88); ~krunkddur = rrand(0.85, 2.3);
				s.sendMsg(\s_new, \krunkd, 500000+(trignum*1000)+krunkdix, 0, 2004, \f1, ~krunkdfreq.midicps, \f2, (~krunkdfreq+1).midicps, \decay, ~krunkddur, \rel, ~krunkddur, \amp, 0.85,\t_tr, 1, \pos, trigphase, \obs, 200+(wandnum*10) );
				krunkdix=krunkdix+1;
			}, //end case 4 krunkd

			5, { //TBONE
				~tbonepitch = rrand(30, 50); ~tboneddur = rrand(0.15, 0.5);
				s.sendMsg(\s_new, \tbone, 600000+(trignum*1000)+tboneix, 0, 2004, \pitch, ~tbonepitch, \dur, ~tboneddur, \t_tr, 1, \pos, trigphase, \obs, 200+(wandnum*10) );
				tboneix=tboneix+1;
			}, //end case 5 tbone

		); //end switch on sndnum

	},'/tr', s.addr); //end OSCdef /soundlauncher

	///////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////
	////// END TRIGGERS
	///////////////////////////////////////////////////////////////////////////////////


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


	//////////////////////////////////////////////////////////////
	////// TRIGGERED TIMERS - FX /////////////////////////////////
	//////////////////////////////////////////////////////////////


	SynthDef(\triggeredtimer, {
		arg clkibs, trigphasebus0, obs0, durphase=0.25;
		var obs = Array.fill(10, {|ix| ix+obs0});
		//signal in from this timers phasor clock
		var clk = In.ar(clkibs);
		//trigphase comes from one of the wand's clocks
		var trigphasebus = Array.fill(10, {|ix| trigphasebus0+ix});
		var trigphase0 = In.ar(trigphasebus[0]);
		var trigphase1 = In.ar(trigphasebus[1]);
		var trigphase2 = In.ar(trigphasebus[2]);
		var trigphase3 = In.ar(trigphasebus[3]);
		var trigphase4 = In.ar(trigphasebus[4]);
		var trigphase5 = In.ar(trigphasebus[5]);
		var trigphase6 = In.ar(trigphasebus[6]);
		var trigphase7 = In.ar(trigphasebus[7]);
		var trigphase8 = In.ar(trigphasebus[8]);
		var trigphase9 = In.ar(trigphasebus[9]);
		// Signal-Rate if control statement, creates a trigger at set phase
		var tr0 = (clk<trigphase0) * ( (clk+durphase)>trigphase0 );
		var tr1 = (clk<trigphase1) * ( (clk+durphase)>trigphase1 );
		var tr2 = (clk<trigphase2) * ( (clk+durphase)>trigphase2 );
		var tr3 = (clk<trigphase3) * ( (clk+durphase)>trigphase3 );
		var tr4 = (clk<trigphase4) * ( (clk+durphase)>trigphase4 );
		var tr5 = (clk<trigphase5) * ( (clk+durphase)>trigphase5 );
		var tr6 = (clk<trigphase6) * ( (clk+durphase)>trigphase6 );
		var tr7 = (clk<trigphase7) * ( (clk+durphase)>trigphase7 );
		var tr8 = (clk<trigphase8) * ( (clk+durphase)>trigphase8 );
		var tr9 = (clk<trigphase9) * ( (clk+durphase)>trigphase9 );

		Out.kr(obs[0], tr0);
		Out.kr(obs[1], tr1);
		Out.kr(obs[2], tr2);
		Out.kr(obs[3], tr3);
		Out.kr(obs[4], tr4);
		Out.kr(obs[5], tr5);
		Out.kr(obs[6], tr6);
		Out.kr(obs[7], tr7);
		Out.kr(obs[8], tr8);
		Out.kr(obs[9], tr9);
	}).add;

	//These are for Processing to retreive phase data of individual targets
	//This one is polled by processing and requests control bus data from server
	OSCdef( \getTimerDat, {
		arg msg;
		var kbus = msg[1].asInteger;
		s.sendMsg(\c_get, kbus+10);
	}, "/getTimerDat");

	//// This one responds to server request, and sends control bus data to processing
	//// Trigger phase control busses are 1000-1999
	OSCdef( \timerkdat, {
		arg msg;
		var bnum=msg[1].asInteger;
		var val=msg[2].asFloat;
		if(bnum>=10,{~proc.sendMsg("/timerkdat", bnum-10, val)});
	}, \c_set);


	0.1.wait;

	//// OSCdef to create a new fx triggered timer
	OSCdef(\mkfx, {
		arg msg;
		var ix = msg[1].asInteger;
		var bpm = msg[2].asFloat;
		var durphase = msg[3].asFloat;
		var fxnum = msg[4].asInteger;
		var fxclrs = ["goldenrod", "dodgerblue", "mint"];

		////// 1) Make a new phasorclock
		////////// fx clocks will be nodes 3010-
		///////////  control busses 10-
		///////////  audio busses 110-
		///////////  group 2001

		s.sendMsg(\s_new, \phasorclock, 3010+ix, 0, 2001, \abus, 110+ix, \kbus, 10+ix, \bpc, 16, \stbpm, bpm, \endbpm, bpm, \rampdur, 0.01, \t_tr, 1);

		//////  2) Make a triggered timer
		////////  nodes 3200-
		////////  group 2005
		//////// control busses 3000-
		s.sendMsg(\s_new, \triggeredtimer, 3200+ix, 0, 2005, \clkibs, 110+ix, \trigphasebus0, 100, \obs0, 3000, \durphase, durphase);

		////// 3) Create an fx
		//////// nodes 3300-
		//////// group 2006

		switch( fxnum,

			0, { //greyhole
				s.sendMsg(\s_new, \greyhole, 3300+ix, 0, 2006, \ibs0, 200, \gateibs0, 3000, \clkibs, 10+ix, \durphase, durphase);
			},

			1, { //decimate
				s.sendMsg(\s_new, \decimate, 3300+ix, 0, 2006, \ibs0, 200, \gateibs0, 3000);
			}
		); //end switch fxnum

		////// 4) Create Animated Graphic in Processing
		// int ix, float rad, float dur, String sclr, int wt

		~proc.sendMsg( "/mktimetrig", ix, 0.5, durphase, fxclrs[fxnum], 15);


	}, "/mkfx");


	SynthDef(\greyhole, {
		arg ibs0, obs=0, gateibs0, clkibs, durphase;

		var ibs = Array.fill(2, {|ix| Array.fill(8,{|ixx| ibs0+(10*ix)+ixx}) });

		var gateibs = Array.fill(2, {|ix| gateibs0+ix});


		var in0 = In.ar(ibs[0],8);
		var in1 = In.ar(ibs[1],8);

		var fx0 = Greyhole.ar(in0, LFTri.kr(0.01).range(0.1, 3.0), LFSaw.kr(0.1).range(0.0, 1.0), LFTri.kr(0.05).range(0.5, 2.5), SinOsc.kr(0.08).range(0.01, 1.0), LFTri.kr(0.005).range(0.1, 1.0));
		var fx1 = Greyhole.ar(in1, LFTri.kr(0.01).range(0.1, 3.0), LFSaw.kr(0.1).range(0.0, 1.0), LFTri.kr(0.05).range(0.5, 2.5), SinOsc.kr(0.08).range(0.01, 1.0), LFTri.kr(0.005).range(0.1, 1.0));


		var gate0 = In.kr(gateibs[0]);
		var gate1 = In.kr(gateibs[1]);

		var env0 = EnvGen.ar(Env.asr(1.25,1,1.25,0),gate0);
		var env1 = EnvGen.ar(Env.asr(1.25,1,1.25,0),gate1);

	//	var pos = (In.kr(clkibs)+(durphase/2.0)).linlin(0.0, 1.0, 0.0, 2.0);

		//fx0 = PanAz.ar(8, fx0, pos);

		Out.ar(obs, fx0*env0);
		Out.ar(obs, fx1*env1);

	}).add;

	SynthDef(\decimate, {
		arg ibs0, obs=0, gateibs0;
		var amp = \amp.kr(0.85, 0.01);
		var rate = LFTri.kr(0.005).range(1000.0, 10000.0);
		var bits = LFTri.kr(0.003).range(1.0, 6.0);

		var ibs = Array.fill(3, {|ix| Array.fill(8,{|ixx| ibs0+(10*ix)+ixx}) });

		var gateibs = Array.fill(3, {|ix| gateibs0+ix});

		//audio in busses
		var in0 = In.ar(ibs[0],8);
		var in1 = In.ar(ibs[1],8);
		var in2 = In.ar(ibs[2],8);

		//gate signals from individual targets/wands
		var gate0 = In.kr(gateibs[0]);
		var gate1 = In.kr(gateibs[1]);
		var gate2 = In.kr(gateibs[2]);

		//envelopes per sig/wand
		var env0 = EnvGen.ar(Env.asr(1.25,1,1.25,0),gate0);
		var env1 = EnvGen.ar(Env.asr(1.25,1,1.25,0),gate1);
		var env2 = EnvGen.ar(Env.asr(1.25,1,1.25,0),gate2);

		var sig0, sig1, sig2;

		//fx per wand
		sig0 = Decimator.ar(in0, rate, bits);
		sig1 = Decimator.ar(in1, rate, bits);
		sig2 = Decimator.ar(in2, rate, bits);

		Out.ar(obs, sig0*env0*amp);
		Out.ar(obs, sig1*env1*amp);
		Out.ar(obs, sig2*env2*amp);
	}).add;


	////SOUNDS SYNTH DEFS
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////

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

		sig = PanAz.ar(8, sig, pos, 1, 2, 0.5);

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
		sig = PanAz.ar(8, sig, pos, 1, 2, 0.5);
		Out.ar(obs, sig*amp*env);
	}).add;

	////JANUS

	SynthDef( \janus, {
		arg obs=0, t_tr=0, amp=0.5, pos;
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
		var sig;
		s1 = Mix.ar(s1);
		s2 = Mix.ar(s2);
		s3 = Mix.ar(s3);

		sig = PanAz.ar(8, (Mix.ar([s1*0.3, s2*0.3, s3*0.3])*fe), pos, 1, 2, 0.5);


		//Out.ar(och, Mix.ar([s1*(1.0/6.0), s2*(1.0/6.0), s3*(1.0/6.0), s1b*(1.0/6.0), s2b*(1.0/6.0), s3b*(1.0/6.0)])*fe);
		Out.ar(obs, sig * amp);
		//Out.ar(0, Mix.ar([s1*(1.0/6.0), s1b*(1.0/6.0)])*fe);
	}).add;

	//////STOCHSYNTH

	SynthDef(\stochsynth, {
		arg obs=0,ampdist = 4.5, durdist = 1.5, adparam = 1, ddparam = 1, minfreq = 50, maxfreq = 6580, ampscale = 1.0, durscale = 0.5, initCPs = 12, knum, mul = 0.5, add = 0, envdur = 2, envdens = 7, atk=0.001, amp = 4.1, rel = 0.5, pos;
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
		var sig;

		sig = PanAz.ar(8, moog, pos, 1, 2, 0.5);

		Out.ar(obs, sig*ampenv*amp);
	}).add;

	//////DRUMLINE

	SynthDef(\drumline, {
		arg rate1=11.0, rate2=10.0, rate3=12.0, gdur=0.03, ffreq=5000, frez=0.5, fr1=300, fr2=12000, amp=1.5, gate=0, dur=0.01, crv=0, pan=0, pos;
		var noise, grainrate1, grainrate2, grainrate3, grainenv1, grainenv2, grainenv3, filterednoise1, filterednoise2, filterednoise3, freqchgrate1, freqchgrate2, freqchgrate3, s1, s2, s3, output, oenv, envtrig, atk, sig;
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

		sig = PanAz.ar(8, output, pos, 1, 2, 0.5);

		Out.ar(0, sig*amp*oenv);
	}).add;

	//////KRUNKD

	SynthDef(\krunkd, {
		arg obs=0, rate=0.7, res=9.8, igain=0.01, type=0, nl=0.33, f1=200, f2=210, decay=0.9, amp=0.5, rq=0.006, atk=0.001, rel=0.5, crv = -4, pan=0, pos;
		var filter, impulse, ftrig, filter2, output, f1b, f2b, freq, oenv,sig;
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
		sig = PanAz.ar(8, output, pos, 1, 2, 0.5);

		Out.ar(obs, sig*amp*oenv);
	}).add;

	//////TBONE

	SynthDef( \tbone, {
		arg obs=0, pitch=60, amp=0.87, dur=3, t_tr=1, ffreq1=500, ffreq2=5000, q1=0.1, q2=0.7, sigamp=0.85, filtersigamp=0.3, fatk=0.3, fsus=0.3, frel=0.4, mq=0.7, mflo=500, mfhi=10000, t60=1, damp=0.5, sz=1, pos;
		var freq = pitch.midicps;
		var osc1, osc2, osc3, osc4;
		var sig, filtersig, sig1, sig2, env, fenv;
		env = EnvGen.ar(Env.perc(0.01, dur), t_tr, doneAction:2);
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
		fenv = (EnvGen.kr(Env.linen(fatk*dur, fsus*dur, frel*dur,), t_tr)*mfhi)+mflo;
		sig = RLPF.ar(sig, fenv, mq);
		sig = JPverb.ar(sig,10,0,0.3);
		sig = Mix.ar(sig*0.5);

		sig = PanAz.ar(8, sig, pos, 1, 2, 0.5);

		Out.ar(obs,sig*amp*env);
	}).add;

	//// END SYNTH DEFS
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////

	0.1.wait;

	//// INITIAL SYNTHS
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////



}}//end fork and s.waitForBoot
)

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
//LEGEND

////PatchBay
/////// Node 3999
/////// Sounds Go Out Audio Busses 200
/////// Patch Bay sends them back out Audio Channels depending on speaker config

//// Phasorclocks
////// nodes 3000-3099; Control Busses 0-99; Audio Busses 100-199; Group 2001

//// Timedtriggers
////// nodes 4000-9999; Group 2003

//// Phasectl
////// nodes 5000-5999; Group 2002; Control Busses 1000-1999

//// fx
////// nodes 6000-6999; Group 2005; Control Busses 2000-2999
////// phasor clocks at nodes 3010-, control busses 10-, audio busses 110-, group 2001


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

////



//////////////////////////////////////////////////////////////////////////

/////////////////  WORKFLOW //////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////

// 4 Phasor Clocks are created on startup
////// Nodes 3000-3003
////// Group 2001
////// Audio rate signals out audiobusses 100-103
////// Control rate signals out controlbusses 0-3


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////