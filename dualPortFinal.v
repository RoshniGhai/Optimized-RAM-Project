module dp_mem_merged (
    input clk,
    input rst,
    input enb,
    input wr,
    input rd,
    input burst,                   // Burst enable
    input [4:0] w_addr,
    input [4:0] r_addr,
    input [7:0] w_data,
    output reg [7:0] r_data
);

    integer i;
    reg [11:0] mem_bank0 [7:0];    // Bank 0: 12-bit encoded data (Hamming code)
    reg [11:0] mem_bank1 [7:0];    // Bank 1: 12-bit encoded data (Hamming code)
    reg [7:0] r_burst_data [3:0];  // Burst-read buffer
    reg error_corrected;           // Flag for error correction

    // Function to count the number of '1's in an 8-bit input
    function integer count_ones(input [7:0] data);
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 8; j = j + 1) begin
                if (data[j]) count_ones = count_ones + 1;
            end
        end
    endfunction

    // Hamming Code Functions
    function [11:0] encode_hamming(input [7:0] data);
        reg [3:0] p; // Parity bits
        begin
            // Calculate parity bits
            p[0] = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6];
            p[1] = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6];
            p[2] = data[1] ^ data[2] ^ data[3] ^ data[7];
            p[3] = data[4] ^ data[5] ^ data[6] ^ data[7];
            encode_hamming = {p, data};
        end
    endfunction

    function [7:0] decode_hamming(input [11:0] code);
        reg [3:0] p, p_calc, syndrome;
        reg [7:0] data;
        begin
            p = code[11:8];
            data = code[7:0];
            p_calc[0] = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6];
            p_calc[1] = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6];
            p_calc[2] = data[1] ^ data[2] ^ data[3] ^ data[7];
            p_calc[3] = data[4] ^ data[5] ^ data[6] ^ data[7];
            syndrome = p ^ p_calc;

            if (syndrome != 4'b0000) begin
                data[syndrome - 1] = ~data[syndrome - 1];
                decode_hamming = {1'b1, data};
            end else begin
                decode_hamming = {1'b0, data};
            end
        end
    endfunction

    // Sequential logic for memory operations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all memory banks and variables
            for (i = 0; i < 8; i = i + 1) begin
                mem_bank0[i] <= 12'b0;
                mem_bank1[i] <= 12'b0;
            end
            r_data <= 8'b0;
            error_corrected <= 1'b0;
        end else if (enb) begin
            if (wr && !rd) begin
                // Write operation
                if (burst) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (w_addr[4]) // Bank 1
                            mem_bank1[w_addr[3:0] + i] <= encode_hamming(
                                (count_ones(w_data + i) > 4) ? ~(w_data + i) : (w_data + i)
                            );
                        else // Bank 0
                            mem_bank0[w_addr[3:0] + i] <= encode_hamming(
                                (count_ones(w_data + i) > 4) ? ~(w_data + i) : (w_data + i)
                            );
                    end
                end else begin
                    if (w_addr[4]) // Bank 1
                        mem_bank1[w_addr[3:0]] <= encode_hamming(
                            (count_ones(w_data) > 4) ? ~w_data : w_data
                        );
                    else // Bank 0
                        mem_bank0[w_addr[3:0]] <= encode_hamming(
                            (count_ones(w_data) > 4) ? ~w_data : w_data
                        );
                end
            end
            if (!wr && rd) begin
                if (burst) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (r_addr[4]) // Bank 1
                            {error_corrected, r_burst_data[i]} <= decode_hamming(mem_bank1[r_addr[3:0] + i]);
                        else // Bank 0
                            {error_corrected, r_burst_data[i]} <= decode_hamming(mem_bank0[r_addr[3:0] + i]);

                        if (error_corrected)
                            $display("Error corrected at address %d", r_addr + i);
                    end
                end else begin
                    if (r_addr[4]) // Bank 1
                        {error_corrected, r_data} <= decode_hamming(mem_bank1[r_addr[3:0]]);
                    else // Bank 0
                        {error_corrected, r_data} <= decode_hamming(mem_bank0[r_addr[3:0]]);

                    if (error_corrected)
                        $display("Error corrected at address %d", r_addr);
                end
            end
        end
    end

endmodule
