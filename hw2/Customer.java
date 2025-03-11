import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Semaphore;

public class Customer implements Runnable {
    private Bakery bakery;
    private Random rnd;
    private List<BreadType> shoppingList;
    private CountDownLatch doneSignal;

    public Customer(Bakery bakery, CountDownLatch doneSignal) {
        this.bakery = bakery;
        this.doneSignal = doneSignal;
        this.rnd = new Random();
        this.shoppingList = new ArrayList<>();
        fillShoppingList();
    }

    public void run() {
        try {
            bakery.enterStore(); // Acquire store capacity semaphore

            // Pick up bread items
            for (BreadType bread : shoppingList) {
                bakery.takeBreadWithLock(bread); // Handles shelf locking inside Bakery
                Thread.sleep(500 + rnd.nextInt(500)); // Simulate shopping time
            }

            // Checkout
            bakery.checkout(getItemsValue()); // Handles cashier locking inside Bakery

            bakery.exitStore(); // Release store capacity semaphore

        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            doneSignal.countDown(); // Mark customer as finished
        }
    }
    private boolean addItem(BreadType bread) {
        return shoppingList.add(bread); // Adds bread and returns true if successful
    }
    private void fillShoppingList() {
        int itemCnt = 1 + rnd.nextInt(3); // 1 to 3 items
        while (itemCnt > 0) {
            addItem(BreadType.values()[rnd.nextInt(BreadType.values().length)]);
            itemCnt--;
        }
    }
    private float getItemsValue() {
        return shoppingList.stream().map(BreadType::getPrice).reduce(0f, Float::sum);
    }
}
