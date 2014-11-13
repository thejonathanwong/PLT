public class MatCab {

public static void main(String[] args) throws Exception
{
int i;
int j;
int cnt;
double[][] A;
double[][] B;
double[][] C;

{
B = new double[20][4];
C = new double[4][10];
A = new double[20][10];
B = Matrix.floatMatrixInit("1,2,3,4;7,3,9,1;5,6,7,3;3,9,1,4;8,3,5,3;6,3,2,7;2,8,5,3;4,2,9,4;6,3,8,4;7,9,5,2;3,8,6,9;3,0,3,1;4,2,2,7;1,6,8,7;3,0,4,3;6,5,7,2;2,7,7,3;5,3,6,9;2,5,5,3;3,5,6,9");
C = Matrix.floatMatrixInit("6,3,4,7,9,5,3,1,3,3;8,4,2,4,5,7,9,0,6,7;9,3,2,1,4,8,9,8,5,3;3,4,4,5,2,7,5,8,3,2");
A = Matrix.floatMatrixInit("64,39,28,33,39,68,69,58,42,33;150,64,56,75,116,135,134,87,87,74;150,72,58,81,109,144,147,85,95,84;111,64,48,78,84,114,119,43,80,83;126,63,60,88,113,122,111,77,76,66;99,64,62,91,91,116,98,78,67,59;130,65,46,66,84,127,138,66,88,83;133,63,54,65,90,134,131,108,81,61;144,70,62,82,109,143,137,102,88,71;165,80,64,100,132,155,157,63,106,103;163,95,76,104,109,182,180,123,114,101;48,22,22,29,41,46,41,35,27,20;79,54,52,73,68,99,83,76,55,46;147,79,60,74,85,160,164,121,100,83;63,33,32,40,49,68,60,59,38,27;145,67,56,79,111,135,136,78,89,78;140,67,48,64,87,136,147,82,92,82;135,81,74,98,102,157,141,125,90,72;106,53,40,54,69,106,111,66,70,62;139,83,70,92,94,161,153,123,96,80");
A = Matrix.matrixMinus(Matrix.matrixTimes(B,C),A);
cnt = (20*10);
System.out.println(Matrix.areaSum(A, 0, 0, 19, 9)/(20*10));

}
}

}