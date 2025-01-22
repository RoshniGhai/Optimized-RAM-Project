`include "defines.v"

module ram(clk, rstn, en, addr, wr_rd, data_in, data_out, out_en);

    input clk, rstn, en, wr_rd;
    input [`data_width -1:0] data_in;
    input [`addr_width -1:0] addr;
    output reg [`data_width -1:0] data_out;
    output reg out_en;

    // Memory declaration
    reg [`data_width -1:0] mem [`depth -1:0];

    // Local variable
    integer i;

    always @(posedge clk) begin
        if (en) begin
            if (!rstn) begin
                data_out <= 0;
                out_en <= 0;
                // Memory initialization is handled in the initial block
            end
            else begin
                if (wr_rd == 1) begin  // Write operation
                    mem[addr] <= data_in;
                end
                else begin  // Read operation
                    data_out <= mem[addr];
                    out_en <= 1;
                    @(posedge clk);
                    out_en <= 0;
                end
            end
        end
        else begin
            $display("RAM is disabled");
        end
    end

    // Initial block for simulation initialization
    initial begin
        // Initialize memory with a known pattern or zero
        for (i = 0; i < (2 ** `addr_width); i = i + 1) begin
            mem[i] = 0; // Initialize to 0
        end

        // Optionally, display memory contents after initialization
        // Comment or uncomment as needed
        /*
        for (i = 0; i < (2 ** `addr_width); i = i + 1) begin
            $display("mem[%0d] = %0h", i, mem[i]);
        end
        */
    end

endmodule
