// Bhagawat Chapagain
// Konstantinos Mokos
// I pledge my honor that I have abided by the Stevens Honor System

import java.util.concurrent.Semaphore

Semaphore a = new Semaphore(1)
Semaphore b = new Semaphore(0)
Semaphore c = new Semaphore(0)

Thread.start{ //P
    while(true)
    {
        a.acquire()
        print("a")
        b.release()
    }
}


Thread.start{ // Q
    while(true)
    {  
        b.acquire();
        print("b")
        c.release();
    }
}


Thread.start{ // R
    while(true)
    {
        c.acquire()
        print("c")
        c.release()
    }
}


Thread.start{ // S
    while(true)
    {
        c.acquire()
        a.release()
    }
}
