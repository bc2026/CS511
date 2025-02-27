// Konstantinos Mokos & Bhagawat Chapagain

import java.util.concurrent.Semaphore

Semaphore gasUp = new Semaphore(6, true)
Semaphore Cmutex = new Semaphore(1)
Semaphore Tmutex = new Semaphore(1)
Semaphore inUse = new Semaphore(1)



final int NC = 100 
final int NT = 10

final int NCt = 0
final int NTt = 0



NC.times{
    Thread.start{
        gasUp.acquire()
        
        Cmutex.acquire()
        if(NCt == 0)
        {  
            inUse.acquire()
        }
            NCt++
        Cmutex.release()
        println("Cars are refueling...")
        println("Cars: " + NCt.toString() + ", " + "Trucks:" + NTt.toString())

        Cmutex.acquire()
        NCt--

        if(NCt == 0)
        {
            inUse.release()
        }

        Cmutex.release()
        gasUp.release()
        
    }
}

NT.times{
    Thread.start{
        // Truck
        
        Tmutex.acquire()
        
        if(NTt == 0)
        {  
            inUse.acquire()
        }
        
        NTt++


        Tmutex.release()    
        println("Trucks are refueling...")
        println("Cars: " + NCt.toString() + ", " + "Trucks:" + NTt.toString())

        Tmutex.acquire()
        NTt--

        if(NTt == 0)
        {
            inUse.release()
        }

        Tmutex.release()
    }
}