  import java.util.concurrent.Semaphore;

  Semaphore okA = new Semaphore(3); // Allows "a" to be printed first
  Semaphore okBorC = new Semaphore(0); // Blocks "b" or "c" until "a" is printed
  Semaphore mutex = new Semaphore(1); // Mutex for mutual exclusion

  // Thread P
  Thread.start { // P
    while (true) {
      okA.acquire(); // Wait until it's "a"'s turn
      print("a");
      okBorC.release(); // Allow either "b" or "c" to print
    } 
  }

  // Thread Q
  Thread.start { // Q
    while (true) {
      mutex.acquire();
      okBorC.acquire(3); // Wait until it's "b"'s or "c"'s turn
      print("b");
      okA.release(3); // Allow "a" to print next
      mutex.release();
    }
  }

  // Thread R
  Thread.start { // R
    while (true) {
      mutex.acquire();
      okBorC.acquire(3); // Wait until it's "b"'s or "c"'s turn
      print("c");
      okA.release(3); // Allow "a" to print next
      mutex.release();
    }
  }

