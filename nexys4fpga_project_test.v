// nexys4fpga.v - Top level module for Nexys4 as used in the ECE 540 Project 1

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

// nexys4fpga.v - Top level module for simple Picoblaze design example //
// Copyright Roy Kravitz, 2015
//
// Created By:  	Roy Kravitz
// Last Modified: 14-October-2015
//
// Revision History:
// -----------------
// 14-Oct-2015 RK  	Created this module for the Nexys4 board
//
//
// Description:
// ------------
// Top level module for a Picoblaze system based on kcpsm6_template.v
// This version is targeted to the Nexys4 FPGA Board (Xilinx XC7A100T-CSG324) //
// This module makes the LEDS, slide switches, and debounced pushbuttons
// available to the Picoblaze as inputs and lets the Picoblaze write to
// the LEDs, and Digit[0] (rightmost) and Decimal points of the 7-segment
//display.
/////////////////////////////////////////////////////////////////////////////
//
// External port names match pin names in the nexys4fpga.xdc constraints file
///////////////////////////////////////////////////////////////////////////

module Nexys4fpga (
 	input   	 	 	clk,             // 100MHz clock from on-board oscillator
 	input  	 	 	btnL, btnR,  	// pushbutton inputs - left
 	 	 	 	 	 	 	 	 	 	//(db_btns[4])and right (db_btns[2])
 	input  	 	 	btnU, btnD,  	// pushbutton inputs - up (db_btns[3])
 	 	 	 	 	 	 	 	 	 	// and down (db_btns[1])
 	input  	 	 	btnC,  	 	// pushbutton inputs - center button ->
 	 	 	 	 	 	 	 	 	 	// db_btns[5]
 	input  	 	 	btnCpuReset,  	// red pushbutton input -> db_btns[0]
 	input [15:0]  	sw,
 	 	 	// switch inputs
 	output [15:0]  	led,
 	 	 	// LED outputs
 	output  [6:0]  	seg,
 	output              dp, 	 	// Seven segment display cathode pins
 	output [7:0]  	an,
 	 	 	// Seven segment display anode pins
 	output [7:0]  	JA
);

 	// parameter
parameter SIMULATE = 0;           // internal variables 	 	// JA Header
	wire  [15:0]  	db_sw;  	 	 	 	// debounced switches

	wire  [5:0]  	db_btns;
 	 	// debounced buttons
	wire 	 	 	sysclk;  	 	 	 	// 100MHz clock from on-board
 	 	 	 	 	 	 	 	 	 	// oscillator
 	wire 	 	 	sysreset; // system reset signal – asserted
// high to force reset

 	wire  [4:0]  	dig7, dig6, dig5, dig4, dig3, dig2,dig1, dig0;// display digits
 	wire  [7:0]  	decpts;  	 	 	// decimal points
 	wire [7:0]  	segs_int;  	 	 	// segment outputs (internal)
 	wire [63:0]  	digits_out;

 	// PicoBlaze interface
  	wire [11:0]  	address;
 	wire [17:0]  	instruction;
  	wire 	 	 	bram_enable;
    wire [7:0]  	port_id;
    	wire [7:0]  	out_port;
 	wire [7:0]  	in_port;
  	wire 	 	 	write_strobe;
    	wire 	 	 	k_write_strobe;
      wire 	 	 	read_strobe;
       wire 	 	 	interrupt;
       wire 	 	 	interrupt_ack;
       wire 	 	 	kcpsm6_sleep;  	 	// digits_out (only for simulation)
wire 	 	 	kcpsm6_reset;
wire 	 	 	cpu_reset;
wire 	 	 	rdl;
wire 	 	 	int_request;

 	// PicoBlaze I/O registers
//  wire [7:0]  	sw_high, sw_low;  //example prog
 //	wire [7:0]  	leds_high, leds_low, digit0_int; //example prog
   wire [7:0] PA_PBTNS; // (i) pushbuttons inputs
   wire [7:0] PA_SLSWTCH; // (i) slide switches
   wire [7:0] PA_LEDS; // (o) LEDs
   wire [7:0] PA_DIG3; // (o) digit 3 port address
   wire [7:0] PA_DIG2; // (o) digit 2 port address
   wire [7:0] PA_DIG1; // (o) digit 1 port address
   wire [7:0] PA_DIG0; // (o) digit 0 port address
   wire [3:0] PA_DP; // (o) decimal points 3:0 port address

    wire [7:0] PA_RSVD; // (o) *RESERVED* port address
    wire [7:0] PA_MOTCTL_IN; // (o) Rojobot motor control output from system
    wire [7:0] PA_LOCX; //(i) X coordinate of rojobot location
    wire [7:0] PA_BOTINFO; // (i) Rojobot info register
    wire [7:0] PA_SENSORS; // (i) Sensor register
    wire [7:0] PA_LMDIST; // (i) Rojobot left motor distance register
    wire [7:0] PA_RMDIST; // (i) Rojobot right motor distance register



    //Extended Alternate I/O interface

    wire [7:0] PA_PBTNS_ALT; // (i) pushbutton inputs alternate port address
    wire [7:0] PA_SLSWTCH1508; // (i) slide switches 15:8 (high byte of switches
    wire [7:0] PA_LEDS1508; //LEDs 15:8 (high byte of switches)
    wire [7:0] PA_DIG7; // (o) digit 7 port address
    wire [7:0] PA_DIG6; //(o) digit 6 port address
    wire [7:0] PA_DIG5; // (o) digit 5 port address
    wire [7:0] PA_DIG4; //(o) digit 4 port address
    wire [7:0] PA_DP0704; //  (o) decimal points 7:4 port address
    wire [7:0] PA_RSVD_ALT; //(o) *RESERVED* alternate port address
    wire [7:0] PA_MOTCTL_IN_ALT; // (o) Rojobot motor control output from system
    wire [7:0] PA_LOCX_ALT; // (i) X coordinate of rojobot location
    wire [7:0] PA_LOCY_ALT; // i))Y coordinate of rojobot location
    wire [7:0] PA_BOTINFO_ALT; // (i) Rojobot info register
    wire [7:0] PA_SENSORS_ALT; // (i) Sensor register
    wire [7:0] PA_LMDIST_ALT; // (i) Rojobot left motor distance register
    wire [7:0] PA_RMDIST_ALT; // (i) Rojobot right motor distance register







 	// set up the display by blanking all but Digit[0]
 	assign  	 	 	dig7 = {5'b11111};
 	assign  	 	 	dig6 = {5'b11111};
 	assign  	 	 	dig5 = {5'b11111};
 	assign  	 	 	dig4 = {5'b11111};

 	// The debounced switches, 7-segment Digit[0] and the 7-segment decimal
 	// points are writable by the Picoblaze
 	assign  	 	 	dig0 = digit0_int[4:0];
  assign  	 	 	dig1 = digit1_int[4:0];
  assign  	 	 	dig2 = digit2_int[4:0];
  assign  	 	 	dig3 = digit3_int[4:0];


 	// global assigns
assign sysclk = clk;
assign  sysreset = ~db_btns[0]; // btnCpuReset is asserted low so invert it assign  sw_high = db_sw[15:8]; assign  sw_low = db_sw[7:0];
assign  led = {leds_high, leds_low};
assign dp = segs_int[7];
assign seg = segs_int[6:0];

 	assign JA = {sysclk, sysreset, 6'b000000};

 	// instantiate the debounce module
 	// RESET_POLARITLY_LOW is 1 because btnCpuReset is asserted
 	// high and the debounced version of btnCpuReset becomees
 	// sysreset

	debounce
 	#(
 	 	.RESET_POLARITY_LOW(1),
 	 	.SIMULATE(SIMULATE)
 	)   DB
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
	 	.RESET_POLARITY_LOW(0),
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


// instantiate the PicoBlaze and instruction ROM
assign kcpsm6_sleep = 1'b0;
assign kcpsm6_reset = sysreset | rdl;

kcpsm6 #(
 	 	.interrupt_vector (12'h3FF),
 	 	.scratch_pad_memory_size(64),
 	 	.hwbuild  	(8'h00))
 	APPCPU(
 	 	.address   	(address),
 	 	.instruction  (instruction),
 	 	.bram_enable  (bram_enable),
 	 	.port_id   	(port_id),
 	 	.write_strobe  (write_strobe),
 	 	.k_write_strobe (),
 	 	.out_port   	(out_port),
 	 	.read_strobe  (read_strobe),
 	 	.in_port   	(in_port),
 	 	.interrupt   	(interrupt),
 	 	.interrupt_ack  (interrupt_ack),
 	 	.reset   	 	(kcpsm6_reset),
 	 	.sleep  	 	(kcpsm6_sleep),
 	 	.clk   	 	(sysclk));

 	proj2demo #(
	 	.C_FAMILY  	   ("7S"),    //Family 'S6' or 'V6' or '7S'
	 	.C_RAM_SIZE_KWORDS (2),      //Program size '1', '2' or '4'
	 	.C_JTAG_LOADER_ENABLE (1))    //Include JTAG Loader when set to 1'b1
	APPPGM (
	 	.rdl   	 	(rdl),
	 	.enable   	(bram_enable),
	 	.address   	(address),
	 	.instruction  (instruction),
 	 	.clk   	 	(sysclk));


 	// instantiate the PicoBlaze I/O register interface

	nexys4_if #(
 	 	.RESET_POLARITY_LOW(0))
 	N4IF(
 	 	.write_strobe(write_strobe),
 	 	.read_strobe(read_strobe),
 	 	.port_id(port_id),
 	 	.io_data_in(out_port),    // data from Picoblaze to the I/O register
 	 	.io_data_out(in_port),    // data from I/O register to Picoblaze
 	 	.interrupt_ack(interrupt_ack),
 	 	.interrupt(interrupt),
 	 	.sysclk(sysclk),
 	 	.sysreset(sysreset),
 	 //	.PORT_A(sw_low),
 	 //	.PORT_B(sw_high),
 	 //	.PORT_C({2'b00, db_btns}),
 	// 	.PORT_D(8'b01011010),
	 //	.PORT_01(leds_low),
	 //	.PORT_02(leds_high),
	 //	.PORT_04(digit0_int),
	 //	.PORT_08(decpts),
    .PORT_00(PA_PBTNS),
    .PORT_01(PA_SLSWTCH),
    .PORT_02(PA_LEDS),
    .PORT_03(PA_DIG3),
    .PORT_04(PA_DIG2),
    .PORT_05(PA_DIG1),
    .PORT_06(PA_DIG0),
    .PORT_07(PA_DP),
    .PORT_08(PA_RSVD),

    .PORT_09(	PA_MOTCTL_IN),
    .PORT_0A(PA_LOCX),
    .PORT_0B(PA_LOCY),
    .PORT_0C(PA_BOTINFO),
    .PORT_0D(PA_SENSORS),
    .PORT_0E(PA_LMDIST),
    .PORT_0F(PA_RMDIST),

    .PORT_10(PA_PBTNS_ALT),
    .PORT_11(PA_SLSWTCH1508),
    .PORT_12(PA_LEDS1508),
    .PORT_13(PA_DIG7),
    .PORT_14(PA_DIG6),
    .PORT_15(PA_DIG5),
    .PORT_16(PA_DIG4),
    .PORT_17(PA_DP0704),
    .PORT_18(PA_RSVD_ALT),

    .PORT_19(PA_MOTCTL_IN_ALT),
    .PORT_1A(PA_LOCX_ALT),
    .PORT_1B(PA_LOCY_ALT),
    .PORT_1C(PA_BOTINFO_ALT),
    .PORT_1D(PA_SENSORS_ALT),
    .PORT_1E(PA_LMDIST_ALT),
    .PORT_1F(PA_RMDIST_ALT),

 	 	.interrupt_request(1'b0) // no interrupts in this example
 	);

endmodule
