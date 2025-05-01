int n2=0
int n=50

 P = Thread.start {
 	while (n > 0) {
		 n = n - 1
		if(n % 2 != 0)
		
	}	 
}

 Thread.start {
 	while (true) {
		 n2 = n2 + 2*n + 1
	}
}
P.join()
 // if your code prints 2600 you might need an extra line of code here
print(n2)
