task sb_test_case();

nb = 36;
nv = 20;
cmax = 8;
vmax = 8;

cbin = '{
	//bin 1
	'{2, 0, 2, 2, 0, 0, 0, 0},
	'{0, 0, 2, 0, 1, 1, 0, 0},
	'{0, 2, 2, 0, 1, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 2
	'{2, 0, 0, 0, 0, 2, 2, 0},
	'{0, 0, 2, 1, 1, 0, 0, 0},
	'{1, 2, 0, 1, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 3
	'{1, 0, 0, 0, 2, 1, 0, 0},
	'{0, 2, 1, 2, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 4
	'{2, 1, 0, 0, 2, 0, 0, 0},
	'{1, 0, 0, 2, 2, 0, 0, 0},
	'{0, 0, 1, 0, 0, 1, 2, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 5
	'{2, 0, 0, 2, 0, 1, 0, 0},
	'{0, 2, 2, 0, 2, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 6
	'{1, 1, 0, 1, 0, 0, 0, 0},
	'{0, 0, 0, 0, 1, 1, 2, 0},
	'{0, 2, 1, 2, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 7
	'{0, 0, 0, 2, 1, 0, 2, 0},
	'{0, 1, 0, 2, 1, 0, 0, 0},
	'{2, 0, 2, 0, 0, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 8
	'{0, 2, 1, 0, 1, 0, 0, 0},
	'{1, 0, 0, 2, 0, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 9
	'{0, 1, 0, 1, 1, 0, 0, 0},
	'{2, 0, 1, 0, 2, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 10
	'{2, 2, 2, 0, 0, 0, 0, 0},
	'{0, 0, 0, 1, 2, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 11
	'{0, 0, 1, 0, 2, 2, 0, 0},
	'{0, 2, 0, 2, 0, 0, 2, 0},
	'{1, 0, 0, 1, 0, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 12
	'{0, 0, 0, 2, 1, 2, 0, 0},
	'{2, 0, 2, 0, 0, 0, 1, 0},
	'{0, 0, 0, 0, 1, 1, 1, 0},
	'{0, 2, 1, 0, 0, 0, 1, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 13
	'{1, 0, 0, 1, 0, 2, 0, 0},
	'{0, 2, 1, 0, 1, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 14
	'{2, 1, 0, 1, 0, 0, 0, 0},
	'{0, 0, 0, 1, 1, 1, 0, 0},
	'{0, 0, 1, 2, 2, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 15
	'{1, 0, 2, 2, 0, 0, 0, 0},
	'{0, 2, 0, 0, 1, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 16
	'{1, 0, 1, 0, 0, 2, 0, 0},
	'{0, 1, 0, 1, 2, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 17
	'{0, 2, 1, 0, 2, 0, 0, 0},
	'{1, 0, 0, 2, 0, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 18
	'{1, 0, 0, 0, 2, 1, 0, 0},
	'{0, 0, 1, 2, 0, 0, 1, 0},
	'{0, 1, 0, 0, 2, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 19
	'{2, 1, 0, 0, 0, 1, 0, 0},
	'{0, 0, 1, 0, 1, 0, 2, 0},
	'{0, 0, 0, 1, 0, 1, 1, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 20
	'{1, 1, 0, 2, 0, 0, 0, 0},
	'{0, 0, 2, 0, 2, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 21
	'{1, 0, 0, 0, 2, 1, 0, 0},
	'{0, 2, 2, 1, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 22
	'{0, 0, 2, 0, 1, 2, 0, 0},
	'{1, 1, 0, 1, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 23
	'{0, 1, 0, 1, 0, 0, 1, 0},
	'{0, 2, 1, 0, 1, 0, 0, 0},
	'{1, 0, 2, 0, 0, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 24
	'{2, 0, 2, 1, 0, 0, 0, 0},
	'{0, 1, 0, 0, 1, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 25
	'{0, 0, 1, 2, 2, 0, 0, 0},
	'{1, 1, 0, 0, 1, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 26
	'{0, 2, 0, 0, 1, 1, 0, 0},
	'{0, 0, 1, 2, 1, 0, 0, 0},
	'{1, 2, 0, 0, 0, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 27
	'{2, 1, 0, 0, 2, 0, 0, 0},
	'{0, 0, 2, 1, 0, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 28
	'{1, 0, 0, 2, 0, 2, 0, 0},
	'{0, 1, 2, 0, 2, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 29
	'{1, 0, 0, 0, 0, 1, 1, 0},
	'{0, 0, 2, 0, 1, 1, 0, 0},
	'{0, 2, 0, 2, 0, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 30
	'{0, 0, 2, 1, 0, 2, 0, 0},
	'{2, 2, 0, 0, 0, 0, 2, 0},
	'{0, 0, 2, 0, 2, 0, 1, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 31
	'{2, 0, 0, 0, 1, 1, 0, 0},
	'{0, 2, 1, 1, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 32
	'{0, 2, 0, 0, 1, 1, 0, 0},
	'{1, 0, 1, 0, 0, 0, 2, 0},
	'{2, 0, 0, 1, 0, 1, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 33
	'{2, 2, 0, 0, 0, 0, 2, 0},
	'{0, 0, 0, 1, 2, 1, 0, 0},
	'{0, 1, 1, 0, 0, 0, 1, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 34
	'{0, 1, 2, 1, 0, 0, 0, 0},
	'{1, 0, 0, 0, 0, 1, 1, 0},
	'{1, 0, 0, 0, 2, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 35
	'{0, 0, 2, 0, 0, 1, 1, 0},
	'{0, 2, 0, 2, 1, 0, 0, 0},
	'{2, 0, 0, 2, 0, 0, 1, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},

	//bin 36
	'{2, 0, 0, 2, 2, 0, 0, 0},
	'{0, 1, 1, 0, 0, 2, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0},
	'{0, 0, 0, 0, 0, 0, 0, 0}
};

vbin = '{
	//bin 1
	4, 5, 8, 10, 16, 20, 0, 0,
	//bin 2
	3, 6, 10, 13, 15, 16, 17, 0,
	//bin 3
	8, 10, 11, 12, 16, 20, 0, 0,
	//bin 4
	4, 6, 10, 11, 12, 15, 19, 0,
	//bin 5
	1, 4, 8, 11, 19, 20, 0, 0,
	//bin 6
	1, 3, 6, 7, 8, 11, 18, 0,
	//bin 7
	5, 6, 7, 8, 16, 17, 20, 0,
	//bin 8
	1, 5, 6, 7, 13, 20, 0, 0,
	//bin 9
	3, 4, 12, 18, 19, 0, 0, 0,
	//bin 10
	1, 9, 14, 16, 19, 20, 0, 0,
	//bin 11
	6, 8, 10, 12, 13, 17, 18, 0,
	//bin 12
	5, 6, 13, 16, 18, 19, 20, 0,
	//bin 13
	3, 5, 6, 7, 16, 19, 0, 0,
	//bin 14
	1, 2, 13, 14, 17, 18, 0, 0,
	//bin 15
	4, 5, 10, 11, 18, 19, 0, 0,
	//bin 16
	2, 7, 9, 14, 16, 20, 0, 0,
	//bin 17
	1, 5, 6, 7, 16, 17, 0, 0,
	//bin 18
	1, 2, 7, 10, 11, 13, 20, 0,
	//bin 19
	7, 8, 9, 11, 13, 19, 20, 0,
	//bin 20
	6, 12, 13, 15, 16, 18, 0, 0,
	//bin 21
	5, 7, 9, 13, 19, 20, 0, 0,
	//bin 22
	1, 8, 9, 10, 12, 17, 0, 0,
	//bin 23
	3, 5, 7, 10, 12, 14, 20, 0,
	//bin 24
	3, 7, 8, 9, 18, 19, 0, 0,
	//bin 25
	1, 9, 11, 14, 18, 0, 0, 0,
	//bin 26
	4, 7, 9, 14, 16, 17, 0, 0,
	//bin 27
	1, 5, 7, 9, 14, 19, 0, 0,
	//bin 28
	2, 5, 9, 13, 18, 19, 0, 0,
	//bin 29
	2, 3, 5, 7, 10, 16, 20, 0,
	//bin 30
	1, 2, 9, 11, 16, 18, 19, 0,
	//bin 31
	9, 11, 13, 16, 17, 19, 0, 0,
	//bin 32
	1, 2, 6, 11, 14, 17, 19, 0,
	//bin 33
	7, 8, 10, 11, 13, 14, 18, 0,
	//bin 34
	1, 2, 6, 7, 9, 12, 17, 0,
	//bin 35
	1, 2, 3, 6, 10, 12, 13, 0,
	//bin 36
	1, 6, 13, 14, 15, 19, 0, 0
};

run_sb_load();

endtask
