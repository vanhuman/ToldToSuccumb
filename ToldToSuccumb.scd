// Werkplan:
// 1. testen van registers
// 2. testen crescendo/decrescendo
// 3. maak subgroepen van registers die bij elkaar passen (variaties) in globale arrays

// for using event type, see bottom

(
// SETUP -----------------------------------------------------------------

Document.current.createBackup;

~hw = [37,38,39,40,41,42,43,44,46,47,48,51,52,57,58,59,60,61,63,64];
~sp = [75,76,77,78,79,80,81,82,83,84,85,86,88,92,95,96,97,98,99,100];
~sw = [112,113,114,115,116,117,118,119, 120,121,122,124,125,127,128,129,130,131,132,133];
~so = [165,166,172,173,174,175,176,177];
~p = [1,2,3,4,5,6,7,8,10,11,12,16,17,18,20,21,22,23,24,25,26];

~hwc = [222,223,224,225,226,227,229,232,235,236,237,238];
~swc = [199,200,201,202,203,204,205,206,207,208,209,210,212,213,214];
~pc = [245,246,248,249,250,251,252,253,254,255,256,258,259,260];

~hwf = [179,180,181,182,183,184,185,186,187,188,189,191,192,193];
~pf = [268,269,270,271];
)


// TESTING -----------------------------------------------------------------

Pdef(\organNotesTest).play;
(
k = (20..40).scramble;
Pdef(\organNotesTest, {
	Pbind(
		\amp, 0,
		\dur, Prand([0.5, 1, 2], inf),
		\note1, Pseq(k, inf),
		\bo, Pfunc { |evt|
			~o.noteLen(0, 1, evt[\note1], evt[\dur] * 0.95);
		},
	)
});
)
Pdef(\organNotesTest).stop;

~o.reg(0, 1, 1)

Pdef(\organRegsTest).play;
(
m = ~p;
Pdef(\organRegsTest, {
	Pbind(
		\amp, 0,
		\dur, 1,
		\reg1, Pseq(m, inf),
		\bo, Pfunc { |evt|
			~o.reg(0, 1, evt[\reg1]);
		},
	)
});
)
Pdef(\organRegsTest).stop;

Pdef(\organRegsCresc).play;
(
t = ~p;
u = t.reverse; u = u.collect { |reg| reg.neg };
Pdef(\organRegsCresc, {
	Pbind(
		\amp, 0,
		\dur, 0.2,
		\reg1, Pseq(t ++ u, inf),
		\bo, Pfunc { |evt|
			~o.regAdd(0, 1, evt[\reg1]);
		},
	)
});
)
Pdef(\organRegsCresc).stop;




// PANIC -----------------------------------------------------------------
~o.stopAllNotes;
~o.clearAllRegs;



// STRUCTURE -----------------------------------------------------------------

// start with organ solo
~o.reg(0, 1, 1); // which registers? vary manually, sometimes in sync with notes
~o.regAdd(0, 1, 2);

~o.note(0,1,30,127);

~o.note(0,1,30,0);
~o.reg(0, 1, 1);
~o.note(0,1,32,127);

~o.note(0,1,32,0);
~o.note(0,1,30,127);

~o.note(0,1,30,0);
~o.note(0,1,36,127);

~o.note(0,1,36,0);
~o.note(0,1,32,127);

~o.note(0,1,32,0);
~o.note(0,1,30,127);

// vary registers: play with rhythm of changes, number of random registers
Pdef(\organRegs).play;
(
a = ~p; // determine which subgroups of registers
b = ~hw;
c = ~sp;
d = ~sw;
Pdef(\organRegs, {
	Pbind(
		\amp, 0,
		\dur, Pwhite(10.0, 14, inf),
		// \dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1].normalizeSum * 5, inf), // boom durations
		// \dur, Pseq([
		//  Pwrand([Pwhite(5, 10.0, 1), Pwhite(0.2, 0.05, Pstutter(Pwhite(4, 12, 1), 1))], [0.8, 0.2], 1),
		// 	Pwhite(0.5, 0.6, 1)
		// ], inf),
		\reg1, Ptuple(Prand(a, inf)!1), // registers pedals
		\reg2, Ptuple(Prand(b, inf)!1), // registers man I
		\reg3, Ptuple(Prand(c, inf)!1), // registers man II
		\reg4, Ptuple(Prand(d, inf)!1), // registers man III
		\bo, Pfunc { |e|
			e[\dur].postln;
			~o.reg(0, 1, e[\reg1].asSet.asArray);
			// ~o.reg(1, 1, e[\reg2].asSet.asArray);
			// ~o.reg(2, 1, e[\reg3].asSet.asArray);
			// ~o.reg(3, 1, e[\reg4].asSet.asArray);
		},
	)
});
)
Pdef(\organRegs).stop;

// a gritty drone // multichannel expansion, amplitude modulation
// first only base
Ndef(\dron1).play.fadeTime_(0.1);
(
Ndef(\dron1, {
	var sig, sig1, sig2, env, envGen;
	~base = 30;
	env = Env.rcurve2(200, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.5, 0.5]);
	// env = Env.rcurve2(200, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.9, 0.1]);
	envGen = EnvGen.kr(env);

	sig1 = Splay.ar(LFPulse.ar([(~base + 0).midicps * 1, ~base.midicps * 1, ~base.midicps * 1, (~base + 0).midicps * 16],
		mul: [0.2, 0.2, 0.2, 0.2]));
	// sig1 = Splay.ar(LFPulse.ar([(~base + 2).midicps * 15, ~base.midicps * 12, ~base.midicps * 3, (~base + 6).midicps * 16],
	sig2 = SinOsc.ar([~base.midicps, (~base + 0).midicps] * LFNoise1.kr(0.3).range(0.97, 1.03), mul: 0.7);
	// sig2 = SinOsc.ar([~base.midicps, (~base + 5).midicps] * LFNoise1.kr(0.3).range(0.97, 1.03), mul: 0.7);

	sig = sig1 + sig2 + BrownNoise.ar(0.1, mul: 0.05);
	sig = sig * envGen * 0.6;
	sig
});
)
Ndef(\dron1).release

~o.note(0,1,30,0);
Pdef(\organ1).play;
// first only base and no jitter
(
Pdef(\organ1, {
	~base = 30;
	Pbind(
		\amp, 0,
		\dur,
		Pseq([
			Pwhite(10.0, 12.0, 3),
			Pseq([
				Pwrand([Pwhite(10.0, 12.0, 1), Pwhite(0.2, 0.05, Pstutter(Pwhite(4, 12, 1), 1))], [0.5, 0.5], 1),
				Pwhite(1, 2.0, 1)
			], inf)
		], 1),
		\freq1, Prand([~base, ~base + 0, ~base + 6], inf),
		\freq2, Prand([~base, ~base + 2, ~base + 6] + 12, inf),
		\freq3, Prand([~base, ~base + 2, ~base + 6] + 24, inf),
		\freq4, Prand([~base, ~base + 2, ~base + 6], inf),
		// \freq1, Prand([~base, ~base + 1, ~base + 5], inf),
		\bo, Pfunc { |evt|
			var dur = evt[\dur];
			~o.noteLen(0, nil, evt[\freq1], dur * 0.99);
			// ~o.noteLen(1, nil, evt[\freq2], dur * 0.99);
			~o.noteLen(2, nil, evt[\freq3], dur * 0.99);
			// ~o.noteLen(3, nil, evt[\freq4], dur * 0.99);
		},
	)
});
)
Pdef(\organ1).stop;

// add jitter to organ1
// add overtones in organ1 and dron1
// play with base

// something to create a sense of time // multichannel expansion
// make sure register changes are in same rythm
(
SynthDef(\boom, {
	arg level = 1, gate = 1;
	var sigKick;
	sigKick = 0.7 * SinOsc.ar( XLine.kr([800, 900],[50, 55], 0.02) * LFNoise1.kr(30).range(0.97, 1.03) );
	sigKick = Splay.ar(sigKick);
	sigKick = sigKick * EnvGen.kr(Env.new([0,1,0],[0.01, 1]), doneAction: 2);
	Out.ar(0, sigKick * level);
}).add;
)

Pdef(\boomPattern2).play;
(
Pdef(\boomPattern2,
	Pbind(
		\instrument, \boom,
		\dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1].normalizeSum * 5, inf),
		\level, Pseq([3,2,3] * 0.6, inf),
	)
);
)
Pdef(\boomPattern2).stop;

// play that sample // multichannel expansion, amplitude modulation, low pitch
(
Ndef(\sample).play.fadeTime_(0.1);
b.free;
b = Buffer.alloc(s, 44100 * 60, 2);
b.read("/Users/Robert/---data---/Temp/Zaal100/ob we cannot turn back.aiff");
)
// Dialog.openPanelAndLoad(b)
(
Ndef(\sample, {
	var sig2, sig, env, playhead, start, end;
	start = [5, 5.1] * 44100 ;
	end = 2 * 44100 + start;
	playhead = Phasor.ar(1, [0.9, 0.91], start, end);
	sig = BufRd.ar(2, b, playhead);
	sig = sig * SinOsc.kr(10);
	sig * 0.5
})
)
Ndef(\sample).release

// sample to very low

Ndef(\dron1).stop

Pdef(\organ1).stop;
Pdef(\organRegs).stop;
~o.stopAllNotes;
~o.clearAllRegs;

// a slower rhythm
Ndef(\dron2).play.fadeTime_(0.1);
(
Ndef(\dron2, {
	var sig, levels, times, env, envGen;
	~base = 30;
	env = Env.rcurve(50, [0.1, 2], [0.01, 0.2]);
	envGen = EnvGen.kr(env);

	sig = Splay.ar(SinOscFB.ar(
		[~base.midicps * 6, (~base + 2).midicps, (~base + 6).midicps * 3, ~base.midicps * 12],
		SinOsc.kr(0.1).range(0,1), mul: [1,2,1]));
	sig = sig * LFPulse.kr(SinOsc.kr(0.3).range(5, 50));
	// sig = sig * Impulse.kr(SinOsc.kr(0.3).range(5, 50), mul: 3);
	sig * envGen * 0.3
});
)
Ndef(\dron2).stop

Pdef(\boomPattern2).stop;

// high notes with only dron2
~o.reg(3, 1, 1); // find out which registers or combinations
~o.regAdd(3, 1, 1);

~o.note(3,1,30 + 60,127);
Ndef(\sample).stop

~o.note(3,1,30 + 60,0);
~o.note(3,1,30 + 60 + 2,127);

~o.note(3,1,30 + 60 + 2,0);
~o.note(3,1,30 + 60,127);

~o.note(3,1,30 + 60,0);
~o.note(3,1,30 + 60 + 6,127);

~o.note(3,1,30 + 60 + 6,0);
~o.note(3,1,30 + 60,127);

Pdef(\organRegs).play;
(
a = ~p; // determine which subgroups of registers
b = ~hw;
c = ~sp;
d = ~sw;
Pdef(\organRegs, {
	Pbind(
		\amp, 0,
		// \dur, Pwhite(10.0, 14, inf),
		// \dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1].normalizeSum * 5, inf), // boom durations
		\dur, Pseq([
		 Pwrand([Pwhite(5, 10.0, 1), Pwhite(0.2, 0.05, Pstutter(Pwhite(4, 12, 1), 1))], [0.8, 0.2], 1),
			Pwhite(0.5, 0.6, 1)
		], inf),
		\reg1, Ptuple(Prand(a, inf)!3), // registers pedals
		\reg2, Ptuple(Prand(b, inf)!1), // registers man I
		\reg3, Ptuple(Prand(c, inf)!2), // registers man II
		\reg4, Ptuple(Prand(d, inf)!2), // registers man III
		\bo, Pfunc { |e|
			e[\dur].postln;
			~o.reg(0, 1, e[\reg1].asSet.asArray);
			// ~o.reg(1, 1, e[\reg2].asSet.asArray);
			// ~o.reg(2, 1, e[\reg3].asSet.asArray);
			~o.reg(3, 1, e[\reg4].asSet.asArray);
		},
	)
});
)
Pdef(\organRegs).stop;

~o.reg(0, 1, 1); // find out which registers or combinations
~o.regAdd(0, 1, 1);
Pdef(\messiaen).play;
(
Pdef(\messiaen, {
	~base = -12;
	// ~notes = ["C#2", "Bb1", "A1", "G1", "F#1", "Eb1", "D1", "C#1", "Bb0", "A0", "B0", "Bb0", "A0", "C#1", "G0"];
	~notes = [ 49, 46, 45, 43, 42, 39, 38, 37, 34, 33, 35, 34, 33, 37, 31 ].reverse.mirror1 - 1 + ~base;
	// ~notes = [ 49, 46, 45, 43, 42, 39, 38, 37, 34, 33, 35, 34, 33, 37, 31 ] - 1 + ~base; // original
	~durs = [ 4, 4, 2, 2, 1, 4, 4, 2, 2, 1, 8, 2, 2, 3, 12].scramble.normalizeSum * 4/0.3;
	// ~durs = [ 4, 4, 2, 2, 1, 4, 4, 2, 2, 1, 8, 2, 2, 3, 12].normalizeSum * 4/0.3; // original
	// ~durs = [ 4, 4, 2, 2, 1, 4, 4, 2, 2, 1, 8, 2, 2, 3, 120] * 4/0.3 * 0.02; // at the end
	Pbind(
		\amp, 0,
		\dur, Pseq(~durs, inf),
		\freq1, Pseq(~notes, inf),
		\bo, Pfunc { |e|
			e[\dur].postln;
			~o.noteLen(0, nil, e[\freq1], e[\dur] * 0.99);
			// ~o.noteLen(1, nil, e[\freq1], e[\dur] * 0.99);
			// ~o.noteLen(2, nil, e[\freq1], e[\dur] * 0.99);
		},
	)
});
)
Pdef(\messiaen).stop;

// play with messiaen timing and base?

// NOISE please
Ndef(\burst).play.fadeTime_(0.1);
(
Ndef(\burst, {
	var sig, sig1, sig2, env, envGen;
	env = Env.rcurve2(2000, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.9, 0.1]);
	envGen = EnvGen.kr(env);

	sig = [ClipNoise.ar(0.9), BrownNoise.ar(0.9)];
	sig = RLPF.ar(sig, LFNoise0.kr(1.5).range(20000, 50000), LFNoise0.kr(1).range(0.6, 0.9));
	sig = sig * envGen;
	sig = sig * TWChoose.kr(Impulse.kr(2), [0,1], [0.8, 0.2]);
	sig
});
)
Ndef(\burst).release

//  a serene voice in there - or leave out completely?
Ndef(\sine).play.fadeTime_(1)
(
Ndef(\sine, {
	Splay.ar(SinOsc.ar([100, 1001, 500, 501, 102, 1198])) * 0.1
})
)
Ndef(\sine).release

// in sync with messiaen
Ndef(\massCom).play.fadeTime_(0.1);
(
Ndef(\massCom, {
	var sig, env, curve, amp, freq, hasFreq, noise, max;
	~base = 30 + 12;
	max = (~base + 2).midicps;
	env = Env.new([
		[(~base + 2).midicps, (~base + 2).midicps * 1.02],
		[~base.midicps, ~base.midicps] * 1.02,
		[~base.midicps, ~base.midicps * 1.02],
		[(~base - 4).midicps, (~base - 4).midicps * 1.02],
		[(~base - 8).midicps, (~base - 8).midicps * 1.03 ]
	],
	[0.2, 1.55, 0.03333, 1.55]).circle;
	curve = EnvGen.kr(env, 1, doneAction: 2);
	sig = LFSaw.ar(curve);
	amp = thresh(Amplitude.kr(sig[0], 0.05, 0.05), 0.01);
	# freq, hasFreq = Pitch.kr(sig[0]);
	noise = BPF.ar(PinkNoise.ar(LFNoise1.kr(0.2).range(4,20)), max(freq, max) * 32, 0.9, mul: amp).dup();
	sig = sig + noise;
	sig = sig * Line.kr(0,1,60); // fade in!
	sig * 0.2
})
)
Ndef(\massCom).release;

// stop dron2 on burst
Ndef(\dron2).stop

Ndef(\burst).release

Ndef(\ruis).play.fadeTime_(1)
(
Ndef(\ruis, {
	var sig, sig1, sig2;
	// sig1 = GrayNoise.ar(0.3);
	sig1 = Dust.ar(100);
	sig2 = PinkNoise.ar(0.2);
	sig1 = RLPF.ar(sig1, 1500, 0.9);
	sig2 = RLPF.ar(sig2, 500, 0.9);
	sig = sig1 + sig2;
	sig = Pan2.ar(sig, LFNoise1.kr(0.2).range(-1,1));
	sig
});
)
Ndef(\ruis).release;
Ndef(\sine).release;
Pdef(\organRegs).stop;



///////////////////////////////////////////
// // when using event type, the note on in noteLen should have a defer() - at least, for the OSC it seems, but maybe it is the OSC monitor?
// x = ~o;
// Event.addEventType(\organ_note, {
// 	x.noteLen(0, 1, ~note.value, ~dur.value * 0.75);
// });

// Pdef(\organNotesTest).play;
// (
// k = (20..40).scramble;
// Pdef(\organNotesTest, {
// 	Pbind(
// 		\type, \organ_note,
// 		\dur, Prand([2], inf),
// 		\note, Pseq(k, inf),
// 	)
// });
// )
// Pdef(\organNotesTest).stop;


