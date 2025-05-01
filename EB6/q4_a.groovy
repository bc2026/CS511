import java.util.concurrent.Semaphore

Semaphore gasUp = new Semaphore(6, true)

final int NC = 100
final int NT = 10
final int i = 0
final int truckFilling = 0


NC.times{
    Thread.start()
    {
       gasUp.acquire() 
       i++

       if(i < 7)
       {
            println("Car filling up...")
       }

       gasUp.release()
    }
}


NT.times{
    Thread.start{
        gasUp.acquire(6)

        println("Truck filling up...")
          
        gasUp.release(6)
    }
}