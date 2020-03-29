// for using event type, see bottom

(
// SETUP -----------------------------------------------------------------

Document.current.createBackup;

~r1 = [1,2,3,4,5,7,8]; // sub
~r2 = [10,12,24,22,23] ++ [59,60,61]; // sub bit harsher and louder
~r3 = [172,173,174,175]; // low loud
~r4 = [16,17,18] ++ [46,47,48,51,52]; // higher, thinnish
~r5 = [40,41,42,43,44]; // subdued
~r6 = [165,166,176,177]; // low softer
~r7 = [95,96,97,98,99,100]; // nasal
~r8 = [118,119,121,122,124,125,127,132]; // soft gentle

~rf1 = [179,180,181,182,183,184,188,189];
~rf2 = [191,192,193];

if (v.isNil) { v = s.volume; v.setVolumeRange(-90, 12); v.volume = -16; v.gui; };

~o.stopAllNotes;
Pdef(\organRegs).stop;
{ ~o.clearAllRegs(2) }.defer(0.5);

// 0 = pedal
// 1 = swellwerk
// 2 = swellpos
// 3 = hauptwerk
// 4 = clarinet
// 5 = fernwerk
// 6 = phisharminonica
// 7 - 11 swell
[0,1,2,3,4,5,6,7,8,9,10,11].do { |section|
	~o.sped(section, 127);
}
// ~o.sped(6, 0);
)

// PANIC -----------------------------------------------------------------
~o.stopAllNotes;
~o.clearAllRegs(2);


// STRUCTURE -----------------------------------------------------------------

// !!!!!!!!!!!!!!!!! RECORDING!!!!!!!!!!!!!!!!!!

// start with organ solo, add registers every round
~o.reg(0, 1, 1);
~o.regAdd(0, 1, [42, 44]);
~o.regAdd(0, 1, 3);

~o.note(0,1,42,127);

~o.note(0,1,42,0);
~o.note(0,1,44,127);

~o.note(0,1,44,0);
~o.note(0,1,42,127);

~o.note(0,1,42,0);
~o.note(0,1,48,127);

~o.note(0,1,48,0);
~o.note(0,1,44,127);

~o.note(0,1,44,0);
~o.note(0,1,42,127);


~o.note(2,1,42,127);

// vary registers: play with rhythm of changes, number of random registers
Pdef(\organRegs).play;
(
a = ~r1;
b = ~r6; // r2 loud, r3 loud, r6
c = ~r4; // r4, r5
d = ~r7; // r7, r8, rf1, rf2
Pdef(\organRegs, {
	Pbind(
		\amp, 0,
		\dur, Pwhite(10.0, 14, inf) * 2,
		// \dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1].normalizeSum * 5, inf), // boom durations
		// \dur, Pseq([
		// 	Pwrand([Pwhite(5, 10.0, 1), Pwhite(0.2, 0.05, Pstutter(Pwhite(4, 12, 1), 1))], [0.5, 0.5], 1),
		// 	Pwhite(0.5, 0.6, 1)
		// ], inf),
		\reg1, Ptuple(Prand(a, inf)!2), // registers pedals
		\reg2, Ptuple(Prand(b, inf)!2), // registers man I
		\reg3, Ptuple(Prand(c, inf)!2), // registers man II
		\reg4, Ptuple(Prand(d, inf)!2), // registers man III
		\bo, Pfunc { |e|
			("Change registrations" + e[\dur].round(0.01).asString + "sec").postln;
			~o.reg(0, 1, e[\reg1].asSet.asArray);
			~o.reg(1, 1, e[\reg2].asSet.asArray);
			~o.reg(2, 1, e[\reg3].asSet.asArray);
			~o.reg(3, 1, e[\reg4].asSet.asArray);
		},
	)
});
)
// Pdef(\organRegs).stop;

Ndef(\dron1).play.fadeTime_(0.1);
(
Ndef(\dron1, {
	var sig, sig1, sig2, env, envGen;
	~base = 30;
	env = Env.rcurve2(200, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.5, 0.5]);
	// env = Env.rcurve2(200, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.9, 0.1]);
	envGen = EnvGen.kr(env);

	sig1 = Splay.ar(LFPulse.ar([(~base + 0).midicps * 1, ~base.midicps * 1, ~base.midicps * 1, (~base + 0).midicps * 1],
		mul: [0.2, 0.2, 0.2, 0.2]));
 // sig1 = Splay.ar(LFPulse.ar([(~base + 2).midicps * 15, ~base.midicps * 12, ~base.midicps * 3, (~base + 6).midicps * 16],
	sig2 = SinOsc.ar([~base.midicps, (~base + 0).midicps] * LFNoise1.kr(0.3).range(0.97, 1.03), mul: 0.5);
 // sig2 = SinOsc.ar([~base.midicps, (~base + 5).midicps] * LFNoise1.kr(0.3).range(0.97, 1.03), mul: 0.5);

	sig = sig1 + sig2 + BrownNoise.ar(0.1, mul: 0.05);
	sig = sig * envGen * 0.6;
	sig
});
)
// Ndef(\dron1).release

~o.note(0,1,42,0);
~o.note(2,1,42,0);
Pdef(\organ1).play;
(
Pdef(\organ1, {
	~base = 42;
	Pbind(
		\amp, 0,
		\dur,
		Pseq([
			Pwhite(10.0, 12.0, 3),
			Pseq([
				Pwrand([Pwhite(10.0, 12.0, 1), Pwhite(0.2, 0.1, Pstutter(Pwhite(4, 12, 1), 1))], [0.9, 0.1], 1),
				Pwhite(1, 2.0, 1)
			], inf)
		], 1),
		\freq1, Prand([~base, ~base + 0, ~base + 6], inf),
		\freq2, Prand([~base, ~base + 2, ~base + 6], inf),
		\freq3, Prand([~base, ~base + 2, ~base + 6] + 24, inf),
		\freq4, Prand([~base, ~base + 2, ~base + 6] + 12, inf),
		// \freq1, Prand([~base, ~base + 1, ~base + 5], inf),
		\bo, Pfunc { |evt|
			var dur = evt[\dur];
			~o.noteLen(0, nil, evt[\freq1], dur * 0.99);
			// ~o.noteLen(1, nil, evt[\freq2], dur * 0.99);
			// ~o.noteLen(2, nil, evt[\freq3], dur * 0.99);
			// ~o.noteLen(3, nil, evt[\freq4], dur * 0.99);
		},
	)
});
)
// Pdef(\organ1).stop;

// add overtones in organ1 and dron1
// play with base

// take organ1 down

// registers r7
Pdef(\organ2).play;
(
Pdef(\organ2, {
	~base = 78;
	Pbind(
		\amp, 0,
		\dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1].normalizeSum * 5 / 4, inf), // boom durations
		\freq4, Prand([~base, ~base + 2, ~base + 6, ~base + 8], inf),
		\bo, Pfunc { |evt|
			var dur = evt[\dur];
			~o.noteLen(3, nil, evt[\freq4], dur * 0.99);
		},
	)
});
)
// Pdef(\organ2).stop;

(
SynthDef(\boom, {
	arg level = 1, gate = 1;
	var sigKick;
	sigKick = 0.7 * SinOsc.ar( XLine.kr([1800, 1900],[50, 51], 0.02) * LFNoise1.kr(30).range(0.97, 1.03) );
	sigKick = Splay.ar(sigKick);
	sigKick = sigKick * EnvGen.kr(Env.new([0,1,0],[0.01, 1]), doneAction: 2);
	Out.ar(0, sigKick * level);
}).add;
)
(
Pdef(\boomPattern2,
	Pbind(
		\instrument, \boom,
		\dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1].normalizeSum * 5, inf),
		\level, Pseq([3,2,3] * 0.6, inf),
	)
);
)
// set drone1 low end *6, then:
Pdef(\boomPattern2).play;
Pdef(\organ2).play;

// let it run for a while, then:
Pdef(\organ2).stop;

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
// Ndef(\sample).release

// sample to very low

Ndef(\dron1).stop

Pdef(\organ1).stop;

// a slower rhythm
// Ndef(\dron2).play.fadeTime_(0.1);
// (
// Ndef(\dron2, {
// 	var sig, levels, times, env, envGen;
// 	~base = 30;
// 	env = Env.rcurve(50, [0.1, 2], [0.01, 0.2]);
// 	envGen = EnvGen.kr(env);
//
// 	sig = Splay.ar(SinOscFB.ar(
// 		[~base.midicps * 6, (~base + 2).midicps, (~base + 6).midicps * 3, ~base.midicps * 12],
// 	SinOsc.kr(0.1).range(0,1), mul: [1,2,1]));
// 	sig = sig * LFPulse.kr(SinOsc.kr(0.3).range(5, 50));
// 	// sig = sig * Impulse.kr(SinOsc.kr(0.3).range(5, 50), mul: 3);
// 	sig * envGen * 0.3
// });
// )
// Ndef(\dron2).stop

// play with pitch boom
Pdef(\boomPattern2).stop;

// Ndef(\sine).play.fadeTime_(1)
(
Ndef(\sine, {
	Splay.ar(SinOsc.ar([100, 1001, 500, 501, 102, 1198])) * 0.1 // LFPulse.kr(10)
})
)
// Ndef(\sine).release

// high notes set regs to ~r7++~rf1 !!!!!!!!!!
~o.note(3,1,90,127);
Ndef(\sine).play.fadeTime_(1);
Ndef(\sample).stop;

~o.note(3,1,90,0);
~o.note(3,1,90 + 2,127);

~o.note(3,1,90 + 2,0);
~o.note(3,1,90,127);

~o.note(3,1,90,0);
~o.note(3,1,90 + 6,127);

~o.note(3,1,90 + 6,0);
~o.note(3,1,90 + 2,127);

~o.note(3,1,90 + 2,0);
~o.note(3,1,90,127);

// stop organRegs for manuals 0, 1, 2 !!!!!!!!!! AND RELOAD

~o.reg(0, 1);
~o.reg(1, 1);
~o.reg(2, 1);

~o.reg(0, 1, [1,7]); // 52, 96, 99
~o.regAdd(0, 1, 99);

~o.reg(1, 1, [59,61]); //21,22,23,24,59,61
~o.regAdd(1, 1, 21);

~o.reg(2, 1, [191,192,193]); // [179,180,181,182,183,184,188,189]

~o.note(3,1,90,0);

// set sine to LFpulse

Pdef(\messiaen).play;
(
Pdef(\messiaen, {
	~base = 12;
	// ~notes = ["C#2", "Bb1", "A1", "G1", "F#1", "Eb1", "D1", "C#1", "Bb0", "A0", "B0", "Bb0", "A0", "C#1", "G0"];
	~notes = [ 49, 46, 45, 43, 42, 39, 38, 37, 34, 33, 35, 34, 33, 37, 31 ].reverse.mirror1 - 1 + ~base;
	// ~notes = [ 49, 46, 45, 43, 42, 39, 38, 37, 34, 33, 35, 34, 33, 37, 31 ] - 1 + ~base; // original
	~durs = [ 4, 4, 2, 2, 1, 4, 4, 2, 2, 1, 8, 2, 2, 3, 12].scramble.normalizeSum * 4/0.3;
	// ~durs = [ 4, 4, 2, 2, 1, 4, 4, 2, 2, 1, 8, 2, 2, 3, 12].normalizeSum * 4/0.3; // original
	// ~durs = [ 4, 4, 2, 2, 1, 4, 4, 2, 2, 1, 8, 2, 2, 3, 60] * 4/0.3 * 0.017; // at the end
	Pbind(
		\amp, 0,
		\dur, Pseq(~durs, inf),
		\freq1, Pseq(~notes, inf),
		\bo, Pfunc { |e|
			~o.noteLen(0, nil, e[\freq1], e[\dur] * 0.99);
			~o.noteLen(1, nil, e[\freq1], e[\dur] * 0.99);
			~o.noteLen(2, nil, e[\freq1], e[\dur] * 0.99);
		},
	)
});
)
// Pdef(\messiaen).stop;

// play with messiaen timing and base

// Ndef(\burst).play.fadeTime_(0.1);
// (
// Ndef(\burst, {
// 	var sig, sig1, sig2, env, envGen;
// 	env = Env.rcurve2(2000, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.9, 0.1]);
// 	envGen = EnvGen.kr(env);
//
// 	sig = [ClipNoise.ar(0.9), BrownNoise.ar(0.9)];
// 	sig = RLPF.ar(sig, LFNoise0.kr(1.5).range(20000, 50000), LFNoise0.kr(1).range(0.6, 0.9));
// 	sig = sig * envGen;
// 	sig = sig * TWChoose.kr(Impulse.kr(2), [0,1], [0.8, 0.2]);
// 	sig
// });
// )
// Ndef(\burst).release

// DO NOT LOAD BEFORE PLAY!
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
	noise = BPF.ar(PinkNoise.ar(LFNoise1.kr(0.2).range(4,20)), max(freq, max) * 32, 0.9, mul: amp * 0.5).dup();
	// sig = sig + noise;
	sig = sig * Line.kr(0,1,120); // fade in!
	sig * 0.3
})
)
// Ndef(\massCom).release;

// take down messiaen when massCom gets louder
// play with messiaen, also putting it only in fernwerk
// add bit of noise to massCom

// Ndef(\burst).release

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
// fade out MassCom
// take up messiaen too a climax, then to the end
Pdef(\messiaen).stop;

Ndef(\ruis).fadeTime_(10);
Ndef(\sine).fadeTime_(10);

Ndef(\ruis).release;
Ndef(\sine).release;
Pdef(\organRegs).stop;


// PANIC -----------------------------------------------------------------
~o.stopAllNotes;
~o.clearAllRegs(2);








// TESTING -----------------------------------------------------------------

Pdef(\organNotesTest).play;
(
k = (60..110);
Pdef(\organNotesTest, {
	Pbind(
		\amp, 0,
		// \dur, Prand([0.5, 1, 2], inf),
		\dur, 1,
		\note1, Pseq(k, inf),
		\bo, Pfunc { |evt|
			~o.noteLen(0, 1, evt[\note1], evt[\dur] * 0.95);
		},
	)
});
)
Pdef(\organNotesTest).stop;

~o.reg(0, 1, [1,6,7]])

~o.note(3,1,44,127);

Pdef(\organRegsTest).play;
(
m = ~r7;
Pdef(\organRegsTest, {
	Pbind(
		\amp, 0,
		\dur, 0.5,
		\reg1, Pseq(m, inf),
		\bo, Pfunc { |evt|
			~o.reg(3, 1, evt[\reg1]);
		},
	)
});
)
Pdef(\organRegsTest).stop;

Pdef(\organRegsCresc).play;
(
t = ~r1++~r2++~r3++~r4++~r5++~r6++~r7++~r8;
u = t.reverse; u = u.collect { |reg| reg.neg };
Pdef(\organRegsCresc, {
	Pbind(
		\amp, 0,
		\dur, 0.1,
		\reg1, Pseq(t ++ u, inf),
		\bo, Pfunc { |evt|
			~o.regAdd(0, 1, evt[\reg1]);
		},
	)
});
)
Pdef(\organRegsCresc).stop;


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


