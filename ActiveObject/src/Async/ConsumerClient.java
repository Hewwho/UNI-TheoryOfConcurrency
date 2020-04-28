package Async;

import java.util.Random;


public class ConsumerClient implements Runnable {
    private Scheduler scheduler;
    private int size;
    private Random generator = new Random();

    public ConsumerClient(Scheduler scheduler, int size){
        this.scheduler = scheduler;
        this.size = size;
    }

    @Override
    public void run() {

        while (true) {

            Task task = new Task(
                    TaskType.CONSUME,
                    generator.nextInt((int)Math.ceil((double)size/2)) + 1,
                    -1);

            scheduler.enqueueTask(task);


            while(!task.future.isDone()) {
                //
                //Thread.sleep(100);
            }

            System.out.println("CONSUMER " + Thread.currentThread().getId() + " FINISHED (" + task.size + ") ######################");

        }
    }
}
