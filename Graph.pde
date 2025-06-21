public class Graph {
  Vertex[] vertices; // vertices
  int size; // size
  int numBatteries = 0;
  int numCapacitors = 0;
  int numInductors = 0;
  ArrayList <Float> capsStart = new ArrayList<Float>();
  ArrayList <Float> indsStart = new ArrayList<Float>();


  public Graph(int size) {
    this.size = size;
    vertices = new Vertex[size];
    for (int i = 0; i<size; i++) {
      vertices[i] = new Vertex((char) ('A' + i));
    }
  }


  // function adds an edge between two vertices if both exist
  public int addEdge(char v1, char v2, float val, String type, float startVal) {
    Vertex vertex1 = null;
    Vertex vertex2 = null;

    // Find vertex to connect to for the character key
    for (int i = 0; i < size; i++) {
      if (vertices[i].name == v1) {
        vertex1 = vertices[i];
      }
      if (vertices[i].name == v2) {
        vertex2 = vertices[i];
      }
    }

    // If both vertices exist, add an edge
    if (vertex1 != null && vertex2 != null) {
      if (type == "Battery") {
        vertex1.connections.add(new Edge(vertex1, vertex2, val, type, numBatteries));
        vertex2.connections.add(new Edge(vertex1, vertex2, val, type, numBatteries));
        return numBatteries;
      } else if (type == "Capacitor") {
        vertex1.connections.add(new Edge(vertex1, vertex2, val, type, numCapacitors));
        vertex2.connections.add(new Edge(vertex1, vertex2, val, type, numCapacitors));
        capsStart.add(startVal);
        return numCapacitors;
      } else if (type == "Inductor") {
        vertex1.connections.add(new Edge(vertex1, vertex2, val, type, numInductors));
        vertex2.connections.add(new Edge(vertex1, vertex2, val, type, numInductors));
        indsStart.add(startVal);
        return numInductors;
      } else {
        vertex1.connections.add(new Edge(vertex1, vertex2, val, type, -1));
        vertex2.connections.add(new Edge(vertex1, vertex2, val, type, -1));
        return -1;
      }
    }
    return -1;
  }

  // Displays the list for each vertex
  public void display() {

    //loop through vertex list
    for (int i = 0; i < size; i++) {

      print(vertices[i].name + ": ");
      //print connections list
      for (int j = 0; j < vertices[i].connections.size(); j++) {
        Edge e = vertices[i].connections.get(j);
        print(e.connectionPoint1.name+"->"+e.connectionPoint2.name+": " + e.type + "("+e.value+", "+e.ID+"), ");
      }
      println();
    }
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

import java.util.ArrayList;
public class Vertex{
    char name;
    //stores connections
    ArrayList<Edge> connections = new ArrayList<>();

    public Vertex(char name){
        this.name = name;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public class Edge {
  
  float value;
  String type;
  Vertex connectionPoint1;
  Vertex connectionPoint2;
  int ID;
  boolean visited = false;
  
  public Edge(Vertex start, Vertex end, float val, String type,int id) {
    this.value = val;
    this.type=type;  
    connectionPoint1 =start;
    connectionPoint2 =end;
    ID = id;

  }
}
