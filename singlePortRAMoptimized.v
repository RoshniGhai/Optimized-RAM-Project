`include "defines.v"

module ram(
    input clk,
    input rstn,
    input en,
    input wr_rd,
    input [`data_width - 1:0] data_in,
    input [`addr_width - 1:0] addr,
    output reg [`data_width - 1:0] data_out,
    output reg out_en
);

    // Memory declaration
    reg [`data_width - 1:0] mem [`depth - 1:0];
    
    // Local variables
    integer i;
    
    // DDR5-like features
    parameter BURST_LENGTH = 8; // Number of words in a burst
    reg [`data_width - 1:0] burst_buffer [0:BURST_LENGTH - 1];
    reg [2:0] burst_counter;
    reg burst_active;

    always @(posedge clk) begin
        if (en) begin
            if (!rstn) begin
                data_out <= 0;
                out_en <= 0;
                burst_counter <= 0;
                burst_active <= 0;
            end else begin
                if (wr_rd) begin  // Write operation
                    burst_buffer[burst_counter] <= data_in; // Buffer incoming data
                    if (burst_counter < BURST_LENGTH - 1) begin
                        burst_counter <= burst_counter + 1; // Increment counter
                    end else begin
                        // Write to memory in a burst
                        for (i = 0; i < BURST_LENGTH; i = i + 1) begin
                            mem[addr + i] <= burst_buffer[i];
                        end
                        burst_active <= 0; // End burst operation
                        burst_counter <= 0; // Reset for the next burst
                    end
                end else begin  // Read operation
                    if (burst_active) begin
                        data_out <= mem[addr + burst_counter]; // Read from memory
                        out_en <= 1; // Set output enable
                        burst_counter <= burst_counter + 1; // Increment counter
                        if (burst_counter == BURST_LENGTH - 1) begin
                            out_en <= 0; // Reset output enable after burst read
                            burst_active <= 0; // Reset for the next burst
                        end
                    end else begin
                        burst_active <= 1; // Activate burst reading
                        burst_counter <= 0; // Reset counter for new burst
                    end
                end
            end
        end else begin
            $display("RAM is disabled");
        end
    end

    // Initial block for simulation initialization
    initial begin
        // Initialize memory with a known pattern or zero
        for (i = 0; i < (2 ** `addr_width); i = i + 1) begin
            mem[i] = 0; // Initialize to 0
        end
    end

endmodule
