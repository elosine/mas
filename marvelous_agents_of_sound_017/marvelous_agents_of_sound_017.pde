import netP5.*;
import oscP5.*;

OscP5 osc;
NetAddress sc;

int eventix = 0;

void setup() {
  size(600, 600);
  osc = new OscP5(this, 12321);
  sc = new NetAddress("127.0.0.1", 57120);

  //Bullseye
  osc.plug(bullseyez, "mk", "/mkclock");
  osc.plug(bullseyez, "rmv", "/rmvclock");
  osc.plug(bullseyez, "rmvall", "/rmvallclock");
  //Dial
  osc.plug(dialz, "mk", "/mkdial");
  osc.plug(dialz, "mkman", "/mkdialman");
  osc.plug(dialz, "rmv", "/rmvdial");
  osc.plug(dialz, "rmvall", "/rmvalldial");
  osc.plug(dialz, "kdat", "/kdat");
  //Timetrig
  osc.plug(timetrigz, "mk", "/mktimetrig");
  osc.plug(timetrigz, "rmv", "/rmvtimetrig");
  osc.plug(timetrigz, "timerkdat", "/timerkdat");
  //Beatgrid
  osc.plug(beatgridz, "mk", "/mkbeatgrid");
  osc.plug(beatgridz, "rmv", "/rmvbeatgrid");
  osc.plug(beatgridz, "hl", "/bhl");
  osc.plug(beatgridz, "mktg", "/mktg");
  osc.plug(beatgridz, "rmvtg", "/rmvtg");
  osc.plug(beatgridz, "chtr", "/chtr");
  osc.plug(beatgridz, "gtbtgr", "/gtbtgr");
  osc.plug(beatgridz, "chgcsr", "/chgcsr");
  //Triggers
  osc.plug(triggerz, "mk", "/mktrigger");
  osc.plug(triggerz, "rmv", "/rmvtrigger");
  osc.plug(triggerz, "tgkdat", "/tgkdat");

  bullseyeCAz.mk( 0, 15.0, 15.0);
  dialz.mk(0, 0, 0.0, 1.0, "yellow", 2);
  dialz.mk(1, 0, 0.0, 1.0, "seagreen", 2);
  dialz.mk(2, 0, 0.0, 1.0, "purple", 2);
  dialz.mk(3, 0, 0.0, 1.0, "pink", 2);
  /*
  beatgridz.mk(0, 0, 0, 16, 1, 3, "limegreen");
   beatgridz.mk(1, 0, 1, 16, 2, 7, "limegreen");
   beatgridz.mk(2, 0, 2, 16, 1, 5, "limegreen");
   beatgridz.mk(3, 0, 3, 16, 1, 4, "limegreen");
   beatgridz.mk(4, 0, 4, 16, 2, 9, "limegreen");
   beatgridz.mk(5, 0, 5, 16, 1, 2, "limegreen");
   beatgridz.mk(6, 0, 6, 16, 4, 11, "limegreen");
   */

  osc.send("/sbtgr", new Object[]{}, sc); 
  // int aix, int abeix, int arnum, int abpercyc, int andiv, int ansdiv, String asclr

  // events(13,20,0,new String[]{"goldenrod", "chocolate", "indigo", "pink", "TranquilBlue", "mint", "pine", "white"}, 2.0, 4.5);
}

void draw() {
  background(0);
  bullseyeCAz.drw();
  timetrigz.drw();
  dialz.drw(); 
  beatgridz.drw();
  triggerz.drw();
}