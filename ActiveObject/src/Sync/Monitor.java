package Sync;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class Monitor {
    private ReentrantLock lockCommon = new ReentrantLock();
    private ReentrantLock lockProducer = new ReentrantLock();
    private ReentrantLock lockConsumer = new ReentrantLock();

    private Condition notEnoughEmpty = lockCommon.newCondition();
    private Condition notEnoughFull = lockCommon.newCondition();

    Buffer buffer;
    int sizeMax;

    public Monitor (int sizeMax){
        this.sizeMax = sizeMax;
        this.buffer = new Buffer(sizeMax);
    }


    public void produce(int toProduce, int value) throws InterruptedException {

        try {
            lockProducer.lock();

            try {
                lockCommon.lock();

                while(buffer.emptyLeft() < toProduce) {
                    notEnoughEmpty.await();
                }

                for(int i = 0; i < toProduce; i++) {
                    buffer.fill(value);
                }
                System.out.println("PRODUCING(" + Thread.currentThread().getId() + "): " + toProduce);

                notEnoughFull.signal();

            } finally {
                lockCommon.unlock();
            }

        } finally {
            lockProducer.unlock();
        }

    }


    public void consume(int toConsume) throws InterruptedException {

        try {
            lockConsumer.lock();

            try {
                lockCommon.lock();

                while(buffer.fullLeft() < toConsume) {
                    notEnoughFull.await();
                }

                for(int i = 0; i < toConsume; i++) {
                    buffer.empty();
                }
                System.out.println("CONSUMING(" + Thread.currentThread().getId() + "): " + toConsume);

                notEnoughEmpty.signal();
            } finally {
                lockCommon.unlock();
            }

        } finally {
            lockConsumer.unlock();
        }

    }
}
