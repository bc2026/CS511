/*
Name1:
Name2:

You may not add print statements but you may add ADDITIONAL semaphores.
The output should be:

aabccaabccaabcc....
*/

import java.util.concurrent.Semaphore;
Semaphore a = new Semaphore(2); 
Semaphore b = new Semaphore(0);
Semaphore c = new Semaphore(0);
// Semaphore cDone = new Semaphore(0)

Thread.start { // P
    while (true) {
	a.acquire()
	print("a");
	b.release()
    }
}

Thread.start { // Q 
    while (true) {
	b.acquire(2)
	print("b");
	c.release(2)
	b.acquire(2)
	a.release(2)
    }
}

Thread.start { // R
    while (true) {
	c.acquire()
	print("c");
	b.release()
    }
}
