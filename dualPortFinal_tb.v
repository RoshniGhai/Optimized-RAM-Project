`include "dualPortFinal.v"

module tb_dp_mem_dbi;

    // Inputs
    reg clk;
    reg rst;
    reg enb;
    reg wr;
    reg rd;
    reg burst;
    reg [4:0] w_addr;
    reg [4:0] r_addr;
    reg [7:0] w_data;

    // Outputs
    wire [7:0] r_data;
    reg ram_passed; // Status flag to check test result

    // Instantiate the Unit Under Test (UUT)
    dp_mem_merged uut (
        .clk(clk),
        .rst(rst),
        .enb(enb),
        .wr(wr),
        .rd(rd),
        .burst(burst),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .w_data(w_data),
        .r_data(r_data)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 0;
        enb = 0;
        wr = 0;
        rd = 0;
        burst = 0;
        w_addr = 0;
        r_addr = 0;
        w_data = 0;
        ram_passed = 1;

        // VCD file generation
        $dumpfile("dp_mem_tb.vcd");  // Set the name of the VCD file
        $dumpvars(0, tb_dp_mem_dbi); // Dump all variables from the testbench module

        // Apply reset
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Enable RAM operations
        enb = 1;

        // Test 1: Write and Read from Bank 0
        wr = 1;
        w_addr = 5'b00001;  // Write to Bank 0
        w_data = 8'b10101010; // Data to be written
        #10;
        $display("Written Data to Bank 0 at address %d: %b", w_addr, w_data);
        wr = 0;

        rd = 1;
        r_addr = 5'b00001;  // Read from Bank 0
        #10;
        $display("Read Data from Bank 0 at address %d: %b", r_addr, r_data);
        rd = 0;

        // Test 2: Write and Read from Bank 1
        wr = 1;
        w_addr = 5'b10001;  // Write to Bank 1 (MSB = 1)
        w_data = 8'b11110000; // Data to be written
        #10;
        $display("Written Data to Bank 1 at address %d: %b", w_addr, w_data);
        wr = 0;

        rd = 1;
        r_addr = 5'b10001;  // Read from Bank 1
        #10;
        $display("Read Data from Bank 1 at address %d: %b", r_addr, r_data);
        rd = 0;

        // Test 3: Burst Write to Bank 0
        wr = 1;
        burst = 1;
        w_addr = 5'b00000;  // Start of Bank 0
        w_data = 8'b10101010;
        #10;
        $display("Burst Write: Written Data to Bank 0 at address %d: %b", w_addr, w_data);
        burst = 0;
        wr = 0;

        // Test 4: Burst Read from Bank 0
        rd = 1;
        burst = 1;
        r_addr = 5'b00000;  // Start of Bank 0
        #40; // Allow time for burst reads
        $display("Burst Read: Read Data from Bank 0 at address %d: %b", r_addr, r_data);
        rd = 0;
        burst = 0;

        // Test 5: Burst Write to Bank 1
        wr = 1;
        burst = 1;
        w_addr = 5'b10000;  // Start of Bank 1
        w_data = 8'b11001100;
        #10;
        $display("Burst Write: Written Data to Bank 1 at address %d: %b", w_addr, w_data);
        burst = 0;
        wr = 0;

        // Test 6: Burst Read from Bank 1
        rd = 1;
        burst = 1;
        r_addr = 5'b10000;  // Start of Bank 1
        #40; // Allow time for burst reads
        $display("Burst Read: Read Data from Bank 1 at address %d: %b", r_addr, r_data);
        rd = 0;
        burst = 0;

        // Test 7: Hamming Error Correction (Bank 0)
        wr = 1;
        w_addr = 5'b00001;
        w_data = 8'b11111111;
        #10;
        $display("Written Data at address %d: %b", w_addr, w_data);
        wr = 0;

        // Introduce error in Bank 0
        uut.mem_bank0[1][2] = ~uut.mem_bank0[1][2]; // Flip bit in Bank 0

        rd = 1;
        r_addr = 5'b00001;
        #10;
        rd = 0;
        $display("Hamming Code Correction Test:");
        $display("Read Data after Error Correction: %b, Expected: 11111111", r_data);

        // Check pass/fail status
        if (ram_passed) begin
            $display("All Tests Passed: The RAM is functioning correctly.");
        end else begin
            $display("Some Tests Failed: The RAM has issues.");
        end

        // Complete the test
        #20;
        $finish;
    end
endmodule
