(

// PITCH
SynthDef(\pitch, {
    | out = 0, channel, n = 0, stepsPerOctave = 12, offsetVolts = 0,
      portamento = 0.05, curve = 0 |
    var bus = (channel ? out ? 0),
        adjustedN = n,
        slew = portamento,
        targetVolts, glideTime, slid;

    adjustedN = adjustedN * (stepsPerOctave / 12);
    adjustedN = adjustedN * ((adjustedN / stepsPerOctave) * (1 / (stepsPerOctave + 1)) / 10);
    slew = slew + ((slew / stepsPerOctave) * (1 / (stepsPerOctave + 1)) / 10);

    targetVolts = (adjustedN / stepsPerOctave) + offsetVolts;
    glideTime = slew.max(0);

    slid = K2A.ar(VarLag.kr(targetVolts, glideTime, curve));
    OffsetOut.ar(bus, slid);
}).add;

// GATE & TRIGGER
SynthDef(\gate, {
    | out = 0, channel, sustain = 0.1, rise = 0.0005, fall = 0.0005, volts = 1, amp = 1 |
    var bus = (channel ? out ? 0);
    var holdTime = (sustain - (rise + fall)).max(0);
    var env = Env([0,1,1,0], [rise, holdTime, fall]);
    OffsetOut.ar(bus, EnvGen.ar(env, doneAction:2) * volts * amp);
}).add;

SynthDef(\trig, {
    | out = 0, channel, volts = 5, amp = 1, pulse = 0.005, rise = 0.0002, fall = 0.0002 |
    var bus = (channel ? out ? 0);
    var hold = (pulse - (rise + fall)).max(0);
    var env = Env([0,1,1,0], [rise, hold, fall], \lin);
    OffsetOut.ar(bus, EnvGen.ar(env, doneAction:2) * volts * amp);
}).add;

// GENERAL VOLTAGE WITH GLIDE
SynthDef(\voltage, {
    | out = 0, channel, value = 0, scale = 5.0, portamento = 0.0, curve = 0 |
    var bus = (channel ? out ? 0);
    var target = value * scale;
    var glideTime = portamento.max(0);
    var v = VarLag.kr(target, glideTime, curve);
    v = K2A.ar(v);
    OffsetOut.ar(bus, v);
}).add;

// SIMPLE SAW / LFO
SynthDef(\saw, { | out = 0, channel, rate = 0.5, amp = 1 |
    var bus = (channel ? out ? 0);
    var sig = LFSaw.ar(rate).range(0,1) * amp;
    OffsetOut.ar(bus, sig);
}).add;

SynthDef(\lfo, {
    | out = 0, channel, rate = 0.5, scale = 5.0, offset = 0.0, wave = 0 |
    var bus = (channel ? out ? 0);
    var sig = Select.ar(wave.clip(0,3), [
        SinOsc.ar(rate),
        LFTri.ar(rate),
        LFSaw.ar(rate),
        LFPulse.ar(rate, 0, 0.5)
    ]);
    sig = sig.range(0,1) * scale + offset;
    OffsetOut.ar(bus, sig);
}).add;

// EVENT ADSR-LIKE ENVELOPE
SynthDef(\ar, {
    | out = 0, channel,
      attack = 0.01,
      decay = 0.05,
      sustainLevel = 0.7,
      release = 0.2,
      sustain = 0.3,
      volts = 5.0 |
    var bus = (channel ? out ? 0);
    var gateEnvTime = attack + decay;
    var holdTime = (sustain - (gateEnvTime + release)).max(0);
    var env = Env(
        levels: [0, 1, sustainLevel, sustainLevel, 0],
        times:  [attack, decay, holdTime, release],
        curve:  \lin
    );
    OffsetOut.ar(bus, EnvGen.ar(env, doneAction:2) * volts);
}).add;

)
