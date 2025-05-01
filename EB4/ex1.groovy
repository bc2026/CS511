import java.util.concurrent.Semaphore

Semaphore af = new Semaphore(0)
Semaphore fc = new Semaphore(0)

Thread.start {
    println "A"
    af.release()
    println "B"
    fc.acquire()
    println "C"
}

Thread.start {
    println "E"
    af.acquire()
    println "F"
    fc.release()
    println "G"
}

