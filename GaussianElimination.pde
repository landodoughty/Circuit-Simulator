class GaussianElimination {
  //This method for solving a linear system of equations of two matrixes is brought to you by:
  //https://introcs.cs.princeton.edu/java/95linear/GaussianElimination.java.html

  private static final double EPSILON = 1e-10;
  //double[][] arr = {{1.,2.,-1.}
  //                ,{-2.,4.,-1.}
  //                ,{2.,2.,3.}};

  //double[] ans = {-4.,6.,1.};

  // arr*x = ans returns x
  double[] doTheThing(double[][]arr, double[]ans) {
    int n = ans.length;
    int[] indexes = new int[n];//this was for my own reference
    for (int i = 0; i < n; i++) {
      indexes[i]=i;
    }

    for (int p = 0; p < n; p++) {

      // find pivot row and swap
      int max = p;
      for (int i = p + 1; i < n; i++) {
        if (Math.abs(arr[i][p]) > Math.abs(arr[max][p])) {
          max = i;
        }
      }
      double[] temp = arr[p];
      arr[p] = arr[max];
      arr[max] = temp;
      double   t    = ans[p];
      ans[p] =ans[max];
      ans[max] = t;
      int tmp = indexes[p];
      indexes[p] = indexes[max];
      indexes[max] = tmp;

      // singular or nearly singular
      if (Math.abs(arr[p][p]) <= EPSILON) {
        print("return");
        return (new double[0]);

        //throw new ArithmeticException("Matrix is singular or nearly singular");
      }

      // pivot within A and b
      for (int i = p + 1; i < n; i++) {
        double alpha = arr[i][p] / arr[p][p];
        ans[i] -= alpha * ans[p];
        for (int j = p; j < n; j++) {
          arr[i][j] -= alpha * arr[p][j];
        }
      }
    }

    //print(arr);
    //print(ans);
    //println();

    // back substitution
    double[] x = new double[n];
    for (int i = n - 1; i >= 0; i--) {
      double sum = 0.0;
      for (int j = i + 1; j < n; j++) {
        sum += arr[i][j] * x[j];
      }
      x[i] = (ans[i] - sum) / arr[i][i];
    }
    //println(indexes);
    return x;
  }
}
