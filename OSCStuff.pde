import oscP5.*;
import netP5.*;

HashMap<String, OscCommand> oscCommands = new HashMap<String, OscCommand>();

OscP5 oscP5;

public static final String MIRROR_IMAGE = "mirror";
public static final String RIGHT_IMAGE = "right";
public static final String LEFT_IMAGE = "left";
public static final String NO_IMAGE = "noimage";
public static final String NORMAL_IMAGE = "normal";

//
// for easy on-the-fly-command store/retrival in HashMap
//
public interface OscCommand  
{
  public void cmd();
}


void showImg(final String mode)
{
  // mirror or ... 
}

void setBrightness(float b)
{
  // only if changed...
}


void setupOSC()
{
  // Populate commands map
  oscCommands.put(MIRROR_IMAGE, new OscCommand() { public void cmd() { showImg(MIRROR_IMAGE); }} );
  oscCommands.put(LEFT_IMAGE, new OscCommand() { public void cmd() { showImg(LEFT_IMAGE); }} );
  oscCommands.put(RIGHT_IMAGE, new OscCommand() { public void cmd() { showImg(RIGHT_IMAGE); }} );
  oscCommands.put(NO_IMAGE, new OscCommand() { public void cmd() { showImg(NO_IMAGE); }} );
  oscCommands.put(NORMAL_IMAGE, new OscCommand() { public void cmd() { showImg(NORMAL_IMAGE); }} );

  // start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);
}

//
// run a string command received from tidalcycles or wherever via osc
//
void runOSCCommand(final String oscCommandString) 
{
  OscCommand oscCommand = oscCommands.get(oscCommandString);
  if (oscCommand != null)
  try {
    oscCommand.cmd();
  }
  catch (Exception e)
  {
    e.printStackTrace();
  }
}


// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) 
{
  /* print the address pattern and the typetag of the received OscMessage */
  //print("# received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //print(" typetag: "+theOscMessage.typetag());
  //print(" timetag: "+theOscMessage.timetag());  

  if (theOscMessage.checkAddrPattern("/tc") && theOscMessage.checkTypetag("ssfs")) 
  {
    // from tidal:
    //S "imgMode" Nothing, -- mirror, left, right, clear, normal
    //S "colorMode" Nothing, -- invert, firey, cool
    //F "brightness" (Just 1.0), 
    //S "storm" Nothing ---big, small, tiny, etc...

    String imgMode = theOscMessage.get(0).stringValue();  
    runOSCCommand(imgMode);
    
    String colorMode = theOscMessage.get(1).stringValue();  
    runOSCCommand(colorMode);
    
    float bright = theOscMessage.get(2).floatValue();    
    setBrightness(bright); // only if changed
    
    String storm = theOscMessage.get(3).stringValue();
    runOSCCommand(storm);

    //print(":::received an osc message /tc with typetag ssfs.");
    //print(":::timetag: "+theOscMessage.timetag());  
    //println(":::values: "+imgMode+", "+colorMode+", "+bright+", "+storm);
  }
}