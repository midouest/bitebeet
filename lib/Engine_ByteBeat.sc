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
          Out.ar(out, (ByteBeat.ar() * amp).dup)
        }).add;

        context.server.sync;

        synth = Synth.new(\bytebeat);
        // 1 is the index of UGen in the synth. This is required to send unit
        // commands to the UGen while it is running.
        controller = ByteBeatController(synth, 1);

        // First argument is a string containing the bytebeat expression to be
        // evaluated. Second argument is integer indicating if the internal time
        // counter should be reset after parsing the incoming expression. If 1,
        // then reset the counter to 0, otherwise the new expression will start
        // evaluating from the current time value.
        this.addCommand(\expr, "si", { arg msg;
          controller.setExpression(msg[1], msg[2]);
        });

        // Set the amplitude amount of the synth output
        this.addCommand(\amp, "f", { arg msg;
          synth.set(\amp, msg[1]);
        });

        // Reset the UGen's internal time counter to 0
        this.addCommand(\restart, "", { arg msg;
            controller.restart();
        });
    }

    free {
        synth.free;
    }
}
