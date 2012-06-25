/* GSM Shield example
 
 created 2011
 by Boris Landoni
 
 This example code is in the public domain.

 
 http://www.open-electronics.org
 http://www.futurashop.it
 */

#include <SoftwareSerial.h>
#include <GSM_Shield.h>
//for enable disable debug rem or not the string       #define DEBUG_PRINT
// definition of instance of GSM class
GSM gsm;



void setup() {
  Serial.begin(9600);
  Serial.println("system startup"); 
  //gsm.InitSerLine(9600);   //initialize serial 1 
  gsm.TurnOn(9600);              //module power on
  //gsm.InitSerLine(9600);   //initialize serial 1 
  gsm.InitParam(PARAM_SET_1);//configure the module  
  gsm.Echo(1);               //enable AT echo 
}


void loop()
{
  
    int call;
    call=gsm.CallStatus();
    switch (call){    
      case CALL_NONE:
        Serial.println("no call");
        break;
      case CALL_INCOM_VOICE:
        Serial.println("incoming voice call"); 
        delay(5000);     
        gsm.PickUp();
        break;
      case CALL_ACTIVE_VOICE:
        Serial.println("active voice call");
        delay(5000);     
        gsm.HangUp();
        break;
      case CALL_NO_RESPONSE:
        Serial.println("no response");
        break;
    }
    delay(1000);
    
}
    
