int x = 0;

active proctype P(){ // thread P
    do
    :: 
        if
        :: x<200 -> 
        atomic {
            x = x+1;
        }
        :: else -> break
        fi
    od
}




active proctype Q(){ // thread Q
   do
    :: 
        if
        :: x<200 -> 
        atomic {
            x = x-1;
        }
        :: else -> break
        fi
    od
}

active proctype R(){ // thread R

       do
    :: 
        if
        :: x<200 -> 
        atomic {
            x = 0;
        }
        :: else -> break
        fi
    od

}