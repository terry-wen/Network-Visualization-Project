static class Utils {
  public static float timeStringToFloat(String timeString) {
    return (float(timeString.substring(0,2)) * 3600)
      + (float(timeString.substring(3,5))*60)
      + float(timeString.substring(6,8))
      + (float(timeString.substring(9))/1000000);
  }
  
  public static String timeFloatToString(float timeFloat) {
    float sec = timeFloat % 60;
    int min = floor(timeFloat/60) % 60;
    int hour = floor(timeFloat/3600);
    return nf(hour, 2) + ":" + nf(min, 2) + ":" + nf(sec, 2, 2);
  }
}
