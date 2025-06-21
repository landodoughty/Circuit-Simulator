//main class for creating a circuit

import java.util.Map;
int gridSize = 10;
int lastCircuitFinishedTime = 0;

//buttons and booleans
boolean showGrid = true;
boolean showJunction = true;
boolean showLabel = true;
boolean showCrosshair = false;
Button showGridButton;
Button showJunctionButton;
Button showLabelButton;
Button showCrosshairButton;


class Circuit {
  //arrays for main objects
  ArrayList<Curve> curves;
  ArrayList<Button> buttons;
  ArrayList<Component> components;
  HashMap<Integer, CircuitNode> nodes = new HashMap<Integer, CircuitNode>();

  
  //current objects
  Curve currentCurve;
  String currentComponent;



  public Circuit() {
    //arrays
    curves = new ArrayList<Curve>();
    buttons = new ArrayList<Button>();
    components = new ArrayList<Component>();
    
    //create buttons
    showGridButton = new Button(width-65, 35, 120, 60, color(150, 150, 150), "Show/Hide Grid");
    showJunctionButton = new Button(width-65, 105, 120, 60, color(150, 150, 150), "Show/Hide Nodes");
    showLabelButton = new Button(width-65, 175, 120, 60, color(150, 150, 150), "Show/Hide Labels");
    showCrosshairButton = new Button(width-65, 245, 120, 60, color(150, 150, 150), "Show/Hide Crosshair");


    //setup of all the buttons for the circuit
    buttons.add(new Button(55, 35, 100, 60, color(150, 150, 150), "Battery"));
    buttons.add(new Button(55, 105, 100, 60, color(150, 150, 150), "Resistor"));
    buttons.add(new Button(55, 175, 100, 60, color(150, 150, 150), "Capacitor"));
    buttons.add(new Button(55, 245, 100, 60, color(150, 150, 150), "Inductor"));

    //these can be reneabled to draw circuits with them but they are unable to be simulated
    //buttons.add(new Button(55, 315, 100, 60, color(150, 150, 150), "Diode"));
    //buttons.add(new Button(55, 385, 100, 60, color(150, 150, 150), "Switch"));
    //buttons.add(new Button(55, 455, 100, 60, color(150, 150, 150), "Voltmeter"));
    //buttons.add(new Button(55, 525, 100, 60, color(150, 150, 150), "Ammeter"));
  }

  //input box
  PopupInputBox input = new PopupInputBox(width/2, 35, 200, 60, "Type Component Value", "");
  PopupInputBox input2 = new PopupInputBox(width/2, 35, 200, 60, "Type Starting Voltage/Current", "");
  void update() {

    //if input box is active then only update that
    if (input !=null && input.isActive) {
      if (escapePressed) {
        input.isActive=false;
        components.remove(components.size()-1);
        return;
      }
      input.update();
      if (!input.isActive&&(currentComponent == "Capacitor" || currentComponent == "Inductor")) {
        input2.popUp();
      }
      return;
    }
    
    //second input box for if capacitor and inductor starting value is needed to be set
    if (input2.isActive) {
      if (escapePressed) {
        input2.isActive=false;
        components.remove(components.size()-1);
        return;
      }
      input2.update();
      return;
    }

    //update status buttons, if one of them is pressed then do that and return so that nothing is accidentally placed there
    showGridButton.update();
    if (showGridButton.isPressed) {
      showGrid = !showGrid;
      delay(100);
      return;
    }

    //see above
    showJunctionButton.update();
    if (showJunctionButton.isPressed) {
      showJunction = !showJunction;
      delay(100);
      return;
    }

    //see above
    showLabelButton.update();
    if (showLabelButton.isPressed) {
      showLabel = !showLabel;
      delay(100);
      return;
    }

    //see above
    showCrosshairButton.update();
    if (showCrosshairButton.isPressed) {
      showCrosshair = !showCrosshair;
      delay(100);
      return;
    }

    //update component if one is being placed, then either place it or get rid of it
    for (Component c : components) {
      if (c.beingPlaced) {
        c.update();
        if (escapePressed) {
          //delete component
          components.remove(components.size()-1);
          escapePressed=false;
          return;
        }
        //update value from input box
        if (c.type != "Switch" && c.type != "Voltmeter" && c.type != "Ammeter"&& c.type != "Diode") {
          c.value = input.getValue();
          c.startingValue = input2.getValue();
        }
        return;
      }
    }

    //check for component button presses
    for (Button b : buttons) {
      b.update();
      if (b.isPressed) {
        currentComponent = b.label;
        if (millis()>100+lastCircuitFinishedTime) {
          lastCircuitFinishedTime = millis();

          //open input box
          if (b.label != "Switch" && b.label != "Voltmeter" && b.label != "Ammeter"&& b.label != "Diode") {
            input.popUp();
          }

          //place new component
          components.add(new Component(0, b.label));
          return;
        }
      }
    }



    //if none of the aboce things are happening and left mouse hit
    if (mousePressed&&mouseButton==LEFT) {
      //if there is currently a connection being drawn
      if (currentCurve!=null&&currentCurve.active) {
        if (millis()>100+lastCircuitFinishedTime) {
          //currently drawing a line


          int gridX = round((mouseX-accumX) / (float) gridSize) * gridSize;
          int gridY = round((mouseY-accumY) / (float) gridSize) * gridSize;
          float k = gridX + gridY * pow(10, (round(log((float) width) / log(10.0)) ) ) * 10;

          //if current point hasn't been added then add
          if (!currentCurve.points.contains(new PVector(gridX, gridY))) {
            currentCurve.addPoint(mouseX-accumX, mouseY-accumY);
          }

          //if you clicked on a node that isnt where you started
          if (nodes.containsKey((int) k)) {
            if (nodes.get((int) k)!= currentCurve.start) {

              //end the connectiion at the current point
              currentCurve.addPoint(mouseX-accumX, mouseY-accumY);
              currentCurve.active=false;
              currentCurve.end = nodes.get((int) k);
              currentCurve.end.numConnections+=1;

              //println("This curve goes from " + currentCurve.start.net + " to " + currentCurve.end.net);
              lastCircuitFinishedTime = millis();
            }
          }
        }
        //if theres not a connection currently being drawn
      } else {
        //need to create a new line
        if (millis()>100+lastCircuitFinishedTime) {
          lastCircuitFinishedTime = millis();
          //create new curve
          currentCurve = new Curve(10);
          curves.add(currentCurve);
          currentCurve.start= addNode(mouseX-accumX, mouseY-accumY);
          currentCurve.addPoint(mouseX-accumX, mouseY-accumY);
          currentCurve.addPoint(mouseX-accumX, mouseY-accumY);
        }
      }

      //if the right mouse button is pressed
    } else if (mousePressed&&mouseButton==RIGHT) {
      //create a new node
      if (millis()>100+lastCircuitFinishedTime) {
        CircuitNode n = addNode(mouseX-accumX, mouseY-accumY);
        n.permanent = true;
        n.numConnections-=1;
        lastCircuitFinishedTime = millis();
      }
    }
    if (keyPressed) {
      //if escape is pressed
      if (escapePressed) {
        escapePressed = false;

        //if drawing connection currently then remove it
        if (currentCurve!=null && currentCurve.active) {
          currentCurve.start.numConnections--;
          curves.remove(curves.size()-1);
          float k = currentCurve.start.x + currentCurve.start.y * pow(10, (round(log((float) width) / log(10.0)) ) ) * 10;
          if (nodes.get((int) k ).numConnections <1 && !nodes.get((int) k ).permanent) {
            nodes.remove((int)k);
          }
          currentCurve = null;
          return;
        }

        //if enter is hit
      } else if (currentCurve!=null&&key == ENTER || key == RETURN) {
        // end curve at last point

        //println(currentCurve.points.size());

        //safety check
        if (currentCurve.active&&currentCurve.end==null) {
          //if curve has more than just an end point end at last point
          if (currentCurve.points.size()>2) {
            currentCurve.active = false;
            int x = (int) currentCurve.points.get(currentCurve.points.size()-1).x;
            int y = (int) currentCurve.points.get(currentCurve.points.size()-1).y;
            currentCurve.end= addNode(x, y);

            //if curve is no points other than the start delete curve
          } else {
            currentCurve.start.numConnections--;
            curves.remove(curves.size()-1);

            float k = currentCurve.start.x + currentCurve.start.y * pow(10, (round(log((float) width) / log(10.0)) ) ) * 10;
            if (nodes.get((int) k ).numConnections <1 && !nodes.get((int) k ).permanent) {
              nodes.remove((int)k);
            }
            currentCurve = null;
          }
        }
      }
    }
  }

  //main function for adding a new node
  CircuitNode addNode(int X, int Y) {

    //new circuit node(junction)
    int gridX = round((X) / (float) gridSize) * gridSize;
    int gridY = round((Y) / (float) gridSize) * gridSize;
    float k = gridX + gridY * pow(10, (round(log((float) width) / log(10.0)) ) ) * 10;

    //check for preexisting node
    if (nodes.containsKey((int) k)) {
      nodes.get((int) k).numConnections+=1;
      return(nodes.get((int) k));
    }
    //add new node
    CircuitNode node = new CircuitNode(gridX, gridY, str(k));
    nodes.put((int) k, node);
    return node;
  }

  //main display function
  void showCircuit () {

    //show grid
    if (showGrid) {
      stroke(200);
      for (int i =0+accumX%20; i<width; i+= 20) {
        line(i, 0, i, height);
      }
      for (int i =accumY%20; i<height; i+= 20) {
        line(0, i, width, i);
      }
    }

    stroke(100);
    if (showCrosshair) {
      int gridX = round(mouseX / (float) gridSize) * gridSize;
      int gridY = round(mouseY / (float) gridSize) * gridSize;
      line(0, gridY, width, gridY);
      line(gridX, 0, gridX, height);
    }

    stroke(0);

    //draw connections
    stroke(50);
    for (Curve curve : curves) {
      curve.drawCurve();
    }
    stroke(0);

    //draw components
    for (Component comp : components) {
      comp.drawComponent();
      if (showLabel) {
        comp.drawValue();
      }
    }

    //draw nodes
    if (showJunction) {
      for (Map.Entry entry : nodes.entrySet()) {
        CircuitNode n = (CircuitNode) entry.getValue();
        n.drawNode();
      }
    }
    //draw buttons
    for (Button b : buttons) {
      b.drawButton();
    }
    showGridButton.drawButton();
    showJunctionButton.drawButton();
    showLabelButton.drawButton();
    showCrosshairButton.drawButton();

    //draw input box
    if (input.isActive) {
      input.show();
    }
    if (input2.isActive) {
      input2.show();
    }
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//class for a node/junction of the circuit design

class CircuitNode {

  int x;
  int y;
  char label;//
  boolean labelNode = false;
  String net;
  int numConnections = 1;
  boolean permanent = false;//if placed manually using right click then it is permanent(doesnt get removed by escape or enter)
  boolean explored;//used for convert

  CircuitNode(int x, int y, String netName) {
    this.x = x;
    this.y = y;
    this.net = netName;
  }

  void drawNode () {
    if (numConnections>=2) {
      fill(0);
    }
    circle(x+accumX, y+accumY, 10);
    noFill();
    if(labelNode){
       text(label,x-10+accumX,y-10+accumY); 
    }
  }
  
  //used to label by graph character for checking purposes
  void label(char label){
    labelNode = true;
    this.label = label;
    
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// class for creating a button that can be used to trigger events
class Button {
  //variables
  float x, y, w, h;
  color btnColor;
  boolean isPressed;
  String label;

  Button(float x, float y, float w, float h, color btnColor, String label) {
    this.x = x - w / 2; // Centering the button
    this.y = y - h / 2;
    this.w = w;
    this.h = h;
    this.btnColor = btnColor;
    this.isPressed = false;
    this.label = label;
  }

  void update() {
    //check for press
    if (mousePressed && mouseButton == LEFT &&
      mouseX > x && mouseX < x + w &&
      mouseY > y && mouseY < y + h) {
      isPressed = true;
    } else {
      isPressed = false;
    }
  }

  void drawButton() {
    fill(isPressed ? btnColor - 50 : btnColor); // Darken when pressed
    stroke(0);
    strokeWeight(2);
    rect(x, y, w, h, 10); // Rounded corners

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w / 2, y + h / 2);
    noFill();
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//class for creating connection between nodes

class Curve {
  ArrayList<PVector> points;
  boolean active;
  int gridSize;
  CircuitNode start;
  CircuitNode end;

  Curve(int size) {
    points = new ArrayList<PVector>();
    active = true;
    gridSize = size;
  }

  //add point to circuit
  void addPoint(float x, float y) {
    if (!active) return;
    float gridX = round(x / (float)gridSize) * gridSize;
    float gridY = round(y / (float)gridSize) * gridSize;

    //enforce 90 degree turns
    if (!points.isEmpty()) {
      PVector last = points.get(points.size() - 1);
      if (abs(gridX - last.x) < abs(gridY - last.y)) {
        gridX = last.x;
      } else {
        gridY = last.y;
      }
    }

    points.add(new PVector(gridX, gridY));
  }

  void drawCurve() {
    if (points.size() < 2) return;

    //stroke(0);
    noFill();
    beginShape();

    //if active add two points to show what circuit would be if placed
    if (active) {
      this.addPoint(mouseX-accumX, mouseY-accumY);
      this.addPoint(mouseX-accumX, mouseY-accumY);
    }

    //draw points
    for (PVector p : points) {
      vertex(p.x+accumX, p.y+accumY);
    }

    //if active remove the two points previously added
    if (active) {
      points.remove(points.size() - 1);
      points.remove(points.size() - 1);
    }

    endShape();
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//class for a component when drawing circuit

class Component {
  int x = -10000;
  int y = -10000;
  float value;//this is the value of the components
  ArrayList<Float> voltages;
  ArrayList<Float> currents;
  ArrayList<Float> times;
  float voltage = 0;
  float current = 0;
  float startingValue = 0;
  String type;
  int rotation = 0;
  boolean simulated = false;
  boolean simulatedTransient = false;
  boolean beingPlaced = true;
  int id;
  boolean findValueAtTime = false;
  boolean findTimeAtVoltage = false;
  boolean findTimeAtCurrent = false;
  PopupInputBox fvat = new PopupInputBox(1000/2, 35, 300, 60, "What time would you like the values of?", "");
  PopupInputBox ftav = new PopupInputBox(1000/2, 35, 300, 60, "What voltage would you like the time of?", "");
  PopupInputBox ftac = new PopupInputBox(1000/2, 35, 300, 60, "What current would you like the time of?", "");

  float time;
  boolean valFound = false;

  Chart chart;

  CircuitNode node1;
  CircuitNode node2;

  Component(float val, String type) {
    this.value = val;
    this.type = type;
    delay(100);

    //println(value);
  }

  void update() {
    //only updates if it is being placed

    //move to grid
    x = round((mouseX-accumX) / (float) gridSize) * gridSize;
    y = round((mouseY-accumY) / (float) gridSize) * gridSize;

    //rotate
    if (keyPressed&&key=='r') {
      rotation += 90;
      delay(100);
    }

    //place and add nodes
    if (mousePressed) {
      beingPlaced = false;

      if (rotation%360 ==0) {
        node1 = c.addNode(x+50, y);
        node2 = c.addNode(x-50, y);
      } else if (rotation%360 ==90) {
        node1 = c.addNode(x, y+50);
        node2 = c.addNode(x, y-50);
      } else if (rotation%360 ==180) {
        node1 = c.addNode(x-50, y);
        node2 = c.addNode(x+50, y);
      } else if (rotation%360 ==270) {
        node1 = c.addNode(x, y-50);
        node2 = c.addNode(x, y+50);
      }
      delay(100);
    }
  }

  // Convert value to readable engineering notation
  String formatValue(float val, int decimals) {
    String[] prefixes = {"p", "n", "u", "m", "", "k", "M", "G"};
    float[] scales = {1e-12, 1e-9, 1e-6, 1e-3, 1, 1e3, 1e6, 1e9};

    for (int i = 0; i < scales.length; i++) {
      if (Math.abs(val) >= scales[i] && (i == scales.length - 1 || Math.abs(val) < scales[i + 1])) {
        return nf(val / scales[i], 1, decimals) + prefixes[i];
      }
    }
    return nf(val, 1, decimals);
  }

  void findValues(){
    
    //find the value ar a set time
    if (findValueAtTime) {
      if (fvat.isActive) {
        if (key==ESC) {
          fvat.isActive=false;
          findValueAtTime=false;
          return;
        }
        fvat.show();
        fvat.update();
        if (!fvat.isActive) {
          //if time has been inputed
          fvat.isActive=false;
          println("FVAT");
          findValueAtTime=false;
          float val = times.get(0);
          boolean start = val<fvat.getValue();
          int i = 0;
          //go through until value is found
          while (i<times.size()&&start==(times.get(i)<fvat.getValue())) {
            i++;
          }
          if (i<times.size()) {
            voltage = voltages.get(i);
            current = currents.get(i);
            time = fvat.getValue();
            //println("Voltage at time "+fvat.getValue()+":"+voltages.get(i));
            //println("Current at time "+fvat.getValue()+":"+currents.get(i));
            valFound=true;
          }
        }
        return;
      } else {
        fvat.popUp();
        return;
      }
    }
    //find the time at a voltage
    if (findTimeAtVoltage) {
      if (ftav.isActive) {
        if (key==ESC) {
          ftav.isActive=false;
          findTimeAtVoltage=false;

          return;
        }
        ftav.update();
        ftav.show();
        if (!ftav.isActive) {
          //if voltage is inputed
          ftav.isActive=false;
          println("FTAV");
          findTimeAtVoltage=false;
          float val = voltages.get(0);
          boolean start = abs(val)<ftav.getValue();
          int i = 0;
          //loop through until voltage is found
          while (i<voltages.size()&&start==(abs(voltages.get(i))<ftav.getValue())) {
            i++;
          }
          if (i<voltages.size()) {
            voltage = ftav.getValue();
            current = currents.get(i);
            time = times.get(i);
            valFound = true;
          } else {
            println(i);
          }
        }
        return;
      } else {
        ftav.popUp();
        return;
      }
    }

    //find time at current
    if (findTimeAtCurrent) {
      if (ftac.isActive) {
        if (key==ESC) {
          ftac.isActive=false;
          findTimeAtCurrent=false;

          return;
        }
        ftac.update();
        ftac.show();
        if (!ftac.isActive) {
          //if current has been inputted
          ftac.isActive=false;
          println("FTAC");
          findTimeAtCurrent=false;
          float val = currents.get(5);
          boolean start = val<ftac.getValue();
          int i = 5;
          //loop through until current is fine
          while (i<currents.size()&&start==(currents.get(i)<ftac.getValue())) {
            i++;
          }
          if (i<currents.size()) {
            current = ftac.getValue();
            voltage = voltages.get(i);
            time = times.get(i);
            valFound = true;
          }
        }
        return;
      } else {
        ftac.popUp();
        return;
      }
    }
  }

  // Draw rotated scientific notation at (x, y)
  void drawValue() {
    
    //format value add add unit
    String display = formatValue(value, 1);
    switch (type) {
    case "Battery":
      display+="V";
      break;
    case "Resistor":
      display+="Ω";
      break;
    case "Capacitor":
      display+="f";
      break;
    case "Inductor":
      display+="H";
      break;
    default:
      return;
    }

    //display formatted value
    pushMatrix();
    translate(x+accumX, y+accumY);
    rotate(radians(rotation));
    translate(30, 30); // Move to the position after rotating
    rotate(radians(-rotation));
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text(display, 0, 0);

    noFill();
    popMatrix();
    
    findValues();
    
  }


  //draw the component
  void drawComponent() {

    //battery draw
    if (type=="Battery") {

      drawRotatedLine(x-50, y, x-5, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+5, y, rotation, x, y);
      drawRotatedLine(x-5, y-30, x-5, y+30, rotation, x, y);
      drawRotatedLine(x+5, y-20, x+5, y+20, rotation, x, y);

      drawRotatedLine(x-20, y-25, x-10, y-25, rotation, x, y);
      drawRotatedLine(x-15, y-20, x-15, y-30, rotation, x, y);

      //resistor draw
    } else if (type=="Resistor") {

      int h = 12;
      drawRotatedLine(x-50, y, x-24, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+24, y, rotation, x, y);
      for (int i = -24; i<24; i+=12) {
        drawRotatedLine(x+i, y, x+i+3, y+h, rotation, x, y);
        drawRotatedLine(x+i+9, y-h, x+i+3, y+h, rotation, x, y);
        drawRotatedLine(x+i+9, y-h, x+i+12, y, rotation, x, y);
      }

      //capacitor draw
    } else if (type=="Capacitor") {

      drawRotatedLine(x-50, y, x-5, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+5, y, rotation, x, y);
      drawRotatedLine(x-5, y-20, x-5, y+20, rotation, x, y);
      drawRotatedLine(x+5, y-20, x+5, y+20, rotation, x, y);

      //diode draw
    } else if (type=="Diode") {

      drawRotatedLine(x-50, y, x-15, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+15, y, rotation, x, y);
      drawRotatedLine(x-15, y-15, x-15, y+15, rotation, x, y);
      drawRotatedLine(x+15, y-15, x+15, y+15, rotation, x, y);
      drawRotatedLine(x+15, y-15, x-15, y, rotation, x, y);
      drawRotatedLine(x+15, y+15, x-15, y, rotation, x, y);

      //switch draw
    } else if (type=="Switch") {

      drawRotatedLine(x-50, y, x-15, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+15, y, rotation, x, y);
      drawRotatedLine(x+15, y-15, x-15, y, rotation, x, y);

      //voltmeter draw
    } else if (type=="Voltmeter") {
      noFill();
      circle(x, y, 50);
      drawRotatedText("V", x, y, rotation);
      drawRotatedLine(x-50, y, x-25, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+25, y, rotation, x, y);

      //ammeter draw
    } else if (type=="Ammeter") {
      noFill();
      circle(x, y, 50);
      drawRotatedText("A", x, y, rotation);
      drawRotatedLine(x-50, y, x-25, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+25, y, rotation, x, y);

      //inductor draw
    } else if (type=="Inductor") {
      drawRotatedLine(x-50, y, x-30, y, rotation, x, y);
      drawRotatedLine(x+50, y, x+30, y, rotation, x, y);
      for (int i = -30; i<30; i+=15) {
        drawRotatedArc(x-i-7.5, y, 15, 30, 0, 180, rotation, x, y);
      }
    }
    if (simulated) {
      //if hovering over component show data
      if (rotation%180==0&&mouseX-accumX>x-40&&mouseX-accumX<x+40&&mouseY-accumY>y-25&&mouseY-accumY<y+25||rotation%180==90&&mouseX-accumX>x-25&&mouseX-accumX<x+25&&mouseY-accumY>y-40&&mouseY-accumY<y+40) {
        textSize(16);
        textAlign(RIGHT, CENTER);
        text(formatValue(abs(voltage), 3)+"V", 80, height - 60);
        text(formatValue(abs(current), 3)+"A", 80, height - 40);
        text(formatValue(abs(voltage*current), 2)+"W", 80, height - 20);
      }
    } else if (simulatedTransient) {
      //if hovering over component show data
      if (rotation%180==0&&mouseX-accumX>x-40&&mouseX-accumX<x+40&&mouseY-accumY>y-25&&mouseY-accumY<y+25||rotation%180==90&&mouseX-accumX>x-25&&mouseX-accumX<x+25&&mouseY-accumY>y-40&&mouseY-accumY<y+40) {

        if (valFound) {
          textSize(16);
          textAlign(RIGHT, CENTER);
          text(formatValue(abs(voltage), 2)+"V", 80, height - 60);
          text(formatValue(abs(current), 2)+"A", 80, height - 40);
          text(formatValue(abs(voltage*current), 2)+"W", 80, height - 20);
          text(formatValue(abs(time), 2)+"s", 80, height - 80);
        }
        chart.display();

        //check for if the user wants to find a value or time
        if (key == 't') {
          findValueAtTime = true;
        }
        if (key == 'v') {
          findTimeAtVoltage = true;
        }
        if (key == 'c') {
          findTimeAtCurrent = true;
        }
      }
    }
  }

  //function that draws a line based on the rotation of the component
  void drawRotatedLine(float x1, float y1, float x2, float y2, float rotation, float midX, float midY) {
    pushMatrix();
    translate(accumX, accumY);
    // Compute the relative positions of the points to the midpoint
    float relX1 = x1 - midX;
    float relY1 = y1 - midY;
    float relX2 = x2 - midX;
    float relY2 = y2 - midY;

    float newX1, newY1, newX2, newY2;

    // Normalize rotation to 0, 90, 180, or 270 degrees
    rotation = (rotation % 360 + 360) % 360;

    // Apply 90-degree rotations
    if (rotation == 90) {
      newX1 = midX - relY1;
      newY1 = midY + relX1;
      newX2 = midX - relY2;
      newY2 = midY + relX2;
    } else if (rotation == 180) {
      newX1 = midX - relX1;
      newY1 = midY - relY1;
      newX2 = midX - relX2;
      newY2 = midY - relY2;
    } else if (rotation == 270) {
      newX1 = midX + relY1;
      newY1 = midY - relX1;
      newX2 = midX + relY2;
      newY2 = midY - relX2;
    } else { // 0 degrees (no rotation)
      newX1 = x1;
      newY1 = y1;
      newX2 = x2;
      newY2 = y2;
    }

    line(newX1, newY1, newX2, newY2);
    popMatrix();
  }

  //function that draws text based on the rotation of the component
  void drawRotatedText(String txt, float x, float y, int rotation) {
    pushMatrix();
    translate(x+accumX, y+accumY);  // Move to the text location

    // Normalize rotation to 0, 90, 180, or 270 degrees
    rotation = (rotation % 360 + 360) % 360;

    // Apply the correct rotation
    if (rotation == 90) {
      rotate(HALF_PI);
    } else if (rotation == 180) {
      rotate(PI);
    } else if (rotation == 270) {
      rotate(PI + HALF_PI);
    } else { // 0 degrees
    }
    textAlign(CENTER, CENTER);
    textSize(40);
    //stroke(1);
    text(txt, 0, 0);  // Draw text at new rotated position
    popMatrix();
  }

  //function that draws arc based on the rotation of the component
  void drawRotatedArc(float centerX, float centerY, float w, float h, float startAngle, float stopAngle,
    int rotation, float pivotX, float pivotY) {
    noFill();
    pushMatrix();

    // Translate to the pivot point
    translate(pivotX+accumX, pivotY+accumY);

    // Normalize rotation to 0, 90, 180, or 270 degrees
    rotation = (rotation % 360 + 360) % 360;

    // Apply 90-degree rotation
    if (rotation == 90) {
      rotate(HALF_PI);
    } else if (rotation == 180) {
      rotate(PI);
    } else if (rotation == 270) {
      rotate(PI + HALF_PI);
    }

    // Translate to the arc's center relative to pivot, then draw
    translate(centerX - pivotX, centerY - pivotY);
    arc(0, 0, w, h, radians(startAngle), radians(stopAngle));

    popMatrix();
  }
}
