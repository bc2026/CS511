class Sequencer {
    private int signal = 0
    
    synchronized void first()
    {
        while(signal != 0)
        {
            wait()
        }
        
        signal = 1
        println("One is released")
        notifyAll()
    }

    synchronized void second()
    {
        while(signal != 1)
        {
            wait()
        }

        signal = 2
        println("Second is released")
        notifyAll()
    }

    synchronized void third()
    {
        while(signal != 2)
        {
           wait()
        }

        signal = 0
        println("Third is released")
        notifyAll()
    }
}

Sequencer s = new Sequencer()

Thread.start { // P
    s.first()
    s.second()
    s.third()
}