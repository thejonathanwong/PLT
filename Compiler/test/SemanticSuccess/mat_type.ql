def test_func(comp a, comp b, comp c, comp d) : matc ret_val { 

	matc x;

	x = [(a,b)(c,d)];

	ret_val = x;
}

def compute() : matc ret_val {


	comp a;
	comp b;
	comp c;
	comp d;
        matc k;

	a = C(4.+5.I);
	b = C(6.+6.I);
	c = C(7.+8.I);
	d = C(9.+10.I);

	ret_val = test_func(a, b, c, d);
}
