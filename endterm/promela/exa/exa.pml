bool flag[2];
byte turn = 0;

active proctype Q()
{
    do 
    ::
        flag[0] = true
        do 
        :: (flag[1] && turn == 1) -> skip
        :: else -> break
        od;
    
    //cs 
    flag[0] = false
    //remainder
    
    od; 
}

active proctype R()
{
    do 
    ::
        flag[1] = true
        turn = 0

        do
        :: (flag[0] && turn == 0) -> skip
        :: else -> break
        od;

    //cs 
    flag[1] = false
    //remainder

    od;
}

 