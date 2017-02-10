import oscP5.*;
import netP5.*;

HashMap<String, OscCommand> oscCommands = new HashMap<String, OscCommand>();

OscP5 oscP5;

// TODO - make "brightness" more adaptable instead of hard-coded version which is crap


// osc commands - thought about using enums but we're getting them as strings.
// could be it's own class but... how would that make things easier/safer?
public static final String MIRROR_IMAGE = "img_mirror";
public static final String RIGHT_IMAGE = "img_right";
public static final String LEFT_IMAGE = "img_left";
public static final String NO_IMAGE = "img_none";
public static final String NORMAL_IMAGE = "img_normal";

public static final String IMG_MODES[] = { MIRROR_IMAGE, RIGHT_IMAGE, LEFT_IMAGE, NO_IMAGE, NORMAL_IMAGE };

public static final String COLOR_MODE_FIREY = "c_firey";
public static final String COLOR_MODE_COOL = "c_cool";
public static final String COLOR_MODE_INVERT = "c_invert";

public static final String COLOR_MODES[] =  {COLOR_MODE_FIREY, COLOR_MODE_COOL, COLOR_MODE_INVERT };

public static final String STORM_MODE_BIG = "st_big";
public static final String STORM_MODE_SMALL = "st_small";
public static final String STORM_MODE_TINY = "st_tiny";

public static final String STORM_MODES[] =  {STORM_MODE_BIG, STORM_MODE_SMALL, STORM_MODE_TINY};

public static final String GS_MODE_NORMAL = "gs_normal";
public static final String GS_MODE_LOOSE = "gs_loose";

public static final String GS_MODES[] = {GS_MODE_NORMAL, GS_MODE_LOOSE};

public static final String UPDATE_SIM = "update";


// TODO: for testing
//private static final String[] ALL_OSC_COMMANDS = [MIRROR_IMAGE, RIGHT_IMAGE


//
// for easy on-the-fly-command store/retrival in HashMap
// If we were using Java 8 this could be much simpler!
//
public interface OscCommand  
{
  public void cmd() throws IllegalArgumentException;
}


void setImgMode(final String mode) throws IllegalArgumentException
{
  // mirror or ...
  switch(mode)
  {
  case MIRROR_IMAGE:
    break;

  case RIGHT_IMAGE:
    break;

  case LEFT_IMAGE:
    break;

  case NO_IMAGE:
    break;

  case NORMAL_IMAGE:
    break;

  default:
    throw new IllegalArgumentException("Invalid image mode: " + mode);
  }
}

void setBrightness(float b) throws IllegalArgumentException
{
  // only if changed...
}

void setColorMode(final String mode) throws IllegalArgumentException
{
  // firey or ...
  switch(mode)
  {
  case COLOR_MODE_FIREY:
    break;


  case COLOR_MODE_COOL:
    break;

  case COLOR_MODE_INVERT:
    break;

  default:
    throw new IllegalArgumentException("Invalid color mode: " + mode);
  }
}


void setStormMode(final String mode) throws IllegalArgumentException
{
  // firey or ...
  switch(mode)
  {
  case STORM_MODE_BIG:
    break;

  case STORM_MODE_SMALL:
    break;

  case STORM_MODE_TINY:
    break;

  default:
    throw new IllegalArgumentException("Invalid color mode: " + mode);
  }
}


void setGSMode(final String mode) throws IllegalArgumentException
{
  GrayScottCoefficient gsc = gsModes.get(mode);
  //println(mode);
  if (gsc != null) gs.setCoefficients(gsc);
  else throw new IllegalArgumentException("Invalid color mode: " + mode);
}


void setupOSC()
{
  for (final String osccmd : IMG_MODES)
  {
    // Populate commands map
    oscCommands.put(osccmd, new OscCommand() { 
      public void cmd() { 
        setImgMode(osccmd);
        //println("osccmd: " + osccmd);
      }
    } 
    );
  }
  for (final String osccmd : COLOR_MODES)
  {
    // Populate commands map
    oscCommands.put(osccmd, new OscCommand() { 
      public void cmd() { 
        setColorMode(osccmd);
        //println("osccmd: " + osccmd);
      }
    } 
    );
  }

  for (final String osccmd : STORM_MODES)
  {
    // Populate commands map
    oscCommands.put(osccmd, new OscCommand() { 
      public void cmd() { 
        setStormMode(osccmd);
        //println("osccmd: " + osccmd);
      }
    } 
    );
  }

  for (final String osccmd : GS_MODES)
  {
    // Populate commands map
    oscCommands.put(osccmd, new OscCommand() { 
      public void cmd() { 
        setGSMode(osccmd);
        //println("osccmd: " + osccmd);
      }
    } 
    );
  }

  /* TODO:
   oscCommands.put(UPDATE_SIM, new OscCommand() { 
   public void cmd() { 
   updateSimulation = true;
   ;
   //println("osccmd: " + "update");
   }
   } 
   );
   */

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

/*
String lastImgMode = "";
 String lastColorMode = "";
 String lastStormMode = "";
 String lastGSMode = "";
 String lastGSMode = "";
 */

//
// incoming osc message are forwarded to the oscEvent method.
// TODO: use final strings for these!
//
void oscEvent(OscMessage theOscMessage) 
{
  // debugging
  //print("# received an osc message.");
  if (false)
  {
    print(" addrpattern: "+theOscMessage.addrPattern());
    print(" typetag: "+theOscMessage.typetag());
    println(" timetag: "+theOscMessage.timetag()+"-------------");
  }

  /* from tidal:
   
   S "imgmode" (Just "mirror"), -- mirror, left, right, clear
   S "colormode" (Just "cool"), -- invert, firey, cool
   F "brightness" (Just 1.0),
   S "storm" (Just "none"), -- big, small, tiny, etc...
   S "gsmode" (Just "normal"), --gray scott diffusion modes
   F "gsf" (Just 0.09), -- gray scott f coeff
   F "gsk" (Just 0.01), -- gray scott k coeff
   I "update" (Just 1) -- update to next frame
   
   */

  if (theOscMessage.checkAddrPattern("/tc"))
  {
    int numMessages = theOscMessage.typetag().length();
    if (numMessages % 2 == 0)
    {
      for (int index = 0; index < numMessages-1; index+=2)
      {
        char msgtype = theOscMessage.typetag().charAt(index);

        // make sure its a string! should be a param name
        if (msgtype == 's')
        {
          final String message = theOscMessage.get(index).stringValue();
          //println("OSC message:" + message);
          // TODO: check all type tags!!!

          msgtype = theOscMessage.typetag().charAt(index+1);

          switch (message)
          {
          case "imgmode":
            String imgMode = theOscMessage.get(index+1).stringValue();
            if (imgMode != null && imgMode != "")
              runOSCCommand("img_"+imgMode);
            break;

          case "colormode":
            String colorMode = theOscMessage.get(index+1).stringValue();  
            if (colorMode != null && colorMode != "")
              runOSCCommand("c_"+colorMode);
            break;

          case "gsmode":
            String gsMode = theOscMessage.get(index+1).stringValue();
            if (gsMode != null && gsMode != "")
              runOSCCommand("gs_"+gsMode);
            break;

          case "brightness":
            float b = theOscMessage.get(index+1).floatValue(); 
            setBrightness(b);
            break;

          case "storm":
            String storm = theOscMessage.get(index+1).stringValue();
            if (storm != null && storm != "")
              runOSCCommand("st_"+storm);
            break;

          case "update":
            int state = theOscMessage.get(index+1).intValue();
            if (state > 0) updateSimulation = true;
            break;


          default: 
            println("Illegal OSC message:" + message);
            throw new IllegalArgumentException("Invalid OSC message received: " + message);
          }
          // make sure we have named params, param pairs
        }
      }
    }
  }
}