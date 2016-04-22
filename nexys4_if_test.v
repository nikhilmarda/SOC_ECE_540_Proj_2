// nexys4_if.v - Register interface to the Nexys 4  //
// Copyright Roy Kravitz, 2015
//
// Created By:  	 	Roy Kravitz
// Last Modified:  	14-October-2015 (RK)
//
// Revision History:
// -----------------
// 14-Oct-2015  	RK  	Created this module
//
// Description
// -----------
// This module implements a register-based interface to the LEDs and switches on
// the Nexys 4. It is connected to
// a PicoBlaze which accesses the registers through its INPUT and OUTPUT // instructions.  The module also
// includes the interrupt flip-flop used to control the PicoBlaze interrupt  // mechanisms.
// This I/O is available at the following Port ID's //
//   Port ID  	Name Dir  	 	 	 	Description
//  -------  ---- --- -----------------------------------------------------
//    0x00 Sw_07_00  I  (PORT_A) Switch[7:0] inputs (should be driven by 	debounced versions)
//  	0x01 	Sw_15_08  	I  (PORT_B) Switch[15:8] inputs (should be driven by debounced versions)
//  	0x02 	DB_Btns  	I (PORT_C) Debounced buttons {btnC,btnL,btnU,btnR,btnD,btnCpuReset}
//
// 	0z03 	Resvd03  	I (PORT_D)** RESERVED **
//  	0x01 	LEDS_07_00 O  (PORT_01) LEDs [7:0]  Drive 1 to light (one-hot  	encoded).  Returned as I/O port 02
//  	0x02 	LEDS_15_08 O  (PORT_02) LEDs [15:8]  Drive 1 to ligh (one-hot  encoded). Returned as I/O port 03
//  	0x04 	DIGIT_0  	O (PORT_04) 7-segment Digit[0] (rightmost)
//  	0x08 	DECPTS  	O (PORT_08) 7-segment Decimal points
//////////

module nexys4_if
#(
  parameter integer RESET_POLARITY_LOW         = 1
)
(
 	// interface to the Picoblaze
 	input   	 	 	write_strobe, 	// Write strobe – assert to write I/O
 	 	 	 	 	 	 	 	 	 	// data
 	 	   	 	 	read_strobe,  	// Read strobe - asserted to read I/O
 	 	 	 	 	 	 	 	 	 	// data
 	input   	[7:0]  port_id,  	 	// I/O port address
 	input   	[7:0]  io_data_in,  	// data from PicoBlaze to be written to
 	 	 	 	 	 	 	 	 	 	// I/O register
 	output reg [7:0]  io_data_out,  	// data from I/O register to PicoBlaze

 	input  	 	 	interrupt_ack, // interrupt acknowledge from PicoBlaze
 	output  reg  	 	interrupt,  	// interrupt request to PicoBlaze

 	// interface to the Nexys4
 	input  	 	 	sysclk,  	 	// system clock
 	input  	 	 	sysreset, 	 	// system reset (asserted high)
  /*
 	input  	[7:0] 	PORT_A,  	 	// slide switches [7:0]
 	input  	[7:0] 	PORT_B,  	 	// slide switches [15:8]
 	input  	[7:0] 	PORT_C,  	 	// debounced buttons
 	input  	[7:0] 	PORT_D,  	 	// reserved
 	output reg [7:0] 	PORT_01,  	 	// LEDs [7:0]
 	output reg [7:0] 	PORT_02,  	 	// LEDs [15:8]
 	output reg [7:0] 	PORT_04,  	 	// Digit[0] of 7 segment display
 	output reg [7:0]  PORT_08,  	 	// 7-segment display decimal points
  */
  input [7:0]  PORT_00,     //PA_PBTNS  (i) pushbuttons inputs
  input [7:0]  PORT_01,   //PA_SLSWTCH (i) slide switches
  output [7:0] PORT_02,  //PA_LEDS (o) LEDs
  output [7:0] PORT_03, //PA_DIG3 (o) digit 3 port address
  output [7:0] PORT_04, //PA_DIG2 (o) digit 2 port address
  output [7:0] PORT_05, //PA_DIG1 (o) digit 1 port address
  output [7:0] PORT_06, //PA_DIG0 (o) digit 0 port address
  output [3:0] PORT_07, //PA_DP (o) decimal points 3:0 port address
  output [7:0] PORT_08, //PA_RSVD (o) *RESERVED* port address


   output [7:0] PORT_09, //PA_MOTCTL_IN (o) Rojobot motor control output from system
   input  [7:0] PORT_0A, // PA_LOCX (i) X coordinate of rojobot location
   input  [7:0] PORT_0B, //PA_LOCY (i)  Y coordinate of rojobot location
   input  [7:0] PORT_0C,  //PA_BOTINFO (i) Rojobot info register
   input [7:0] PORT_0D,//PA_SENSORS (i) Sensor register
   input [7:0] PORT_0E, // PA_LMDIST (i) Rojobot left motor distance register
   input [7:0] PORT_0F, //PA_RMDIST (i) Rojobot right motor distance register



   //Extended Alternate I/O interface

   input [7:0] PORT_10, //PA_PBTNS_ALT (i) pushbutton inputs alternate port address
   input [7:0] PORT_11, //PA_SLSWTCH1508 (i) slide switches 15:8 (high byte of switches
   output [7:0] PORT_12, // PA_LEDS1508 LEDs 15:8 (high byte of switches)
   output [7:0] PORT_13, // PA_DIG7 (o) digit 7 port address
   output [7:0] PORT_14, //PA_DIG6 (o) digit 6 port address
   output [7:0] PORT_15, //PA_DIG5 (o) digit 5 port address
   output [7:0] PORT_16, //PA_DIG4 (o) digit 4 port address
   output [7:0] PORT_17,//PA_DP0704  (o) decimal points 7:4 port address
   output [7:0] PORT_18, //PA_RSVD_ALT (o) *RESERVED* alternate port address
   output [7:0] PORT_19, //PA_MOTCTL_IN_ALT (o) Rojobot motor control output from system

   input [7:0] PORT_1A, //PA_LOCX_ALT (i) X coordinate of rojobot location
   input [7:0] PORT_1B, //PA_LOCY_ALT i))Y coordinate of rojobot location
   input [7:0] PORT_1C, //PA_BOTINFO_ALT (i) Rojobot info register
   input [7:0] PORT_1D, //PA_SENSORS_ALT (i) Sensor register
   input [7:0] PORT_1E, //PA_LMDIST_ALT (i) Rojobot left motor distance register
   input [7:0] PORT_1F, //PA_RMDIST_ALT (i) Rojobot right motor distance register



 	input	interrupt_request // Interrupt request input
);

// internal variables

// reset - asserted high
wire reset_in                                  = RESET_POLARITY_LOW ? ~sysreset : sysreset;

/////////////////////////////////////////////////////////////////////////////////
// General Purpose Input Ports.
/////////////////////////////////////////////////////////////////////////////////
//
//
// The inputs connect via a pipelined multiplexer. For optimum implementation,
// the input selection control of the multiplexer is limited to only those
// signals of 'port_id' that are necessary. In this case, only 2-bits are
// required to identify each of four input ports to be read by KCPSM6.
//
// Note that 'read_strobe' only needs to be used when whatever supplying
// information to KCPSM6 needs to know when that information has been read. For
// example, when reading a FIFO a read signal would need to be generated when
// that port is read such that the FIFO would know to present the next oldest
// information.
//// Note:  The input registers are binary encoded per kcpsm6_design_template.v
//
always @ (posedge sysclk) begin
        case (port_id[3:0])

/*
        // Read  (i) pushbuttons inputs
        2'b00 : io_data_out                   <= PORT_00;

        // Read  (i) slide switches
        2'b01 : io_data_out                   <= PORT_01;

        // Read Debounced pushbuttons[7:0] from stored value
        2'b10 : io_data_out <= PORT_C;

        // Read LED[15:8] at port address 03 hex
        2'b11 : io_data_out                   <= PORT_D;

*/

        // Read  (i) pushbuttons inputs
        4'b0000 : io_data_out                   <= PORT_00;

        // Read  (i) pushbuttons inputs
        4'b0001 : io_data_out                   <= PORT_01;

        // Read  (i) pushbuttons inputs
        4'b0010 : io_data_out                   <= PORT_0A;

        // Read  (i) pushbuttons inputs
        4'b0011 : io_data_out                   <= PORT_0B;

        // Read  (i) pushbuttons inputs
        4'b0100 : io_data_out                   <= PORT_0C;

        // Read  (i) pushbuttons inputs
        4'b0101 : io_data_out                   <= PORT_0D;

        // Read  (i) pushbuttons inputs
        4'b0110 : io_data_out                   <= PORT_0E;

        // Read  (i) pushbuttons inputs
        4'b0111 : io_data_out                   <= PORT_0F;

        // Read  (i) pushbuttons inputs
        4'b1000 : io_data_out                   <= PORT_10;

        // Read  (i) pushbuttons inputs
        4'b1001 : io_data_out                   <= PORT_11;

        // Read  (i) pushbuttons inputs
        4'b1010 : io_data_out                   <= PORT_1A;

        // Read  (i) pushbuttons inputs
        4'b1011 : io_data_out                   <= PORT_1B;

        // Read  (i) pushbuttons inputs
        4'b1100 : io_data_out                   <= PORT_1C;

        // Read  (i) pushbuttons inputs
        4'b1101 : io_data_out                   <= PORT_1D;

        // Read  (i) pushbuttons inputs
        4'b1110 : io_data_out                   <= PORT_1E;

        // Read  (i) pushbuttons inputs
        4'b1111 : io_data_out                   <= PORT_1F;





         // To ensure minimum logic implementation when defining a multiplexer
         // always use don't care for any of the unused cases (although there are
         // none in this example).

        default : io_data_out                 <= 8'bXXXXXXXX ;  // Do I need edit ??
     endcase
     end
/////////////////////////////////////////////////////////////////////////////////
// General Purpose Output Ports
/////////////////////////////////////////////////////////////////////////////////
//
//
// Output ports must capture the value presented on the 'out_port' based on the
 // value of 'port_id' when 'write_strobe' is High.
//
// Note: The output registers are one-hot encoded per kcpsm6_design_template.v

    always @ (posedge sysclk) begin
    // 'write_strobe' is used to qualify all writes to general output ports.
    if (write_strobe == 1'b1) begin

    /*
        // Write to LEDS[7:0] at port address 01 hex
        if (port_id[0] == 1'b1) begin
        PORT_01 <= io_data_in;         end

        // Write to LEDS[15:8] at port address 02 hex
        if (port_id[1] == 1'b1) begin
        PORT_02                               <= io_data_in;         end

 	 	// Write to DIGIT[0] of 7-segment display at port address 04 hex
    	if (port_id[2] == 1'b1) begin
      PORT_04                                 <= io_data_in;         end

 	 	// Write to decimal points of 7-segment display at port address 08 hex
    if (port_id[3] == 1'b1) begin
    PORT_08                                   <= io_data_in;         end

   */


   // Write to LEDS[7:0] at port address 01 hex
   if (port_id[0] == 1'b1) begin
   PORT_03 <= io_data_in;
   PORT_04 <= io_data_in;
   PORT_05 <= io_data_in;
   PORT_06 <= io_data_in;
   PORT_06 <= io_data_in;  //decimal point... 

    end



    end
    end

/////////////////////////////////////////////////////////////////////////////////
// Recommended 'closed loop' interrupt interface (when required).
///////////////////////////////////////////////////////////////////////////////// //
// Interrupt becomes active when 'int_request' is observed and then remains  // active until
// acknowledged by KCPSM6. Please see description and waveforms in documentation.
//
 always @ (posedge sysclk) begin
  if (interrupt_ack == 1'b1) begin
    interrupt <= 1'b0;     end
    else if (interrupt_request == 1'b1) begin
        interrupt                             <= 1'b1;
          end     else begin         interrupt <= interrupt;
           end
           end // always
              endmodule
