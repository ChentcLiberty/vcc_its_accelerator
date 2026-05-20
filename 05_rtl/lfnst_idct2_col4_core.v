module lfnst_idct2_col4_core #(
    parameter integer DATA_W      = 16,
    parameter integer IDCT_OUT_W  = 32,
    parameter        LFNST_MEM_FILE = "lfnst_tables.memh",
    parameter        IDCT_MEM_FILE  = "idct2_tables.memh"
) (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      start,
    output wire                      in_ready,
    input  wire [1:0]                lfnst_tr_set_idx,
    input  wire [1:0]                lfnst_idx,
    input  wire signed [DATA_W-1:0]  x_bar_0,
    input  wire signed [DATA_W-1:0]  x_bar_1,
    input  wire signed [DATA_W-1:0]  x_bar_2,
    input  wire signed [DATA_W-1:0]  x_bar_3,
    input  wire signed [DATA_W-1:0]  x_bar_4,
    input  wire signed [DATA_W-1:0]  x_bar_5,
    input  wire signed [DATA_W-1:0]  x_bar_6,
    input  wire signed [DATA_W-1:0]  x_bar_7,
    input  wire signed [DATA_W-1:0]  x_bar_8,
    input  wire signed [DATA_W-1:0]  x_bar_9,
    input  wire signed [DATA_W-1:0]  x_bar_10,
    input  wire signed [DATA_W-1:0]  x_bar_11,
    input  wire signed [DATA_W-1:0]  x_bar_12,
    input  wire signed [DATA_W-1:0]  x_bar_13,
    input  wire signed [DATA_W-1:0]  x_bar_14,
    input  wire signed [DATA_W-1:0]  x_bar_15,
    input  wire                      out_req,
    output wire                      out_valid,
    output wire                      out_last,
    output wire [5:0]                out_row_base,
    output reg signed [IDCT_OUT_W-1:0] out_data_0,
    output reg signed [IDCT_OUT_W-1:0] out_data_1,
    output reg signed [IDCT_OUT_W-1:0] out_data_2,
    output reg signed [IDCT_OUT_W-1:0] out_data_3,
    output reg                       done,
    output wire                      busy
);

    localparam [3:0] S_IDLE        = 4'd0;
    localparam [3:0] S_PREP_BYPASS = 4'd1;
    localparam [3:0] S_START_LFNST = 4'd2;
    localparam [3:0] S_RUN_LFNST   = 4'd3;
    localparam [3:0] S_REMAP_BLOCK = 4'd4;
    localparam [3:0] S_PREP_IDCT   = 4'd5;
    localparam [3:0] S_START_IDCT  = 4'd6;
    localparam [3:0] S_RUN_IDCT    = 4'd7;
    localparam [3:0] S_STREAM_OUT  = 4'd8;

    reg [3:0] state_r;
    reg [1:0] lfnst_tr_set_idx_r;
    reg [1:0] lfnst_idx_r;
    reg [1:0] col_idx_r;
    reg [5:0] out_row_base_r;

    reg signed [DATA_W-1:0] x_bar_in_r [0:15];
    reg signed [DATA_W-1:0] lfnst_vec_r [0:15];
    reg signed [DATA_W-1:0] block_r [0:15];
    reg signed [DATA_W-1:0] idct_x_r [0:63];
    reg signed [IDCT_OUT_W-1:0] col_block_r [0:15];

    wire lfnst_in_ready;
    wire lfnst_out_valid;
    wire lfnst_out_last;
    wire [5:0] lfnst_out_row_base;
    wire signed [DATA_W-1:0] lfnst_out_data_0;
    wire signed [DATA_W-1:0] lfnst_out_data_1;
    wire signed [DATA_W-1:0] lfnst_out_data_2;
    wire signed [DATA_W-1:0] lfnst_out_data_3;
    wire lfnst_done;

    wire idct_in_ready;
    wire idct_out_valid;
    wire idct_out_last;
    wire [6:0] idct_out_index_base;
    wire signed [IDCT_OUT_W-1:0] idct_out_data_0;
    wire signed [IDCT_OUT_W-1:0] idct_out_data_1;
    wire signed [IDCT_OUT_W-1:0] idct_out_data_2;
    wire signed [IDCT_OUT_W-1:0] idct_out_data_3;
    wire idct_done;

    wire lfnst_start = (state_r == S_START_LFNST);
    wire lfnst_out_req = (state_r == S_RUN_LFNST);
    wire idct_start = (state_r == S_START_IDCT);
    wire idct_out_req = (state_r == S_RUN_IDCT);

    integer idx;

    assign in_ready = (state_r == S_IDLE);
    assign out_valid = (state_r == S_STREAM_OUT);
    assign out_row_base = out_row_base_r;
    assign out_last = (state_r == S_STREAM_OUT) && (out_row_base_r == 6'd12);
    assign busy = (state_r != S_IDLE);

    lfnst_core #(
        .MEM_FILE(LFNST_MEM_FILE)
    ) u_lfnst_core (
        .clk              (clk),
        .rst_n            (rst_n),
        .start            (lfnst_start),
        .in_ready         (lfnst_in_ready),
        .tu_width         (7'd4),
        .tu_height        (7'd4),
        .lfnst_tr_set_idx (lfnst_tr_set_idx_r),
        .lfnst_idx        (lfnst_idx_r),
        .x_bar_0          (x_bar_in_r[0]),
        .x_bar_1          (x_bar_in_r[1]),
        .x_bar_2          (x_bar_in_r[2]),
        .x_bar_3          (x_bar_in_r[3]),
        .x_bar_4          (x_bar_in_r[4]),
        .x_bar_5          (x_bar_in_r[5]),
        .x_bar_6          (x_bar_in_r[6]),
        .x_bar_7          (x_bar_in_r[7]),
        .x_bar_8          (x_bar_in_r[8]),
        .x_bar_9          (x_bar_in_r[9]),
        .x_bar_10         (x_bar_in_r[10]),
        .x_bar_11         (x_bar_in_r[11]),
        .x_bar_12         (x_bar_in_r[12]),
        .x_bar_13         (x_bar_in_r[13]),
        .x_bar_14         (x_bar_in_r[14]),
        .x_bar_15         (x_bar_in_r[15]),
        .out_req          (lfnst_out_req),
        .out_valid        (lfnst_out_valid),
        .out_last         (lfnst_out_last),
        .out_row_base     (lfnst_out_row_base),
        .out_data_0       (lfnst_out_data_0),
        .out_data_1       (lfnst_out_data_1),
        .out_data_2       (lfnst_out_data_2),
        .out_data_3       (lfnst_out_data_3),
        .done             (lfnst_done),
        .busy             ()
    );

    idct2_1d_core #(
        .MEM_FILE(IDCT_MEM_FILE)
    ) u_idct2_1d_core (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (idct_start),
        .in_ready      (idct_in_ready),
        .n_tbs         (7'd4),
        .non_zero_size (7'd4),
        .x_0           (idct_x_r[0]),
        .x_1           (idct_x_r[1]),
        .x_2           (idct_x_r[2]),
        .x_3           (idct_x_r[3]),
        .x_4           (idct_x_r[4]),
        .x_5           (idct_x_r[5]),
        .x_6           (idct_x_r[6]),
        .x_7           (idct_x_r[7]),
        .x_8           (idct_x_r[8]),
        .x_9           (idct_x_r[9]),
        .x_10          (idct_x_r[10]),
        .x_11          (idct_x_r[11]),
        .x_12          (idct_x_r[12]),
        .x_13          (idct_x_r[13]),
        .x_14          (idct_x_r[14]),
        .x_15          (idct_x_r[15]),
        .x_16          (idct_x_r[16]),
        .x_17          (idct_x_r[17]),
        .x_18          (idct_x_r[18]),
        .x_19          (idct_x_r[19]),
        .x_20          (idct_x_r[20]),
        .x_21          (idct_x_r[21]),
        .x_22          (idct_x_r[22]),
        .x_23          (idct_x_r[23]),
        .x_24          (idct_x_r[24]),
        .x_25          (idct_x_r[25]),
        .x_26          (idct_x_r[26]),
        .x_27          (idct_x_r[27]),
        .x_28          (idct_x_r[28]),
        .x_29          (idct_x_r[29]),
        .x_30          (idct_x_r[30]),
        .x_31          (idct_x_r[31]),
        .x_32          (idct_x_r[32]),
        .x_33          (idct_x_r[33]),
        .x_34          (idct_x_r[34]),
        .x_35          (idct_x_r[35]),
        .x_36          (idct_x_r[36]),
        .x_37          (idct_x_r[37]),
        .x_38          (idct_x_r[38]),
        .x_39          (idct_x_r[39]),
        .x_40          (idct_x_r[40]),
        .x_41          (idct_x_r[41]),
        .x_42          (idct_x_r[42]),
        .x_43          (idct_x_r[43]),
        .x_44          (idct_x_r[44]),
        .x_45          (idct_x_r[45]),
        .x_46          (idct_x_r[46]),
        .x_47          (idct_x_r[47]),
        .x_48          (idct_x_r[48]),
        .x_49          (idct_x_r[49]),
        .x_50          (idct_x_r[50]),
        .x_51          (idct_x_r[51]),
        .x_52          (idct_x_r[52]),
        .x_53          (idct_x_r[53]),
        .x_54          (idct_x_r[54]),
        .x_55          (idct_x_r[55]),
        .x_56          (idct_x_r[56]),
        .x_57          (idct_x_r[57]),
        .x_58          (idct_x_r[58]),
        .x_59          (idct_x_r[59]),
        .x_60          (idct_x_r[60]),
        .x_61          (idct_x_r[61]),
        .x_62          (idct_x_r[62]),
        .x_63          (idct_x_r[63]),
        .out_req       (idct_out_req),
        .out_valid     (idct_out_valid),
        .out_last      (idct_out_last),
        .out_index_base(idct_out_index_base),
        .out_data_0    (idct_out_data_0),
        .out_data_1    (idct_out_data_1),
        .out_data_2    (idct_out_data_2),
        .out_data_3    (idct_out_data_3),
        .done          (idct_done),
        .busy          ()
    );

    always @(*) begin
        out_data_0 = col_block_r[out_row_base_r + 0];
        out_data_1 = col_block_r[out_row_base_r + 1];
        out_data_2 = col_block_r[out_row_base_r + 2];
        out_data_3 = col_block_r[out_row_base_r + 3];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r            <= S_IDLE;
            lfnst_tr_set_idx_r <= 2'd0;
            lfnst_idx_r        <= 2'd0;
            col_idx_r          <= 2'd0;
            out_row_base_r     <= 6'd0;
            done               <= 1'b0;
            for (idx = 0; idx < 16; idx = idx + 1) begin
                x_bar_in_r[idx]  <= {DATA_W{1'b0}};
                lfnst_vec_r[idx] <= {DATA_W{1'b0}};
                block_r[idx]     <= {DATA_W{1'b0}};
                col_block_r[idx] <= {IDCT_OUT_W{1'b0}};
            end
            for (idx = 0; idx < 64; idx = idx + 1) begin
                idct_x_r[idx] <= {DATA_W{1'b0}};
            end
        end else begin
            done <= 1'b0;

            case (state_r)
                S_IDLE: begin
                    out_row_base_r <= 6'd0;
                    if (start) begin
                        lfnst_tr_set_idx_r <= lfnst_tr_set_idx;
                        lfnst_idx_r        <= lfnst_idx;
                        x_bar_in_r[0]  <= x_bar_0;
                        x_bar_in_r[1]  <= x_bar_1;
                        x_bar_in_r[2]  <= x_bar_2;
                        x_bar_in_r[3]  <= x_bar_3;
                        x_bar_in_r[4]  <= x_bar_4;
                        x_bar_in_r[5]  <= x_bar_5;
                        x_bar_in_r[6]  <= x_bar_6;
                        x_bar_in_r[7]  <= x_bar_7;
                        x_bar_in_r[8]  <= x_bar_8;
                        x_bar_in_r[9]  <= x_bar_9;
                        x_bar_in_r[10] <= x_bar_10;
                        x_bar_in_r[11] <= x_bar_11;
                        x_bar_in_r[12] <= x_bar_12;
                        x_bar_in_r[13] <= x_bar_13;
                        x_bar_in_r[14] <= x_bar_14;
                        x_bar_in_r[15] <= x_bar_15;
                        state_r <= (lfnst_idx == 2'd0) ? S_PREP_BYPASS : S_START_LFNST;
                    end
                end

                S_PREP_BYPASS: begin
                    for (idx = 0; idx < 16; idx = idx + 1) begin
                        lfnst_vec_r[idx] <= x_bar_in_r[idx];
                    end
                    state_r <= S_REMAP_BLOCK;
                end

                S_START_LFNST: begin
                    if (lfnst_in_ready) begin
                        state_r <= S_RUN_LFNST;
                    end
                end

                S_RUN_LFNST: begin
                    if (lfnst_out_valid) begin
                        lfnst_vec_r[lfnst_out_row_base + 0] <= lfnst_out_data_0;
                        lfnst_vec_r[lfnst_out_row_base + 1] <= lfnst_out_data_1;
                        lfnst_vec_r[lfnst_out_row_base + 2] <= lfnst_out_data_2;
                        lfnst_vec_r[lfnst_out_row_base + 3] <= lfnst_out_data_3;
                    end
                    if (lfnst_done) begin
                        state_r <= S_REMAP_BLOCK;
                    end
                end

                S_REMAP_BLOCK: begin
                    block_r[0]  <= lfnst_vec_r[0];
                    block_r[4]  <= lfnst_vec_r[1];
                    block_r[1]  <= lfnst_vec_r[2];
                    block_r[8]  <= lfnst_vec_r[3];
                    block_r[5]  <= lfnst_vec_r[4];
                    block_r[2]  <= lfnst_vec_r[5];
                    block_r[12] <= lfnst_vec_r[6];
                    block_r[9]  <= lfnst_vec_r[7];
                    block_r[6]  <= lfnst_vec_r[8];
                    block_r[3]  <= lfnst_vec_r[9];
                    block_r[13] <= lfnst_vec_r[10];
                    block_r[10] <= lfnst_vec_r[11];
                    block_r[7]  <= lfnst_vec_r[12];
                    block_r[14] <= lfnst_vec_r[13];
                    block_r[11] <= lfnst_vec_r[14];
                    block_r[15] <= lfnst_vec_r[15];
                    col_idx_r <= 2'd0;
                    state_r <= S_PREP_IDCT;
                end

                S_PREP_IDCT: begin
                    for (idx = 0; idx < 64; idx = idx + 1) begin
                        idct_x_r[idx] <= {DATA_W{1'b0}};
                    end
                    idct_x_r[0] <= block_r[col_idx_r + 0];
                    idct_x_r[1] <= block_r[col_idx_r + 4];
                    idct_x_r[2] <= block_r[col_idx_r + 8];
                    idct_x_r[3] <= block_r[col_idx_r + 12];
                    state_r <= S_START_IDCT;
                end

                S_START_IDCT: begin
                    if (idct_in_ready) begin
                        state_r <= S_RUN_IDCT;
                    end
                end

                S_RUN_IDCT: begin
                    if (idct_out_valid) begin
                        col_block_r[col_idx_r + 0]  <= idct_out_data_0;
                        col_block_r[col_idx_r + 4]  <= idct_out_data_1;
                        col_block_r[col_idx_r + 8]  <= idct_out_data_2;
                        col_block_r[col_idx_r + 12] <= idct_out_data_3;
                    end
                    if (idct_done) begin
                        if (col_idx_r == 2'd3) begin
                            out_row_base_r <= 6'd0;
                            state_r <= S_STREAM_OUT;
                        end else begin
                            col_idx_r <= col_idx_r + 2'd1;
                            state_r <= S_PREP_IDCT;
                        end
                    end
                end

                S_STREAM_OUT: begin
                    if (out_req) begin
                        if (out_row_base_r == 6'd12) begin
                            out_row_base_r <= 6'd0;
                            done <= 1'b1;
                            state_r <= S_IDLE;
                        end else begin
                            out_row_base_r <= out_row_base_r + 6'd4;
                        end
                    end
                end

                default: begin
                    state_r <= S_IDLE;
                end
            endcase
        end
    end

endmodule
