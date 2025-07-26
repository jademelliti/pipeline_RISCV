module cache #(
    localparam ByteOffsetBits = 4,
    localparam IndexBits = 6,
    localparam TagBits = 22,

    localparam NrWordsPerLine = 4,
    localparam NrLines = 64,

    localparam LineSize = 32 * NrWordsPerLine
) (
    input logic clk_i,
    input logic rstn_i,

    input logic [31:0] addr_i,

    // Read port
    input logic read_en_i,
    output logic read_valid_o,
    output logic [31:0] read_word_o,

    // Memory
    output logic [31:0] mem_addr_o,

    // Memory read port
    output logic mem_read_en_o,
    input logic mem_read_valid_i,
    input logic [LineSize-1:0] mem_read_data_i
);

    // Memories for the cache
    logic [TagBits-1:0] tag_mem [0:NrLines-1];      // Tag memory
    logic [LineSize-1:0] data_mem [0:NrLines-1];    // Data memory
    logic valid_mem [0:NrLines-1];                  // Valid bits

    // Address decomposition
    logic [TagBits-1:0] tag;                        // Tag extracted from address
    logic [IndexBits-1:0] index;                    // Index extracted from address
    logic [ByteOffsetBits-1:0] offset;              // Offset extracted from address

    assign tag = addr_i[31:10];
    assign index = addr_i[9:4];
    assign offset = addr_i[3:2];

    // Cache hit detection
    logic hit;
    assign hit = (valid_mem[index] && (tag_mem[index] == tag) && read_en_i);

    // Read operation
    always_comb begin
        if (hit) 
            read_word_o = data_mem[index][offset * 32 +: 32];
	else read_word_o = 32'b0;
    end

    assign read_valid_o = hit;

    // Memory access control
    assign mem_addr_o = {tag, index, 4'b0}; // Align to the line size
    assign mem_read_en_o = !hit;

    // Sequential logic
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // Reset all cache entries
            integer i;
            for (i = 0; i < NrLines; i = i + 1) begin
                valid_mem[i] <= 1'b0;
                tag_mem[i] <= {TagBits{1'b0}};
                data_mem[i] <= {LineSize{1'b0}};
            end
        end else if (mem_read_valid_i) begin
            // Update cache when memory read completes
            data_mem[index] <= mem_read_data_i; // Store the entire line
            tag_mem[index] <= tag;             // Update the tag
            valid_mem[index] <= 1'b1;          // Mark the line as valid
        end
    end

endmodule

