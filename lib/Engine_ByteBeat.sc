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
          arg out;

          var rate = \rate.kr(8000),
              amplag = \amplag.kr(0.02),
              amp = \amp.kr(0.5, amplag),
              reset = \reset.tr(0);

          var t = PulseCount.ar(Impulse.ar(rate), reset);
          Out.ar(out, (ByteBeat.ar(t) * amp).dup);
        }).add;

        context.server.sync;

        synth = Synth.new(\bytebeat);
        // Second argument is the index of UGen in the synth. This is required
        // to send unit commands to the UGen while it is running.
        controller = ByteBeatController(synth, 8);

        // Argument is a string containing the bytebeat expression to be
        // evaluated.
        this.addCommand(\eval, "si", { arg msg;
          controller.eval(msg[1]);
          synth.set(\reset, msg[2]);
        });

        // Set the amplitude amount of the synth output
        this.addCommand(\amp, "f", { arg msg;
          synth.set(\amp, msg[1]);
        });

        this.addCommand(\reset, "", { arg msg;
          synth.set(\reset, 1);
        });
    }

    free {
        synth.free;
    }
}
