class Simulator {
  //see comment around line 100
  //double dtMin = 0.0000001;// 0.01 -> 0.0000001 with mid at 0.000001 works for most, slightly jagged at low RC constants
  //double dtMax = 0.001;

  //change this for accuracy of simulation, 0.0001 good rule of thumb for anything not crazy large.
  double dtMid = 0.0001;
  double dt;//starting dt

  Graph g;

  boolean staticCircuit;
  boolean waiting = false;
  ArrayList<double[]> resultList;
  ArrayList<Double> timeList;
  ArrayList<Double> dts;

  public Simulator(Graph graph) {
    g = graph;
    staticCircuit = true;
    for (Vertex v : g.vertices) {
      for (Edge e : v.connections) {
        if (e.type == "Capacitor" || e.type == "Inductor") {
          staticCircuit = false;
        }
      }
    }
  }
  double[] solve (double maxTime, double dtSet) {
    //check if circuit is only resistors and batteries

    if (staticCircuit) {
      return staticSolve();
    } else {
      println("Simulating time based components");
      println(maxTime);
      //dt = maxTime*dtMid;
      dt = dtSet;
      println(dt);

      double[] result = new double[100];
      result[0] = 10;
      int iterations = 0;
      double currentTime = 0.0;
      double deltaV = 0;
      resultList = new ArrayList<double[]>();
      timeList = new ArrayList<Double>();
      dts = new ArrayList<Double>();
      double dtDeletedSum = 0;
      currentTime=0;
      boolean del = false;


      boolean deletedRecent = false;
      //while less then max time and not using millions of data points
      while (currentTime<maxTime&&iterations<1500000) {
        //main updates
        result = transientSolve(iterations==0, result);
        iterations++;
        resultList.add(result);
        timeList.add(currentTime);
        currentTime += (dt);
        dts.add(dt+dtDeletedSum);
        dtDeletedSum=0;


        //find change in all the voltages
        deltaV = 0;
        double prevV = 0;
        for (int i = 0; i<g.size-1; i++) {
          if (resultList.size()>=2) {
            deltaV -= abs((float)resultList.get(resultList.size()-2)[i]);
            prevV += abs((float)resultList.get(resultList.size()-2)[i]);
          }
          deltaV += abs((float)result[i]);
          if (prevV == 0) deltaV = 1;
          else deltaV/=prevV;
          deltaV = abs((float)deltaV);
        }

        if (deltaV<0.001) {
          del=true;
        }

        //this  delets unnecesary data points
        if (del) {
          del=false;
          if (!deletedRecent) {
            //println("d");
            //currentTime -= timeList.get(resultList.size()-1);
            //currentTime += timeList.get(resultList.size()-2);
            resultList.remove(resultList.size()-1);
            timeList.remove(resultList.size()-1);
            dts.remove(dts.size()-1);
            //dts.set(dts.size()-1,dts.get(dts.size()-1)+dt);
            dtDeletedSum=dt;
            deletedRecent = true;
            iterations-=1;
          } else {
            deletedRecent =false;
          }
        }


        //the following code I got rid of because it was making things break very inconsistently so I switched to the deletion of unnecesary data points with constant dt.

        //this function updates the size of the simulation steps based on the change in all the voltages from the previous step
        //float pow = map(constrain(log((float)maxTime)/log(10), -5, 3), -5, 3, 0.1, 1);
        //dt = dtMid * pow(abs((float)(1/ deltaV)), pow);


        //if (dt<=dtMin) dt = dtMin;
        //if (dt>=dtMax) {
        //  dt = dtMax;
        //  del = true;
        //}
      }
      println(resultList.size());
      println(dt);
      println(deltaV);


      return result;
    }
  }

  //solver used for all components - setup is the same for resistors/batteries
  //capacitors add a conductivity equal to
  double[] transientSolve(boolean start, double[] prev) {
    int n = g.size+g.numBatteries+g.numInductors-1;

    //creates arrays which are then solved to find answers (linear system of equations)LSOE
    double [][] arr = new double[n][n];
    double [] ans = new double[n];


    if (start) {
      println(start);
      prev = new double[n];
      //for (double item : prev) {
      //  item = 0;
      //}
    }
    ArrayList<Integer> batVisited = new ArrayList<Integer>();
    ArrayList<Integer> capVisited = new ArrayList<Integer>();
    ArrayList<Integer> indVisited = new ArrayList<Integer>();


    //loop through all vertices in the graph
    for (int i = 1; i<g.size; i++) {
      Vertex v = g.vertices[i];
      int row = v.name - 'B';

      //ans[row]=0;

      //loop through all the edges that each vertex has
      for (Edge e : v.connections) {
        //if that edge is a resistor
        if (e.type=="Resistor") {

          if (start) println("R");
          int col = -1;//will throw an error if neither are the node which shouldnt happen
          int col2 = -1;//will throw an error if neither are the node which shouldnt happen
          //set col1/col2 variables to indices of matrix based on polarity of component
          if (e.connectionPoint1==v) {
            col = e.connectionPoint2.name - 'B';
            col2 = e.connectionPoint1.name - 'B';
          } else if (e.connectionPoint2==v) {
            col = e.connectionPoint1.name - 'B';
            col2 = e.connectionPoint2.name - 'B';
          }
          //if the indices aren't -1 (node A) then add the neccesary value - node A is assumed to be ground so therefore has no part in the LSOE array
          if (col>=0) {
            arr[row][col] -= 1 / e.value;
            if (start) println(1/e.value);
          }
          if (col2>=0) {
            arr[row][col2] += 1 / e.value;
            if (start) println(1/e.value);
          }

          //if not a resistor but a battery
        } else if (e.type == "Battery") {
          int battRow = g.size+e.ID-1;
          //makes sure not to add the same one twice
          if (!batVisited.contains(e.ID)) {
            if (start) println("B");
            batVisited.add(e.ID);
            //e.visited=true;
            //gets neccesary indices
            int col = e.connectionPoint2.name - 'B';
            int col2 = e.connectionPoint1.name - 'B';

            //battRow = g.size+e.ID-1;

            //add to neccesary parts of LSOE
            ans[battRow] = e.value;
            if (col>=0) {
              arr[battRow][col]+=1;
            }
            if (col2>=0) {
              arr[battRow][col2]-=1;
            }
          }
          if (e.connectionPoint1==v) {
            arr[row][battRow] -= 1;
          } else {
            arr[row][battRow] += 1;
          }
        } else if (e.type == "Capacitor") {
          //if capacitor

          //if (e.connectionPoint1==v) {
          int n1 = e.connectionPoint1.name - 'B';
          int n2 = e.connectionPoint2.name - 'B';
          //} else if (e.connectionPoint2==v) {
          //  n1 = e.connectionPoint1.name - 'B';
          //  n2 = e.connectionPoint2.name - 'B';
          //}
          if (!capVisited.contains(e.ID)) {//this makes sure the capacitor is only handled once
            capVisited.add(e.ID);
            if (start) {
              println("C");
              println(n1);
              println(n2);
            }
            double g = round((float)(e.value / dt));
            float volt  = 0;
            if (n1>=0) volt += prev[n1];
            if (n2>=0) volt -= prev[n2];
            if (start) {
              volt = this.g.capsStart.get(e.ID);
            }
            double I = g * (volt);
            //println("I: " + I);
            // Matrix contributions
            if (n1 >= 0) {
              //if (start) println();
              arr[n1][n1] += g;
              if (n2 >= 0) {
                arr[n1][n2] -= g;
              }
            }
            if (n2 >= 0) {
              //if (start) println();
              arr[n2][n2] += g;
              if (n1 >= 0) {
                arr[n2][n1] -= g;
              }
            }

            // ans contributions
            if (n1 >= 0) {
              ans[n1] += I;
            }
            if (n2 >= 0) {
              ans[n2] -= I;
            }
          }
        } else if (e.type == "Inductor") {
          //if inductor

          int n1 = e.connectionPoint1.name - 'B';
          int n2 = e.connectionPoint2.name - 'B';
          if (!indVisited.contains(e.ID)) {//this makes sure the inductor is only handled once
            indVisited.add(e.ID);

            int indRow = g.size + g.numBatteries + e.ID-1;
            double val = -e.value/dt;
            if (start) {
              println("I");
              println(val);
              println(prev[indRow]);
            }
            //add neccesary things
            if (n1>=0) arr[indRow][n1] = 1;
            if (n2>=0)arr[indRow][n2] = -1;
            arr[indRow][indRow] = val;
            ans[indRow] = val * prev[indRow];
            if (start) {
              ans[indRow] = val * this.g.indsStart.get(e.ID);
            }
            if (n1 >= 0) arr[n1][indRow] += 1;
            if (n2 >= 0) arr[n2][indRow] -= 1;
          }
        }
      }
    }
    //for (double[] a : arr) {
    //  println(a);
    //}
    //println();
    //println(ans);
    if (start) {
      for (double[] r : arr) {
        for (double val : r) {
          print(val+" ");
        }
        println();
      }
    }
    if (start) {
      println(ans);
    }

    GaussianElimination gauss = new GaussianElimination();

    double[] result = gauss.doTheThing(arr, ans);
    if (result.length==0) {
      println("Unable to simulate circuit");
      return(null);
    } else {

      //println();
      //for (int i = 0; i < n; i++) {
      //  if (i<g.size-1) {
      //    print("The voltage at vertex ");
      //    print(char(i+66));
      //    print(" relative to vertex A is ");
      //  } else {
      //    print("The current at battery number ");
      //    print( i-g.size+2);
      //    print(" is ");
      //  }
      //  println(result[i]);
      //}
      if (start) {
        println(result);
      }
      return(result);
      ////if(abs((float)result[result.length-1])>0.01){
      //  transientSolve(false,ans);
      //  println("again!");
      //}
    }
  }













  //first type of solve only used for resistors and batteries
  double[] staticSolve() {
    int n = g.size+g.numBatteries-1;

    //creates arrays which are then solved to find answers (linear system of equations)LSOE
    double [][] arr = new double[n][n];
    double [] ans = new double[n];
    int batteryIterator = -1;

    //loop through all vertices in the graph
    for (int i = 1; i<g.size; i++) {
      Vertex v = g.vertices[i];
      int row = v.name - 'B';
      //loop through all the edges that each vertex has
      for (Edge e : v.connections) {
        //if that edge is a resistor
        if (e.type=="Resistor") {
          int col = 1000000;//will throw an error if neither are the node which shouldnt happen
          int col2 = 1000000;//will throw an error if neither are the node which shouldnt happen
          //set col1/col2 variables to indices of matrix based on polarity of component
          if (e.connectionPoint1==v) {
            col = e.connectionPoint2.name - 'B';
            col2 = e.connectionPoint1.name - 'B';
          } else if (e.connectionPoint2==v) {
            col = e.connectionPoint1.name - 'B';
            col2 = e.connectionPoint2.name - 'B';
          }
          //if the indices aren't -1 (node A) then add the neccesary value - node A is assumed to be ground so therefore has no part in the LSOE array
          if (col>=0) {
            arr[row][col] -= 1 / e.value;
          }
          if (col2>=0) {
            arr[row][col2] += 1 / e.value;
          }
          //if not a resistor but a battery
        } else if (e.type == "Battery") {
          int battRow = g.size+batteryIterator-1;
          //makes sure not to add the same one twice
          if (!e.visited) {
            e.visited = true;
            //gets neccesary indices
            int col = e.connectionPoint2.name - 'B';
            int col2 = e.connectionPoint1.name - 'B';

            batteryIterator++;
            battRow = g.size+batteryIterator-1;

            //add to neccesary parts of LSOE
            ans[battRow] = e.value;
            if (col>=0) {
              arr[battRow][col]=1;
            }
            if (col2>=0) {
              arr[battRow][col2]=-1;
            }
          }
          if (e.connectionPoint1==v) {
            arr[row][battRow] = -1;
          } else {
            arr[row][battRow] = 1;
          }
        }
      }
      ans[row]=0;
    }

    //for (double[] row : arr) {
    //  for (double item : row) {
    //    print(item+" ");
    //  }
    //  println();
    //}
    //println(ans);

    GaussianElimination gauss = new GaussianElimination();

    double[] result = gauss.doTheThing(arr, ans);
    if (result.length==0) {
      println("Unable to simulate circuit");
      return new double[0];
    }
    //println(result);
    for (int i = 0; i < n; i++) {
      if (i<g.size-1) {
        print("The voltage at vertex ");
        print(char(i+66));
        print(" relative to vertex A is ");
      } else {
        print("The current at battery number ");
        print( i-g.size+2);
        print(" is ");
      }
      println(result[i]);
    }
    return result;
  }
}
