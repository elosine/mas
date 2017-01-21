// DECLARE/INITIALIZE CLASS SET
TriggerSet triggerz = new TriggerSet();

/**
 /// PUT IN SETUP ///
 osc.plug(triggerz, "mk", "/mktrigger");
 osc.plug(triggerz, "rmv", "/rmvtrigger");
 
 /// PUT IN DRAW ///
 triggerz.drw();
 **/

class Trigger {

  // CONSTRUCTOR VARIALBES //
  int ix;
  float minutes, radius, size;
  String tclr;
  // CLASS VARIABLES //
  int bullseyeIx = 0;
  float bullseyeRadius, c, m, x, y, radians;
  boolean on = true;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Trigger(int aix, float aminutes, float aradius, float asize, String atclr) {
    ix = aix;
    minutes = aminutes;
    radius = aradius;
    size = asize;
    tclr = atclr;

    //Grab Coordinates of Bullseye
    for (BullseyeCA inst : bullseyeCAz.cset) {
      if (bullseyeIx == inst.ix) {
        c = inst.c;
        m = inst.m;
        bullseyeRadius = inst.rad;
      }
    }

    radians = map(minutes, 0.0, 60.0, 0.0, TWO_PI);
    radians = radians-HALF_PI;

    x = ( cos(radians) * radius*bullseyeRadius ) + c;
    y = ( sin(radians) * radius*bullseyeRadius ) + m;
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    noStroke();
    fill(clr.get(tclr));
    ellipseMode(CENTER);
    ellipse(x, y, size, size);
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class TriggerSet {
  ArrayList<Trigger> cset = new ArrayList<Trigger>();

  // Make Instance Method //
  void mk(int aix, float aminutes, float aradius, float asize, String atclr) {
    cset.add( new Trigger(aix, aminutes, aradius, asize, atclr) );
  } //end mk method
  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Trigger inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (Trigger inst : cset) {
      inst.drw();
    }
  }//end drw method
  //
  //
} // END CLASS SET CLASS