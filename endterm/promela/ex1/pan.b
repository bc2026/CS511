	switch (t->back) {
	default: Uerror("bad return move");
	case  0: goto R999; /* nothing to undo */

		 /* PROC R */

	case 3: // STATE 2
		;
		now.x = trpt->bup.oval;
		;
		goto R999;

	case 4: // STATE 12
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC Q */

	case 5: // STATE 2
		;
		now.x = trpt->bup.oval;
		;
		goto R999;

	case 6: // STATE 12
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC P */

	case 7: // STATE 2
		;
		now.x = trpt->bup.oval;
		;
		goto R999;

	case 8: // STATE 12
		;
		p_restor(II);
		;
		;
		goto R999;
	}

