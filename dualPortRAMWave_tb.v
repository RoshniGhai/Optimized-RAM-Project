`include "dualPortRAMWave.v"

module tb;

    // Inputs
    reg clk;
    reg rst;                // Reset signal
    reg wr_en;
    reg [7:0] data_in;
    reg [3:0] addr_in_0;    // Address width set to 4 bits
    reg [3:0] addr_in_1;    // Address width set to 4 bits
    reg port_en_0;
    reg port_en_1;
    reg [5:0] burst_len_0;  // Burst length for port 0 (6-bit for larger lengths)
    reg [5:0] burst_len_1;  // Burst length for port 1 (6-bit for larger lengths)
    reg burst_en_0;         // Burst enable for port 0
    reg burst_en_1;         // Burst enable for port 1

    // Outputs
    wire [7:0] data_out_0;
    wire [7:0] data_out_1;
    wire ram_passed;        // Status output to indicate pass/fail

    integer i;

    // Instantiate the Unit Under Test (UUT)
    dual_port_ram uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .data_in(data_in),
        .addr_in_0(addr_in_0), 
        .addr_in_1(addr_in_1), 
        .port_en_0(port_en_0),
        .port_en_1(port_en_1),
        .burst_len_0(burst_len_0),
        .burst_len_1(burst_len_1),
        .burst_en_0(burst_en_0),
        .burst_en_1(burst_en_1),
        .data_out_0(data_out_0),
        .data_out_1(data_out_1),
        .ram_passed(ram_passed)
    );

    // Clock generation (toggle every 2.5 time units)
    always #2.5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        addr_in_0 = 0;
        addr_in_1 = 0;
        port_en_0 = 0;
        port_en_1 = 0;
        wr_en = 0;
        data_in = 0;
        burst_len_0 = 6'd16;  // Burst length set to 16
        burst_len_1 = 6'd16;  // Burst length set to 16
        burst_en_0 = 0;
        burst_en_1 = 0;
        
        // Initialize waveform dumping
        $dumpfile("dualPortRam_tb.vcd");
        $dumpvars(0, tb);
        
        // Apply reset
        rst = 1;
        #10;
        rst = 0;
        
        // Test Burst Write Operation
        port_en_0 = 1;
        wr_en = 1;
        burst_en_0 = 1;
        
        // Write data with burst mode
        for (i = 0; i < 16; i = i + 1) begin
            data_in = i + 1;
            addr_in_0 = i[3:0];  // Address width truncated to 4 bits
            #10;
            $display("Writing at address %d, Data: %d", addr_in_0, data_in); // Debugging write
        end
        
        wr_en = 0;
        burst_en_0 = 0;
        
        // Add delay to ensure write is complete
        #50;
        
        // Read data from port 1 with burst mode
        port_en_1 = 1;
        burst_en_1 = 1;
        
        for (i = 0; i < 16; i = i + 1) begin
            addr_in_1 = i[3:0];  // Address width truncated to 4 bits
            #10;
            $display("Reading from address %d, Data: %d", addr_in_1, data_out_1); // Debugging read
        end
        
        port_en_1 = 0;
        burst_en_1 = 0;

        // Check pass/fail status
        #10;
        if (ram_passed) begin
            $display("Test Passed: The RAM is functioning correctly.");
        end else begin
            $display("Test Failed: The RAM has issues.");
        end
        
        // End simulation
        $finish;
    end
endmodule

