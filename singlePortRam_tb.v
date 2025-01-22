`include "defines.v"
`include "singlePortRam.v"

module top;
    // Output should be reg type only
    reg clk, rstn, en, wr_rd;
    reg [`data_width-1:0] data_in;
    reg [`addr_width-1:0] addr;
    wire [`data_width-1:0] data_out;  // Correct width for data_out
    wire out_en;  // Correct width for out_en, should be 1-bit
    reg [`data_width-1:0] temp[`depth-1:0]; // Internal memory of testbench
    reg [`data_width-1:0] data_out_l; // To hold the data read out

    // Local variables
    reg [`addr_width-1:0] addr_l;

    // Instantiate DUT
    ram dut (clk, rstn, en, addr, wr_rd, data_in, data_out, out_en);  // Correct order and size of ports

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock generation
    end

    // Reset generation
    initial begin
        en = 1;
        rstn = 0; // Active low reset
        #10
        rstn = 1;
    end

    // Add dumpfile and dumpvars for waveform generation
    initial begin
        $dumpfile("waveform.vcd");  // VCD file to be opened in GTKWave
        $dumpvars(0, top);  // Dump all variables in the "top" module
    end

    // Main test sequence
    initial begin
        repeat(10)begin
            write_mem();
            #50;
            read_mem();
            comp();
        end
    end

    // Task to write to memory
    task write_mem();
        begin
            wr_rd = 1; // Write operation
            addr = $random % (2 ** `addr_width); // Ensure address is within bounds
            data_in = $random; // Generates random values for data input
            addr_l = addr; // Store the address locally
            temp[addr_l] = data_in; // Save the data into the internal memory
            $display("WRITE PACKET :: en=%b wr_rd=%b addr=%h data_in=%h", en, wr_rd, addr, data_in);
        end
    endtask

    // Task to read from memory
    task read_mem();
        begin
            wr_rd = 0; // Read operation
            addr = addr_l; // Use the address from the write operation
            wait(out_en); // Wait for the output enable signal
            data_out_l = data_out; // Capture the data output
            $display("READ PACKET :: en=%b wr_rd=%b addr=%h data_out=%h", en, wr_rd, addr, data_out);
        end
    endtask

    // Task to compare read and written values
    task comp();
        begin
            if (temp[addr_l] == data_out_l) begin
                $display("RAM is PASSED ");
                $display("temp[%h]=%h data_out_l=%h \n", addr_l, temp[addr_l], data_out_l);
            end else begin
                $display("RAM is FAILED ");
                $display("temp[%h]=%h data_out_l=%h \n", addr_l, temp[addr_l], data_out_l);
            end
        end
    endtask

    // Logic to end the simulation
    initial begin
        #1000;
        $finish;
    end

endmodule
