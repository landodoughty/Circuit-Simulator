class PopupInputBox {
  float x, y, w, h;
  String prompt;
  String inputText = "";
  boolean isActive = false;
  boolean inputSubmitted = false;
  float result = Float.NaN;
  int lastTypedTime = 0;
  char lastTyped;
  String unit;

  PopupInputBox(float x, float y, float w, float h, String prompt, String unit) {
    this.x = x - w / 2; // Centering the button
    this.y = y - h / 2;
    this.w = w;
    this.h = h;
    this.prompt = prompt;
    this.unit = unit;
  }

  void popUp() {
    isActive = true;
    inputText = "";
    inputSubmitted = false;
    result = Float.NaN;
  }

  void update() {
    if (isActive && ( lastTyped!=key || (millis()>50+lastTypedTime && key==BACKSPACE)||millis()>200+lastTypedTime)) {
      lastTyped = key;
      lastTypedTime = millis();
      // Handle key input only when a key is pressed
      if (keyPressed) {
        //println("keypressed");
        if (key == ENTER || key == RETURN) {
          try {
            result = Float.parseFloat(inputText);
            inputSubmitted = true;
            isActive = false;  // Hide popup after input
          }
          catch (NumberFormatException e) {
            inputText = ""; // Clear input if invalid
          }
        } else if (key == BACKSPACE && inputText.length() > 0) {
          inputText = inputText.substring(0, inputText.length() - 1);
        } else if ((key >= '0' && key <= '9') || key == '.' || key == '-'|| key == 'e') {
          inputText += key;
          //println(key);
          key = ' ';
          
        }
        //delay(100);
      }
      key = ' ';
    }
    key = ' ';
  }

  void show() {
    if (isActive) {
      // Draw the input box
      fill(200);
      stroke(0);
      rect(x, y, w, h, 10);

      // Draw the prompt
      fill(0);
      textSize(16);
      textAlign(CENTER, CENTER);
      text(prompt, x + w / 2, y + 20);

      // Draw the input text
      textAlign(CENTER, CENTER);
      text(inputText+unit, x + w / 2, y + h / 2 + 10);
    }
  }



  float getValue() {
    return inputSubmitted ? result : Float.NaN;
  }
}
