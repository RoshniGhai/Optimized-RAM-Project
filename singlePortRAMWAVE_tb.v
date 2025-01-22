`include "singlePortRAMWAVE.v"

module single_port_ram_tb();
  reg [7:0] data;   // Data signal
  reg [5:0] addr;   // Address signal
  reg we;
  reg clk;
  wire [7:0] q;

  // Instantiating the single_port_ram module
  single_port_ram single_port_ram(
    .data(data),
    .addr(addr),
    .we(we),
    .clk(clk),
    .q(q)
  );

  // Clock generation
  initial 
  begin
    clk = 1'b1;
    forever #50 clk = ~clk;
  end

  // Waveform dump initialization
  initial
  begin
    $dumpfile("single_port_ram_tb.vcd"); // Specify the name of the VCD file
    $dumpvars(0, single_port_ram_tb);    // Dump all signals in the testbench
  end

  // Stimulus for testing
  initial
  begin
    // Write data
    data = 8'h01;
    addr = 6'd0;   // Address for writing
    we = 1'b1;
    #100;
    
    data = 8'h02;
    addr = 6'd1;
    #100;
    
    data = 8'h03;
    addr = 6'd2;
    #100;
    
    // Read data
    we = 1'b0;   // Disable write
    addr = 6'd0;
    #100;
    
    addr = 6'd1;
    #100;
    
    addr = 6'd2;
    #100;

    $finish;  // End simulation
  end

endmodule
