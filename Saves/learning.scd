
s.boot;
s.quit;
s.reboot;

(
z = {
	arg noiseHz = 8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02, 0.06);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.free;
s.freeAll;

z.set(\noiseHz, exprand(4, 20));


////////////////////////////////////////////////////////////////////////////////

s.boot;
s.quit;

(
SynthDef.new(\sineTest, {
	arg noiseHz = 8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02, 0.06);
	sig = SinOsc.ar(freq) * amp;

	Out.ar(0, sig);
}).add;
)

x = Synth.new(\sineTest);
x.set(\noiseHz, 2)

y = Synth.new(\sineTest, [\noiseHz, 32]);

x.free;
y.free;


//////////////////////////////////////////////////////////////////////////////////


s.boot;
s.reboot;
s.quit;

(
SynthDef.new(\pulseTest, {
	arg ampHz = 4, fund = 40, maxPartial = 4, width = 0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.25;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.25;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

x.set(\width, 0.5);
x.set(\fund, 20);
x.set(\maxPartial, 6);

x = Synth.new(\pulseTest);
y = Synth.new(\pulseTest, [\ampHz, 3.3, \fund, 48\]);

x.free;


//////////////////////////////////////////////////////////////////////////\

s.plotTree; //execute to bring up window

(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(30,500), 0.5, 0.2) * env;
}.play;
)
//execute the above a bunch of times, and watch items get added in the tree (window)

x.free;
//now you just freed the most recent one, what above all the previous ones that still exist in mem

s.freeAll; //frees everything


(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1, doneAction: 2); //note the done action difference
	sig = Pulse.ar(ExpRand(30,500), 0.5, 0.2) * env;
}.play;
)
//execute the above a bunch of times and watch as items DO NOT get added to the tree


//////////////////////////////////////////////////////////////////////////////////

//try switching between playing the 2

(x = {
	var sig, env;
	env = Line.kr(1, 0, 5, doneAction: 2); //note the done action difference
	sig = Pulse.ar(ExpRand(30,500), 0.5, 0.2) * env;
})
(y = {
	var fund = 40;
	var sig, env, freq1;
	env = Line.kr(1, 0, 1, doneAction: 2);
	freq1 = LFNoise0.kr(4).exprange(100, 500);
	sig = Pulse.ar(ExpRand(80,200), 0.5, 0.2) * env;
	sig = Pulse.ar(freq1, 0.5, 0.2) * env;
})
(z = {
	var env, sig1;
	//freq1 = LFNoise0.kr(4).exprange(200, 1200);
	//freq1 = freq1 * LFPulse.kr(8, add:1);
	env = Line.kr(1, 0, 2, doneAction: 2);
	sig1 = Pulse.ar(ExpRand(80, 140), 0.5, 0.3) * env;
	sig1 = FreeVerb.ar(sig1, 0.7, 0.5, 0.5);
})

y.play;
x.play;
z.play;


s.boot;
s.freeAll;
s.reboot;


///////////////////////////////////////////////////////////////////

// an envelope in a synth

(
{
    var env = Env([0, 1, 0.5, 1, 0], [0.01, 0.5, 0.02, 0.5]);
    SinOsc.ar(470) * EnvGen.kr(env, doneAction: Done.freeSelf)
}.play
)
// an envelope to control a parameter in a pattern
(
Pbind(\note, Env([0, 12, 6, 13, 0], [1, 5, 2, 10]),
	\dur, 0.1).play
)

///////////////////////////////////////////////////////////////////



{ [SinOsc.ar(140, 0, 0.2), SinOsc.ar(902, 0, 0.2)] }.play;
{ SinOsc.ar([140, 442], 0, 0.2) }.play;

(
{ var freq;
	freq = [[600, 559], [339, 602], 1320, 880].choose;
	SinOsc.ar(freq, 0, 0.2);
}.play;
)

{ Pan2.ar(PinkNoise.ar(0.2), -0.3) }.play;

//////////////////////////////////////////////////////////////////

{ Mix.new{[SinOsc.ar(440, 0, 0.2), Saw.ar(662, 0.2)]).postln }.play;

({
	var a, b;
	a = [SinOsc.ar(240, 0, 0.2), Saw.ar(662, 0.2)];
	b = [SinOsc.ar(450, 0, 0.2), Saw.ar(968, 0.2)];
	Mix([a, b]).postln;
}.play;)


/////////////////////////////////////////////////////////////////////


(

{

	var n = 33; 	//try changing me to 34, or 3, and then re-running...



	Resonz.ar(

		Mix.fill(n,{



			var freq=rrand(50,560.3);

			var numcps= rrand(2,20);



			Pan2.ar(Gendy1.ar(6.rand,6.rand,1.0.rand,1.0.rand,freq ,freq, 1.0.rand, 1.0.rand, numcps, SinOsc.kr(exprand(0.02,0.2), 0, numcps/2, numcps/2), 0.5/(n.sqrt)), 1.0.rand2)

		}),

		MouseX.kr(100,2000),

		MouseY.kr(0.01,1.0)

	);

}.play

)


////////////////////////////////////////////////////////////////////////

(		//select this code within the outer parentheses

		//then press the evalute key command

{

SinOsc.ar(440,0,0.1)

+

Pulse.ar(443,0.6,0.05)

}.play

)
