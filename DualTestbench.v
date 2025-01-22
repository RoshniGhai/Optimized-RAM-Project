// Code your testbench here
// or browse Examples
`include "intf.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard. sv"
`include "environment.sv"
module top;
environment env;
bit clk, rst;
always #5 clk=!clk;
initial begin
rst=0;
repeat (1)@(negedge clk); rst=1; #1000 Sfinish;
end
intf pif (clk,rst);
dp_mem dut (.clk(pif.clk), .rst(pif.rst),.enb(pif.enb), .wr(pif.wr),.rd(pif.rd),.w_addr(pif.w_addr),.r_addr (pif.r_addr ),.w_data(pif.w_data),.r_data(pif.r_data));
  
  initial begin
    env=new(pif);
    env.run();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule