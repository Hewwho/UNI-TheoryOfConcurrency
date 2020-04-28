package Sync;

import java.util.LinkedList;
import java.util.Queue;

public class Buffer {
    int sizeMax;
    Queue<Integer> buffer;

    public Buffer(int sizeMax) {
        this.sizeMax = sizeMax;
        this.buffer = new LinkedList<>();
    }

    public int empty() {
        return buffer.poll();
    }

    public void fill(int value) {
        buffer.add(value);
    }

    public int emptyLeft () {
        return (sizeMax - buffer.size());
    }

    public int fullLeft () {
        return buffer.size();
    }
}
