import java.security.MessageDigest;
String dpr;

static String UNLICENSED = "Unlicensed";

class License extends Object {
  int demotime = 1800;
  long sessionT;
  String[] licenseKey;
  protected boolean valid = false;
  MessageDigest md;
  
  public License() {
    sessionT = (new Date()).getTime();
    dpr = "";
    if (DEBUG) dpr = "/Users/markqvist/Documents/Processing/midikatapult/";
    licenseKey = loadStrings(dpr+"license.txt");
    try {
      //println("License test running...");
      md = MessageDigest.getInstance("MD5");
      
      String[] components = split(licenseKey[0], "-");
      String id = licenseKey[0].substring(0, 6);
      String checksum = components[1];
      //println("id: "+id);
      //println("checksum: "+checksum);
      md.reset();
      md.update(id.getBytes("UTF-8"));
      byte[] digest = md.digest();
      String gens = "";
      for (int i = 0; i < digest.length; i++) {
        gens += digest[i];
        //print(" "+(int)digest[i]+" ");
      }
      gens = id + gens;
      //println();
      //println("F:"+licenseKey[0]);
      //println("G:"+gens);        // REMOVE!!!
      if (licenseKey[0].equals(gens)) {
        valid = true;
        UNLICENSED = "";
      }
    } catch (Exception e) { };
  }
  
  public boolean isValid() {
    return valid;
  }
}

boolean demoIsValid() {
  long now = (new Date()).getTime();
  if (now - license.sessionT < license.demotime*1000) {
    return true;
  } else {
    return false;
  }
}
