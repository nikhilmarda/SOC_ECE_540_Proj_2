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
 	input  	[7:0] 	PORT_A,  	 	// slide switches [7:0]
 	input  	[7:0] 	PORT_B,  	 	// slide switches [15:8]
 	input  	[7:0] 	PORT_C,  	 	// debounced buttons
 	input  	[7:0] 	PORT_D,  	 	// reserved
 	output reg [7:0] 	PORT_01,  	 	// LEDs [7:0]
 	output reg [7:0] 	PORT_02,  	 	// LEDs [15:8]
 	output reg [7:0] 	PORT_04,  	 	// Digit[0] of 7 segment display
 	output reg [7:0]
 	 	PORT_08,  	 	// 7-segment display decimal points

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
// signals of 'port_id' that are necessary. In this case, only 2-bits are  // required to identify each of four input ports to be read by KCPSM6.
//
// Note that 'read_strobe' only needs to be used when whatever supplying
// information to KCPSM6 needs to know when that information has been read. For
// example, when reading a FIFO a read signal would need to be generated when
// that port is read such that the FIFO would know to present the next oldest
// information.
//// Note:  The input registers are binary encoded per kcpsm6_design_template.v
//
always @ (posedge sysclk) begin     case (port_id[1:0])

        // Read sw[7:0] at port address 00 hex
        2'b00 : io_data_out                   <= PORT_A;

        // Read sw[15:8] at port address 01 hex
        2'b01 : io_data_out                   <= PORT_B;

        // Read Debounced pushbuttons[7:0] from stored value         2'b10 : io_data_out <= PORT_C;

        // Read LED[15:8] at port address 03 hex
        2'b11 : io_data_out                   <= PORT_D;          // To ensure minimum logic implementation when defining a multiplexer   	 	// always use don't care for any of the unused cases (although there are   	 	// none in this example).

        default : io_data_out                 <= 8'bXXXXXXXX ;
     endcase end
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
        // Write to LEDS[7:0] at port address 01 hex
        if (port_id[0] == 1'b1) begin
        PORT_01 <= io_data_in;         end

        // Write to LEDS[15:8] at port address 02 hex
        if (port_id[1] == 1'b1) begin
        PORT_02                               <= io_data_in;         end

 	 	// Write to DIGIT[0] of 7-segment display at port address 04 hex
    	if (port_id[2] == 1'b1) begin
      PORT_04                                 <= io_data_in;         end

 	 	// Write to decimal points of 7-segment display at port address 04 hex
    if (port_id[3] == 1'b1) begin
    PORT_08                                   <= io_data_in;         end

    end end

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
