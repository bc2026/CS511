class Bar {
	private int NP = 0
	private int NJ = 0
	
	synchronized void patriots()
	{
		NP++
		println ("Patriots fan entered")
		if(NP % 2  == 0)
		{
			notifyAll()
		}
	}

	synchronized void jets(){
		while(NP < 2 || 2*NJ >= NP)
		{
			wait()
			
		}

		NJ++
		println ("Jets fan entered")

	}
}	

Bar b = new Bar()

51.times{
		Thread.start{
			b.jets()
	}
}


100.times{
	Thread.start {
		b.patriots()
	}
}
