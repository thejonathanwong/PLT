#include <iostream>
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

/*
 * (H tensor X)|00>
 */


Matrix4f tensor2f(Matrix2f a, Matrix2f b);

int main() {

	// |00> column vector
	VectorXf v(4);
	v << 1, 0, 0, 0;

	// H matrix
	Matrix2f H;
	H << 1, 1,
	     1, -1;
	H *= (1/sqrt(2));

	//X matrix
	Matrix2f X;
	X << 0, 1,
	     1, 0;

	cout << tensor2f(H,X) * v << endl;
  	
}

//method for tensor product of two 2x2 square matrices
Matrix4f tensor2f(Matrix2f a, Matrix2f b) {
	Matrix4f out = Matrix4f::Zero();
	Matrix2f tl = a(0,0) * b;
	Matrix2f tr = a(1,0) * b;
	Matrix2f br = a(1,1) * b;
	Matrix2f bl = a(0,1) * b;

	out.topLeftCorner(2,2) = tl;
	out.topRightCorner(2,2) = tr;
	out.bottomRightCorner(2,2) = br;
	out.bottomLeftCorner(2,2) = bl;
	
	return out;
}