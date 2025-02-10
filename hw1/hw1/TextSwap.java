import java.io.*;
import java.util.*;


public class TextSwap {

    private static String readFile(String filename, int chunkSize) throws Exception {
        String line;
        StringBuilder buffer = new StringBuilder();
        File file = new File(filename);
//	 The "-1" below is because of this:
//	 https://stackoverflow.com/questions/729692/why-should-text-files-end-with-a-newline
	 if ((file.length()-1) % chunkSize!=0)
	     { throw new Exception("File size not multiple of chunk size"); };


        BufferedReader br = new BufferedReader(new FileReader(file));
        while ((line = br.readLine()) != null){
            buffer.append(line);
        }
        br.close();
        return buffer.toString();
    }

    private static Interval[] getIntervals(int numChunks, int chunkSize) {
        // TODO: Implement me!
        int letter_index = 0;
        int array_index = 1;

        Interval currentChunk = new Interval(0, chunkSize);
        Interval resultInterval[] = new Interval[numChunks];

        resultInterval[0] = currentChunk;

        do {
            if (letter_index == chunkSize)
            {
                // new chunk
                int x = currentChunk.getY();
                int y = x + (chunkSize);

                Interval nextChunk = new Interval(x, y);
                currentChunk = nextChunk;

                resultInterval[array_index] = nextChunk;

                array_index++;
                letter_index = 0;
            }

            letter_index++;
        } while (array_index != numChunks);

        return resultInterval;
    }

    private static List<Character> getLabels(int numChunks) {
        Scanner scanner = new Scanner(System.in);
        List<Character> labels = new ArrayList<Character>();
        int endChar = numChunks == 0 ? 'a' : 'a' + numChunks - 1;
        System.out.printf("Input %d character(s) (\'%c\' - \'%c\') for the pattern.\n", numChunks, 'a', endChar);
        for (int i = 0; i < numChunks; i++) {
            labels.add(scanner.next().charAt(0));
        }
        scanner.close();
        // System.out.println(labels);

        return labels;
    }

    private static char[] runSwapper(String content, int chunkSize, int numChunks) throws Exception {
        // TODO: Order the intervals properly, then run the Swapper instances.

        List<Character> labels = getLabels(numChunks);
        Interval[] intervals = getIntervals(numChunks, chunkSize);
        char[] buffer = new char[content.length()]; // Create a shared buffer

//        boolean temp = false;

        List<Thread> T = new ArrayList<Thread>();

        char currentLabel;
        Interval currentInterval = null;
//        Swapper s = new Swapper(null, content, null, 0);

        for (int i = 0; i < labels.size(); i++) {
            currentLabel = Character.toLowerCase(labels.get(i));
            currentInterval = intervals[currentLabel-'a'];

            if(currentInterval != null) {
                Swapper s = new Swapper(currentInterval, content, buffer, i);

                Thread t = new Thread(s);
                t.start();
                T.add(t);
            }
            else throw new Exception("Current interval is null");
        }

        for (Thread thread : T) {
            try {
                thread.join();
            }
            catch (InterruptedException e) {
                e.printStackTrace();
            }

        }
        return buffer; // Return final buffer after all threads complete
    }

    private static void writeToFile(String contents, int chunkSize, int numChunks) throws Exception {
        char[] buff = runSwapper(contents, chunkSize, contents.length() / chunkSize);
        PrintWriter writer = new PrintWriter("output.txt", "UTF-8");
        writer.print(buff);
        writer.close();
    }

     public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.out.println("Usage: java TextSwap <chunk size> <filename>");
            return;
        }
        String contents = "";

        int chunkSize = Integer.parseInt(args[0]);

        if(chunkSize > 26) throw new Exception("“Chunk size too small");


        try {
            contents = readFile(args[1],chunkSize);

//            if((contents.length()-1) % chunkSize != 0) throw new Exception("File size must be a multiple of the chunk size");

            Interval[] intervals = getIntervals(contents.length() / chunkSize, chunkSize);

            writeToFile(contents, chunkSize, contents.length() / chunkSize);
        } catch (Exception e) {
            System.out.println("Error with IO.");
            return;
        }
    }
}
