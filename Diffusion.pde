import toxi.sim.grayscott.*;
import toxi.math.*;

import toxi.color.*;

final String GS_MODE_NORMAL = "normal";
final String GS_MODE_LOOSE = "loose";
final String COLOR_MODE_FIREY = "firey";
final String COLOR_MODE_COOL = "cool";
final String COLOR_MODE_INVERT = "invert";

int NUM_ITERATIONS = 1;

PatternedGrayScott gs;

HashMap<String, ToneMap> gsColors;

PGraphics gsImg;
boolean clearGs = false;

int gsScale = 6;

// present modes for GrayScott coefficients, usually changed via OSC
HashMap<String, GrayScottCoefficient> gsModes; 

ToneMap gsColorMap;

void setupGrayScott()
{
  //gsImg = createImage(4*width/scaling, 4*height/scaling,ARGB);
  gsImg = createGraphics(width, height, P3D); 
  gsImg.beginDraw();
  gsImg.background(0);
  gsImg.endDraw();

  gs=new PatternedGrayScott(width, height, false);

  gsModes = new HashMap<String, GrayScottCoefficient>();
  gsModes.put(GS_MODE_NORMAL, new GrayScottCoefficient(0.02, 0.066, 0.06, 0.09));
  gsModes.put(GS_MODE_LOOSE, new GrayScottCoefficient(0.02, 0.07, 0.12, 0.08));

  gs.setCoefficients(gsModes.get(GS_MODE_NORMAL)); //    setCoefficients(float f, float k, float dU, float dV) 

  gsColors = new HashMap<String, ToneMap>();

  // create a color gradient for 256 values
  ColorGradient grad=new ColorGradient();
  // NamedColors are preset colors, but any TColor can be added
  // see javadocs for list of names:
  // http://toxiclibs.org/docs/colorutils/toxi/color/NamedColor.html
  //grad.addColorAt(0, NamedColor.BLACK);
  //grad.addColorAt(16, NamedColor.WHITE);
  //grad.addColorAt(64, NamedColor.BLACK);
  //grad.addColorAt(128, NamedColor.YELLOW);
  //grad.addColorAt(192, NamedColor.RED);
  //grad.addColorAt(255, TColor.newRGB(1f,0.3f,1f));

  //monochrome

  //monochrome
  grad.addColorAt(0, NamedColor.BLACK);
  grad.addColorAt(16, NamedColor.WHITE);
  grad.addColorAt(64, NamedColor.BLACK);
  grad.addColorAt(128, NamedColor.WHITE);
  grad.addColorAt(200, NamedColor.YELLOW);
  grad.addColorAt(230, NamedColor.BLACK);


  //grad.addColorAt(0, TColor.newRGB(0f, 0f, 0f));
  //grad.addColorAt(8, TColor.newRGB(0.2f, 0.3f, 0.2f));
  //grad.addColorAt(36, TColor.newRGB(0.2f, 0.8f, 0.2f));
  //grad.addColorAt(64, NamedColor.BLACK);
  //grad.addColorAt(128, NamedColor.PINK);
  //grad.addColorAt(200, NamedColor.GREEN);
  //grad.addColorAt(230, NamedColor.BLACK);

  // this gradient is used to map simulation values to colors
  // the first 2 parameters define the min/max values of the
  // input range (Gray-Scott produces values in the interval of 0.0 - 0.5)
  // setting the max = 0.33 increases the contrast

  gsColorMap = new ToneMap(0, 0.43, grad);

  gsColors.put(COLOR_MODE_FIREY, gsColorMap);

  grad=new ColorGradient();
  // NamedColors are preset colors, but any TColor   
  grad.addColorAt(0, NamedColor.BLACK);
  grad.addColorAt(16, NamedColor.GRAY);
  grad.addColorAt(64, NamedColor.BLACK);
  grad.addColorAt(128, NamedColor.WHITE);
  grad.addColorAt(192, TColor.newRGB(0.2f, 0.3f, 0.8f));
  grad.addColorAt(255, NamedColor.PURPLE);

  gsColors.put(COLOR_MODE_COOL, new ToneMap(0, 0.43, grad));

  grad=new ColorGradient();
  // NamedColors are preset colors, but any TColor   
  grad.addColorAt(0, NamedColor.WHITE);
  grad.addColorAt(16, NamedColor.BLACK);
  grad.addColorAt(64, NamedColor.GRAY);
  grad.addColorAt(128, NamedColor.GREEN);
  grad.addColorAt(192, NamedColor.BLUE);
  grad.addColorAt(255, NamedColor.GREEN);

  gsColors.put(COLOR_MODE_INVERT, new ToneMap(0, 0.43, grad));
}


void drawGrayScott()
{
  if (clearGs)
  {
    println("CLEAR");
    clearGs = false;
    gs.reset();

    gsImg.beginDraw();
    gsImg.background(0);
    gsImg.endDraw();
  } else
  {
    // update the simulation a few time steps
    for (int i=0; i<NUM_ITERATIONS; i++) {
      gs.update(1);
    }
    // read out the V result array
    // and use tone map to render colours

    //if ((millis()/1000) % 2 == 0) toneMap = toneMapCool;

    gsImg.loadPixels();
    gsColorMap.getToneMappedArray(gs.v, gsImg.pixels);
    gsImg.updatePixels();
    //imageMode(CORNERS);
    //blendMode(REPLACE);
    //image(gsImg,0,0,width,height);
  }
}



// using inheritance and overwriting of 2 supplied adapter methods,
// we can customize the standard homogenous behaviour and create new outcomes.
class PatternedGrayScott extends GrayScott {
  public PatternedGrayScott(int w, int h, boolean tiling) {
    super(w, h, tiling);
  }

  //
  // convenience function
  //
  public void setCoefficients(GrayScottCoefficient gsc)
  {
    this.setCoefficients(gsc.f, gsc.k, gsc.du, gsc.dv);
  }


  // we use the x position to divide the simulation space into columns
  // of alternating behaviors
  public float getFCoeffAt(int x, int y) {
    x/=16;
    return 0==x%2 ? f : f-0.002;
  }

  // we use the y position to create a gradient of varying values for
  // the simulation's K coefficient
  public float getKCoeffAt(int x, int y) {
    y/=8;
    return 0==y%2 ? k : k-y*0.00004;
  }

  public void clearRect(int x, int y, int w, int h) {
    int mix = MathUtils.clip(x - w / 2, 0, width);
    int max = MathUtils.clip(x + w / 2, 0, width);
    int miy = MathUtils.clip(y - h / 2, 0, height);
    int may = MathUtils.clip(y + h / 2, 0, height);
    for (int yy = miy; yy < may; yy++) {
      for (int xx = mix; xx < max; xx++) {
        int idx = yy * width + xx;
        uu[idx] = 1f;
        vv[idx] = 0f;
      }
    }
  }

  public void clearRect(int x, int y, int w, int h, float uuu, float vvv) {
    int mix = MathUtils.clip(x - w / 2, 0, width);
    int max = MathUtils.clip(x + w / 2, 0, width);
    int miy = MathUtils.clip(y - h / 2, 0, height);
    int may = MathUtils.clip(y + h / 2, 0, height);
    for (int yy = miy; yy < may; yy++) {
      for (int xx = mix; xx < max; xx++) {
        int idx = yy * width + xx;
        uu[idx] = uuu;
        vv[idx] = vvv;
      }
    }
  }
}

//
// for storing present modes
//
public class GrayScottCoefficient extends Object
{
  public float f, k, du, dv;

  GrayScottCoefficient(float _f, float _k, float _du, float _dv)
  {
    f = _f;
    k = _k;
    du = _du;
    dv = _dv;
  }
} // class GrayScottCoefficient