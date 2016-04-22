// nexys4fpga.v - Top level module for Nexys4 as used in the ECE 540 Project 1
//
// Copyright Roy Kravitz, 2008-2015, 2016
//
// Created By:		Roy Kravitz and Dave Glover
// Last Modified:	27-Mar-2014 (RK)
// Last Modified:	15-Apr-2016 (Joel Jacob)
//
// Revision History:
// -----------------
// Nov-2008		RK		Created this module for the S3E Starter Board
// Apr-2012		DG		Modified for Nexys 3 board
// Dec-2014		RJ		Cleaned up formatting.  No functional changes
// Mar-2014		CZ		Modified for Nexys 4 board and added functionality for CPU RESET button
// Aug-2014		RK		Modified for Vivado.  No functional changes
// Apr-2016		JJ		Modified for new project_1 module.
//
// Description:
// ------------
// Top level module for the ECE 540 Project 1 reference design
// on the Nexys4 FPGA Board (Xilinx XC7A100T-CSG324)
// Can be used with some modifications for Projec1 1
//
// Use the pushbuttons to control the Rojobot wheels:
//	btnl			Left wheel forward
//	btnu			Left wheel reverse
//	btnr			Right wheel forward
//	btnd			Right wheel reverse
//  btnc			Not used in this design
//	btnCpuReset		CPU RESET Button - System reset.  Asserted low by Nexys 4 board
//
//	sw[15:0]		Not used in this design
//
// External port names match pin names in the nexys4fpga.xdc constraints file
///////////////////////////////////////////////////////////////////////////

module Nexys4fpga (
	input 				clk,                 	// 100MHz clock from on-board oscillator
	input				btnL, btnR,				// pushbutton inputs - left (db_btns[4])and right (db_btns[2])
	input				btnU, btnD,				// pushbutton inputs - up (db_btns[3]) and down (db_btns[1])
	input				btnC,					// pushbutton inputs - center button -> db_btns[5]
	input				btnCpuReset,			// red pushbutton input -> db_btns[0]
	input	[15                          : 0]		sw,						// switch inputs

	output	[15                         : 0]		led,  					// LED outputs

	output 	[6                         : 0]		seg,					// Seven segment display cathode pins
	output              dp,
	output	[7                          : 0]		an,						// Seven segment display anode pins

	output	[7                          : 0]		JA						// JA Header
);

	// parameter
	parameter SIMULATE = 0;

	// internal variables
	wire 	[15                          : 0]		db_sw;					// debounced switches
	wire 	[5                           : 0]		db_btns;				// debounced buttons

	wire				sysclk;					// 100MHz clock from on-board oscillator
	wire				sysreset;				// system reset signal - asserted high to force reset

	wire 	[4                           : 0]		dig7, dig6,
						dig5, dig4,
						dig3, dig2,
						dig1, dig0;				// display digits
	wire 	[7                           : 0]		decpts;					// decimal points
	wire 	[15                          : 0]		chase_segs;				// chase segments from Rojobot (debug)

	wire    [7                         : 0]       segs_int;              // sevensegment module the segments and the decimal point

/******************************************************************/
/* CHANGE THIS SECTION FOR YOUR LAB 1                             */
/******************************************************************/
	wire	[10                           : 0]		compass_val; 	//WIRE for displaying compass display
	wire 	[4                           : 0]			motion_val; 	//wire to display motion indicator
	wire	[7                            : 0]	  	right_pos;
	wire 	[63                          : 0]	 	digits_out;				// ASCII digits (Only for Simulation)

	// set up the display and LEDs
	assign	dig7 = {5'b00000};					// blank
	assign	dig6 = {5'b00000};
	assign	dig5 = {5'b00000};
	assign	dig4 = {5'b00000};

	assign	dig3 = {motion_val[4:0]};
	assign	dig2 = {1'b0,compass_val[10:8]};  //display compass values on individual LED segements from MSB to LSB
	assign 	dig1 = {1'b0,compass_val[7:4]};
	assign	dig0 = {1'b0,compass_val[3:0]};
	assign	decpts = 8'b00000000;			// d2 is on
	assign	led = db_sw;					// leds show the debounced switches

/******************************************************************/
/* THIS SECTION SHOULDN'T HAVE TO CHANGE FOR LAB 1                */
/******************************************************************/
	// global assigns
	assign	sysclk = clk;
	assign 	sysreset = db_btns[0]; // btnCpuReset is asserted low

	assign dp = segs_int[7];
	assign seg = segs_int[6:0];

	assign	JA = {sysclk, sysreset, 6'b000000};

	//instantiate the debounce module
	debounce
	#(
		.RESET_POLARITY_LOW(1),
		.SIMULATE(SIMULATE)
	)  	DB
	(
		.clk(sysclk),
		.pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
		.switch_in(sw),
		.pbtn_db(db_btns),
		.swtch_db(db_sw)
	);

	// instantiate the 7-segment, 8-digit display
	sevensegment
	#(
		.RESET_POLARITY_LOW(1),
		.SIMULATE(SIMULATE)
	) SSB
	(
		// inputs for control signals
		.d0(dig0),
		.d1(dig1),
 		.d2(dig2),
		.d3(dig3),
		.d4(dig4),
		.d5(dig5),
		.d6(dig6),
		.d7(dig7),
		.dp(decpts),

		// outputs to seven segment display
		.seg(segs_int),
		.an(an),

		// clock and reset signals (100 MHz clock, active high reset)
		.clk(sysclk),
		.reset(sysreset),

		// ouput for simulation only
		.digits_out(digits_out)
	);

/******************************************************************/
/* CHANGE THIS DEFINITION FOR YOUR LAB 1                          */
/******************************************************************/
	// instantiate RojoBot module
    RojoBot1
	#(
		.RESET_POLARITY_LOW(1),
		.SIMULATE(SIMULATE)
	) RB
	(
		.clk(sysclk),
		.reset(sysreset),
		.left_fwd(db_btns[4]),
		.left_rev(db_btns[3]),
		.right_fwd(db_btns[2]),
		.right_rev(db_btns[1]),
		.motion_val(motion_val),
		.compass_val(compass_val),  // left wheel position counter output
		.right_pos(right_pos) // right wheel position counter output
	);



endmodule
