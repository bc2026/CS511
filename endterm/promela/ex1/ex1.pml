int x = 0;

active proctype P(){ // thread P
    do
    :: 
        atomic {
        if
        :: x<200 -> 
            x = x+1;
            assert(x<=200);
        :: else -> break
        fi
        }
    od
}


active proctype Q(){ // thread Q
   do
    :: 
        atomic {
        if
        :: x>0 -> 
            x = x-1;
            assert(x>=0);
        :: else -> break
        fi
        }
    od
}

active proctype R(){ // thread R

       do
    :: 
    atomic{
        if
        :: x==200 -> 

            x = 0;
            assert(x>=0 && x<=200);
        :: else -> break
        fi
        }
    od

}