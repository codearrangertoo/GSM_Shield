
/* GSM Shield example
 
 created 2011
 by Boris Landoni
 
 This example code is in the public domain.

 
 http://www.open-electronics.org
 http://www.futurashop.it
 */

#include <SoftwareSerial.h> 
#include <GSM_Shield.h>

//**************************************************************************
char number[]="+39123456789";  //Destination number 
char text[]="hello world";  //SMS to send
byte type_sms=SMS_UNREAD;      //Type of SMS
byte del_sms=0;                //0: No deleting sms - 1: Deleting SMS
//**************************************************************************

GSM gsm;
char sms_rx[122]; //Received text SMS
//int inByte=0;    //Number of byte received on serial port
char number_incoming[20];
int call;
int error;


void setup() 
{
  Serial.begin(9600);
  Serial.println("system startup"); 
  gsm.TurnOn(9600);          //module power on
  gsm.InitParam(PARAM_SET_1);//configure the module  
  gsm.Echo(0);               //enable AT echo 

}


void loop()
{ 
  char inSerial[5];   
  int i=0;
  delay(2000);
  
    Check_Call(); //Check if there is an incoming call
    Check_SMS();  //Check if there is SMS 
    //Check data serial com 
    
    if (Serial.available() > 0) 
    {             
       while (Serial.available() > 0) {
         inSerial[i]=(Serial.read()); //read data  
         i++;      
       }
       inSerial[i]='\0';
      Check_Protocol(inSerial);
    }
       
}  

void Check_Protocol(String inStr)
{   
       Serial.print("Command: ");
       Serial.println(inStr);
       
  Serial.println("Check_Protocol");
  
    switch (inStr[0])
      {
       case 'a' :  //Answer        
           if (gsm.CallStatus()==CALL_INCOM_VOICE){
             gsm.PickUp();
             Serial.println("Answer");
           }
           else
           {
             Serial.println("No incoming call");
           }
         break;
       
    
       case 'c': // C  //Call
         if (inStr.length()<2)  //To call variable 'number'    comand   c
         {
           Serial.print("Calling ");
           Serial.println(number);         
           gsm.Call(number);
         }
         if (inStr.length()==2)  //To call number in phone book position   comand   cx where x is the SIM position
         {
             error=gsm.GetPhoneNumber(inStr[1],number);
             if (error!=0)
             {
               Serial.print("Calling ");
               Serial.println(number);
               gsm.Call(number);
             }
             else 
             {
               Serial.print("No number in pos ");
               Serial.println(inStr[1]);
             }
         }
         break;
          
       case 'h': //H //HangUp if there is an incoming call
         if (gsm.CallStatus()!=CALL_NONE)         
         {
           Serial.println("Hang");
           gsm.HangUp();              
         }
         else
         {
           Serial.println("No incoming call");
         }    
         break;
         
         
       case 's': //S //Send SMS
         Serial.print("Send SMS to ");
         Serial.println(number);
         error=gsm.SendSMS(number,text);  
         if (error==0)  //Check status
         {
             Serial.println("SMS ERROR \n");
         }
         else
         {
             Serial.println("SMS OK \n");             
         }
         break;
              
       case 'p':  //Read-Write Phone Book
         if (inStr.length()==3)
         {
           
           switch (inStr[1])
           {
             case 'd':  //Delete number in specified position  pd2
               error=gsm.DelPhoneNumber(inStr[2]);
               if (error!=0)
               {
                 Serial.print("Phone number position ");
                 Serial.print(inStr[2]);
                 Serial.println(" deleted");
               }
               break;
               
               
               
             case 'g':  //Read from Phone Book position      pg2
               error=gsm.GetPhoneNumber(inStr[2],number);
               if (error!=0)  //Find number in specified position
               {
                 Serial.print("Phone Book position ");
                 Serial.print(inStr[2]);
                 Serial.print(": ");
                 Serial.println(number);
               }
               else  //Not find number in specified position
               {
                 Serial.print("No Phone number in position ");
                 Serial.println(inStr[2]);
               }
               break;
             case 'w':  //Write from Phone Book Position    pw2
               error=gsm.WritePhoneNumber(inStr[2],number);
               if (error!=0)
               {
                 Serial.print("Number ");
                 Serial.print(number);
                 Serial.print(" writed in Phone Book position ");
                 Serial.println(inStr[2]);
               }
               else Serial.println("Writing error");
               break;
               
               
               
           }
           
         }
         break;
         
       }
   
    delay(1500);
    
    return;
 }
 
 
 void Check_Call()  //Check status call if this is available
 {     
     call=gsm.CallStatus();
     switch (call)
     {    
       case CALL_NONE:
         Serial.println("no call");
         break;
       case CALL_INCOM_VOICE:
         gsm.CallStatusWithAuth(number_incoming,0,0);        
         Serial.print("incoming voice call from ");     
         Serial.println(number_incoming);
         break;
       case CALL_ACTIVE_VOICE:
         Serial.println("active voice call");    
         break;
       case CALL_NO_RESPONSE:
         Serial.println("no response");
         break;
     }
     return;
 }
 
 
 void Check_SMS()  //Check if there is an sms 'type_sms'
 {
     char pos_sms_rx;  //Received SMS position     
     pos_sms_rx=gsm.IsSMSPresent(type_sms);
     if (pos_sms_rx!=0)
     {
       //Read text/number/position of sms
       gsm.GetSMS(pos_sms_rx,number_incoming,sms_rx,120);
       Serial.print("Received SMS from ");
       Serial.print(number_incoming);
       Serial.print("(sim position: ");
       Serial.print(word(pos_sms_rx));
       Serial.println(")");
       Serial.println(sms_rx);
       if (del_sms==1)  //If 'del_sms' is 1, i delete sms 
       {
         error=gsm.DeleteSMS(pos_sms_rx);
         if (error==1)Serial.println("SMS deleted");      
         else Serial.println("SMS not deleted");
       }
     }
     return;
 }
 
 


 

  
