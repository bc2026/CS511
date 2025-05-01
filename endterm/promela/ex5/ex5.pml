bool flag [2]
bool turn

byte critical = 0

active [2] proctype user ()
{
    flag [_pid] = true ;
    turn = _pid ;
    do
    :: ( flag [1 - _pid ] == false || turn == 1 - _pid ) -> break
    :: else -> skip
    od;
    // critical section
    atomic{
        critical = 1
        printf("critical=%d", critical);
    } 
    flag [ _pid ] = false
}