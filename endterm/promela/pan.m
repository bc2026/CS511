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
	case 3: // STATE 1 - ex1/ex1.pml:37 - [((x<200))] (0:0:0 - 1)
		IfNotBlocked
		reached[2][1] = 1;
		if (!((now.x<200)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 4: // STATE 2 - ex1/ex1.pml:39 - [x = 0] (0:0:1 - 1)
		IfNotBlocked
		reached[2][2] = 1;
		(trpt+1)->bup.oval = now.x;
		now.x = 0;
#ifdef VAR_RANGES
		logval("x", now.x);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 5: // STATE 11 - ex1/ex1.pml:45 - [-end-] (0:0:0 - 3)
		IfNotBlocked
		reached[2][11] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC Q */
	case 6: // STATE 1 - ex1/ex1.pml:23 - [((x<200))] (0:0:0 - 1)
		IfNotBlocked
		reached[1][1] = 1;
		if (!((now.x<200)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 7: // STATE 2 - ex1/ex1.pml:25 - [x = (x-1)] (0:0:1 - 1)
		IfNotBlocked
		reached[1][2] = 1;
		(trpt+1)->bup.oval = now.x;
		now.x = (now.x-1);
#ifdef VAR_RANGES
		logval("x", now.x);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 8: // STATE 11 - ex1/ex1.pml:30 - [-end-] (0:0:0 - 3)
		IfNotBlocked
		reached[1][11] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC P */
	case 9: // STATE 1 - ex1/ex1.pml:7 - [((x<200))] (0:0:0 - 1)
		IfNotBlocked
		reached[0][1] = 1;
		if (!((now.x<200)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 10: // STATE 2 - ex1/ex1.pml:9 - [x = (x+1)] (0:0:1 - 1)
		IfNotBlocked
		reached[0][2] = 1;
		(trpt+1)->bup.oval = now.x;
		now.x = (now.x+1);
#ifdef VAR_RANGES
		logval("x", now.x);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 11: // STATE 11 - ex1/ex1.pml:14 - [-end-] (0:0:0 - 3)
		IfNotBlocked
		reached[0][11] = 1;
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

