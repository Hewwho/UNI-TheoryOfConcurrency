package Sync;

import java.util.Random;

public class Runner {
    public static void main(String[] args) {

        final int producers = 6;
        final int consumers = 5;
        final int size = 60;
        Random generator = new Random();

        Monitor monitor = new Monitor(size);

        final Runnable producer = () -> {

            while(true) {
                try {
                    monitor.produce(generator.nextInt((int)Math.ceil((double)size/2)) + 1, (int)Thread.currentThread().getId());

                    //Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        };


        final Runnable consumer = () -> {

            while(true) {
                try {
                    monitor.consume(generator.nextInt((int)Math.ceil((double)size/2)) + 1);

                    //Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        };


        for(int i = 0; i < producers; i++) {
            new Thread(producer).start();
        }

        for(int i = 0; i < consumers; i++) {
            new Thread(consumer).start();
        }

    }
}
