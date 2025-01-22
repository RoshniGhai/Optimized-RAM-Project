module dual_port_ram (
    input clk,               // Clock
    input rst,               // Reset signal
    input wr_en,             // Write enable for port 0
    input [7:0] data_in,     // Input data to port 0
    input [3:0] addr_in_0,   // Address for port 0
    input [3:0] addr_in_1,   // Address for port 1
    input port_en_0,         // Enable port 0
    input port_en_1,         // Enable port 1
    input [5:0] burst_len_0, // 6-bit Burst length for port 0
    input [5:0] burst_len_1, // 6-bit Burst length for port 1
    input burst_en_0,        // Burst enable for port 0
    input burst_en_1,        // Burst enable for port 1
    output [7:0] data_out_0, // Output data from port 0
    output [7:0] data_out_1, // Output data from port 1
    output reg ram_passed    // Status signal to indicate pass or fail
);

// Memory declaration
reg [7:0] ram[0:255];  // Increased memory size for DDR5 simulation

// Internal burst address counters
reg [5:0] burst_addr_0, burst_addr_1;

// Writing to the RAM with burst support
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset burst address counters
        burst_addr_0 <= 6'd0;
        burst_addr_1 <= 6'd0;
        ram_passed <= 1'b1;
    end else begin
        if (port_en_0 && wr_en && burst_en_0) begin
            // Write data in burst mode
            ram[addr_in_0 + burst_addr_0] <= data_in;
            burst_addr_0 <= burst_addr_0 + 1'b1;
            if (burst_addr_0 == burst_len_0 - 1) begin
                burst_addr_0 <= 6'd0; // Reset burst counter
            end
        end
        if (port_en_1 && !wr_en && burst_en_1) begin
            // Read data in burst mode
            burst_addr_1 <= burst_addr_1 + 1'b1;
            if (burst_addr_1 == burst_len_1 - 1) begin
                burst_addr_1 <= 6'd0; // Reset burst counter
            end
        end
    end
end

// Always reading from the RAM
assign data_out_0 = port_en_0 ? ram[addr_in_0] : 8'dZ;
assign data_out_1 = port_en_1 ? ram[addr_in_1] : 8'dZ;

// Check pass/fail status
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ram_passed <= 1'b1;
    end else if (port_en_1 && !wr_en) begin
        if (ram[addr_in_1] !== data_out_1) begin
            ram_passed <= 1'b0; // Set fail if data read does not match
        end
    end
end

endmodule
