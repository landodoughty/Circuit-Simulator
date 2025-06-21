class Converter {
  Circuit circ;
  ArrayList<ArrayList<CircuitNode>> connections;
  int i;

  Converter(Circuit circuit) {
    this.circ = circuit;
    connections = new ArrayList<ArrayList<CircuitNode>>();
  }

  //change first row to be the negative of the battery;
  void fix() {
    for (int j = 0; j<connections.size(); j++) {

      for (int i =0; i<c.components.size(); i++) {
        if (c.components.get(i).type == "Battery") {
          if (connections.get(j).contains(c.components.get(i).node1)) {
            ArrayList<CircuitNode> temp = connections.get(j);
            connections.set(j, connections.get(0));
            connections.set(0, temp);
          }
        }
      }
    }
  }

  Graph convert() {
    i = 0;
    for (Map.Entry entry : circ.nodes.entrySet()) {
      CircuitNode n = (CircuitNode) entry.getValue();
      n.explored = false;
    }
    //create connection map - loop  thtough all circuit nodes
    for (Map.Entry entry : circ.nodes.entrySet()) {
      CircuitNode n = (CircuitNode) entry.getValue();

      if (!n.explored) {
        convertHelper(i, n, true);
        i++;
      }
    }

    Graph g = new Graph(connections.size());

    fix();

    for (Component comp : c.components) {
      char node1 = ' ';
      char node2 = ' ';
      for (int i =0; i<connections.size(); i++) {
        if (connections.get(i).contains(comp.node1)) {
          node1 = (char) ('A' + i);
          comp.node1.label(node1);
        }
        if (connections.get(i).contains(comp.node2)) {
          node2 = (char) ('A' + i);
          comp.node2.label(node2);
        }
      }
      if (node1!=' '&&node2!=' ') {

        comp.id = g.addEdge(node1, node2, comp.value, comp.type, comp.startingValue);
         
      }
      if (comp.type=="Battery") {
        g.numBatteries++;
      }

      if (comp.type=="Capacitor") {
        g.numCapacitors++;
      }

      if (comp.type=="Inductor") {
        g.numInductors++;
      }
    }


    //int index = node1 - 'B';
    //g.startingValues[index] += comp.startingValue;

    g.display();
    println(connections);
    return g;
  }

  void convertHelper(int index, CircuitNode currNode, boolean add) {
    if (!currNode.explored) {

      //println(currNode);
      //println(index);
      //println(add);
      if (add) {
        connections.add(new ArrayList<CircuitNode>());
      }
      connections.get(index).add(currNode);
      currNode.explored=true;
      for (Curve con : circ.curves) {
        if (con.start == currNode && con.end!= null && !con.end.explored) {
          convertHelper(index, con.end, false);
          //i--;
        }
        if (con.end == currNode && !con.start.explored) {
          convertHelper(index, con.start, false);
          //i--;
        }
      }
    }
  }
}
