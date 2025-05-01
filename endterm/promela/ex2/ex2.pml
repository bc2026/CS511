int turn = 1;

active proctype P()
{
    do
    ::
        do
            :: turn != 1 -> skip
        od

        atomic {
        turn = 2;
        }
    od
}

active proctype Q()
{
    do
    ::
        do
            :: turn != 1 -> skip
        od

        atomic {
        turn = 1;
        }
    od
}
