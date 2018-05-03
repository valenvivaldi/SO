public class Consumer extends Thread {
	private Buffer buffer;

	public Consumer(Buffer buffer) {
		super();
		this.buffer = buffer;
	}

	public synchronized void run()  {
		while(true) {
			while (buffer.empty()) {
				try {
					System.out.println("buffer vacio");
					wait();
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			
			buffer.get();
			notifyAll();
		}

	}


}


