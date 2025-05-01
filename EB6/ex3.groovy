import java.util.concurrent.Semaphore


class Barrier {
    private int N
    private int i = 0
    
    Semaphore mutex = new Semaphore(1)

    public Barrier(int N)
    {
        this.N = N
    }

    synchronized void waitAtBarrier()
    {
        i++  

        while(i != N)
        {
            wait()
        }

        notify()
    }
}

Barrier b = new Barrier(3)

Thread.start{
    println("a")
    b.waitAtBarrier()
    println("A")

}
Thread.start{
    println("b")
    b.waitAtBarrier()
    println("B")

}
Thread.start{
    println("c")
    b.waitAtBarrier()
    println("C")

}








