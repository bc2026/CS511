import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Semaphore;
import java.util.concurrent.CountDownLatch;

public class Bakery implements Runnable {
    private static final int TOTAL_CUSTOMERS = 200;
    private static final int CAPACITY = 50;
    private static final int FULL_BREAD = 20;
    private Map<BreadType, Integer> availableBread;
    private ExecutorService executor;
    private float sales = 0;
    private CountDownLatch doneSignal = new CountDownLatch(TOTAL_CUSTOMERS);

    // Synchronization primitives
    private final Semaphore storeCapacity = new Semaphore(CAPACITY);
    private final Semaphore ryeShelf = new Semaphore(1);
    private final Semaphore sourdoughShelf = new Semaphore(1);
    private final Semaphore wonderShelf = new Semaphore(1);
    private final Semaphore cashiers = new Semaphore(4);

    public void run() {
        // Initialize stock
        availableBread = new ConcurrentHashMap<>();
        availableBread.put(BreadType.RYE, FULL_BREAD);
        availableBread.put(BreadType.SOURDOUGH, FULL_BREAD);
        availableBread.put(BreadType.WONDER, FULL_BREAD);

        executor = Executors.newFixedThreadPool(CAPACITY);

        // Start customer threads
        for (int i = 0; i < TOTAL_CUSTOMERS; i++) {
            executor.execute(new Customer(this, doneSignal));
        }

        try {
            doneSignal.await();
            System.out.printf("Total sales = %.2f\n", sales);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            executor.shutdown();
        }
    }

    public void enterStore() throws InterruptedException {
        storeCapacity.acquire();
        System.out.println("Customer entered the bakery.");
    }

    public void exitStore() {
        storeCapacity.release();
        System.out.println("Customer exited the bakery.");
    }

    public void takeBreadWithLock(BreadType bread) throws InterruptedException {
        Semaphore shelf = getShelfSemaphore(bread);
        shelf.acquire();
        takeBread(bread);
        shelf.release();
    }

    private Semaphore getShelfSemaphore(BreadType bread) {
        return switch (bread) {
            case RYE -> ryeShelf;
            case SOURDOUGH -> sourdoughShelf;
            case WONDER -> wonderShelf;
        };
    }

    public void checkout(float value) throws InterruptedException {
        cashiers.acquire();
        System.out.println("Customer checking out...");
        Thread.sleep(300 + (int)(Math.random() * 700)); // Simulate checkout time
        addSales(value);
        cashiers.release();
    }

    public void takeBread(BreadType bread) {
        int breadLeft = availableBread.get(bread);
        if (breadLeft > 0) {
            availableBread.put(bread, breadLeft - 1);
        } else {
            System.out.println("No " + bread.toString() + " bread left! Restocking...");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException ie) {
                ie.printStackTrace();
            }
            availableBread.put(bread, FULL_BREAD - 1);
        }
    }

    public void addSales(float value) {
        sales += value;
    }
}
