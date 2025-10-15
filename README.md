<img src="https://cdn.sanity.io/images/os5aqg3v/production/1df428507bbab5a032dcb43701e80b4e9aeb29f5-2048x1475.jpg?auto=format" width="500" />

# SuperDirt Voltage

A small set of SuperDirt synths and Tidal helpers to control modular synths. No
MIDI required!

**2025**

- Persistant Pitch (pitch values are stored in SuperCollider and are no longer dependant on cycle/legato length)
- Performance updates

---

### Install

1: Clone this repo and add the path to `superdirt-voltage.scd` to your SuperDirt startup file:

```supercollider
// ensure you update to the correct path on your machine
("./superdirt-voltage.scd").load;

// Add this block to enable the new pitch synths
 ~pitchNodes = ~pitchNodes ? IdentityDictionary.new;

~dirt.soundLibrary.addSynth(\persistantPitch, (
    play: {
        var out      = (~channel ? 0).asInteger;
        var n        = ~n ? 0;
        var port     = ~portamento ? 0.05;
        var steps    = ~stepsPerOctave ? 12;
        var offset   = ~offsetVolts ? 0;
        var curve    = ~curve ? 0;

        if (~pitchNodes[out].isNil or: { ~pitchNodes[out].isRunning.not }) {
            ~pitchNodes[out] = Synth(\pitch, [
                \out, out,
                \n, n,
                \stepsPerOctave, steps,
                \offsetVolts, offset,
                \portamento, port,
                \curve, curve
            ]);
        } {
            s.sendBundle(s.latency, {
                ~pitchNodes[out].set(
                    \n, n,
                    \stepsPerOctave, steps,
                    \offsetVolts, offset,
                    \portamento, port,
                    \curve, curve
                );
            });
        };
    }
));
```

2: Evaluate `voltage.tidal` (or add to your `bootTidal.hs` config)

---

#### Pitch, with octave quantisation

```haskell
-- change notes per octave on each cycle
d1 $ pitch "0 10 8 1" # octave "<12 31 8>" # x 1
```

`pitch` allows a pattern of note values. `octave` sets the amount of notes per
octave. The pitch and scale values will be converted to `1v/octave`. Both
`pitch` and `octave` can be sequenced for some microtonal madness...

`glide` accepts a strengh (in semitones, relative to scale), a rate (in step
length).

```haskell
-- glide to pitch
d1 $ pitch "0 10 8 1" # scale "<12 31 8>" # x 1 # glide 12 0.5
```

#### Gate

```haskell
-- sequence gate inputs
d2 $ gate "0 1 0 0 1 1 1" # x 2
```

`gate` will take a 0/1 pattern and return +5v signals for the `1` values. Use
`-1` if you need a -5v.

#### Voltage automation

```haskell
-- create stepped automation
d3 $ volt "1 0.2 0.5 -0.2" # x 3
```

`volt` will allow you to sequence voltages however you like.

#### ADSR/AR

```haskell
--- adsr
d4 $ adsr 0 0.2 1 0.2 # x 4
```

There is also just an `ar` helper too, which has a default D and S value.

```haskell
-- create ar
d5 $ struct "t f t t" # ar 0 0.5 # x 5
```

```haskell
-- patternise ar
d5 $ struct "t f t t" # ar (range 0.1 1 sine) "<0 0.4>" # x 5
```

In the above example, the attack time would grow for each triggered envelope
over course of the cycle.

#### Sine LFO

This will create an sine waveform, the sine will restart with each cycle, which
gives a neat synced/trigger effect for modulations.

```haskell
d6 $ lfo 0.5 # x 6
```

#### Saw LFO

This will create a sawtooth waveform, the sawtooth will restart with each cycle,
which gives a neat synced/trigger effect for modulations.

```haskell
d6 $ saw 0.5 # x 6
```

#### Clock

```haskell
-- clock cv output
d6 $ clock # x 6
```

`clock` will output a clock cv, which matches the bpm of your tidal project. You
can `slow` / `fast` this as well.

#### Amp

Using the `amp` modifier in Tidal Cycles will scale the output of `gate`,
`voltage`, `saw`, `ar`, and `lfo`. Awesome for creating more suble modulations.

```haskell
d6 $ saw 0.5 # x 6 # amp 0.3
```

---

### Fine print

**These require a DC-coupled sound card.**

Add the `voltage.scd` synths to your active SuperDirt synth definitions.

Evaluate the `voltage.tidal` definitions after starting Tidal. These can also be
added to your Tidal startup file.

In the above examples, `x` maps to a channel on your audio card. If you have an
8 output audio card, the `x` will likely be 0-7. If you are using an aggregate
device, please refer to your Audio settings.

---

### Feedback and/or additions?

[@slash@merveilles.town](https://merveilles.town/@slash)

[club.tidalcycles thread](https://club.tidalcycles.org/t/using-tidal-to-control-modular-synths-with-cv/863)
