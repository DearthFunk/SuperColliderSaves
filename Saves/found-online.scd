
// COPIED FROM: http://sccode.org/1-5gs
{var a=LFNoise0,b=SinOscFB,c=Pulse;b.ar(a.ar([2,3])*(c.ar([5,7],b.kr([7,5]))*(a.ar([3,2]))*[800,1200]),(c.kr([100,80])*[2,3]))}.play

// COPIED FROM: http://sccode.org/1-4SV
{((SmoothDecimator.ar(Saw.ar([4e3,4054],0,0.2),LFTri.kr(0.01,1e3,1e3).abs)**Saw.ar(400))**Saw.ar(2e3)).clip(-0.5,0.5)}.play //

// COPIED FROM: http://sccode.org/1-5fq#c1005
(
{
	arg hz=440,amp=0.5;
	var note=hz.cpsmidi;
	var snd,snd2,intro;

	// these notes are directly from Eno's Music for Airports
	// each phrase is one line, and played through
	var airports=[
		[5,7,4,2,0,12,7,5,7,4,2,0],
		[5,7,4,2,0,12,4,7,5,0],
		[-5,2,0,4,7,12,5,2,7,4,0,7,2,5,5,2,4,0],
		[7,7,2,4,4,4,2,0,7,0,0],
	];
	// these are some chords I made up that sound nice with it
	var planes=[
		[0,4,7,12],
		[4,7,11,16],
		[-3,0,4,7],
		[-3,0,5,9],
	];

	// setup the note change variables
	var seq,seqnote,notepulse,noterate;
	var planeseq,planenotes,planeenv,planenotechange;
	// piano stuff
	var noise, string, delaytime, lpf, noise_env,pianosnd,pianosnd2, damp_mul,pianohz,noise_hz;
	var noise_attack=0.002, noise_decay=0.06,
	tune_up = 1.0005, tune_down = 0.9996, string_decay=6.0,
	lpf_ratio=2.0, lpf_rq = 4.0, hpf_hz = 40, damp=0, damp_time=0.1;

	// chord and note changes (random)
	planenotechange=Dust.kr(1/30)+Impulse.kr(0);
	planeenv=1-EnvGen.kr(Env.perc(3,10,0.9),planenotechange);
	planenotes=Demand.kr(TDelay.kr(planenotechange,3),0,Dxrand(planes,inf));
	notepulse=1;
	noterate=TChoose.kr(Dust.kr(notepulse)+Impulse.kr(0),[0.02,0.05,1,2,0.5,0.25,2]/2)*Rand(0.78,1.32);
	notepulse=Impulse.kr(noterate);
	seq=Demand.kr(Dust.kr(0.1)+Impulse.kr(0),0,Dxrand(airports,inf));
	seqnote=Demand.kr(notepulse,0,Dseq(seq,inf));
	// bass note
	snd=SinOsc.ar((note-24).midicps,mul:SinOsc.kr(Rand(0.001,0.01)).range(0.05,0.15));
	snd=snd+SinOsc.ar((note-12).midicps,mul:SinOsc.kr(Rand(0.001,0.01)).range(0.001,0.05));
	// chords
	snd=snd+(planeenv*Mix.ar(Array.fill(8,{arg i;
		var snd;
		snd=SawDPW.ar((note+planenotes[i%4]+Select.kr(DC.kr(i%4)<1,[24.neg,36.neg])).midicps,mul:0.9);
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,hz,hz*5));
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/7
	})));
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*60));
	snd=snd+(0.55*DynKlank.ar(`[[(note+planenotes[0]).midicps, (note+planenotes[1]).midicps, (note+planenotes[2]).midicps, (note+planenotes[3]).midicps], nil, [1, 1, 1, 1]], PinkNoise.ar([0.004, 0.004])));

	// piano sound from https://github.com/catfact/zebra/blob/master/lib/Engine_DreadMoon.sc#L20-L41
	noise_hz=VarLag.kr(LFNoise0.kr(1/10),10).range(2000,5000);
	pianohz=A2K.kr((note+seqnote-12).midicps);
	noise_env = Decay2.ar(Impulse.ar(noterate));
	noise = LFNoise2.ar(noise_hz) * noise_env;
	damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);
	delaytime = 1.0 / (pianohz * [tune_up, tune_down]);
	string = Mix.new(CombL.ar(noise, delaytime, delaytime, string_decay * damp_mul));
	pianosnd = RLPF.ar(string, lpf_ratio * pianohz, lpf_rq) * amp;
	pianosnd = HPF.ar(pianosnd, hpf_hz);

	// polyperc sound
	pianosnd2=(
		EnvGen.ar(Env.perc(release:4),notepulse)*
		MoogFF.ar(Pulse.ar((note+seqnote).midicps,mul:1.0),(note).midicps*1.5)
	);

	// mix between polyperc and piano sound randomly
	snd=snd+SelectX.ar(SinOsc.kr(LFNoise0.kr(0.1).range(0.01,0.1)).range(0.1,0.9),[pianosnd*0.3,pianosnd2]);
	snd=LPF.ar(snd,(note+36).midicps);
	snd=HPF.ar(snd,120);
	snd=snd*EnvGen.ar(Env.new([0,0,1],[0.5,3]));
	snd=FreeVerb.ar(snd,0.45,2.0,0.5);
	snd2=snd;

	// reverb
	snd2 = DelayN.ar(snd2, 0.03, 0.03);
	snd2 = CombN.ar(snd2, 0.1, {Rand(0.01,0.099)}!32, 4);
	snd2 = SplayAz.ar(2, snd2);
	snd2 = LPF.ar(snd2, 1500);
	5.do{snd2 = AllpassN.ar(snd2, 0.1, {Rand(0.01,0.099)}!2, 3)};

	// final output
	Out.ar(0,(snd2*0.1+snd)*amp);
}.play;
)

// COPIED FROM: http://sccode.org/1-5gi
//All 8 algoritms of the dx11 opamt defines the output level and thus the amount of phase modulation going into the carrier
(
SynthDef(\dex11algo1,///op4--->op3-->op2--->op1
	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=3,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps,op4);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps,op3);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps,op2);
		op1=op1*env1;
		signal=op1*op1amt;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo1)
/////////////////////
/////////////////////
(
SynthDef(\dex11algo2,//op4+op3--->op2--->op1
	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=3,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps,op3+op4);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps,op2);
		op1=op1*env1;
		signal=op1*op1amt;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo2)

////////////////
///////////////
(
SynthDef(\dex11algo3,//op3-->op2-->op1<--op4
	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=1,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps,op3);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps,op2+op4);
		op1=op1*env1;
		signal=op1*op1amt;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo3)
///////////////////
//////////////////
(
SynthDef(\dex11algo4,//op2-->op1<--op3<--op4
	{
		|
		pitch=60,
		op1att=0.001,op1dec=0.4,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=0.50,op2amt=1,op2tune=12,
		op3att=0.001,op3dec=0.5,op3amt=0,op3tune=12.1,
		op4att=0.001,op4dec=0.050,op4amt=1,op4tune=0.1,feedbackamt=1|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps,op4);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps,op2+op3);
		op1=op1*env1;
		signal=op1*op1amt;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo4)
//////////////
//////////////
(
SynthDef(\dex11algo5,//op2-->op1   op4-->op3

	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=1,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps,op4);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps,op2);
		op1=op1*env1;
		op1=op1*op1amt;
		signal=(op1+op3)/2;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)
/////
Synth(\dex11algo5)

///////////////////
///////////////////
(
SynthDef(\dex11algo6,// op4--->ALL

	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=1,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps,op4);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps,op4);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps,op4);
		op1=op1*env1;
		op1=op1*op1amt;
		signal=(op1+op2+op3)/3;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo6)
//////////////////
/////////////////
(
SynthDef(\dex11algo7,// op4--->op3    op2+op1-->out

	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=1,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps,op4);
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps);
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps);
		op1=op1*env1;
		op1=op1*op1amt;
		signal=(op1+op2+op3)/3;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo7)
////////////////////
//////////////////////
(
SynthDef(\dex11algo8,// all out

	{
		|
		pitch=60,
		op1att=0.001,op1dec=5.250,op1amt=1,op1tune=0,
		op2att=0.001,op2dec=1.250,op2amt=1,op2tune=0,
		op3att=0.001,op3dec=1.250,op3amt=1,op3tune=0,
		op4att=0.001,op4dec=1.250,op4amt=1,op4tune=0,feedbackamt=0|
		var env1,env2,env3,env4,op1,op2,op3,op4,pan=(0.0),signal;

		env4=EnvGen.ar(Env([0,1,0],[op4att,op4dec],[0,-5]),doneAction:0);
		op4=SinOscFB.ar((pitch+op4tune).midicps,env4*feedbackamt);
		op4=op4*env4;
		op4=op4*op4amt;
		op4;
		env3=EnvGen.ar(Env([0,1,0],[op3att,op3dec],[0,-5]),doneAction:0);
		op3=SinOsc.ar((pitch+op3tune).midicps );
		op3=op3*env3;
		op3=op3*op3amt;
		env2=EnvGen.ar(Env([0,1,0],[op2att,op2dec],[0,-5]),doneAction:0);
		op2=SinOsc.ar((pitch+op2tune).midicps );
		op2=op2*env2;
		op2=op2*op2amt;
		env1=EnvGen.ar(Env([0,1,0],[op1att,op1dec],[0,-5]),doneAction:2);
		op1=SinOsc.ar((pitch+op1tune).midicps );
		op1=op1*env1;
		op1=op1*op1amt;
		signal=(op1+op2+op3+op4)/4;
		signal=Pan2.ar(signal,pos:pan);
		Out.ar(0,signal);
}).add
)

/////
Synth(\dex11algo8)


/////////////////////////////////////////////////////////
// COPIED FROM: http://sccode.org/1-5gl
(
var win = Window();
var display = UserView().layout_(HLayout().margins_(30));

var availableNotes = [58, 60, 61, 63, 65, 66, 68, 70].midicps;
var timesNotesWerePlayed = Array.fill(availableNotes.size, { 0 });
var timers = Array.fill(availableNotes.size, { 0 });

var myFavoriteColor = Color(1, 0.333, 0.333);
var mySecondFavoriteColor = Color(1, 1, 1);
var blinkTime = 0.25;

var displayRatio = 0.1;

var playedNote;

availableNotes.size.do({ |note, index|
	var view = UserView();
	var counterView = UserView().animate_(true).frameRate_(24);
	var numberView = UserView().animate_(true);
	var barSize = 0;

	counterView.drawFunc_({ |view|
		barSize = view.bounds.height * displayRatio * timesNotesWerePlayed[index];
		Pen.fillColor_(
			Color(
				myFavoriteColor.red +
				(mySecondFavoriteColor.red - myFavoriteColor.red * timers[index]),
				myFavoriteColor.green +
				(mySecondFavoriteColor.green - myFavoriteColor.green * timers[index]),
				myFavoriteColor.blue +
				(mySecondFavoriteColor.blue - myFavoriteColor.blue * timers[index]),
			)
		);

		Pen.fillRect(
			Rect(
				0, view.bounds.height - barSize,
				view.bounds.width, barSize
			)
		);

		if(timers[index] > 0)
		{ timers[index] = timers[index] - (blinkTime.reciprocal / view.frameRate) }
		{ timers[index] = 0 };
	});

	numberView.drawFunc = { |view|
		Pen.stringCenteredIn(
			timesNotesWerePlayed[index].asString,
			Rect(
				0, 0,
				view.bounds.width, view.bounds.height
			),
			Font.default.deepCopy.size_(view.bounds.height * 0.5),
			Color.white
		)
	};

	view.layout_(
		VLayout(
			[counterView, stretch: 6],
			[numberView, stretch: 1]
		).margins_(3)
	);

	display.layout.add(view);
});

Pbind(
	\instrument, \default,
	\dur, 0.25,

	\amp, 0.5,
	\freq, Prand(availableNotes, inf),

	\foo, Pfunc({ |event|
		playedNote = availableNotes.indexOf(event.freq);

		timesNotesWerePlayed[playedNote] = timesNotesWerePlayed[playedNote] + 1;
		if((timesNotesWerePlayed[playedNote] * displayRatio) >= 1)
		{ displayRatio = displayRatio / 2 };

		timers[playedNote] = 1;

		0
	})
).play;

display.drawFunc_({ |view|
	Pen.fillColor_(myFavoriteColor);
	Pen.fillRect(
		Rect(
			0, 0,
			view.bounds.width, view.bounds.height
		)
	);
	Pen.fillColor_(Color.black);
	Pen.fillRect(
		Rect(
			5, 5,
			view.bounds.width - 10, view.bounds.height - 10
		)
	);
});

win.layout_(
		VLayout(display).margins_(0)
);

win.front;
CmdPeriod.doOnce({ win.close });
)

// COPIED FROM: http://sccode.org/1-5fL#c995
(
//Created by Eli Fieldsteel 2022 Feb 26

var shm, spectrum;

//frequency-scaling factor: closer to zero -> slow motion
var freq_scale = 0.5;

//amplitude-scaling factor: pixel radius when amplitude = 1
var amp_scale = 80;

//spectrum is provided as an array containing one or more events
//each event represents a sine wave with keys for 'freq', 'amp', and 'phs'

//uncomment for examples
/*sine (the default)*/ spectrum = [ (freq:1, amp:1, phs:0) ];
// /*harmonics 1 & 2 */ spectrum = [ (freq:1, amp:1, phs:0), (freq:2, amp:1/2, phs:0) ];
// /*harmonics 1 thru 4 */ spectrum = ((1..4).collect({ |n| (freq:n, amp:1/n, phs:0) }));
// /*sawtooth*/ spectrum = ((1..12).collect({ |n| (freq:n, amp:1/n, phs:0) }));
// /*square*/ spectrum = ((1,3..11).collect({ |n| (freq:n, amp:1/n, phs:0) }));
// /*triangle*/ spectrum = ((1,3..11).collect({ |n| (freq:n, amp:1/(n**2), phs:n.odd.asInteger*pi+(pi/2)) }));
// /*impulse (i.e. "Blip")*/ spectrum = ((1..12).collect({ |n| (freq:n, amp:1/4, phs:pi/2) }));

Window.closeAll;

shm = {
	arg input = [(freq:1, amp:1, phs:0)], freqscl=0.5, ampscl=75, datasize=200, framerate=40;
	var win, cview, wview, phs;
	var t = 0; //time/phase counter
	var wavedata = Array.newClear(datasize); //waveform y-coordinate values

	win = Window(
		"Simple Harmonic Motion Animation — (spacebar to pause/unpause)",
		Rect(100, 100, 1020, 520)
	).background_(Color.gray(0.2)).front;
	win.view.decorator_(FlowLayout(win.view.bounds, 10@10, 10@10));
	cview = UserView(win.view, 1000@500).background_(Color.gray(0.25));

	cview.drawFunc_({ |v|
		var center, newcenter, x, y;

		//dividing line between circles/waveform
		Pen.width_(2);
		Pen.strokeColor_(Color.gray(0.5));
		Pen.line(600@0, 600@520);
		Pen.stroke;

		//draw circles
		Pen.capStyle_(1);
		Pen.width_(2);
		input.do({ |sine, i|
			if (center == nil) { center = 300@250} { center = newcenter };
			x = cos(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			y = sin(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			newcenter = (x@y) * ampscl * Point(1,-1);
			newcenter = newcenter.translate(center);
			Pen.strokeColor_(Color.gray(i.linlin(0, input.size, 0.7, 0.5), 0.8));
			Pen.addArc(center, sine.amp * ampscl, 0, 2pi);
		});
		Pen.stroke;

		//draw radii
		center = nil;
		Pen.width_(4);
		input.do({ |sine, i|
			if (center == nil) { center = 300@250} { center = newcenter };
			x = cos(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			y = sin(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			newcenter = (x@y) * ampscl * Point(1,-1);
			newcenter = newcenter.translate(center);
			Pen.strokeColor_(Color(0.25, i.linlin(0, input.size-1, 0.55, 0.85), 0.95, 0.9));
			Pen.line(center, newcenter);
			Pen.stroke;
		});

		//draw horizontal line connecting radii to waveform
		Pen.width_(2);
		Pen.strokeColor_(Color.gray(1,0.3));
		Pen.line(600@(newcenter.y), newcenter);
		Pen.stroke;

		//store y-coordinate
		wavedata = wavedata.rotate(1);
		wavedata.put(0, newcenter.y);

		//draw waveform with connecting lines between adjacent wavedata values
		Pen.width_(3);
		Pen.strokeColor_(Color(1, 0.75, 0, 0.6));
		wavedata.drop(-1).do({ |y,i|
			if (y.notNil && wavedata.wrapAt(i+1).notNil)
			{Pen.line(Point(600 + (i*2), y), Point(600 + (i*2+2), wavedata.wrapAt(i+1)))};
		});
		Pen.stroke;

		//advance time
		(t = t + (2pi/framerate))%2pi;

	});

	cview.frameRate_(framerate);
	cview.animate_(true);

	//spacebar to pause
	cview.keyDownAction_({ |v, char|
		if (char == $ ) { cview.animate_(cview.animate.not) };
	});
};

shm.(spectrum, freq_scale, amp_scale); //run
)

// COPIED FROM: http://sccode.org/1-8i
s.boot;

 /*SynthDef section*/
(
SynthDef(\raintree02, {arg freq,amp,pan;
	var out, env;
	env = Env.perc(0.01,0.5);
	out = SinOsc.ar(freq.midicps,0,1.0) * EnvGen.kr(env, doneAction: 2);
	out = Pan2.ar(out, pan);
	out = FreeVerb.ar(out, 0.3,0.3,0.1,amp);
	Out.ar(0, out);
}).send(s);
)


/*Task section*/
(

var midiArray = [ [31,38,41,44,48,52] ,[33,38,45,48,51,55],[35,42,44,45,48,52]  ];

var midi;
var  taskArray = [ 0,0 ];

   Task({

		inf.do({arg num1;

			if( (num1+1).mod(4) == 0,{
			  midiArray = midiArray.scramble;
			  midiArray = midiArray + 1.rand2;
			  });

			  midi = midiArray.wrapAt(num1);
			  num1.postln;

		       midi.postln;
		  taskArray.wrapAt(num1).stop;
            taskArray.wrapPut(num1,
              Task({
		        inf.do({arg num2;
			      var oct;
			      oct = [0,12,24,36].wchoose( [0.2,0.25,0.3,0.25]);

			       Synth(\raintree02,[
		                            \freq, midi.wrapAt(num2)+oct,
		                            \amp,  rrand(0.05, 0.4),
		                            \pan, [-0.8,0.8].wrapAt(num1);
		                              ]);
		       if( (num2+1).mod(40) == 0,{
			           midi = midi.scramble;
		          });

                                 0.25.wait;
		            })
		    }).start;
		    );

      20.wait;


	})
}).start;

 )

// COPIED FROM: http://sccode.org/1-m
(
SynthDef(\dollar, { |out, freq = 440, amp = 0.1, pan = 0, sustain = 1.0|
	var env = EnvGen.kr(Env([amp, amp, 0], [sustain, 0.01]), doneAction: 2);
	var decay = freq ** -0.5 * 100;
	var string = CombL.ar(Decay2.ar(Impulse.ar(0), 0.0001, 0.001), 1/freq, 1/freq, decay);
	var damped = string; //LPF.ar(string, Line.kr(11000, 3000, decay));
	OffsetOut.ar(out, Pan2.ar(damped * env, pan));
}).add;
)

(
SynthDef(\euro, { |out, freq = 440, amp = 0.1, pan = 0, sustain = 1.0|
	var env = EnvGen.kr(Env.perc(0.001, sustain), doneAction: 2);
	var decay = freq ** -0.5 * 100;
	var thing;
	freq = freq * (1..7).nthPrime;
	thing = SinOsc.ar(freq , 0, amp * AmpComp.kr(freq)).mean;
	OffsetOut.ar(out, Pan2.ar(thing * env, pan));
}).add;
)


(
Pdef(\stock, { |note = 0, sustain = 1|
	Pbind(
		\instrument, [\dollar, \euro].choose,
		\note, note.value + Pseq((12..0).curdle(0.1).scramble.flat * 3),
		\dur, sustain.value / 12
	)
})
);

(
Pdef(\ett,
	Pbind(
		\type, \phrase,
		\instrument, \stock,
		\dur, 4,
		\legato, Prand((1..5), inf),
		\note, Prand((0..12), inf) + Prand([[0, 2], [0, 6], [0, 7], 0, 0], inf)
	)
).play
)


// COPIED FROM: http://sccode.org/1-51w
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
{
    var snd, envTime, knee, out;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    envTime = MouseX.kr(1.0e-3, 0.1e-3);
    knee = MouseY.kr(0, -90).dbamp;
    out = DelayC.ar(snd, 0.01, envTime * 0.5) * EnvFollow.ar(snd, 1 - (envTime * SampleRate.ir).reciprocal).max(knee).reciprocal;
    out * 0.1!2
}.play;
)


///////////////////////////////////////////////////////////////

// COPIED FROM: http://sccode.org/1-56B

Quarks.gui //this opens the GUI for quarks, you need to have the JITLibExtensions selected and then recompile the library

(
Ndef(\ambienceMaker).addSpec(\rWet, [-1, 1, \lin]);
Ndef(\ambienceMaker).addSpec(\rateRedux, [0, 1]);
Ndef(\ambienceMaker).addSpec(\bits, [1, 32, \lin]);

Ndef(\ambienceMaker).addSpec(\bpWet, [0, 1, \lin]);
Ndef(\ambienceMaker).addSpec(\bpFreq, \freq);
Ndef(\ambienceMaker).addSpec(\bpRq, [0, 2, \lin]);

Ndef(\ambienceMaker).addSpec(\hpnoise, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\white, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\pink, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\brown, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\gray, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\dust, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\dustDensity, [1, s.sampleRate/2, \exp]);

Ndef(\ambienceMaker).addSpec(\drops, [-48, 0, \db]);
Ndef(\ambienceMaker).addSpec(\dropDensity, [1, s.sampleRate/2, \exp]);
Ndef(\ambienceMaker).addSpec(\dropDecay, [0.001, 1, \exp]);
Ndef(\ambienceMaker).addSpec(\dropFFreq, \freq);
Ndef(\ambienceMaker).addSpec(\dropFRq, [0, 2, \lin]);



Ndef(\ambienceMaker, {
	var noise, src;
	var zeroAmp = 0.0039811;
	var hpnoise = \hpnoise.kr(1).dbamp - zeroAmp;
	var hpNFreq = \hpNFreq.kr(1000, 0.1);
	var white = \white.kr(1).dbamp - zeroAmp;
	var pink = \pink.kr(1).dbamp - zeroAmp;
	var brown = \brown.kr(1).dbamp - zeroAmp;
	var gray = \gray.kr(1).dbamp - zeroAmp;
	var dust = \dust.kr(1).dbamp - zeroAmp;
	var dustDensity = \dustDensity.kr(1);

	var drops = \drops.kr(1).dbamp - zeroAmp;
	var dropDensity = \dropDensity.kr(1);
	var dropDecay = \dropDecay.kr(1);
	var dropFFreq = \dropFFreq.kr(1);
	var dropFRq = \dropFRq.kr(1);


	var bpF;
	var bpWet = \bpWet.kr(0);
	var bpFreq = \bpFreq.kr(20000, 0.01);
	var bpRq = \bpRq.kr(1, 0.01);


	var redux;
	var rWet = \rWet.kr(0);
	var rateRedux = \rateRedux.kr(1, 0.01);
	var bits = \bits.kr(32);


	hpnoise = {HPF.ar(PinkNoise.ar(hpnoise), hpNFreq)}!2;
	white   = {WhiteNoise.ar(white)}!2;
	pink    = {PinkNoise.ar(pink)}!2;
	brown   = {BrownNoise.ar(brown)}!2;
	gray    = {GrayNoise.ar(gray)}!2;
	dust    = {Dust2.ar(dustDensity, dust)}!2;



	src = Mix([white, pink, brown, gray, dust, hpnoise]);

	drops = {Decay.ar(Dust.ar(dropDensity, drops), dropDecay) * PinkNoise.ar}!2;

	src = Mix([src, drops]);

	bpF = BPF.ar(src, bpFreq, bpRq);
	src = SelectX.ar(bpWet, [src, bpF]);

	redux = Latch.ar(src, Impulse.ar(SampleRate.ir * (rateRedux/2)));
	redux = redux.round(0.5 ** bits);
	SelectX.ar(1 + rWet, [src - redux, src, redux]);

})
)


Ndef(\ambienceMaker).gui

(
Ndef('noiseBurst').set('white', -48.0, 'pink', -40.494860819681, 'bpWet', 0.76190476190476, 'bpRq', 1.2910052910053, 'dust', -17.0397263296, 'dropDecay', 0.0066895487869141, 'dustDensity', 4.89136346687, 'bits', 3.952380952381, 'noiseType', 1.1746031746032, 'dropFFreq', 119.89685006379, 'bpFreq', 928.31776672256, 'brown', -36.400703367795, 'dropDensity', 6.7191745397468, 'dropFRq', 0.074074074074074, 'gray', -48.0, 'rateRedux', 0.47619047619048, 'drops', -9.8101205277825, 'rWet', 0.37037037037037);

)