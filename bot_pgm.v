//
///////////////////////////////////////////////////////////////////////////////////////////
// Copyright � 2010-2013, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
///////////////////////////////////////////////////////////////////////////////////////////
//
// Disclaimer:
// This disclaimer is not a license and does not grant any rights to the materials
// distributed herewith. Except as otherwise provided in a valid license issued to
// you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
// MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
// DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
// INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
// OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
// (whether in contract or tort, including negligence, or under any other theory
// of liability) for any loss or damage of any kind or nature related to, arising
// under or in connection with these materials, including for any direct, or any
// indirect, special, incidental, or consequential loss or damage (including loss
// of data, profits, goodwill, or any type of loss or damage suffered as a result
// of any action brought by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-safe, or for use in any
// application requiring fail-safe performance, such as life-support or safety
// devices or systems, Class III medical devices, nuclear facilities, applications
// related to the deployment of airbags, or any other applications that could lead
// to death, personal injury, or severe property or environmental damage
// (individually and collectively, "Critical Applications"). Customer assumes the
// sole risk and liability of any use of Xilinx products in Critical Applications,
// subject only to applicable laws and regulations governing limitations on product
// liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// Production definition of a 1K program for KCPSM6 in a 7-Series device using a 
// RAMB18E1 primitive.
//
// Note: The complete 12-bit address bus is connected to KCPSM6 to facilitate future code 
//       expansion with minimum changes being required to the hardware description. 
//       Only the lower 10-bits of the address are actually used for the 1K address range
//       000 to 3FF hex.  
//
// Program defined by 'C:\PSU_Projects\ECE540_Fall14_Projects\project2\firmware_part1\bot_pgm\bot_pgm.psm'.
//
// Generated by KCPSM6 Assembler: 11 Oct 2014 - 10:29:30. 
//
// Assembler used ROM_form template: ROM_form_7S_1K_14March13.v
//
//
module bot_pgm (
input  [11:0] address,
output [17:0] instruction,
input         enable,
input         clk);
//
//
wire [13:0] address_a;
wire [17:0] data_in_a;
wire [17:0] data_out_a;
wire [13:0] address_b;
wire [17:0] data_in_b;
wire [17:0] data_out_b;
wire        enable_b;
wire        clk_b;
wire [3:0]  we_b;
//
//
assign address_a = {address[9:0], 4'b1111};
assign instruction = data_out_a[17:0];
assign data_in_a = {16'h0000, address[11:10]};
//
assign address_b = 14'b11111111111111;
assign data_in_b = data_out_b[17:0];
assign enable_b = 1'b0;
assign we_b = 4'h0;
assign clk_b = 1'b0;
//
// 
RAMB18E1 # ( .READ_WIDTH_A              (18),
             .WRITE_WIDTH_A             (18),
             .DOA_REG                   (0),
             .INIT_A                    (16'b000000000000000000),
             .RSTREG_PRIORITY_A         ("REGCE"),
             .SRVAL_A                   (36'h000000000000000000),
             .WRITE_MODE_A              ("WRITE_FIRST"),
             .READ_WIDTH_B              (18),
             .WRITE_WIDTH_B             (18),
             .DOB_REG                   (0),
             .INIT_B                    (36'h000000000000000000),
             .RSTREG_PRIORITY_B         ("REGCE"),
             .SRVAL_B                   (36'h000000000000000000),
             .WRITE_MODE_B              ("WRITE_FIRST"),
             .INIT_FILE                 ("NONE"),
             .SIM_COLLISION_CHECK       ("ALL"),
             .RAM_MODE                  ("TDP"),
             .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
             .SIM_DEVICE                ("7SERIES"),
             .INIT_00                   (256'h002200310E00005F019790000031019100221C401D401E001F0200B000640046),
             .INIT_01                   (256'h180019000C100D0000D202E001F00F00008202E001F02020E015D80FE015D90F),
             .INIT_02                   (256'hD00ED00ED00CD00CDA03DB04DC02DD010A0001880B00010402C001D0200A01C2),
             .INIT_03                   (256'h400E400E400E400EE041410EA0200200400E00105000D00DD00DD806D9055000),
             .INIT_04                   (256'h1001E10011CE1001E10011001001E100110010205000A02002105000300F5000),
             .INIT_05                   (256'h01005000E100114F1001E10011D81001E10011EE1001E10011CC1001E10011CE),
             .INIT_06                   (256'hE10011421001E10011311001E10011201001E10011171000500000361220310F),
             .INIT_07                   (256'h1200013041065000E10011061001E10011751001E10011641001E10011531001),
             .INIT_08                   (256'h20AF00406090D50820AF0040608CD50420AF00406088D5000520041050000036),
             .INIT_09                   (256'hD50E20AF007D13000100007D13000140609FD50D20AF007D130001406096D50C),
             .INIT_0A                   (256'h5000004020AF007D13010100007D1301014060AED50F20AF007D1301014060A5),
             .INIT_0B                   (256'h1001E10011011001E10011111001E10011101001E100111F1001E100110F1010),
             .INIT_0C                   (256'h400E400E400E310F0100004312105000E10011FF1001E10011F01001E10011F1),
             .INIT_0D                   (256'h60E2D10F060020DE960160DDD00F60E4D40400C907C006D0051004205000400E),
             .INIT_0E                   (256'h871020F4170160EFD10F860020EB160160EAD00F60F1D40820F4071020F49701),
             .INIT_0F                   (256'hD108500001700060500001C000D060FCD00200FF0270016050000170006020F4),
             .INIT_10                   (256'h00FF1101040000FF920191016116DF00070000FF02C001D05000900A0000D209),
             .INIT_11                   (256'h1101050000FF1201040000FF920211016124DF015000017A060000FF11010500),
             .INIT_12                   (256'h060000FF1201050000FF1201040000FF920111016132DF025000017A060000FF),
             .INIT_13                   (256'h5000017A060000FF1201050000FF9101040000FF120111026140DF035000017A),
             .INIT_14                   (256'h615CDF055000017A060000FF9101050000FF9101040000FF12011101614EDF04),
             .INIT_15                   (256'h12019101616ADF065000017A060000FF9201050000FF9201040000FF12029101),
             .INIT_16                   (256'h040000FF920191026178DF075000017A060000FF9201050000FF9201040000FF),
             .INIT_17                   (256'h6181D50230F8617ED7011007500010FF5000017A060000FF9201050000FF1101),
             .INIT_18                   (256'h4010310701F0400640064006400600E0500050086187D60250106184D4025018),
             .INIT_19                   (256'h410E1000420E420E420E420E0200310F010050000A0001881B00180019005000),
             .INIT_1A                   (256'h400E5080092021AFD2003201400E5080081021A9D1003101400E4008420E4008),
             .INIT_1B                   (256'h920101B81219500061B9910101B41128500061B5900110185000400E400E400E),
             .INIT_1C                   (256'h61CD930101BD13C8500061C8930101BD1364500061C3930101BD1332500061BE),
             .INIT_1D                   (256'h00000000000000000000500061D793010330130A500061D2940101CC14055000),
             .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_30                   (256'hD90598049902D00CD00CDC02DD014C060CD01D01D004900018FF19FF1C001D00),
             .INIT_31                   (256'h0000000000000000000000000000000000002304D00ED00E01CCD00DD00DD806),
             .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_00                  (256'h16861861861860A0286186186186086255D14AAAAAAA220A008082DDA28A802A),
             .INITP_01                  (256'hA08360826759DD99D677600954228618618618608A0836836820DA0D8D8D8D0A),
             .INITP_02                  (256'hD348A24925DA24925DA24925DA24925DA24925DA24925DA24925DA24925D2082),
             .INITP_03                  (256'h0000000000000000002D0B62D8B62D8B62D8B495474474554550220201548D34),
             .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
             .INITP_06                  (256'h00000000000000000000000000000000000000000000000000002AAA96A91800),
             .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
 kcpsm6_rom( .ADDRARDADDR               (address_a),
             .ENARDEN                   (enable),
             .CLKARDCLK                 (clk),
             .DOADO                     (data_out_a[15:0]),
             .DOPADOP                   (data_out_a[17:16]), 
             .DIADI                     (data_in_a[15:0]),
             .DIPADIP                   (data_in_a[17:16]), 
             .WEA                       (2'b00),
             .REGCEAREGCE               (1'b0),
             .RSTRAMARSTRAM             (1'b0),
             .RSTREGARSTREG             (1'b0),
             .ADDRBWRADDR               (address_b),
             .ENBWREN                   (enable_b),
             .CLKBWRCLK                 (clk_b),
             .DOBDO                     (data_out_b[15:0]),
             .DOPBDOP                   (data_out_b[17:16]), 
             .DIBDI                     (data_in_b[15:0]),
             .DIPBDIP                   (data_in_b[17:16]), 
             .WEBWE                     (we_b),
             .REGCEB                    (1'b0),
             .RSTRAMB                   (1'b0),
             .RSTREGB                   (1'b0));
//
//
endmodule
//
////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE bot_pgm.v
//
////////////////////////////////////////////////////////////////////////////////////
