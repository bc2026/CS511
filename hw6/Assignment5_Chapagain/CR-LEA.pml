#define N 5
#define L (2*N)

mtype = { id_msg, leader_msg }

chan q[N] = [L] of { mtype, byte }; // asynchronous ring channels

proctype Node(chan inp, out; byte myid)
{
    bit is_active = 1, know_leader = 0;
    byte nr, maxid = myid, neighborR;

    xr inp; // exclusive receive access
    xs out; // exclusive send access

    printf("Node %d started\n", myid);
    out!id_msg(myid);

    do
    :: inp?id_msg(nr) ->
        if
        :: is_active ->
            if
            :: nr != maxid ->
                out!leader_msg(nr);
                neighborR = nr
            :: else ->
                know_leader = 1;
                out!leader_msg(nr);
            fi
        :: else ->
            out!id_msg(nr)
        fi
    :: inp?leader_msg(nr) ->
        if
        :: is_active ->
            if
            :: neighborR > nr && neighborR > maxid ->
                maxid = neighborR;
                out!id_msg(neighborR)
            :: else ->
                is_active = 0
            fi
        :: else ->
            out!leader_msg(nr)
        fi
    :: inp?leader_msg(nr) ->
        if
        :: nr != myid ->
            printf("Node %d: LOST\n", myid)
        :: else ->
            printf("Node %d: LEADER\n", myid)
        fi;
        if
        :: know_leader -> skip
        :: else -> out!leader_msg(nr)
        fi;
        break
    od
}

init {
    byte i;
    atomic {
        // create the ring
        i = 0;
        do
        :: i < N ->
            run Node(q[(i+N-1)%N], q[i], i+1);
            i++
        :: else -> break
        od
    }
}