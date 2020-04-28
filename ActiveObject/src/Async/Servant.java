package Async;

import java.util.LinkedList;
import java.util.Queue;

public class Servant {
    private int sizeMax;
    private Queue<Integer> buffer = new LinkedList<>();

    public Servant(int sizeMax) {
        this.sizeMax = sizeMax;
    }

    public boolean canExecute(Task task) {
        if (task.type == TaskType.CONSUME) {
            return buffer.size() >= task.size;
        } else {
            return sizeMax >= (buffer.size() + task.size);
        }
    }

    public TaskResult execute (Task task) {
        TaskResult result = new TaskResult(task.type);
        int size = task.size;

        if (task.type == TaskType.PRODUCE) {
            while (size-- > 0) {
                buffer.add(task.value);
            }
        } else {
            while (size-- > 0) {
                result.values.add(buffer.poll());
            }
        }

        return result;
    }

}
