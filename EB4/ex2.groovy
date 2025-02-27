import java.util.concurrent.Semaphore

Semaphore sem_LAS = new Semaphore(0)
Semaphore sem_ER = new Semaphore(0)


Thread.start { // P
print("L")
sem_LAS.release()

sem_ER.acquire()
print("E")
print("R")
sem_ER.release()


}

Thread.start { // Q
sem_LAS.acquire()
print("A")
print("S")
sem_ER.release()

}



