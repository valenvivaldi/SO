
public class Main {

	public static void main(String[] args) {
		Buffer b = new Buffer();
		Consumer c = new Consumer(b);
		Productor p = new Productor(b);

		c.start();
		p.start();
	}
}
