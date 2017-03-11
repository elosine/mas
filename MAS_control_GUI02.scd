(
w = Window.new(bounds:Rect(1100,200,800,800)).layout_(
	VLayout (

		HLayout(

			Button()
			.states_([["Toy Piano",Color.black, Color.new255(153,255,0)]])
			.minHeight_(110)
			.maxWidth_(110)
			.font_(Font("Monaco", 18))
			.focusColor_(Color.red)
			.mouseDownAction_({ ~sclang.sendMsg("/mktr", 0) })
			.keyDownAction_({ ~sclang.sendMsg("/mktr", 0) }),

			Button()
			.states_([["Puff Daddy",Color.black, Color.new255( 128, 0, 128 )]])
			.minHeight_(110)
			.maxWidth_(110)
			.font_(Font("Monaco", 18))
			.focusColor_(Color.red)
			.mouseDownAction_({  ~sclang.sendMsg("/mktr", 1)  })
			.keyDownAction_({  ~sclang.sendMsg("/mktr", 1)  }),

			Button()
			.states_([["Janus",Color.black, Color.new255( 218, 165, 32 )]])
			.minHeight_(110)
			.maxWidth_(110)
			.font_(Font("Monaco", 18))
			.focusColor_(Color.red)
			.mouseDownAction_({  ~sclang.sendMsg("/mktr", 2)  })
			.keyDownAction_({  ~sclang.sendMsg("/mktr", 2)  }),

			Button()
			.states_([["Drumline",Color.black, Color.new255( 30, 144, 255 )]])
			.minHeight_(110)
			.maxWidth_(110)
			.font_(Font("Monaco", 18))
			.focusColor_(Color.red)
			.mouseDownAction_({  ~sclang.sendMsg("/mktr", 3)  })
			.keyDownAction_({  ~sclang.sendMsg("/mktr", 3)  }),

			Button()
			.states_([["Krunkd",Color.black, Color.new255( 67, 205, 128 )]])
			.minHeight_(110)
			.maxWidth_(110)
			.font_(Font("Monaco", 18))
			.focusColor_(Color.red)
			.mouseDownAction_({  ~sclang.sendMsg("/mktr", 4)  })
			.keyDownAction_({  ~sclang.sendMsg("/mktr", 4)  }),

		), //end hlayout 1

		Button()
		.states_([["Add Wand 2",Color.black, Color.new255( 0, 199, 140 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({  ~sclang.sendMsg("/mkwand", 1, 88.0)  })
		.keyDownAction_({  ~sclang.sendMsg("/mkwand", 1, 88.0)  }),

		Button()
		.states_([["Add Wand 3",Color.black, Color.new255( 208, 32, 144 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({  ~sclang.sendMsg("/mkwand", 2, 42.0)  })
		.keyDownAction_({  ~sclang.sendMsg("/mkwand", 2, 42.0)  }),

		Button()
		.states_([["Move Target", Color.black, Color.new255( 255, 234, 100 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({ var trgnum = rrand(0, 21).round; var dir = [0,1].choose;
			switch(dir,
				0, {~sclang.sendMsg( "/mvsndtr", trgnum, 1.0, 0.0, rrand(5.0, 60.0) )},
				1, { ~sclang.sendMsg("/mvsndtr", trgnum, 0.0, 1.0, rrand(5.0, 60.0) ) }
			);

		}),

		Button()
		.states_([["Change Wand", Color.black, Color.new255( 128, 84, 98 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({ var wandnum = rrand(0, 2).round; ~sclang.sendMsg("/chgwand", wandnum, rrand(30.0, 150.0), 20.0, [1,-1].choose ) }),

		Button()
		.states_([["Add FX 1", Color.black, Color.new255( 218, 165, 32 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({ ~sclang.sendMsg("/mkfx", 0, 100.0, 0.5, 0)}),

		Button()
		.states_([["Add FX 2", Color.black, Color.new255( 0, 199, 140 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({ ~sclang.sendMsg("/mkfx", 1, 120.0, 0.5, 1)}),

		Button()
		.states_([["Stop Wand", Color.black, Color.new255( 128, 84, 98 )]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({ var wandnum = rrand(0, 2).round; ~sclang.sendMsg("/chgwand", wandnum, 0, 90.0, 1) }),

		Button()
		.states_([["Remove Target", Color.black, Color.red]])
		.minHeight_(50)
		.font_(Font("Monaco", 18))
		.focusColor_(Color.red)
		.mouseDownAction_({ ~sclang.sendMsg("/rmtrg")}),


	) //end vlayout
).front;
)

Server.default.makeGui