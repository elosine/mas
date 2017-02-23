// DECLARE/INITIALIZE CLASS SET
TimetrigSet timetrigz = new TimetrigSet();

/**
 *
 *
 /// PUT IN SETUP ///
 osc.plug(timetrigz, "mk", "/mktimetrig");
 osc.plug(timetrigz, "rmv", "/rmvtimetrig");
 osc.plug(timetrigz, "rmvall", "/rmvalltimetrig");
 
 /// PUT IN DRAW ///
 timetrigz.drw();
 *
 *
 */


class Timetrig {

  // CONSTRUCTOR VARIALBES //
  int ix;
  float rad, dur;
  String sclr;
  int wt;
  // CLASS VARIABLES //
  float durRadians;
  int bullseyeIx = 0;
  float bullseyeRadius, c, m, radians, radiansnorm;
  boolean on = true;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Timetrig(int aix, float arad, float adur, String asclr, int awt) {

    ix = aix;
    rad = arad;
    dur = adur;
    sclr = asclr;
    wt = awt;

    //Grab Coordinates of Bullseye
    for (BullseyeCA inst : bullseyeCAz.cset) {
      if (bullseyeIx == inst.ix) {
        c = inst.c;
        m = inst.m;
        bullseyeRadius = inst.rad;
      }
    }
    rad = map(rad, 0.0, 1.0, 0.0, bullseyeRadius);
    durRadians = map(dur, 0.0, 1.0, 0.0, TWO_PI);
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    
    //Get Trigger Location
    osc.send("/getTimerDat", new Object[]{ix}, sc);
    radians = map(radiansnorm, 0.0, 1.0, 0.0, TWO_PI);
    radians = radians-HALF_PI;
    println(radiansnorm);

   // noFill();
    fill(clr.getAlpha(sclr, 100));
  //  strokeCap(SQUARE);
   // strokeWeight(wt);
   noStroke();
    arc(c, m, bullseyeRadius*2, bullseyeRadius*2, radians, (radians+durRadians));
  } //End drw

  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class TimetrigSet {
  ArrayList<Timetrig> cset = new ArrayList<Timetrig>();

  // Make Instance Method //
  void mk(int aix, float arad, float adur, String asclr, int awt) {
        cset.add( new Timetrig( aix, arad, adur, asclr, awt) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Timetrig inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (Timetrig inst : cset) {
      inst.drw();
    }
  }//end drw method

  // Get Radians Method //
  void timerkdat(int ix, float val) {
    for (Timetrig inst : cset) {
      if (inst.ix==ix) inst.radiansnorm=val;
    }
  }//end tgkdat method

  //
  //
} // END CLASS SET CLASS