package Async;

import java.util.Random;


public class ProducerClient implements Runnable {
    private Scheduler scheduler;
    private int size;
    private Random generator = new Random();

    public ProducerClient(Scheduler scheduler, int size){
        this.scheduler = scheduler;
        this.size = size;
    }

    @Override
    public void run() {

        while (true) {

            Task task = new Task(
                    TaskType.PRODUCE,
                    generator.nextInt((int)Math.ceil((double)size/2)) + 1,
                    (int) Thread.currentThread().getId());

            scheduler.enqueueTask(task);


            while(!task.future.isDone()) {
                //
                //Thread.sleep(100);
            }

            System.out.println("PRODUCER " + Thread.currentThread().getId() + " FINISHED (" + task.size + ")");

        }
    }
}
