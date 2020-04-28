package Async;

import java.util.concurrent.CompletableFuture;

public class Task {
    TaskType type;
    int size, value;
    CompletableFuture<TaskResult> future;

    public Task(TaskType type, int size, int value) {
        this.type = type;
        this.size = size;
        this.value = value;
        this.future = new CompletableFuture<>();
    }
}
