
import java.util.LinkedList;
import java.util.Queue;

public class Buffer  {
	public Buffer() {
		super();
		this.buff = new LinkedList<String>();
		
	}

	Queue<String> buff;

	public boolean full() {
		return (buff.size()>=10);
	}

	public synchronized void put(String v)  {
		System.out.println("se agrego el elemento "+v);
		buff.add(v);
		

	}

	public boolean empty() {
		
		return buff.isEmpty();
	}

	public synchronized String get()  {
		System.out.println("se saca el elemento "+buff.peek());
		return buff.remove();
		
	}

}
