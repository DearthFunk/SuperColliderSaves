(
SynthDef(\ping, {|freq|
	var e, z;
	e= EnvGen.ar(Env.perc(0, 0.1), doneAction:2);
	z= SinOsc.ar(freq.dup, 0, 0.2);
	OffsetOut.ar(0, z*e);
}).send(s);
)

//-- go from 1.5 to 0.8 and end on downbeat 4 sec from now
~from= 1.5;
~to= 0.8;
~sec= 4;
c= TempoClock(~from);
c.sched(c.timeToNextBeat(1), {Synth(\ping, [\freq, 800]); 1});
(
SystemClock.sched(~sec, {Synth(\ping, [\freq, 1200]); ~to.reciprocal});
c.sync(~to, ~sec);
)

//-- dec temo.  after 8.1 sec tempo 1.1
~from= 1.9;
~to= 1.1;
~sec= 8.1;
c= TempoClock(~from);
c.sched(c.timeToNextBeat(1), {Synth(\ping, [\freq, 800]); 1});
(
SystemClock.sched(~sec, {Synth(\ping, [\freq, 1200]); ~to.reciprocal});
c.sync(~to, ~sec);
)

//-- inc
~from= 1.1;
~to= 1.9;
~sec= 8.1;
c= TempoClock(~from);
c.sched(c.timeToNextBeat(1), {Synth(\ping, [\freq, 800]); 1});
(
SystemClock.sched(~sec, {Synth(\ping, [\freq, 1200]); ~to.reciprocal});
c.sync(~to, ~sec);
)

//-- quick adjust.  interpolation suffers a little.
~from= 1.0;
~to= 1.2;
~sec= 3.3;
c= TempoClock(~from);
c.sched(c.timeToNextBeat(1), {Synth(\ping, [\freq, 800]); 1});
(
SystemClock.sched(~sec, {Synth(\ping, [\freq, 1200]); ~to.reciprocal});
c.sync(~to, ~sec);
)


//-- 2 tempoclocks!!!  syncs them after 4.7 seconds
~from1= 1.02;
~to1= 1.8;
~from2= 1.3;
~to2= 1.8;
~sec= 4.7;
c= TempoClock(~from1);
d= TempoClock(~from2);
c.sched(c.timeToNextBeat(1), {Synth(\ping, [\freq, 800]); 1});
d.sched(d.timeToNextBeat(1), {Synth(\ping, [\freq, 1200]); 1});
(
c.sync(~to1, ~sec);
d.sync(~to2, ~sec);
)

//-- 2 tempoclocks synced almost at once
~from1= 1.02;
~to1= 1.8;
~from2= 1.3;
~to2= 1.8;
~sec= 0;
c= TempoClock(~from1);
d= TempoClock(~from2);
c.sched(c.timeToNextBeat(1), {Synth(\ping, [\freq, 800]); 1});
d.sched(d.timeToNextBeat(1), {Synth(\ping, [\freq, 1200]); 1});
(
c.sync(~to1, ~sec);
d.sync(~to2, ~sec);
)


//-- resolution make the interpolation smoother.  this will update tempo 5times/beat (0.2)
~from= 1.1;
~to= 1.5;
~sec= 7.3;
c= TempoClock(~from);
a= Pbind(\degree, Pseq([0, 5, 3, 2], inf), \dur, 0.125, \amp, 0.1).play(c);
c.sync(~to, ~sec, 0.2);
