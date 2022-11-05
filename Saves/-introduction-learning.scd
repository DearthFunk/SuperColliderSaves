s.boot;
s.quit;

//open the GUI for managing Quarks
//Quarks = package of SC code containing classes, extension methods, documentation and server UGen plugins.
Quarks.gui

// ctrl + . (numpad) to kill all
// ctrl + enter to play
// play a note
{ SinOsc.ar(840, 0, 0.2) }.play

// play and stop a note
x = { SinOsc.ar(660, 0, 0.2) }.play; // short form
x.free;
// same deal but long form synthDef, this is the exact same as the above one
y = SynthDef.new("tutorial-SinOsc", { |out| Out.ar(out, SinOsc.ar(660, 0, 0.2)) }).play; // long form
y.free;

// create/access a synth by name
SynthDef.new("tutorial-PinkNoise", { |out| Out.ar(out, PinkNoise.ar(0.3)) }).add;
// then:
x = Synth.new("tutorial-PinkNoise");
y = Synth.new("tutorial-PinkNoise");
x.free;
y.free;

// left channel = 440 / right channel = 870
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(870, 0, 0.2)] }.play;
// same deal, another format
{ SinOsc.ar([440, 870], 0, 0.2) }.play;

// oscillate the amplitude
({
    var ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
    SinOsc.ar(440, 0, ampOsc);
}.play;)

// radom note from set
({ var freq = [200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800].choose;
   SinOsc.ar(freq, 0, 0.2);
}.play;)
// same deal, but now with some stero items
({ var freq = [[660, 880], [440, 660], 1320, 880].choose;
   SinOsc.ar(freq, 0, 0.2);
}.play;)

// panning pinknoise
{ Pan2.ar(PinkNoise.ar(0.2), SinOsc.kr(0.5)) }.play;
{ Pan2.ar(PinkNoise.ar(0.2), -0.3) }.play; // slightly to the left

// mix some waves together
{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.play;

// todo: I don't get the point of this, it writes out "a BinaryOpUgen", but why use Mix.new?
{ Mix.new([SinOsc.ar(440, 0, 0.2), Saw.ar(660, 0.2)]).postln }.play;
​
// combine two stereo arrays
(
{
    var a = [SinOsc.ar(440, 0, 0.2), Saw.ar(662, 0.2)];
    var b = [SinOsc.ar(442, 0, 0.2), Saw.ar(660, 0.2)];
    Mix([a, b]).postln;
}.play;
)

(
    var n = 8;
    { Mix.fill(n, { SinOsc.ar(500 + 500.0.rand, 0, 1 / n) }) }.play;
)

// Look at the post window for frequencies and indices
(
    var n = 8;
    {
        Mix.fill(n, { arg index;
            var freq;
            index.postln;
		freq = 440 + (index * 2);
            freq.postln;
            SinOsc.ar(freq , 0, 1 / n)
        })
    }.play;
)

// plot the graph on a grid
{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.plot
{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.plot(0.05);
{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.plot(0.5);
{ PinkNoise.ar(0.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.plot(1);
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.scope;
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.scope(zoom: 10);
// scoping on demand (after audio already started
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;
s.scope;

// first with a Function. Note the random frequency each time 'play' is called.
f = { SinOsc.ar(440 + 200.rand, 0, 0.2) };
x = f.play;
y = f.play;
z = f.play;
x.free; y.free; z.free;

// Now with a SynthDef. No randomness! syntheDef exectues the 200.rand on class defined, not usage/initialization
SynthDef("tutorial-NoRand", { |out| Out.ar(out, SinOsc.ar(440 + 200.rand, 0, 0.2)) }).add;
x = Synth("tutorial-NoRand");
y = Synth("tutorial-NoRand");
z = Synth("tutorial-NoRand");
x.free; y.free; z.free;

// With Rand, it works! TODO: why/why the difference ( Rand() vs x.rand )
SynthDef("tutorial-Rand", { |out| Out.ar(out, SinOsc.ar(Rand(440, 660), 0, 0.2)) }).add;
x = Synth("tutorial-Rand");
y = Synth("tutorial-Rand");
z = Synth("tutorial-Rand");
x.free; y.free; z.free;

(SynthDef("tutorial-args", { arg freq = 440, out = 0; Out.ar(out, SinOsc.ar(freq, 0, 0.2)); }).add;)
x = Synth("tutorial-args");                // no args, so default values
y = Synth("tutorial-args", ["freq", 660]);        // change freq
z = Synth("tutorial-args", ["freq", 880, "out", 1]);    // change freq and output channel1
x.free; y.free; z.free;

// upate values of a playing synth
(SynthDef.new("tutorial-args", { arg freq = 440, out = 0; Out.ar(out, SinOsc.ar(freq, 0, 0.2)); }).add; )
s.scope; // scope so you can see the effect
x = Synth.new("tutorial-args");
x.set("freq", 660);
x.set("freq", 880, "out", 1);
x.free;


// TODO / NEXT : 11.Busses
