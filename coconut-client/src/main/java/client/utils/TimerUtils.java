package client.utils;

import co.paralleluniverse.fibers.Suspendable;
import co.paralleluniverse.strands.Strand;

import java.util.Timer;
import java.util.TimerTask;

public class TimerUtils extends TimerTask {

    private final Strand s;
    private final Timer timer;

    public TimerUtils(final Strand s, final Timer timer) {
        this.s = s;
        this.timer = timer;
    }

    @Suspendable
    public void run() {
        if (s != null && s.isAlive()) {
            s.interrupt();
            timer.cancel();
        }
    }
}
