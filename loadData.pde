//final String dataFile = "11_Nov_selected.csv";  
//final String dataFile = "20160323.csv";
final String dataFile = "20160622.csv";
//final String dataFieldName = "MQ135 value";
//final String dataFieldName = "sound peak";
final String dataFieldName = "light";
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
    
return new float[]{ myW * (0.15 + 0.7 * lon / PI), myH * (0.15 + 0.7*lat/PI)};
//return new float[]{ myW * (0.1 + 4 * lon / PI), myH * (-1.125 + 2*lat/PI)};
 }
 
 

  
float[][] loadAllData()
{
  Table table;

  float[][] theData;

  table = loadTable(dataFile, "header");

  println(table.getRowCount() + " total rows in table"); 

  theData = new float[table.getRowCount()][3];

  // latitude,longitude,MQ135 value,MQ2 value,MQ2 average,MQ2 peak,dust

  float[] latExtent = {9999, -9999};
  float[] lonExtent = {9999, -9999};
  float[] MQ135Extent = {9999, -9999};
  

  for (TableRow row : table.rows()) {
    latExtent[0] = min(latExtent[0], row.getFloat("latitude"));
    latExtent[1] = max(latExtent[1], row.getFloat("latitude"));
    
    lonExtent[0] = min(lonExtent[0], row.getFloat("longitude"));
    lonExtent[1] = max(lonExtent[1], row.getFloat("longitude"));
    float data = row.getFloat(dataFieldName);
    
    MQ135Extent[0] = min(MQ135Extent[0], data);
    MQ135Extent[1] = max(MQ135Extent[1], data);
  }

  int i=0;
  
  for (TableRow row : table.rows()) {
    //println(i);
    float lat = map(row.getFloat("latitude"), latExtent[0], latExtent[1],0,PI);
    float lon = map(row.getFloat("longitude"), lonExtent[0], lonExtent[1],0,PI);
    float[] latLon = coordinateToCartesian(lat,lon);
    theData[i][0] = latLon[0];
    theData[i][1] = latLon[1];
    theData[i][2] = map(row.getFloat(dataFieldName), MQ135Extent[0], MQ135Extent[1],0,1);
    // for sound only:
    if (dataFieldName.equals("sound peak") || dataFieldName.equals("light"))
      theData[i][2] = pow(theData[i][2], 0.25);
      
    //println(theData[i][2]);
    i++;
  }
  return theData;
  //end loadAllData
}