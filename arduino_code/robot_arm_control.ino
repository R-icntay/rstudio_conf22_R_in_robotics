//#include <Servo.h>
#include "VarSpeedServo.h"
#include <EEPROM.h> // memory whose values are kept when the  board is turned off (like a small hard drive)
#include <HCSR04.h>

// assigning potentiometers to analog pins since potentiometers give an analog output which will then be converted to a range of 0-1023

int pot0=A0; //base
int pot1=A1; //main
int pot2=A2; //forearm
int pot3=A3; //end effector


// using the VarspeedServo library to assign the servos to pins
// Class for manipulating servo motors connected to Arduino pins.


VarSpeedServo servo0;
VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;

int  t=0;
String mychar2 = "HAI!!Execution Complete";
String names = "EricIanSam";
int val0;
int valmapped0;
int val1;
int valmapped1;
int val2;
int valmapped2;
int val3;
int valmapped3;


//servoSequencePoint loops(120A120B120C120D);

byte mode; // stores an 8 bit unassigned number from 0-255 since there are two modes

//int led=2;
//HCSR04 hc(3,4); //initialisation class HCSR04 (trig pin , echo pin)

void setup()
{
 Serial.begin(9600);

 //Serial.println("Let's begin");
 
 // attach(pin )  - Attaches a servo motor to an i/o pin.
 servo0.attach(5);
 servo1.attach(6);
 servo2.attach(9);
 servo3.attach(10);

 pinMode(pot0,INPUT); // not necessary since pins are input puins by default
// pinMode(led,OUTPUT);
}

/*if(dist<=17){
    digitalWrite(led,HIGH);
    //Serial.println(dist);
    delay(5000);
  }else{
    digitalWrite(led,LOW);
  }
*/

void loop()
{ 
 // The static keyword is used to create variables that are visible to only one function. 
 //However unlike local variables that get created and destroyed every time a function is called,
 //static variables persist beyond the function call, preserving their data between function calls.
 
 
 
 
  if(Serial.available()){
     
  
  static int t=0;
    

    char mychar=Serial.read();
    
    

    //Like if statements, 
    //switch case controls the flow of programs by allowing programmers 
    //to specify different code that should be executed in various conditions.
    //When a case statement is found whose value matches that of the variable,
    //the code in that case statement is run.The break keyword exits the switch statement.

    switch(mychar){
      //mychar: a variable whose value to compare with various cases.
      
      case '0'...'9':
        t=t*10 + mychar - '0';

        break;

      case 'a':
        {
          
            servo0.write(t,20); //  write(value, speed) - speed varies the speed of the move to new position 0=full speed, 1-255 slower to faster
            //Serial.print(t);
            //Serial.print("\t");
        }
        t=0;

        break;

      case 'b':
        {
          
            servo1.write(t,20);
             //int th2=t;
           // Serial.print(t);
            //Serial.print("\t");
        }
        t=0;

        break;

      case 'c' :
        {
          
          
            servo2.write(t,10);
            //int th3=t;
          //  Serial.print(t);
           // Serial.print("\t");
        }
        t=0;

        break;

      case 'd':
        {
          
            servo3.write(t,10);
             //Serial.print(t); 
             //Serial.print("\t"); 
        }
        t=0;

        break;


// trying to make the joints move sequentially, not all at the same time. Check the library for another servo.write deviant
// write(value, speed, wait) - wait is a boolean that, if true, causes the function call to block until move is complete
// Boolean is a value just like an integer that can take a number, but instead of 0-65535 it can take a number 0 or 1.


         case 'A':
        {
            Serial.println(t);
            servo0.write(t,50,1);
             //int th1=t;
          //  Serial.print(t);
           // Serial.print("\t"); 
        }
        t=0;

        break;

      case 'B':
        {
            Serial.println(t);
            servo1.write(t,50,1);
             //int th2=t;
         //   Serial.print(t);
           // Serial.print("\t");
        }
        t=0;

        break;

      case 'C' :
        {
          Serial.println(t);
          servo2.write(t,50,1);
          
          
            //int th3=t;
            //Serial.println(t);
            //Serial.print("\t");
        }
        t=0;

        break;

      case 'D':
        {
            //Serial.println(t);
            servo3.write(t,20,1);
            // Serial.print(t);
            // Serial.print("\t");  
        }
        t=0;

        break;

        //case 'L':
         //{
          //if(mode==1)
          //  sequencePlay(loops,3,true,90);
        // }
        // t=0;

         //break;

      case 'm':
        {
          Serial.print("Servos will be controlled using potentiometers");
          delay(2000);
          mode=0;
          Serial.println(mode);
        }
        break;
        t=0;


     

      case 'y':
    {

      mode=6;
      delay(100);
    }
    t=0;

    break;
        

      case 'W':
    {
      delay(100);
    }

    break;

 

      
    }

    //Serial.print(mychar);
  // while(t<1){
   // Serial.println(mychar2);
   // t++;
  //}
    
  }
  

/*if(mode==5){
   int dist=hc.dist();
  if(dist<=17){
    digitalWrite(led,HIGH);
    Serial.println(dist);
    delay(5000);
  }else{
    digitalWrite(led,LOW);
  }

}*/
  

}
