module cache #(
    localparam ByteOffsetBits = 4,
    localparam IndexBits = 6,
    localparam TagBits = 27,

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

    //paramètres à stocker
    logic [TagBits-1:0] tag_mem1 [0:NrLines-1];      // mémoire du tag du cache 1
    logic [LineSize-1:0] data_mem1 [0:NrLines-1];    // mémoire de données du cache 1
    logic valid_mem1 [0:NrLines-1];                  // bits valides du cache 1


    logic [TagBits-1:0] tag_mem0 [0:NrLines-1];      // mémoire du tag du cache 0
    logic [LineSize-1:0] data_mem0 [0:NrLines-1];    // mémoire de données du cache 0
    logic valid_mem0 [0:NrLines-1];                  // bits valides du cache 0

    // Décomposition de l'adress
    logic [TagBits-1:0] tag;                        // Tag 
    logic [IndexBits-1:0] index;                    // Index 
    logic [ByteOffsetBits-1:0] offset;              // Offset 

    logic lru_mem [0:NrLines-1];

    assign tag = addr_i[31:10];
    assign index = addr_i[9:4];
    assign offset = addr_i[3:2];

    // Mise en place du signal hit
    assign hit0 = (valid_mem0[index] && (tag_mem0[index] == tag));
    assign hit1 = (valid_mem1[index] && (tag_mem1[index] == tag));
    assign hit = hit0 || hit1;


    // Lire à travers hit
    always_comb begin
        if (hit) begin
	    if (hit0) read_word_o = data_mem0[index][(offset * 32) +: 32];
            else read_word_o = data_mem1[index][offset * 32 +: 32];
	end else read_word_o = 32'b0;
    end

    assign read_valid_o = hit;

    
    // Mémoire
    assign mem_addr_o = {tag, index, 4'b0}; // Align to the line size
    assign mem_read_en_o = !hit;

    // Logique séquentielle
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            integer i;
            for (i = 0; i < NrLines; i = i + 1) begin
                valid_mem0[i] <= 1'b0;
                tag_mem0[i] <= {TagBits{1'b0}};
                data_mem0[i] <= {LineSize{1'b0}};
                valid_mem1[i] <= 1'b0;
                tag_mem1[i] <= {TagBits{1'b0}};
                data_mem1[i] <= {LineSize{1'b0}};
                lru_mem[i] <= 1'b0;
            end
        end else if (mem_read_valid_i) begin
            if (lru_mem[index]==0) begin
            data_mem1[index] <= mem_read_data_i; 
            tag_mem1[index] <= tag;             
            valid_mem1[index] <= 1'b1;          
            lru_mem[index] <= 1;
            end
            else begin
            data_mem0[index] <= mem_read_data_i; 
            tag_mem0[index] <= tag;             
            valid_mem0[index] <= 1'b1;           
            lru_mem[index] <= 0;
            end
        end
    end

endmodule

