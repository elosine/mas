(
SynthDef( \puffdaddy, {
	//add a freq arg
	arg obs=0, t_tr=0, ivc = #[3,10,14,23,28,31,32], il1=1.27,d1=0.17, il2=1.2,d2=0.14, il3=1.3,d3=0.22, il4=1.12,d4=0.11, il5=1.24,d5=0.25, il6=0.14,d6=0.19, il7=0.3,d7=0.22, pos=0, wd=2, rq=0.08, amp=1, rt=0.1, dp=0.5;
	var iv1 = [3,10,2,11,4,7,8], iv2= [1,4,5,6,7,10,11], iv3= [1,6,11,5,7, 12,18], iv4= [4,6,8,10,11,2,5];
	var imp, p1,p2,p3,p4,p5,p6,p7, ivs, iv, pd1,pd2,pd3,pd4,pd5,pd6,pd7, c1,c1d, c2,c2d, c3,c3d, c4,c4d, c5,c5d, c6,c6d, c7,c7d, sig;
	var st2,st3,st4,st5,st6,st7;
	var lfo1;
	var hp;
	var pd1b;
	var env = EnvGen.ar(Env.linen(0.01, il1*2, 0.1),t_tr, doneAction:2);
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
	//sig = Mix.ar([ c1*(1.0/3.0), c1d*(1.0/3.0),  c2*(1.0/3.0),c2d*(1.0/3.0), c3*(1.0/3.0),c3d*(1.0/3.0), c4*(1.0/4.0),c4d*(1.0/3.0), c5*(1.0/3.0),c5d*(1.0/3.0), c6*(1.0/3.0),c6d*(1.0/3.0), c7*(1.0/3.0),c7d*(1.0/3.0) ]);
	sig = Mix.ar([c1, c1d, c2, c2d, c3, c3d, c4, c4d, c5, c5d, c6, c6d, c7, c7d]);

	hp = RHPF.ar(sig, SinOsc.kr(0.03).range(3000, 12000), rq);
	hp = JPverb.ar(hp, rt, dp);
	hp = Mix.ar(hp);

	sig = RLPF.ar(sig, SinOsc.kr(0.03).range(1200, 12000), rq);
	sig = Mix.ar([sig, hp*0.03]);

	//sig = PanAz.ar(8, Mix.ar([sig, hp*0.33]), pos, 1, wd, 0.5);
	//sig = PanAz.ar(8, sig, pos, 1, wd, 0.5);
	//sig = PanAz.ar(8, sig, SinOsc.kr(0.03), 1, wd, 0.5);
	//sig = PanAz.ar(8, Mix.ar([sig, JPverb.ar(hp, rt, dp)*0.33]), SinOsc.kr(0.03), 1, wd, 0.5);
	//sig = Mix.ar([sig, hp*0.02]);
	Out.ar(obs, sig*amp);
}).add;
)

a = Synth(\puffdaddy, [\t_tr, 1, \obs, 0]);
s.meter