/* start the simulation */
public class Assignment2 {
    public static void main(String[] args) {
        Bakery b = new Bakery();

        Thread thread = new Thread(b);
        thread.start();

        try {
            thread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
