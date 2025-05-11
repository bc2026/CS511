#define rand	pan_rand
#define pthread_equal(a,b)	((a)==(b))
#if defined(HAS_CODE) && defined(VERBOSE)
	#ifdef BFS_PAR
		bfs_printf("Pr: %d Tr: %d\n", II, t->forw);
	#else
		cpu_printf("Pr: %d Tr: %d\n", II, t->forw);
	#endif
#endif
	switch (t->forw) {
	default: Uerror("bad forward move");
	case 0:	/* if without executable clauses */
		continue;
	case 1: /* generic 'goto' or 'skip' */
		IfNotBlocked
		_m = 3; goto P999;
	case 2: /* generic 'else' */
		IfNotBlocked
		if (trpt->o_pm&1) continue;
		_m = 3; goto P999;

		 /* PROC R */
	case 3: // STATE 1 - ex1.pml:38 - [((x==200))] (9:0:1 - 1)
		IfNotBlocked
		reached[2][1] = 1;
		if (!((now.x==200)))
			continue;
		/* merge: x = 0(9, 2, 9) */
		reached[2][2] = 1;
		(trpt+1)->bup.oval = now.x;
		now.x = 0;
#ifdef VAR_RANGES
		logval("x", now.x);
#endif
		;
		/* merge: assert(((x>=0)&&(x<=200)))(9, 3, 9) */
		reached[2][3] = 1;
		spin_assert(((now.x>=0)&&(now.x<=200)), "((x>=0)&&(x<=200))", II, tt, t);
		/* merge: .(goto)(9, 7, 9) */
		reached[2][7] = 1;
		;
		/* merge: .(goto)(0, 10, 9) */
		reached[2][10] = 1;
		;
		_m = 3; goto P999; /* 4 */
	case 4: // STATE 12 - ex1.pml:47 - [-end-] (0:0:0 - 1)
		IfNotBlocked
		reached[2][12] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC Q */
	case 5: // STATE 1 - ex1.pml:23 - [((x>0))] (9:0:1 - 1)
		IfNotBlocked
		reached[1][1] = 1;
		if (!((now.x>0)))
			continue;
		/* merge: x = (x-1)(9, 2, 9) */
		reached[1][2] = 1;
		(trpt+1)->bup.oval = now.x;
		now.x = (now.x-1);
#ifdef VAR_RANGES
		logval("x", now.x);
#endif
		;
		/* merge: assert((x>=0))(9, 3, 9) */
		reached[1][3] = 1;
		spin_assert((now.x>=0), "(x>=0)", II, tt, t);
		/* merge: .(goto)(9, 7, 9) */
		reached[1][7] = 1;
		;
		/* merge: .(goto)(0, 10, 9) */
		reached[1][10] = 1;
		;
		_m = 3; goto P999; /* 4 */
	case 6: // STATE 12 - ex1.pml:30 - [-end-] (0:0:0 - 1)
		IfNotBlocked
		reached[1][12] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC P */
	case 7: // STATE 1 - ex1.pml:8 - [((x<200))] (9:0:1 - 1)
		IfNotBlocked
		reached[0][1] = 1;
		if (!((now.x<200)))
			continue;
		/* merge: x = (x+1)(9, 2, 9) */
		reached[0][2] = 1;
		(trpt+1)->bup.oval = now.x;
		now.x = (now.x+1);
#ifdef VAR_RANGES
		logval("x", now.x);
#endif
		;
		/* merge: assert((x<=200))(9, 3, 9) */
		reached[0][3] = 1;
		spin_assert((now.x<=200), "(x<=200)", II, tt, t);
		/* merge: .(goto)(9, 7, 9) */
		reached[0][7] = 1;
		;
		/* merge: .(goto)(0, 10, 9) */
		reached[0][10] = 1;
		;
		_m = 3; goto P999; /* 4 */
	case 8: // STATE 12 - ex1.pml:15 - [-end-] (0:0:0 - 1)
		IfNotBlocked
		reached[0][12] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */
	case  _T5:	/* np_ */
		if (!((!(trpt->o_pm&4) && !(trpt->tau&128))))
			continue;
		/* else fall through */
	case  _T2:	/* true */
		_m = 3; goto P999;
#undef rand
	}

