package Async;

import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class Scheduler implements Runnable {
    private Queue<Task> queueMain = new LinkedList<>();
    private Queue<Task> queueProduce = new LinkedList<>();
    private Queue<Task> queueConsume = new LinkedList<>();

    private ReentrantLock lockMain = new ReentrantLock();

    private Condition conditionEmpty = lockMain.newCondition();

    private Servant servant;

    public Scheduler(int sizeMax) {
        servant = new Servant(sizeMax);
    }

    @Override
    public void run() {
        while (true) {
            Task task = getNextTask();

            if(servant.canExecute(task)) {
                TaskResult result = servant.execute(task);
                task.future.complete(result);
            } else {
                putToWaitingQueue(task);
            }
        }
    }

    public void enqueueTask(Task task) {
        try {
            lockMain.lock();
            queueMain.add(task);
            conditionEmpty.signal();
        } finally {
            lockMain.unlock();
        }
    }

    private Task getNextTask() {

        Task task;

        if(!queueProduce.isEmpty() && servant.canExecute(queueProduce.peek())) {
            task = queueProduce.poll();
        } else if(!queueConsume.isEmpty() && servant.canExecute(queueConsume.peek())){
            task = queueConsume.poll();
        } else {
            try {
                lockMain.lock();

                try {
                    while (queueMain.isEmpty()) {
                        conditionEmpty.await();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                task = queueMain.poll();
            } finally {
                lockMain.unlock();
            }
        }

        return task;
    }

    private void putToWaitingQueue(Task task) {

        switch (task.type) {
            case PRODUCE:
                queueProduce.add(task);
                break;
            case CONSUME:
                queueConsume.add(task);
                break;
        }
    }
}
