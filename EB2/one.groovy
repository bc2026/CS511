import java.util.concurrent.atomic.AtomicBoolean

interface Lock {
    void lock(int id)
    void unlock(int id)
}

class Peterson implements Lock {
    private volatile int turn = 0
    private AtomicBoolean[] flag = [new AtomicBoolean(false), new AtomicBoolean(false)]

    void lock(int id) {
        int other = 1 - id
        flag[id].set(true)  // Indicate this thread wants to enter CS
        turn = other  // Give turn to the other process

        while (flag[other].get() && turn == other) {
            Thread.yield()  // Prevents busy-waiting by yielding CPU
        }
    }

    void unlock(int id) {
        flag[id].set(false)  // Indicate this thread is leaving CS
    }
}

// Peterson's Lock Usage
Lock l = new Peterson()
int c = 0

def P = Thread.start {
    10.times {
        l.lock(0)
        c++  // Critical Section
        l.unlock(0)
    }
}

def Q = Thread.start {
    10.times {
        l.lock(1)
        c++  // Critical Section
        l.unlock(1)
    }
}

P.join()
Q.join()

println "Final value of c: $c"

