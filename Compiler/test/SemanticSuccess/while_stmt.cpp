
        #include <iostream>
        #include <complex>
        #include <cmath>
        #include <Eigen/Dense>
        #include <qlang>
        using namespace Eigen;
        using namespace std;
        
int func_test (int z )
{
	int a;
	int ret_name;
 
	a = 5;
while (a <= 10)
	a = a + 1;

while (a != 1)

	{
	a = a + 1 % 42;

	}

	ret_name = a;

	return ret_name;
}
int main ()
{
	int trial;
 
		trial = func_test(5);

	std::cout << trial << endl;

	return 0;
}