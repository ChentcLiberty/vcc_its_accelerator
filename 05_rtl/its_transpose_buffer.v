module its_transpose_buffer #(
    parameter integer DATA_W  = 32,
    parameter integer MAX_DIM = 64
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     clear,
    input  wire [6:0]               n_rows,
    input  wire [6:0]               n_cols,
    input  wire                     wr_valid,
    input  wire                     wr_transpose,
    input  wire [6:0]               wr_row_idx,
    input  wire [6:0]               wr_col_base,
    input  wire signed [DATA_W-1:0] wr_data_0,
    input  wire signed [DATA_W-1:0] wr_data_1,
    input  wire signed [DATA_W-1:0] wr_data_2,
    input  wire signed [DATA_W-1:0] wr_data_3,
    input  wire                     rd_transpose,
    input  wire [6:0]               rd_major_idx,
    input  wire [6:0]               rd_minor_base,
    output reg signed [DATA_W-1:0]  rd_data_0,
    output reg signed [DATA_W-1:0]  rd_data_1,
    output reg signed [DATA_W-1:0]  rd_data_2,
    output reg signed [DATA_W-1:0]  rd_data_3
);

    reg signed [DATA_W-1:0] mem_r [0:MAX_DIM*MAX_DIM-1];
    integer idx;

    always @(*) begin
        rd_data_0 = {DATA_W{1'b0}};
        rd_data_1 = {DATA_W{1'b0}};
        rd_data_2 = {DATA_W{1'b0}};
        rd_data_3 = {DATA_W{1'b0}};

        if (!rd_transpose) begin
            if ((rd_major_idx < n_rows) && (rd_minor_base + 7'd0 < n_cols)) begin
                rd_data_0 = mem_r[(rd_major_idx * MAX_DIM) + rd_minor_base + 7'd0];
            end
            if ((rd_major_idx < n_rows) && (rd_minor_base + 7'd1 < n_cols)) begin
                rd_data_1 = mem_r[(rd_major_idx * MAX_DIM) + rd_minor_base + 7'd1];
            end
            if ((rd_major_idx < n_rows) && (rd_minor_base + 7'd2 < n_cols)) begin
                rd_data_2 = mem_r[(rd_major_idx * MAX_DIM) + rd_minor_base + 7'd2];
            end
            if ((rd_major_idx < n_rows) && (rd_minor_base + 7'd3 < n_cols)) begin
                rd_data_3 = mem_r[(rd_major_idx * MAX_DIM) + rd_minor_base + 7'd3];
            end
        end else begin
            if ((rd_major_idx < n_cols) && (rd_minor_base + 7'd0 < n_rows)) begin
                rd_data_0 = mem_r[((rd_minor_base + 7'd0) * MAX_DIM) + rd_major_idx];
            end
            if ((rd_major_idx < n_cols) && (rd_minor_base + 7'd1 < n_rows)) begin
                rd_data_1 = mem_r[((rd_minor_base + 7'd1) * MAX_DIM) + rd_major_idx];
            end
            if ((rd_major_idx < n_cols) && (rd_minor_base + 7'd2 < n_rows)) begin
                rd_data_2 = mem_r[((rd_minor_base + 7'd2) * MAX_DIM) + rd_major_idx];
            end
            if ((rd_major_idx < n_cols) && (rd_minor_base + 7'd3 < n_rows)) begin
                rd_data_3 = mem_r[((rd_minor_base + 7'd3) * MAX_DIM) + rd_major_idx];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (idx = 0; idx < MAX_DIM*MAX_DIM; idx = idx + 1) begin
                mem_r[idx] <= {DATA_W{1'b0}};
            end
        end else begin
            if (clear) begin
                for (idx = 0; idx < MAX_DIM*MAX_DIM; idx = idx + 1) begin
                    mem_r[idx] <= {DATA_W{1'b0}};
                end
            end else if (wr_valid) begin
                if (!wr_transpose) begin
                    if ((wr_row_idx < n_rows) && (wr_col_base + 7'd0 < n_cols)) begin
                        mem_r[(wr_row_idx * MAX_DIM) + wr_col_base + 7'd0] <= wr_data_0;
                    end
                    if ((wr_row_idx < n_rows) && (wr_col_base + 7'd1 < n_cols)) begin
                        mem_r[(wr_row_idx * MAX_DIM) + wr_col_base + 7'd1] <= wr_data_1;
                    end
                    if ((wr_row_idx < n_rows) && (wr_col_base + 7'd2 < n_cols)) begin
                        mem_r[(wr_row_idx * MAX_DIM) + wr_col_base + 7'd2] <= wr_data_2;
                    end
                    if ((wr_row_idx < n_rows) && (wr_col_base + 7'd3 < n_cols)) begin
                        mem_r[(wr_row_idx * MAX_DIM) + wr_col_base + 7'd3] <= wr_data_3;
                    end
                end else begin
                    if ((wr_row_idx < n_cols) && (wr_col_base + 7'd0 < n_rows)) begin
                        mem_r[((wr_col_base + 7'd0) * MAX_DIM) + wr_row_idx] <= wr_data_0;
                    end
                    if ((wr_row_idx < n_cols) && (wr_col_base + 7'd1 < n_rows)) begin
                        mem_r[((wr_col_base + 7'd1) * MAX_DIM) + wr_row_idx] <= wr_data_1;
                    end
                    if ((wr_row_idx < n_cols) && (wr_col_base + 7'd2 < n_rows)) begin
                        mem_r[((wr_col_base + 7'd2) * MAX_DIM) + wr_row_idx] <= wr_data_2;
                    end
                    if ((wr_row_idx < n_cols) && (wr_col_base + 7'd3 < n_rows)) begin
                        mem_r[((wr_col_base + 7'd3) * MAX_DIM) + wr_row_idx] <= wr_data_3;
                    end
                end
            end
        end
    end

endmodule
