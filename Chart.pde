class Chart {
  float x, y, w, h;
  float buffer = 20;

  ArrayList<Float> times;
  boolean display = false;
  int numLines = 12;

  ArrayList<Float>[] valueLists;
  String[]titles;
  int numAdded = 0;
  color[] colors = {color(0, 100, 200,200), color(0, 200, 100,200), color(200, 0, 100,200), color(100, 0, 200,200), color(200, 100, 0,200), color(100, 200, 0,200)};


  Chart(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    valueLists = new ArrayList[4];
    titles = new String[4];
    times = new ArrayList<Float>();
  }



  void setArrays(ArrayList<Float> values, ArrayList<Float> times, String t) {
    this.times = times;
    if (numAdded<=3) {
      this.titles[numAdded]=t;
      this.valueLists[numAdded] = values;
      numAdded++;
    }
  }

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

  void display() {
    if (true) {
      pushMatrix();
      translate(x, y);

      // Draw background with buffer area
      fill(255);
      stroke(0);
      rect(0, 0, w, h);

      if (valueLists[0].size() < 2) {
        popMatrix();
        return;
      }

      float minT = times.get(0);
      float maxT = times.get(times.size() - 1);
      float maxY = 0;
      float minY = 0;
      for (ArrayList<Float> valueList : valueLists) {
        if (valueList!=null) {
          for (float value : valueList) {
            if (value > maxY) maxY = value;
            if (minY > value) minY = value;
          }
        }
      }

      // Expand bounds with buffer around Y range
      float yRange = maxY - minY;
      if (yRange == 0) yRange = 1;
      minY -= yRange * 0.1;
      maxY += yRange * 0.1;

      float graphW = w - 2 * buffer;
      float graphH = h - 2 * buffer;

      // Draw grid lines
      stroke(200);
      for (int i = 0; i <= numLines; i++) {
        float ty = map(i, 0, numLines, 0, graphH);
        float fVal = map(ty, graphH, 0, minY, maxY);
        line(buffer, buffer + ty, buffer + graphW, buffer + ty);
        fill(0);
        textSize(10);
        textAlign(LEFT, CENTER);
        text(nf(fVal, 1, 2), 2, buffer + ty);
      }

      for (int i = 0; i <= numLines; i++) {
        float tx = map(i, 0, numLines, 0, graphW);
        float tVal = map(tx, 0, graphW, minT, maxT);
        line(buffer + tx, buffer, buffer + tx, buffer + graphH);
        fill(0);
        textSize(10);
        textAlign(CENTER, TOP);
        text(formatValue(tVal, 2), buffer + tx, buffer + graphH + 2);
      }

      // F(t) = 0 axis
      if (minY < 0 && maxY > 0) {
        float zeroY = map(0, minY, maxY, graphH, 0);
        stroke(100);
        line(buffer, buffer + zeroY, buffer + graphW, buffer + zeroY);
      }

      // Plot the graph lines
      //stroke(0, 100, 200);
      int colorIndex = 0;
      noFill();
      for (ArrayList<Float> valueList : valueLists) {
        if (valueList!=null) {
          stroke(colors[colorIndex]);
          beginShape();
          for (int i = 0; i < valueList.size(); i++) {
            float tx = map(times.get(i), minT, maxT, 0, graphW);
            float ty = map(valueList.get(i), minY, maxY, graphH, 0);
            vertex(buffer + tx, buffer + ty);
          }
          endShape();
          colorIndex++;
        }
      }
      textSize(16);
      textAlign(RIGHT, CENTER);
      float[]allignment = {w/4, w/2, 3*w/4, w};
      colorIndex = 0;
      for (String t : titles) {
        if (t!=null) {
          fill(colors[colorIndex]);
          text(t, (int)allignment[colorIndex], 10);
          colorIndex++;
        }
      }
      noFill();
      textAlign(CENTER, CENTER);

      popMatrix();

      stroke(0);
    }
  }
}
