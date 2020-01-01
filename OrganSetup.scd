(

// ----------------------------- Setup environment -----------------------------
// connect with DHCP to server 192.168.0.60

~testMode = true;

if(~o.notNil, { ~o.clearAll() });
~o = EM(); // functions in an EM always have the environment as first argument

if (~testMode) {
	~o.addr = NetAddrMon.new("127.0.0.1", 8000);
} {
	~o.addr = NetAddrMon.new("192.168.0.1", 1803);
};
~o.currentDir = Document.current.dir;
~o.sendMidi = true;

~midiOutDevice = "IAC1";
SetMIDIOut.new();
~o.midiOut = ~midiOut;

(Document.current.dir ++ "/Lib/Definitions.scd").load();

~oscOutMonitor = 2;

)


// ----------------------------- Testing -----------------------------

// OSC monitor on/off
~oscOutMonitor = 2;
~oscOutMonitor = 1;
~oscOutMonitor = 0;

// tuning
{SinOsc.ar(60.midicps)!2}.play;

// Manuals are counted from 0, so pedals is 0, manuals 1, 2, 3 are numbers 1, 2, 3. Layers per manual are counted from 1.
// Often, if the layer is omitted, parameters are set for all layers on that manual

// panic: stop all notes, remove all registers, delete all extra layers
~o.panic();

// trigger a note
// channel, layer, note(s), velocity
~o.note(0, 1, 85, 127);
~o.note(0, 1, 85, 0);
~o.note(0, 1, 60, 0);
~o.note(0, nil, 60, 0);

// 3 notes to all channels
~o.note(0, nil, [60, 62, 76], 64);
~o.note(0, nil, [60, 62, 76], 0);
// shortcut
~o.midinote(0, [60, 62, 76], 64);

// add registers to Utopa
// chan, layer, register(s)
~o.reg(0, 1, [37,40]); // set only 37 and 40, remove all others
~o.regAdd(0, 1, 51); // add register 51
~o.regAdd(0, 1, [-40, 42]); // remove register 40 and add register 42

// add registers to Sauer in two steps: Divisions and Registers

// chan, layer, division
~o.div(0, 1, [2, 3]); // set only divisions green (2) and white (3), remove all others
~o.divAdd(0, 1, 1); // add division grey (1)

// chan, layer, div, register(s), clear
~o.divReg(3, 1); // set only register 1 to division white (3), remove all other stops
~o.divReg(3, [1, 3, 4]);
~o.divRegAdd(3, [1, 3, 4, 7]); // add registers 1, 3, 4 to division white (3)

// layer 2 with two registers and a delay of 100ms
~o.reg(0, 2, [41, 42]);
~o.delay(0, 2, 200);

// example: looping notes
(
~duration = 0.1;
~pause = 0.2;
~play = {
	var note = 35;
	var sign = -1;
	inf.do { arg index;
		if (index%31 == 0) {
			sign = sign.neg;
		};
		// note = max(36, note + sign);
		note = rrand(36, 66);
		~o.note(0, nil, note, 127);
		~duration.wait;
		~o.note(0, nil, note, 0);
		~pause.wait;
	}
}.fork;
)
~play.stop;

// transposing
~o.transpose(0, 1, 3);
~o.transpose(0, 1, 0);
~o.transpose(0, 2, 8);
~o.transpose(0, 2, 0);

~o.staccato(0, 1, 50);
~o.staccato(0, 1, 0);
~o.staccato(0, 2, 50);
~o.staccato(0, 2, 0);





// example: setting up manual I
(
// layer 1 with three registers
~o.reg(1, 1, [36, 40, 51]);

// layer 2 with two registers and a delay of 100ms
~o.reg(0, 2, [41, 42]);
~o.delay(0, 2, 100);

// layer 3 with one register and a delay of 200ms
~o.reg(1, 3, 62);
~o.delay(1, 3, 200);

// layer 4 with two registers and a delay of 300ms
~o.reg(1, 4, [53, 54]);
~o.delay(1, 4, 300);

// add a layer
~o.addLayer(1);

// layer 5 with two registers and a delay of 400ms
~o.reg(1, 5, [37, 38]);
~o.delay(1, 5, 400);

)



// send a note to all layers
~o.note(1, nil, 60, 127);

// stop note
~o.note(1, nil, 60, 0);

// channel, layer, delay-time in milliseconds
~o.delay(1, 1, 100);
~o.delay(1, 1, 0); // 0 msec = delay off

// add a layer to a channel
~o.addLayer(1);

// transposing
~o.transpose(1, 2, 0);
~o.transpose(0, 1, 0);
(
~pause = 0.1;
~transpose = {
	var semitones = 0;
	var sign = -1;
	inf.do { arg index;
		if ( index%24 == 0 ) {
			sign = sign.neg;
		};
		semitones = semitones + sign;
		~o.transpose(1, 1, semitones);
		~pause.wait;
	};
}.fork;
)
~transpose.stop;

~o.staccato(0, 2, 10);
~o.staccato(0, 2, 0);

~o.prolong(0, 2, 600);
~o.prolong(0, 2, 0);

~o.pulsefreq(0, 2, 0.5)
~o.pulsefreq(0, 1, 0.5, \off)
~o.pulsewidth(0, 1, 0.4)
~o.pulsewidth(1, 1, 0.5, \off)

~o.trem('OW', 150, 0.3);
~o.trem('OW', 100, 0.6, \off);
~o.trem('HW', 250, 0.6);

~o.sostenuto(1, 1, 0.9);
~o.sostenuto(1, 1, 0.7, \off);

~o.sustain(1, 1, 0.9);
~o.sustain(1, 1, 0.7, \off);

// schwell pedal 0 is Utopa air and schwell pedal 2 is the Sauer schwellchest
~o.sp(0, 0);
~o.sp(0, 127);
~o.sp(2, 0);
~o.sp(2, 127);

(
~pedal = 0;
~pause = 0.1;
~step = 1;
~sp = {
	var value = 0;
	var sign = ~step.neg;
	inf.do { arg index;
		if ( index%127 == 0 ) {
			sign = sign.neg;
		};
		value = value + sign;
		value = min(127, max(0, value));
		~o.sp(~pedal, value);
		~pause.wait;
	};
}.fork;
)
~sp.stop;

// not working
~o.mute(1, 1);
~o.mute(1, 1, \off);







