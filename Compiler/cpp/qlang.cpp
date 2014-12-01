#include <complex>
#include <Eigen/Dense>
#include <cmath>
#include <iostream>
#include "tensorProduct.h"
#include "constants.h"

using namespace Eigen;
using namespace std;

/*
Matrix<complex<float>, Dynamic, Dynamic> tensor(Matrix<complex<float>, Dynamic,
	Dynamic> mat1, Matrix<complex<float>, Dynamic, Dynamic> mat2) {
	*/
MatrixXcf tensor(MatrixXcf mat1, MatrixXcf mat2) {

	int mat1rows = mat1.rows();
	int mat1cols = mat1.cols();
	int mat2rows = mat2.rows();
	int mat2cols = mat2.cols();

	MatrixXcf output(mat1rows * mat2rows, mat1cols * mat2cols);

	//iterates through one matrix, multiplying each element with the whole
	//2nd matrix
	for(int m = 0; m < mat1rows; m++) {
		for(int n = 0; n < mat1cols; n++) {
			output.block(m*mat2cols,n*mat2rows,mat2rows,mat2cols) = 
				mat1(m,n) * mat2;
		}
	}

	return output;
	
}

Matrix4cf control(Matrix2cf mat) {
	Matrix4cf output;
	output.topLeftCorner(2,2) = I;
	output.topRightCorner(2,2) = Matrix<complex<float>,2,2>::Zero();
	output.bottomLeftCorner(2,2) = Matrix<complex<float>,2,2>::Zero();
	output.bottomRightCorner(2,2) = mat;

	return output;
}

MatrixXcf genQubit(string s) {
	
	int slen = s.length();
	int qstrlen = slen-2; //length of the qubit string removing end chars

	string qstr = s.substr(1, qstrlen); //binary substring from qubit rep
	int qlen = pow(2, qstrlen); //length of the vector

	int base10num = 0;

	//iterates through qstr. Whenever digit is a 1, it adds the associated 
	//power of 2 for that position to base10num
	const char * cq = qstr.c_str();
	char * c = new char();
	for(int i = 0; i < qstrlen; i++) {
		strncpy(c,cq+i,1);
		base10num += strtol(c,NULL,10) * pow(2,(qstrlen-1-i));  
	}
	delete c;

	//creates the vector and sets correct bit to 1
	MatrixXcf qub;
	if(!s.compare(0, 1, "<")) {
		qub = MatrixXcf(1,qlen);
		qub(0,qlen-1-base10num) = 1;
	} else if(!s.compare(slen-1, 1, ">")){
		qub = MatrixXcf(qlen,1);
		qub(base10num,0) = 1;
	}

	return qub;
}

/*
int main() {

	complex<float> c1 = 2;
	complex<float> c2 = 3;
	Matrix2cf mat1, mat2;
	mat1 << c1,c1,c1,c1;
	mat2 << c2,c2,c2,0;

	cout << tensor(mat1,mat2) << endl;


	return 0;
}
*/

