import java.util.concurrent.Semaphore


final int N = 4
int i = 0
int j = 0

permToBoard = [new Semaphore(1), new Semaphore(1)]
confirmOnBoard = [new Semaphore(0), new Semaphore(0)]
permToLeave = new Semaphore(0)
gotOff = new Semaphore(0)
mutex = new Semaphore(1)

2.times{
    Thread.start{
        int floor = 0
        while(true)
        {
            for (int i = 0; i < N; i++) {
                permToBoard[floor].release()     // Allow a worker to board
                confirmOnBoard[floor].acquire()  // Wait for worker to confirm boarding
            }
        
            if(i == N)
            {
                permToLeave.release()
            }

            if(j == N)
            {
                permToLeave.release()
            }

    
            floor = 1 - floor

            for (int i = 0; i < N; i++) {
                permToLeave.release()  // Allow a worker to leave
            }
            
            for (int i = 0; i < N; i++) {
                gotOff.acquire()  // Wait for each worker to confirm exit
            }
        
        }
    }
}

100.times{
    Thread.start{
        permToBoard[0].acquire()
        confirmOnBoard[0].release()

        // get off
        permToLeave.acquire()
        gotOff.release()
    }
}

100.times{
    Thread.start{
        permToBoard[1].acquire()
        confirmOnBoard[1].release()
    
        // get off 
        permToLeave.acquire()
        gotOff.release()
    }
}
