s.reboot;
s.boot;
// Hello World

a=GRMonome64.new; // create a monome
//b=GRButton(a, 0@0); // a 1x1 button placed at top left key
//b.action = { |view, value| (value.if("Hello", "Goodbye") + "World").postln }; // an action triggered when the button is pressed

// A tour of widgets...
//b.remove; // remove the button created above

a.spawnGui; // spawnGui creates a virtual grid (GRScreenGrid) attached to the same view as the monome. key presses and led state of the monome will be indicated on the virtual grid.

GRCommon.indicateAddedRemovedAttachedDetached = true; // when this global is true views added and removed will be indicated on the monome and virtual grid

b=GRButton(a, 5@0, 3, 3); // create a bigger button in the top-right corner
b.action = { |view, value| ("Big button says:" + value.if("Hello", "Goodbye")).postln };

c=GRHToggle(a, 0@7, 8, 1); // a horizontal 8x1 toggle placed at row 8
c.action = { |view, value| ("Horizontal toggle says:" + value).postln };

d=GRVToggle(a, 0@0, 2, 7); // a vertical 2x7 toggle placed at columns 1 and 2
d.action = { |view, value| ("Vertical toggle says:" + value).postln };

e=GRMultiButtonView(a, 2@0, 3, 7); // a view with 21 buttons
e.action = { |view, value| ("MultiButtonView says:" + value).postln };

f=GRSwitcher(a, 5@3, 3, 3); // a view for paging other views
o=GRMultiButtonView(f, 0@0, 3, 3); // first view of switcher: a group of 3x3 buttons
p=GRMultiToggleView(f, 0@0, 3, 3, 'horizontal'); // second view: a group of 3x1 toggles
q=GRMultiToggleView(f, 0@0, 3, 3); // third view: a group of 1x3 toggles

n=GRHToggle(a, 5@6, 3, 1); // a vertical 3x1 toggle that controls switcher page
n.action = { |view, value| f.value = value };

// now, let some widgets control sound
s.boot; // boot server if not already booted
s.latency=0.05; // lower server latency for leds to update in sync

i = 440; // frequency

(
// let big button toggle a sound
b.action = { |view, value|
	value.if {
		j = { |freq| SinOsc.ar(Lag.kr(freq), mul: (-20).dbamp) ! 2 }.play(args: [\freq, i]);
	} {
		j !? {
			j.release;
			j = nil;
		}
	};
};
)

(
// let vertical toggle determine the frequency of big button's sound
d.action = { |view, value|
	i = \midfreq.asSpec.map([0, view.maximumValue].asSpec.unmap(value));
	j !? { j.set(\freq, i) };
};
d.valuesAreInverted=true;
)

(
// setup the 3x7 button group to toggle individual sounds
k = Group.basicNew(nodeID: 1); // default_group
h = Array2D(3, 7);
e.buttonValueChangedAction = { |view, x, y, value|
	var ugenGraphFunc = { |freq|
		var sig = Pan2.ar(SinOsc.ar(Lag.kr(freq+(y*freq), 1)*SinOsc.ar(freq + ((y/7)*freq)), mul: (-30).dbamp), x-1);
		sig + CombC.ar(sig, 1, (y/7), x);
	};
	value.if {
		h.put(x, y, ugenGraphFunc.play(target: k, args: [\freq, i]));
	} {
		h.at(x, y) !? { |synth|
			synth.release;
			h.put(x, y, nil);
		}
	};
};
e.action = nil;
)

(
// let vertical toggle determine the frequency of both big button sound and button group sounds by sending set(\freq, i) to default_group
d.action = { |view, value|
	i = \midfreq.asSpec.map([0, view.maximumValue].asSpec.unmap(value));
	k.set(\freq, i);
};
)

(
SynthDef(
	\grrr_test,
	{ |freq, width, gate=1, amp|
		var sig = VarSaw.ar(freq, width: width);
		var amp_env = EnvGen.ar(Env.perc, gate, amp, doneAction: 2);
		var filter_env = EnvGen.ar(Env.perc(0.01, 0.5), gate);
		sig = RLPF.ar(sig, filter_env.linexp(-1, 1, 20, 8000)) * amp_env;
		Out.ar(0, sig ! 2);
	}
).add;
)

(
// let switcher widgets play a 3x3 sequence
l=Pbind(*[
	\instrument, \grrr_test,
	\degree, Prout({
		loop {
			3.do { |y|
				3.do { |x| (if (o.buttonValue(x, y), 7.rand, \r)).yield };
			}
		}
	}),
	\dur, Prout({
		loop {
			3.do { |togglenum| (switch (p.toggleValue(togglenum), 0, {0.25}, 1, {0.35}, 2, {0.45})).yield };
		}
	}),
	\width, Prout({
		loop {
			3.do { |togglenum| (switch (q.toggleValue(togglenum), 0, {0.15}, 1, {0.35}, 2, {0.55})).yield };
		}
	}),
	\flash, Prout(
		{
			loop {
				3.do { |y|
					3.do { |x|
						switch (f.value,
							0, { o.flashButton(x, y, 100) },
							1, { p.flashToggle(x, 100) },
							2, { q.flashToggle(x, 100) }
						);
						1.yield;
					};
				}
			}
		}
	)
]);
m=l.play;
)