module dp_mem (
    input clk,
    input rst,
    input enb,
    input wr,
    input rd,
    input [4:0] w_addr,
    input [4:0] r_addr,
    input [7:0] w_data,
    output reg [7:0] r_data
);

integer i;
reg [7:0] mem [15:0];

// Sequential logic: always triggered on clock edge
always @(posedge clk) begin
    // Synchronous active-low reset
    if (!rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            mem[i] <= 8'bx;  // Initialize memory to unknown values (if needed)
        end
    end else begin
        if (enb) begin
            if (wr == 1 && rd == 0) begin
                // Write operation
                mem[w_addr] <= w_data;
            end else if (wr == 0 && rd == 1) begin
                // Read operation
                r_data <= mem[r_addr];
            end else if (wr == 1 && rd == 1) begin
                // Simultaneous read and write
                mem[w_addr] <= w_data;
                r_data <= mem[r_addr];
            end else begin
                // Hold memory contents
                for (i = 0; i < 16; i = i + 1) begin
                    mem[i] <= mem[i];
                end
            end
        end else begin
            // Hold memory contents when enb is low
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= mem[i];
            end
        end
    end
end

endmodule
