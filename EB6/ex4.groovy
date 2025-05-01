import java.util.concurrent.locks.*;

class TrainStation {
    ReentrantLock lock = new ReentrantLock()
    Condition N = lock.newCondition()
    Condition S = lock.newCondition()
    int onN = 0
    int onS = 0

    void acquireNorthTrackP() {
        lock.lock()
        try{
            
            while(onN)
            {
                N.await()
            }

            onN = 1
        }

        finally{
            lock.unlock()
        }

    }

    void releaseNorthTrackP() {
        lock.lock()
        try{
            onN = 0
            N.signalAll()
        }

        finally{
            lock.unlock()
        }
    }

    void acquireSouthTrackP()
    {
        lock.lock()
        try{
            while(onS)
            {
                S.await()
            }

            onS = 1
        }

        finally{
            lock.unlock()
        }

    }

    void releaseSouthTrackP (){
        lock.lock()
        try{
            onS = 0
            S.signalAll()
            
        }

        finally{
            lock.unlock()
        }
    }

    void acquireTracksF(){
        lock.lock()
        try{

            while(onN)
            {
                N.await()
            }
            while(onS)
            {
                S.await()
            }

            onN = 1
            onS = 1
        }

        finally{
            lock.unlock()
        }

    }
    void releaseTracksF(){
        lock.lock()
        try{
            onN = 0
            onS = 0


            N.signalAll()
            S.signalAll()
        }

        finally{
            lock.unlock()
        }
    }

}

TrainStation s = new TrainStation();

100.times{
    Thread.start { // Passenger Train going North
        s.acquireNorthTrackP();
        println "NPT"+Thread.currentThread().getId();
        s.releaseNorthTrackP();
    }
}

100.times{
    Thread.start { // Passenger Train going South
        s.acquireSouthTrackP();
        println "SPT"+ Thread.currentThread().getId();
        s.releaseSouthTrackP()
    }
}

10.times {
    Thread.start { // Freight Train
        s.acquireTracksF();
        println "FT "+ Thread.currentThread().getId();
        s.releaseTracksF();
    }
}