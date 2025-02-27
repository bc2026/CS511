import java.util.concurrent.Semaphore

Semaphore I = new Semaphore(0);
Semaphore O = new Semaphore(0);
Semaphore ThreeOKs = new Semaphore(0);


Thread.start{
    print("R");
    I.release();

    ThreeOKs.acquire();
    print("OK");
}

Thread.start{
    // mutex.acquire();
    I.acquire();
    print("I");
    // mutex.release();

    O.release();

    ThreeOKs.acquire();
    print("OK");
}

Thread.start{
    // mutex.acquire();
    O.acquire();
    print("O");
    // mutex.release();

    ThreeOKs.release(3);
    
    print("OK");
}