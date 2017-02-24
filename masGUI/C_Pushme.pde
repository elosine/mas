// DECLARE/INITIALIZE CLASS SET
PushmeSet pushmez = new PushmeSet();

/**
 *
 *
 /// PUT IN SETUP ///
 osc.plug(pushmez, "mk", "/mkpushme");
 osc.plug(pushmez, "rmv", "/rmvpushme");
 
 /// PUT IN DRAW ///
 pushmez.drw();
 *
 *
 */


class Pushme {

  // CONSTRUCTOR VARIALBES //
  int ix, x, y, w, h;
  String clr, label;
  int intmsg;
  // CLASS VARIABLES //
  int l, t, r, b, m, c;
  String bclr;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Pushme(int aix, int ax, int ay, int aw, int ah, String aclr, String alabel, int aintmsg) {
    ix = aix;
    x = ax;
    y = ay;
    w = aw;
    h = ah;
    clr = aclr;
    label = alabel;
    intmsg = aintmsg;

    l = x;
    t = y;
    r = x+w;
    b = y+h;
    m = x + int(w/2);
    c = y + int(h/2);
    bclr = clr;
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    //DRAW BUTTON
    rectMode(CORNER);
    noStroke();
    fill( clrs.get(bclr) );
    rect(l, t, w, h, 9);
    //DRAW LABEL
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    fill(0);
    text(label, m, c, w-6, h-6);
  } //End drw

  //  MOUSE MOVED METHOD //
  void msmvd() {
    if (msovr()) bclr = "sunshine";
    else bclr = clr;
  } //End mouse moved

  //  MOUSE PRESSED METHOD //
  void msprs() {
    bclr = "orange";
    osc.send("/mktr", new Object[]{intmsg}, sc);
  } //End mouse pressed

  //  MOUSE RELEASEd METHOD //
  void msrel() {
    bclr = clr;
  } //End mouse released

  //  Mouse Over Detect METHOD //
  boolean msovr() {
    boolean mouseover = false;
    if ( mouseX >= l && mouseX <= r && mouseY >=t && mouseY <= b ) mouseover = true;
    else mouseover = false;
    return mouseover;
  } //End mouseover detect
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class PushmeSet {
  ArrayList<Pushme> cset = new ArrayList<Pushme>();

  // Make Instance Method //
  void mk(int ix, int x, int y, int w, int h, String clr, String label, int intmsg) {
    cset.add( new Pushme(ix, x, y, w, h, clr, label, intmsg) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Pushme inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (Pushme inst : cset) {
      inst.drw();
    }
  }//end drw method

  // Mouse Moved Set Method //
  void msmvd() {
    for (Pushme inst : cset) {
      inst.msmvd();
    }
  }//end mouse moved method

  // Mouse Moved Set Method //
  void msprs() {
    for (Pushme inst : cset) {
      inst.msprs();
    }
  }//end mouse moved method

  // Mouse Moved Set Method //
  void msrel() {
    for (Pushme inst : cset) {
      inst.msrel();
    }
  }//end mouse moved method
  //
  //
} // END CLASS SET CLASS