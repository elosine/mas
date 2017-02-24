/////////////////////////////////////
// MAKE NEW SOUND TARGETS - /mktr ///
/////////////////////////////////////

(// 0) Toy Piano - Limegreen
~sclang.sendMsg("/mktr", 0); )

(// 1) Puffdaddy - Purple
~sclang.sendMsg("/mktr", 1); )

(// 2) Janus - Goldenrod
~sclang.sendMsg("/mktr", 2); )

(// 3) Drumline - Dodgerblue
~sclang.sendMsg("/mktr", 3); )

(// 4) Krunkd - SeaGreen
~sclang.sendMsg("/mktr", 4); )


/////////////////////////////////////
// MAKE NEW WANDS - /mkwand       ///
/////////////////////////////////////

(// 1) Wand 01 - Turquoiseblue
~sclang.sendMsg("/mkwand", 1, 128.0); )

(// 2) Wand 02 - Violetred
~sclang.sendMsg("/mkwand", 2, 42.0); )

(// 3) Wand 03 - Limegreen
~sclang.sendMsg("/mkwand", 3, 98.3); )

(// 1) Wand 04 - Fig
~sclang.sendMsg("/mkwand", 4, 157.0); )

/////////////////////////////////////
// MOVE SOUND TARGETS - /mvsndtr  ///
/////////////////////////////////////

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 0, 0.0, 1.0, 20.0); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 1, 1.0, 0.0, 20.0); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 2, 0.0, 1.0, 33); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 3, 1.0, 0, 10.0); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 4, 0.25, 0.75, 25); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 16, 1, 0.75, 40); )


/////////////////////////////////////
// WAND SPEED - /mkwand       ///
/////////////////////////////////////

// 1) Wand 01 - Turquoiseblue
~sclang.sendMsg("/mkwand", 1, 128.0);

// 2) Wand 02 - Violetred
~sclang.sendMsg("/mkwand", 2, 42.0);

// 3) Wand 03 - Limegreen
~sclang.sendMsg("/mkwand", 3, 98.3);

// 1) Wand 04 - Fig
~sclang.sendMsg("/mkwand", 4, 157.0);




//remove sound targets
//wand speed
