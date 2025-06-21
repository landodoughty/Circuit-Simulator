//main program

Circuit c;
boolean escapePressed = false;
boolean dragging = false;
Chart chart1;
Simulator sim;
boolean simulate = false;
boolean simInput = false;

PopupInputBox input = new PopupInputBox(1000/2, 35, 300, 60, "How long should the simulation run", "s");
PopupInputBox input2 = new PopupInputBox(1000/2, 35, 300, 60, "How long should the time increment be", "s");



void setup() {
  size(1000, 800);
  //fullScreen();
  background(255);
  c = new Circuit();
}
int accumX = 0;
int accumY = 0;
int offsetX = 0;
int offsetY = 0;

void draw() {
  //surface.setResizable(true);
  background(255);
  //update simulation(only runs when correct button is hit)
  simulate();

  //update and show circuit
  c.update();
  c.showCircuit();
  //show input box for length of simulation so that it is on top of the circuit.
  if (input.isActive) {
    input.show();
  }
  if (input2.isActive) {
    input2.show();
  }

  //text("accumX: " + accumX, 20, 20);
  //text("accumY: " + accumY, 20, 40);
  
  //drag screen around
  if (dragging) {
    int dx = mouseX - pmouseX;
    int dy = mouseY - pmouseY;
    offsetX += dx;
    offsetY += dy;
    accumX = offsetX;
    accumY = offsetY;
  }
}

//main simulation function
void simulate() {
  //runs if s is pressed
  if (simulate) {
    //if static circuit then you can just solve
    if (sim.staticCircuit) {
      simulate = false;
    } else {
      
      if(key==ESC){
        simInput = false;
        input.isActive= false;
        input2.isActive = false;
        simulate = false;
        return;
      }
      //get length of simulation
      if (!simInput) {
        if (input.isActive) {
          input.update();
          if (input.isActive) {
            return;
          }
          simInput = true;
          input2.popUp();
          return;
        } else {
          input.popUp();
          return;
        }
        
      //get time increment size of simulation
      } else {
        if (input2.isActive) {
          input2.update();
          if (input2.isActive) {
            return;
          }
        } else {
          input2.popUp();
          return;
        }
      }
    }
    // if neccesary variables have been gotten from the person it will get to here
    simInput =false;
    simulate = false;
    key = ' ';
    //simulate
    double[] results = sim.solve(input.getValue(), input2.getValue());
    if (results.length==0) {
      return;
    }
    
    if (sim.staticCircuit) {
      //loop through components
      for (Component comp : c.components) {
        //if resistor(not battery)
        if (comp.type=="Resistor") {
          //set voltage and current of resistor
          comp.voltage = 0;
          int node1 = comp.node1.label - 'B';
          int node2 = comp.node2.label - 'B';
          if (node1>=0) {
            comp.voltage+=results[node1];
          }
          if (node2>=0) {
            comp.voltage-=results[node2];
          }
          comp.current = comp.voltage/comp.value;
          comp.simulated = true;
        }
      }
    } else {
      //if time based circuit
      for (Component comp : c.components) {
        //loop through components
        if (comp.type!="Battery") {
          
          int node1 = comp.node1.label - 'B';
          int node2 = comp.node2.label - 'B';
          comp.voltages = new ArrayList<Float>();
          comp.currents = new ArrayList<Float>();
          comp.times = new ArrayList<Float>();
          int iter = 0;
          //loop through time in simulation
          for (double[] result : sim.resultList) {
            float voltage = 0;
            //set voltage of components to be difference between two nodes
            if (node1>=0) {
              voltage+=result[node1];
            }
            if (node2>=0) {
              voltage-=result[node2];
            }

            comp.voltages.add(voltage);
            
            //different ways of adding currents
            if (comp.type=="Capacitor") {
              //if capacitor add derivative of voltage * value
              if (comp.voltages.size()>=2) {
                double dt = sim.dts.get(iter);
                float val = (float)(comp.value*((comp.voltages.get(comp.voltages.size()-1)-comp.voltages.get(comp.voltages.size()-2))/dt));
                comp.currents.add(val);
              } else {
                comp.currents.add(0.0);
              }
            } else if (comp.type == "Resistor") {
              //if resistor use ohms law for current
              comp.currents.add(voltage/comp.value);
              
            } else if (comp.type == "Inductor") {
              //if inductor use the current of that source(already calculated in the simulation results)
              comp.currents.add((float)result[comp.id+sim.g.size+sim.g.numBatteries-1]);
            }
            comp.times.add((float)sim.timeList.get(iter).doubleValue());
            iter++;
          }
          
          //comp.times.remove(comp.times.size()-1);
          //comp.voltages.remove(comp.voltages.size()-1);
          //comp.currents.remove(comp.currents.size()-1);
          //comp.times = sim.timeList;
          //set values for component
          comp.simulatedTransient = true;
          comp.simulated = false;
          comp.chart = new Chart(width-600, height-300, 600, 300);
          comp.chart.setArrays(comp.currents, comp.times, "Current Vs Time");
          comp.chart.setArrays(comp.voltages, comp.times, "Voltage Vs Time");
        }
      }
    }
  }
}

void mousePressed() {
  if (mouseButton == CENTER) {
    dragging = true;
  }
}

void mouseReleased() {
  if (mouseButton == CENTER) {
    dragging = false;
    accumX = round(offsetX/10)*10;
    accumY = round(offsetY/10)*10;
    //lock to grid when released
  }
}

void keyPressed() {
  if (key == ESC) {
    key = 0;  // Prevents Processing from closing the sketch
    //if(
    escapePressed=true;
    //println(escapePressed);
  } else if (key == 's') {
    Converter conv = new Converter(c);//converts to graph and combines nodes
    sim = new Simulator(conv.convert());
    simulate = true;//this tells the simulate function to actually run
    delay(100);
  }
}
