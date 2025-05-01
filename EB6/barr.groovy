// Barrier exercise (one-time use)
// eb6
// 6 March 2025

class Barrier {
    final int N
    int c
    
    Barrier(int size) {
	N=size
	c=0
    }
    
    synchronized void waitAtBarrier() {
	c++
	while (c<N) {
	    wait()
	}
	notify() // cascaded signalling
    }
}
Barrier b = new Barrier (3)

Thread.start{//T1
	print("a")
	b.waitAtBarrier()
	print("1")
}
Thread.start{//T2
	print("b")
	b.waitAtBarrier()
	print("2")
}
Thread.start{//T3
	print("c")
	b.waitAtBarrier()
	print("3")
}
