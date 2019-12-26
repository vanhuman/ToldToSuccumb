(
'Loading definitions'.postln;

// data containers ------------------------------------

~o.ped = 0; ~o.man1 = 1; ~o.man2 = 2; ~o.man3 = 3;
~o.layersPerManual = (0: 1, 1: 1, 2: 1, 3: 1);

~o.hw = [37,38,39,40,41,42,43,44,46,47,48,51,52,57,58,59,60,61,63,64];
~o.sp = [75,76,77,78,79,80,81,82,83,84,85,86,88,92,95,96,97,98,99,100];
~o.sw = [112,113,114,115,116,117,118,119, 120,121,122,124,125,127,128,129,130,131,132,133];
~o.so = [165,166,172,173,174,175,176,177];
~o.p = [1,2,3,4,5,6,7,8,10,11,12,16,17,18,20,21,22,23,24,25,26];

~o.hwc = [222,223,224,225,226,227,229,232,235,236,237,238];
~o.swc = [199,200,201,202,203,204,205,206,207,208,209,210,212,213,214];
~o.pc = [245,246,248,249,250,251,252,253,254,255,256,258,259,260];

~o.hwf = [179,180,181,182,183,184,185,186,187,188,189,191,192,193];
~o.pf = [268,269,270,271];

// functions ------------------------------------

~o.clearAll = {
	MIDIdef.freeAll;
	NetAddr.disconnectAll;
	~bo = nil;
};

~o.chanLayer = {
	// this returns the general OSC address
	arg evt, chan, layer;
	var layerPart = if (layer.notNil, { "/L" ++ layer }, { "" });
	"/M" ++ chan ++ layerPart
};

~o.note = {
	// notes: integer or integer[]
	// layer: integer or null (all layers)
	arg evt, chan, layer, notes, val;
	var force;
	if (val.isNil) { val = 127 };
	force = (val / 127).round(0.001);
	// send OSC
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/V", force, *notes);
	// send MIDI
	if (evt.sendMidi, {
		if (notes.isInteger, {
			evt.midiOut.noteOn(chan, notes, val);
		}, {
			notes.do { arg note;
				evt.midiOut.noteOn(chan, note, val);
			}
		});
	});
	""
};

~o.midinote = {
	// send note to all layers
	arg evt, chan, notes, val;
	evt.note(chan, nil, notes, val);
	""
};

~o.noteLen = {
	// send note to all layers and stop after duration
	arg evt, chan, notes, len, val;
	if (len.isNil) { len = 1 };
	if (val.isNil) { val = 127 };
	evt.note(chan, nil, notes, val);
	{ evt.note(chan, nil, notes, 0) }.defer(len);
	""
};

~o.addLayer = {
	arg evt, chan;
	evt.addr.sendMsg("/M" ++ chan ++ "/createLayer");
	""
};

~o.reg = {
	// set absolute registers, or relative if clear is false
	// regs: integer or integer[], a negative number meaning 'remove stop'
	arg evt, chan, layer, regs, clear = true;
	if(regs.isNil, { regs = [ ] });
	if(regs.isArray.not, { regs = [regs] });
	if(clear, { regs = [0] ++ regs }); // clear all active registers
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/S", *regs);
	""
};
~o.regAdd = {
	arg evt, chan, layer, regs;
	evt.reg(chan, layer, regs, false);
};

~o.delay = {
	arg evt, chan, layer, msec;
	var onOff = if(msec > 0, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Delay", msec, onOff);
	""
};

~o.transpose = {
	arg evt, chan, layer, semitones;
	var onOff = if(semitones > 0, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Transpose", semitones, onOff);
	""
};

~o.staccato = {
	arg evt, chan, layer, msec;
	var onOff = if(msec > 0, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Staccato", msec, onOff);
	""
};

~o.prolong = {
	arg evt, chan, layer, msec;
	var onOff = if(msec > 0, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Prolong", msec, onOff);
	""
};

~o.pulsefreq = {
	// value 0.0 - 1.0 linear from 245ms to 5ms, -1.0 - 0.0 linear from 5bpm to 245bpm
	arg evt, chan, layer, value, on = \on;
	var onOff = if(on == \on, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/PulseFreq", value, onOff);
	""
};

~o.pulsewidth = {
	// fraction 0.0 - 1.0
	arg evt, chan, layer, fraction, on = \on;
	var onOff = if(on == \on, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/PulseWidth", fraction, onOff);
	""
};

// schwell pedal 0 is Utopa air and schwell pedal 2 is the Sauer schwellchest
~o.sped = {
	arg evt, pedal, value;
	evt.addr.sendMsg("/SP" ++ pedal.asString, value);
	""
};

~o.trem = {
	// werk = 'OW' or 'HW', pulsewidth = 0.0 - 1.0
	arg evt, werk = 'OW', msec, pulsewidth = 0.5, on = \on;
	var onOff = if(on == \on, { "on" }, { "off" });
	evt.addr.sendMsg("/Trem" ++ werk, onOff, pulsewidth, msec.asString ++ 'ms');
	""
};

~o.mute = {
	arg evt, chan, layer, on = \on;
	var onOff = if(on == \on, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Mute", onOff);
	""
};

~o.sostenuto = {
	arg evt, chan, layer, boundary, on = \on;
	var onOff = if(on == \on, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Sostenuto", boundary, onOff);
	""
};

~o.sustain = {
	arg evt, chan, layer, boundary, on = \on;
	var onOff = if(on == \on, { "on" }, { "off" });
	evt.addr.sendMsg(evt.chanLayer(chan, layer) ++ "/Sustain", boundary, onOff);
	""
};

~o.panic = {
	arg evt;
	evt.addr.sendMsg("/panic");
	""
};

~o.stopAllNotes = {
	arg evt, chans, layers;
	if(chans.isNil, { chans = [evt.ped, evt.man1, evt.man2, evt.man3] });
	if(chans.isArray.not, { chans = [chans] });
	if(layers.notNil and: { layers.isArray.not }, { layers = [layers] });
	chans.do { |chan|
		var layersTemp = if(layers.notNil, { layers }, { Array.series(evt.layersPerManual[chan], 1, 1) });
		if(layersTemp.size == 0, { layersTemp = (1..4) });
		("Stopping all notes on manual" + chan ++ ", layer(s)" + layersTemp.toString).warn;
		layersTemp.do { |layer|
			127.do { |note|
				evt.note(chan, layer, note, 0);
			};
		};
	};
};

~o.clearAllRegs = {
	arg evt;
	var chans = [evt.ped, evt.man1, evt.man2, evt.man3];
	var layers;
	chans.do { |chan|
		layers = Array.series(evt.layersPerManual[chan], 1, 1);
		if(layers.size == 0, { layers = (1..4) });
		("Clearing all registers on manual" + chan ++ ", layer(s)" + layers.toString).warn;
		layers.do { |layer|
			evt.reg(chan, layer);
		};
	};
};

)