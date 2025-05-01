bool wantP = false;
bool wantQ = false;



active proctype P()
{
    do 
    ::
        atomic {
        wantP = true;
        }
        
        do
            :: wantQ -> skip
            :: else break
        od

        //enter cs 
        atomic{
        wantP = false;
        }
}

active proctype Q(){
    do
    ::
    atomic{
        wantQ = true;
    }

        do 
            :: wantP -> skip
            :: else break
        od

        //cs
        atomic{
        wantQ = false;
        }
    od
}


