// byte sem = 0;


// inline acquire(sem)
// {
//     active proctype A()
//     {
//     do
//         ::
//             do 
//                 :: sem != 0 -> skip
//                 :: else -> break
//             od;


//         //cs
//         atomic {sem = sem+1}
//         //exit
//     }
// }

// inline release(sem)
// {
//     active proctype R()
//     {
//     do
//         ::
//             do 
//                 :: sem != 0 -> skip
//                 :: else -> break
//             od;


//         //cs
//         atomic {sem = sem-1}
//         //exit
//     }
// }



inline acquire(s) {
    do
    :: atomic {
        s > 0 ->
        s--;
        break
    }
    od
}

inline release(s) {
    atomic {
        s++
    }
}

// ex 10

#include "bw_sem.h"
byte ticket = 0;
byte mutex = 1;

/* a dd it io nal d e c l a r a t i o n s here */
active [20] proctype Jets () {
    acquire(mutex)
    acquire(ticket)
    acquire(ticket)
    release(mutex)
}
 /* complete */
active [20] proctype Patriots () {
acquire(mutex)

acquire(ticket)
acquire(ticket)

release(mutex)


}
/* complete */