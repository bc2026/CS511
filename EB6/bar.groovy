
 // Bar Problem
 // 20 Feb 2025

 
import java.util.concurrent.Semaphore
import groovy.transform.Field

final int NP = 2
final int NJ = 2

Semaphore ticket = new Semaphore(0)
Semaphore mutex = new Semaphore(1)
@Field volatile Boolean itGotLate = false

NP.times {
    Thread.start { // Patriots
	ticket.release()
    }
}

NJ.times {
    Thread.start { // Jets
	mutex.acquire()
	if (!itGotLate) {
	    ticket.acquire()
	    ticket.acquire()
	}
	mutex.release()
	// goes in
    }
}

Thread.start {
    sleep(1000)
    itGotLate=true;
    ticket.release(2)
}
