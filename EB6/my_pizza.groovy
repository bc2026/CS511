import java.util.concurrent.locks.*;
import java.util.Random.*
class Pizza {
    // Variables declared here
    // You can add necessary variables such as semaphores, counters, etc.
    int lg = 0
    int sm = 0

    ReentrantLock lock = new ReentrantLock()
    Condition s = lock.newCondition()
    Condition lOr2s = lock.newCondition()
    

    void purchaseSmallPizza() {
        lock.lock()
        try{
                sm--
                while(sm <= 0)
                {
                    s.await()
                }
        }
        finally{
            lock.unlock()
        }
    }

    void purchaseLargePizza() {
       lock.lock()
        try{
                lg--
                while(lg == 0 && sm < 2)
                {
                    lOr2s.await()
                }

                lg-- ? lg>0 : sm-=2
        }

        finally{
            lock.unlock()
        }
    }

    void bakeSmallPizza() {
       lock.lock()
        try{
                sm++
                s.signalAll()
        }

        finally{
            lock.unlock()
        }
    }

    void bakeLargePizza() {
       lock.lock()
        try{
            lg++
            lOr2s.signalAll()
        }

        finally{
            lock.unlock()
        }
}
}


Pizza p = new Pizza()

100.times {
    Thread.start { //Baker
	switch (new Random()).nextInt(1) {
	    case 0: p.bakeSmallPizza();
		break
	    default:
		p.bakeLargePizza()		
	}
    }
}

100.times {
    Thread.start { // Patron
	switch (new Random()).nextInt(1) {
	    case 0: p.purchaseSmallPizza();
		break
	    default:
		p.purchaseLargePizza()
	}
    }
}
    