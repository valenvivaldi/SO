public class Productor extends Thread  {

	private Buffer buffer;
	private int i;

	public Productor(Buffer buffer) {
		super();
		this.buffer = buffer;
	}

	String producir(){
		i++;
		return ""+i;
	}

	public synchronized void run()  {
		String  v; 
		while (true) {
			v= producir();
			while (buffer.full()) {
				try {
					System.out.println("buffer lleno");
					wait();
				} catch (InterruptedException e) {}
			}
			buffer.put(v);
			notifyAll();
		}

	}


}
