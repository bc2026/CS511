public class Swapper implements Runnable {
    private int offset;
    private Interval interval;
    private String content;
    private char[] buffer;

    public Swapper(Interval interval, String content, char[] buffer, int offset) {
        this.offset = offset;
        this.interval = interval;
        this.content = content;
        this.buffer = buffer;
    }

    @Override
    public void run() {
        Interval currentInterval = getInterval();
        int chunkSize = currentInterval.getY() - currentInterval.getX();
        int newX = getOffset() * chunkSize;
        int newY = newX + chunkSize;

        if (newY > content.length()) {
            throw new IndexOutOfBoundsException("Computed new indices exceed content length.");
        }

        // Extract substrings for swapping
        char[] x = content.substring(currentInterval.getX(), currentInterval.getY()).toCharArray();
        char[] y = content.substring(newX, newY).toCharArray();

        // Perform both swaps on the same buffer
        synchronized (this) {
            // Only update one part of the buffer at a time to avoid overwriting
            System.arraycopy(y, 0, buffer, currentInterval.getX(), y.length);
            System.arraycopy(x, 0, buffer, newX, x.length);
        }

        // Update buffer once
        setBuffer(buffer);
    }

    public String setStringAt(int x, int y, String s) {
        // Ensure indices are within bounds
        if (x < 0 || y > buffer.length || x > y) {
            throw new IllegalArgumentException("Invalid index range");
        }

        // Correct replacement logic (direct buffer manipulation)
        System.arraycopy(s.toCharArray(), 0, buffer, x, s.length());
        return String.valueOf(buffer);
    }

    public char[] getBuffer() {
        return this.buffer;
    }

    public void setContent(String newContent) {
        this.content = newContent;
    }

    public Interval getInterval() {
        return interval;
    }

    public int getOffset() {
        return offset;
    }

    public String getContent() {
        return content;
    }

    public void setBuffer(char[] buffer) {
        this.buffer = buffer;
    }

    @Override
    public String toString() {
        String vars = "(interval, content, buffer, offset)";
        String vals = String.format("(%s, %s, %s, %d)", getInterval(), getContent(), String.valueOf(getBuffer()), getOffset());
        return vars + " = " + vals;
    }
}
