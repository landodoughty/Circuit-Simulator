# Circuit-Simulator
A circuit simulator for passive circuits containing resistors, inductors, capacitors, and batteries

All code is provided broken down into general categorized files, most of these files have multiple classes within. An EXE is also provided for the app itself.

# USING THE PROGRAM

**Placing Components**
Place components by pressing their button and providing the value you want that component to be. For capacitors and inductors, it will also ask for a starting voltage or current respectively. This number can be inputted in decimal form (0.0035) or in scientific notation (3.5e-3) for your conveinance. Once you have provided the values neccesary, you can place the component. Use 'R' to rotate the component if desired. 

**Connecting Components**
Placed components will have empty circles on their ends, representing each node. You can connect components by placing two component so that their ends/circles line up. Alternatively, you can click on one node and draw a line to another to connect it, clicking to terminate the line. Pressing escape will terminate the current line being drawn and pressing enter will cut it off to the most recent point.

**Simulating the circuit**
To simulate the circuit, press 'S'. If your circuit is purely resistive(contains only batteries and resistors), the circuit will immediately simulate, and by hovering your cursor over any resistor, you can determine the voltage, current, and power of that resistor. If your circuit contains time based components(capacitors and inductors), a pop up will appear asking you to input how long yo simulate for. Once you have filled this in, it will ask for the time increment of the simulation. Do not worry too much about getting these values perfect on the first try, as you can always re-simulate by pressing 'S'. Generally, starting out with a time increment of 0.001 is a good idea, but keep in mind there is a limit to how many datapoints the simulation will collect so if you try to have very small increments over a long simulation period it will likely cut short. Once again, hovering over a component will show its values, this time in graph form.

**Getting Specific Values from Time based Circuit**
When hovering over a component in a time based circuit a graph will appear, showing voltage and current over time. However, if you want a more precise method of determining a specific value, you can use the following tools:
* Get the values at a time by pressing 't' - input the time you want and the voltage, current, and power will appear at the bottom left.
* Get the values at a voltage by pressing 'v' - input the voltage you want and the time, current, and power will appear at the bottom left.
* Get the values at a current by pressing 'c' - input the current you want and the time, voltage, and power will appear at the bottom left.
Keep in mind that the second two of these will return the first time the voltage is seen so in an oscilating circuit you will not get multiple values.
