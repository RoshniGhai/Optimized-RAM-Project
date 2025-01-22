`include "defines.v"
`include "singlePortRam.v"

module top;
    reg clk, rstn, en, wr_rd;
    reg [`data_width - 1:0] data_in;
    reg [`addr_width - 1:0] addr;
    wire [`data_width - 1:0] data_out;
    wire out_en;
    reg [`data_width - 1:0] temp[`depth - 1:0];
    reg [`data_width - 1:0] data_out_l;
    reg [`addr_width - 1:0] addr_l;

    // Instantiate DUT
    ram dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .wr_rd(wr_rd), 
        .data_in(data_in), 
        .addr(addr), 
        .data_out(data_out), 
        .out_en(out_en)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock generation
    end

    initial begin
        en = 1;
        rstn = 0; 
        #10
        rstn = 1;
    end

    initial begin
        $dumpfile("singlePortRAMoptimized.vcd");  
        $dumpvars(0, top);
    end

    initial begin
        repeat(10) begin
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

    initial begin
        #1000;
        $finish;
    end

endmodule
