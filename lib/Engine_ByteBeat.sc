// A bytebeat interpreter
//
// This engine will not produce any audio initially. Use the "expr" command
// to set the bytebeat expression to be evaluated by the UGen.
//
// Requires the ByteBeat UGen to be installed in the SuperCollider user
// extensions directory. See: https://github.com/midouest/bytebeat

Engine_ByteBeat : CroneEngine {
    var <synth;
    var <controller;

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        SynthDef.new(\bytebeat, {
          arg out, amp=0.5, amplag=0.02;
          var amp_ = Lag.ar(K2A.ar(amp), amplag);
          var t = PulseCount.ar(Impulse.ar(8000));
          Out.ar(out, (ByteBeat.ar(t) * amp).dup)
        }).add;

        context.server.sync;

        synth = Synth.new(\bytebeat);
        // Second argument is the index of UGen in the synth. This is required
        // to send unit commands to the UGen while it is running.
        controller = ByteBeatController(synth, 3);

        // Argument is a string containing the bytebeat expression to be
        // evaluated.
        this.addCommand(\expr, "s", { arg msg;
          controller.eval(msg[1]);
        });

        // Set the amplitude amount of the synth output
        this.addCommand(\amp, "f", { arg msg;
          synth.set(\amp, msg[1]);
        });
    }

    free {
        synth.free;
    }
}
