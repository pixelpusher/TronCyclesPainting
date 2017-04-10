String dataFile = "11_Nov_selected.csv";  
float[][] walkData;
int currentDataRow = -1;
 
 // http://paulbourke.net/geometry/transformationprojection/
 //
 float[] coordinateToCartesian(float lat, float lon)
 {
    float x = myW * (0.125 + 0.75 * lon / PI);
    float y = myH * (0.15 + 0.9*log((1f + sin(lat))/(1f - sin(lat))) / (2 * TWO_PI)); 
    float[] val = {x,y};
    //println(val);
    return val;
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

    MQ135Extent[0] = min(MQ135Extent[0], row.getFloat("MQ135 value"));
    MQ135Extent[1] = max(MQ135Extent[1], row.getFloat("MQ135 value"));
  }

  int i=0;
  
  for (TableRow row : table.rows()) {
    println(i);
    float lat = map(row.getFloat("latitude"), latExtent[0], latExtent[1],0,PI);
    float lon = map(row.getFloat("longitude"), lonExtent[0], lonExtent[1],0,PI);
    float[] latLon = coordinateToCartesian(lat,lon);
    theData[i][0] = latLon[0];
    theData[i][1] = latLon[1];
    theData[i][2] = map(row.getFloat("MQ135 value"), MQ135Extent[0], MQ135Extent[1],0,1);
    println(theData[i][2]);
    i++;
  }
  return theData;
  //end loadAllData
}