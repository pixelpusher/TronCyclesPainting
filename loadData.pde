final String dataFile = "new-ppm-air-quality-mq135top.csv";
//final String dataFile = "11_Nov_selected.csv";  
//final String dataFile = "20160323.csv";
//final String dataFile = "20160622.csv";

final String dataFieldName = "MQ135 value 0-1024";

//final String dataFieldName = "MQ135 value";
//final String dataFieldName = "sound peak";
//final String dataFieldName = "light";
float[][] walkData;
int currentDataRow = -1;
 
 // http://paulbourke.net/geometry/transformationprojection/
 //
 float[] coordinateToCartesian(float lat, float lon)
 {
    //float x = myW * (0.125 + 0.75 * lon / PI);
    //float y = myH * (0.15 + 0.9*log((1f + sin(lat))/(1f - sin(lat))) / (2 * TWO_PI)); 
    //float[] val = {x,y};
    
    //return val;
    //println("lat: " + lat);
    
return new float[]{ 1.6*myW * (0. + 0.8 * lon), 1.6*myH * (-0.25 + 0.8*lat)};
//return new float[]{ myW * (0.1 + 4 * lon / PI), myH * (-1.125 + 2*lat/PI)};
 }
 
 
// http://paulbourke.net/geometry/transformationprojection/
 //
 float[] cartesianToCoordinate(float x, float y)
 {
  float lon = (x/myW -0.1)*PI/0.8;
  lon = map(lon, 0,1, lonExtent[0], lonExtent[1]);
  lon /= 10000f;
  
  float lat = (y/myH -0.1)*PI/0.8;
  lat = map(lat, 0,1, latExtent[0], latExtent[1]);
  
  return new float[]{ lon, lat };
 }


float[] latExtent = {9999, -9999};
float[] lonExtent = {9999, -9999};
float[] dataExtent = {9999, -9999};
 
  
float[][] loadAllData()
{
  Table table;

  float[][] theData;
  float lonScale = 10000; // for increased precision

  table = loadTable(dataFile, "header");

  println(table.getRowCount() + " total rows in table"); 

  theData = new float[table.getRowCount()][3];

  // latitude,longitude,MQ135 value,MQ2 value,MQ2 average,MQ2 peak,dust

   

  for (TableRow row : table.rows()) {
    latExtent[0] = min(latExtent[0], row.getFloat("latitude"));
    latExtent[1] = max(latExtent[1], row.getFloat("latitude"));
    
    lonExtent[0] = min(lonExtent[0], row.getFloat("longitude")*lonScale);
    lonExtent[1] = max(lonExtent[1], row.getFloat("longitude")*lonScale);
    float data = row.getFloat(dataFieldName);
    
    dataExtent[0] = min(dataExtent[0], data);
    dataExtent[1] = max(dataExtent[1], data);
  }

  int i=0;
  
  for (TableRow row : table.rows()) {
    //println(i);
    float lat = map(row.getFloat("latitude"), latExtent[0], latExtent[1],0,1);
    float lon = map(row.getFloat("longitude")*lonScale, lonExtent[0], lonExtent[1],0,1);
    if (i<400) println(i+":"+lat + ", " + lon);
    float[] latLon = coordinateToCartesian(lat,lon);
    if (latLon[0] > 18)
    {
      theData[i][0] = latLon[0];
      theData[i][1] = latLon[1];
      theData[i][2] = map(row.getFloat(dataFieldName), dataExtent[0], dataExtent[1],0,1);
      // for sound only:
      if (dataFieldName.equals("sound peak") || dataFieldName.equals("light"))
        theData[i][2] = pow(theData[i][2], 0.25);
    }
    else
    {
      theData[i][0] = 0;
      theData[i][1] = 0;
      theData[i][2] = 0;
    }
    
    //println(theData[i][2]);
    i++;
  }
  println("lon extent: " + lonExtent[0] + ", " + lonExtent[1]);
  println("lat extent: " + latExtent[0] + ", " + latExtent[1]);
  return theData;
  //end loadAllData
}