import toxi.sim.grayscott.*;
import toxi.math.*;

import toxi.color.*;

int NUM_ITERATIONS = 1;

PatternedGrayScott gs;
ToneMap toneMapFire, toneMapCool;

PGraphics gsImg;
boolean clearGs = false;

int gsScale = 2;

void setupGrayScott()
{
  //gsImg = createImage(4*width/scaling, 4*height/scaling,ARGB);
  gsImg = createGraphics(gsScale*width/scaling, gsScale*height/scaling, P3D); 
  gsImg.beginDraw();
  gsImg.background(0);
  gsImg.endDraw();

  gs=new PatternedGrayScott(gsScale*width/scaling, gsScale*height/scaling, false);
  //melty
  //gs.setCoefficients(0.02, 0.07, 0.12, 0.02);
  gs.setCoefficients(0.02, 0.07, 0.12, 0.08);
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
  grad.addColorAt(0, NamedColor.BLACK);
  grad.addColorAt(16, NamedColor.WHITE);
  grad.addColorAt(64, NamedColor.BLACK);
  grad.addColorAt(128, NamedColor.WHITE);
  grad.addColorAt(200, NamedColor.YELLOW);
  grad.addColorAt(230, NamedColor.BLACK);




  // this gradient is used to map simulation values to colors
  // the first 2 parameters define the min/max values of the
  // input range (Gray-Scott produces values in the interval of 0.0 - 0.5)
  // setting the max = 0.33 increases the contrast
  toneMapFire=new ToneMap(0, 0.43, grad);

  ColorGradient grad2=new ColorGradient();
  // NamedColors are preset colors, but any TColor   
  grad2.addColorAt(0, NamedColor.BLACK);
  grad2.addColorAt(16, NamedColor.GRAY);
  grad2.addColorAt(64, NamedColor.BLACK);
  grad2.addColorAt(128, NamedColor.WHITE);
  grad2.addColorAt(192, NamedColor.BLUE);
  grad2.addColorAt(255, NamedColor.PURPLE);

  toneMapCool=new ToneMap(0, 0.43, grad2);
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

    ToneMap toneMap = toneMapFire;

    //if ((millis()/1000) % 2 == 0) toneMap = toneMapCool;

    gsImg.loadPixels();
    toneMap.getToneMappedArray(gs.v, gsImg.pixels);
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

  // we use the x position to divide the simulation space into columns
  // of alternating behaviors
  public float getFCoeffAt(int x, int y) {
    x/=8;
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