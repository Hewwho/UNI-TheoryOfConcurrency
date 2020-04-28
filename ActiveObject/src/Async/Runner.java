package Async;

public class Runner {

    public static void main(String[] args) {
        final int producers = 6;
        final int consumers = 5;
        final int sizeMax = 60;

        Thread[] producerThreads = new Thread[producers];
        Thread[] consumerThreads = new Thread[consumers];

        Scheduler scheduler = new Scheduler(sizeMax);
        Thread schedulerThread = new Thread(scheduler);

        schedulerThread.start();

        ProducerClient pc = new ProducerClient(scheduler, sizeMax);
        for(int i = 0; i < producers; i++) {
            producerThreads[i] = new Thread(pc);
            producerThreads[i].start();
        }


        ConsumerClient cc = new ConsumerClient(scheduler, sizeMax);
        for(int i = 0; i < consumers; i++) {
            consumerThreads[i] = new Thread(cc);
            consumerThreads[i].start();
        }
    }
}


//szczególnie 5.3.1
//zadanie z pdfa 2.2 na ocenę za dwa tygodnie (można też zrobić na za tydzień), a tamto 2.1 na plusa na za tydzień
//ważne jest rozproszenie bufora (po pamięci wielu procesów)
//trzeba pomyśleć gdzie będziemy tracić na komunikatach (nic nie zyskujemy)
//chcemy to zrobić tak żeby jak najmniej się komunikować
//i takie pytanie: którędy płynie sterowanie a którędy płyną dane, bo jeżeli dane są ciężkie to sterowanie typu czy już mogę, jest wolne