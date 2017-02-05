/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("# received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //print(" typetag: "+theOscMessage.typetag());
  //print(" timetag: "+theOscMessage.timetag());  


  if (theOscMessage.checkAddrPattern("/tc")==true) {
    /* check if the typetag is the right one. */
    //  print(" TOTAL: " + theOscMessage);

    if (theOscMessage.checkTypetag("sfiis")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */

      // from tidal:
      //text       = makeS unity "text"
      //size       = makeF unity "size"
      //vertical   = makeF unity "vertical"
      //horizontal = makeF unity "horizontal"
      //thing     = makeS unity "thing"     

      String textValue = theOscMessage.get(0).stringValue();  
      float sizeValue = theOscMessage.get(1).floatValue();
      int thirdValue = theOscMessage.get(2).intValue();
      print("### received an osc message /test with typetag sfiis.");
      println(" values: "+textValue+", "+sizeValue+", "+thirdValue);
      return;
    }
  }
}

class OSCMsg 
{
  String textValue;
  float sizeValus;
  float x, y;
  String thingValue;  
}