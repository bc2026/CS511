import java.util.concurrent.Semaphore;


int catsEating = 0
int dogsEating = 0
Semaphore dog = new Semaphore(0);
Semaphore cat = new Semaphore(0);
Semaphore mutexC = new Semaphore(1);

Semaphore mutexD = new Semaphore(1);


20.times{   
    Thread.start{ // Cat
        mutexC.acquire()
        if(dogsEating == 0)
        {
            println("Cat entering feeding area...")
        }
        mutexC.release()
        
        cat.acquire()
        println("Cat feeding...")
        catsEating++
        println("Cat leaving feeding area...")
        catsEating--;

        mutexC.acquire()
            if(catsEating == 0)
            {
                dog.release()
            }
        mutexC.release()    

    }
}

20.times{ 
  Thread.start{ // Cat
        mutexD.acquire()
        if(catsEating == 0)
        {
            println("Dog entering feeding area...")
        }
        mutexD.release()
        
        cat.acquire()
        println("Cat feeding...")
        catsEating++
        entering.release()
        println("Cat leaving feeding area...")
        catsEating--;

        mutex.acquire()
            if(dogsEating == 0)
            {
                cat.release()
            }
        mutex.release()    

    }
}