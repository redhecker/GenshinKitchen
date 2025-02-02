`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/08 13:04:08
// Design Name: 
// Module Name: ProjTop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DemoTop(
    input [4:0] button,
    input [7:0] switches,

    output [7:0] led,
    output [7:0] led2,
    
    input clk,
    input rx,
    input rst_n,//used in clock, maybe more usage in other tops in future
    output tx
    );

// The wire below is useful!
        wire uart_clk_16;
        
        wire [7:0] dataIn_bits;
        wire dataIn_ready;
    
        wire [7:0] dataOut_bits;
        wire dataOut_valid;
    
        wire script_mode;
        wire [7:0] pc;
        wire [15:0] script;
// The wire above is useful~

    ScriptMem script_mem_module(
      .clock(uart_clk_16),   // please use the same clock as UART module
      .reset(0),           // please use the same reset as UART module
      
      .dataOut_bits(dataOut_bits), // please connect to io_dataOut_bits of UART module
      .dataOut_valid(dataOut_valid), // please connect to io_dataOut_valid of UART module
      
      .script_mode(script_mode), // output 1 when loading script from UART.
                                 // at this time, you should not use dataOut_bits or use pc and script.
      
      .pc(pc), // (a) give a program counter (address) to ScriptMem.
      .script(script) // referring (a), returning the corresponding instructions of pc
    );
        
    UART uart_module(
          .clock(uart_clk_16),     // uart clock. Please use 16 x BultRate. (e.g. 9600 * 16 = 153600Hz��
          .reset(0),               // reset
          
          .io_pair_rx(rx),          // rx, connect to R5 please
          .io_pair_tx(tx),         // tx, connect to T4 please
          
          .io_dataIn_bits(dataIn_bits),     // (a) byte from DevelopmentBoard => GenshinKitchen
          .io_dataIn_ready(dataIn_ready),   // referring (a)��pulse 1 after a byte tramsmit success.
          
          .io_dataOut_bits(dataOut_bits),     // (b) byte from GenshinKitchen => DevelopmentBoard, only available if io_dataOut_valid=1
          .io_dataOut_valid(dataOut_valid)  // referring (b)
        );
    //时钟分频
    wire clk_slow;
    DelayClock c(.clk(clk),.out(uart_clk_16));

    //按钮消抖
    wire [7:0] fix_switches;
    wire [5:0] fix_button;
    SwitchesDebounce sd(
      .button(button),
      .switches(switches),
      .clk(clk),
      .rst_n(rst_n),
      .fix_button(fix_button),
      .fix_switches(fix_switches)
    );

    //游戏逻辑模块
    DesignedTop dst(
    .origin_clk(clk),
    .clk(uart_clk_16),
    .rst_n(rst_n),
    .button(fix_button),
    .switches(fix_switches),
    .led(led),
    .led2(led2),

    .dataOut_bits(dataOut_bits),
    .dataOut_valid(dataOut_valid),
    
    .script_mode(script_mode),
    .pc(pc),
    .script(script),    
    
    .dataIn_bits(dataIn_bits),
    .dataIn_ready(dataIn_ready)
    );
    
    // loadingLamp ld(
    //   .clk(clk),
    //   .rst_n(rst_n),
    //   .enable(1'b1),
    //   .loadingLamp(led2)
    // );
endmodule

