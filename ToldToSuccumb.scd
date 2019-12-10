

// start with organ solo
// vary registers
~bo.note(0,1,30,127);

~bo.note(0,1,30,0);
~bo.note(0,1,31,127);

~bo.note(0,1,31,0);
~bo.note(0,1,30,127);

~bo.note(0,1,30,0);
~bo.note(0,1,35,127);

~bo.note(0,1,35,0);
~bo.note(0,1,31,127);

~bo.note(0,1,31,0);
~bo.note(0,1,30,127);


// a gritty drone // multichannel expansion, amplitude modulation
// first only base
Ndef(\dron1).play.fadeTime_(0.1);
(
Ndef(\dron1, {
	var sig, sig1, sig2, env, envGen;
	~base = 30;
	env = Env.rcurve2(200, [0.1, 1], [0.001, 0.01], [0.2, 0.5], [0.9, 0.1]);
	envGen = EnvGen.kr(env);

	sig1 = Splay.ar(LFPulse.ar([(~base + 1).midicps * 1, ~base.midicps * 1, ~base.midicps * 1, (~base + 0).midicps * 16], mul: [0.2, 0.2, 0.2, 0.2]));
	sig2 = SinOsc.ar([~base.midicps, (~base + 0).midicps] * LFNoise1.kr(0.3).range(0.97, 1.03), mul: 0.7);
	// sig1 = Splay.ar(LFPulse.ar([(~base + 1).midicps * 15, ~base.midicps * 12, ~base.midicps * 3, (~base + 5).midicps * 16], mul: [0.1, 0.1, 0.1, 0.1]));
	// sig2 = SinOsc.ar([~base.midicps, (~base + 5).midicps] * LFNoise1.kr(0.3).range(0.97, 1.03), mul: 0.7);

	sig = sig1 + sig2 + BrownNoise.ar(0.1, mul: 0.05);
	sig = sig * envGen * 0.8;
	sig
});
)
Ndef(\dron1).release


~bo.note(0,1,30,0);
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
				Pwrand([Pwhite(10.0, 12.0, 1), Pwhite(0.2, 0.05, Pstutter(Pwhite(4, 12, 1), 1))], [0.8, 0.2], 1),
				Pwhite(1, 2.0, 1)
			], inf)
		], 1),
		\freq1, Prand([~base, ~base + 0, ~base + 5], inf),
		\freq2, Prand([~base, ~base + 1, ~base + 5] + 12, inf),
		\freq3, Prand([~base, ~base + 1, ~base + 5] + 24, inf),
		\freq4, Prand([~base, ~base + 1, ~base + 5], inf),
		// \freq1, Prand([~base, ~base + 1, ~base + 5], inf),
		\bo, Pfunc { |e|
			var freq1 = e[\freq1];
			var freq2 = e[\freq2];
			var freq3 = e[\freq3];
			var freq4 = e[\freq4];
			var dur = e[\dur];
			~bo.noteWithLength(0, freq1, 127, dur * 0.99);
			~bo.noteWithLength(1, freq2, 127, dur * 0.99);
			~bo.noteWithLength(2, freq3, 127, dur * 0.99);
			~bo.noteWithLength(3, freq4, 127, dur * 0.99);
		},
	)
});
)
Pdef(\organ1).release;

// add jitter to organ1
// add overtones in organ1 and dron1
// play with base

// play with registers
// slowly, but also fast with a pbind

Pdef(\organRegs).play;
(
Pdef(\organRegs, {
	Pbind(
		\amp, 0,
		\dur, Pseq([
			Pwrand([Pwhite(0.5, 1.0, 1), Pwhite(0.2, 0.05, Pstutter(Pwhite(4, 12, 1), 1))], [0.8, 0.2], 1),
			Pwhite(0.5, 0.6, 1)
		], inf),
		\reg1, Prand([1,2,3,4,5,6,7,8,9,10], inf), // registers pedals
		\reg2, Prand([1,2,3,4,5,6,7,8,9,10], inf), // registers man I
		\reg3, Prand([1,2,3,4,5,6,7,8,9,10], inf), // registers man II
		\reg4, Prand([1,2,3,4,5,6,7,8,9,10], inf), // registers man III
		\bo, Pfunc { |e|
			var reg1 = e[\reg1];
			var reg2 = e[\reg2];
			var reg3 = e[\reg3];
			var reg4 = e[\reg4];
			~bo.reg(0, 1, reg1);
			~bo.reg(1, 1, reg2);
			~bo.reg(2, 1, reg3);
			~bo.reg(3, 1, reg4);
		},
	)
});
)
Pdef(\organRegs).stop;


// something to create a sense of time // multichannel expansion
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
		\dur, Pseq([1.1, 0.9, 0.4, 0.45, 1.1] * 2, inf),
		\level, Pseq([3,2,3] * 0.6, inf),
	)
);
)
Pdef(\boomPattern2).stop;


( // just a little help to load samples easier
~load = {
	arg buffer;
	Dialog.openPanel({ arg path;
		var file = SoundFile.new();
		var channels;
		if (file.openRead(path)) {
			channels = if (file.numChannels == 1, { [0,0] }, { [0,1] });
			buffer.readChannel(path, channels: channels);
			("Loaded:" + path.subStr(path.findBackwards("/") + 1)).postln;
			file.close;
		}
	}, path: "/Users/Robert/---data---/Temp/Zaal100/");
}
)
// play that sample // multichannel expansion, amplitude modulation, low pitch
Ndef(\sample).play.fadeTime_(0.1);
b = Buffer.alloc(s, 44100 * 60, 2);
~load.(b)
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

// a slower rhythm
Ndef(\dron2).play.fadeTime_(0.1);
(
Ndef(\dron2, {
	var sig, levels, times, env, envGen;
	~base = 30;
	env = Env.rcurve(50, [0.1, 2], [0.01, 0.2]);
	envGen = EnvGen.kr(env);

	sig = Splay.ar(SinOscFB.ar([~base.midicps * 6, (~base + 1).midicps, (~base + 5).midicps * 3, ~base.midicps * 12], SinOsc.kr(0.1).range(0,1), mul: [1,2,1]));
	sig = sig * LFPulse.kr(SinOsc.kr(0.3).range(5, 50));
	// sig = sig * Impulse.kr(SinOsc.kr(0.3).range(5, 50), mul: 3);
	sig * envGen * 0.5
});
)
Ndef(\dron2).release

// stop sample

Ndef(\dron1).release

Pdef(\organ1).stop;

// high notes with only dron2
~bo.note(0,1,30 + 60,127);

~bo.note(0,1,30 + 60,0);
~bo.note(0,1,30 + 60 + 1,127);

~bo.note(0,1,30 + 60 + 1,0);
~bo.note(0,1,30 + 60,127);

~bo.note(0,1,30 + 60,0);
~bo.note(0,1,30 + 60 + 5,127);

~bo.note(0,1,30 + 60 + 5,0);
~bo.note(0,1,30 + 60,127);


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

// stop dron2 on burst
Ndef(\dron2).release

// play with registers of high notes


//  a serene voice in there
Ndef(\sine).play.fadeTime_(1)
(
Ndef(\sine, {
	Splay.ar(SinOsc.ar([100, 1001, 500, 501, 102, 1198])) * 0.1
})
)
Ndef(\sine).release



Ndef(\massCom).play.fadeTime_(0.1);
(
Ndef(\massCom, {
	var sig, env, curve, amp, freq, hasFreq, noise;
	~base = 30 + 12;
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
	noise = BPF.ar(PinkNoise.ar(LFNoise1.kr(0.2).range(4,20)), freq * 32, 0.9, mul: amp).dup();
	sig = sig + noise;
	sig * 0.2
})
)
Ndef(\massCom).release;



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
Ndef(\ruis).release




Pdef(\boomPattern).play;
(
Pdef(\boomPattern,
	Pbind(
		\instrument, \boom,
		\dur, Pseq([1.1, 0.9, 0.9, 1.1], inf),
		\level, Pseq([3,2,3] * 0.7, inf),
	)
);
)
Pdef(\boomPattern).stop;
