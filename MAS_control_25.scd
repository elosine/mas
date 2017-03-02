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
~sclang.sendMsg("/mkwand", 1, 88.0); )

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
~sclang.sendMsg("/mvsndtr", 5, 1, 0.75, 40); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 6, 0.25, 0.75, rrand(5.0, 60.0)); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 7, 1.0, 0.0, rrand(5.0, 60.0)); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 8, 0.0, 1.0, rrand(5.0, 60.0)); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 9, 1.0, 0.0, rrand(5.0, 60.0)); )

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 10, 0.0, 1.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 11, 1.0, 0.0, rrand(5.0, 60.0) );

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 12, 0.0, 1.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 13, 0.0, 1.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 14, 0.0, 1.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 15, 1.0, 0.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 16, 1.0, 0.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 17, 0.0, 1.0, rrand(5.0, 60.0));

(// ix, lo, hi, rampdur
~sclang.sendMsg("/mvsndtr", 18, 1.0, 0.0, rrand(5.0, 60.0));

/////////////////////////////////////
// WAND SPEED - /chgwand          ///
/////////////////////////////////////

// 0) Wand 00 - Yellow
~sclang.sendMsg("/chgwand", 0, 135.0, 25.0, 1);

// 1) Wand 01 - Turquoiseblue
~sclang.sendMsg("/chgwand", 1, 87.0, 25.0, -1);

// 2) Wand 02 - Violetred
~sclang.sendMsg("/chgwand", 2, 100.0, 60.0, -1);

// 3) Wand 03 - Limegreen
~sclang.sendMsg("/chgwand", 3, 78.0, 40.0, -1);

// 4) Wand 04 - Fig
~sclang.sendMsg("/chgwand", 4, 135.0, 25.0, 1);


/////////////////////////////////////
// MAKE FX - /mkfx                ///
/////////////////////////////////////

// 0) FX 00 - Yellow
~sclang.sendMsg("/mkfx", 0, 100.0, 0.5, 0);

// 1) FX 01 - Turquoiseblue
~sclang.sendMsg("/mkfx", 1, 120.0, 0.5, 1);


/////////////////////////////////////
// STOP WANDS - /chgwand          ///
/////////////////////////////////////

// 0) Wand 00 - Yellow
~sclang.sendMsg("/chgwand", 0, 0, 90.0, 1);

// 1) Wand 01 - Turquoiseblue
~sclang.sendMsg("/chgwand", 1, 0, 90.0, 1);

// 2) Wand 02 - Violetred
~sclang.sendMsg("/chgwand", 2, 0, 90.0, 1);

// 3) Wand 03 - Limegreen
~sclang.sendMsg("/chgwand", 3, 0, 90.0, 1);

// 4) Wand 04 - Fig
~sclang.sendMsg("/chgwand", 4, 0, 90.0, 1);


/////////////////////////////////////
// REMOVE SOUND TARGETS - /rmtrg  ///
/////////////////////////////////////

// 0) Wand 00 - Yellow
~sclang.sendMsg("/rmtrg");

//remove sound targets
//wand speed
