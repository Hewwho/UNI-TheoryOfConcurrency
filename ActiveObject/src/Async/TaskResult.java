package Async;

import java.util.LinkedList;
import java.util.Queue;

public class TaskResult {
    TaskType type;
    Queue<Integer> values;

    public TaskResult(TaskType type) {
        this.type = type;
        values = new LinkedList<>();
    }
}
