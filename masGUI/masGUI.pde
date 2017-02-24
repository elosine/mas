import netP5.*;
import oscP5.*;

OscP5 osc;
NetAddress sc;
PFont monaco13;

int targetnum = 0;


void setup() {
  size(500, 500);
  osc = new OscP5(this, 12322);
  sc = new NetAddress("127.0.0.1", 57120);
  
  monaco13 = loadFont("Monaco-13.vlw");
  textFont(monaco13);

  osc.plug(pushmez, "mk", "/mkpushme");
  osc.plug(pushmez, "rmv", "/rmvpushme");
  
  pushmez.mk(0, 50, 50, 50, 50, "limegreen", "ToyPiano", 0);
}
void draw() {
  pushmez.drw();
}
void mouseMoved() {
  pushmez.msmvd();
}
void mousePressed() {
  pushmez.msprs();
}
void mouseReleased() {
  pushmez.msrel();
}