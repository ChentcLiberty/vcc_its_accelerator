module tb_its_transpose_buffer;

    localparam int DATA_W  = 16;
    localparam int MAX_DIM = 8;

    reg clk;
    reg rst_n;
    reg clear;
    reg [6:0] n_rows;
    reg [6:0] n_cols;
    reg wr_valid;
    reg [6:0] wr_row_idx;
    reg [6:0] wr_col_base;
    reg signed [DATA_W-1:0] wr_data_0;
    reg signed [DATA_W-1:0] wr_data_1;
    reg signed [DATA_W-1:0] wr_data_2;
    reg signed [DATA_W-1:0] wr_data_3;
    reg rd_transpose;
    reg [6:0] rd_major_idx;
    reg [6:0] rd_minor_base;

    wire signed [DATA_W-1:0] rd_data_0;
    wire signed [DATA_W-1:0] rd_data_1;
    wire signed [DATA_W-1:0] rd_data_2;
    wire signed [DATA_W-1:0] rd_data_3;

    integer error_count;

    its_transpose_buffer #(
        .DATA_W(DATA_W),
        .MAX_DIM(MAX_DIM)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear),
        .n_rows(n_rows),
        .n_cols(n_cols),
        .wr_valid(wr_valid),
        .wr_row_idx(wr_row_idx),
        .wr_col_base(wr_col_base),
        .wr_data_0(wr_data_0),
        .wr_data_1(wr_data_1),
        .wr_data_2(wr_data_2),
        .wr_data_3(wr_data_3),
        .rd_transpose(rd_transpose),
        .rd_major_idx(rd_major_idx),
        .rd_minor_base(rd_minor_base),
        .rd_data_0(rd_data_0),
        .rd_data_1(rd_data_1),
        .rd_data_2(rd_data_2),
        .rd_data_3(rd_data_3)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic write_group(
        input [6:0] row_idx,
        input [6:0] col_base,
        input signed [DATA_W-1:0] d0,
        input signed [DATA_W-1:0] d1,
        input signed [DATA_W-1:0] d2,
        input signed [DATA_W-1:0] d3
    );
        begin
            @(posedge clk);
            wr_valid    <= 1'b1;
            wr_row_idx  <= row_idx;
            wr_col_base <= col_base;
            wr_data_0   <= d0;
            wr_data_1   <= d1;
            wr_data_2   <= d2;
            wr_data_3   <= d3;
            @(posedge clk);
            wr_valid    <= 1'b0;
            wr_row_idx  <= 7'd0;
            wr_col_base <= 7'd0;
            wr_data_0   <= '0;
            wr_data_1   <= '0;
            wr_data_2   <= '0;
            wr_data_3   <= '0;
        end
    endtask

    task automatic check_read(
        input bit transpose_mode,
        input [6:0] major_idx,
        input [6:0] minor_base,
        input signed [DATA_W-1:0] exp0,
        input signed [DATA_W-1:0] exp1,
        input signed [DATA_W-1:0] exp2,
        input signed [DATA_W-1:0] exp3,
        input [255:0] case_name
    );
        begin
            rd_transpose  = transpose_mode;
            rd_major_idx  = major_idx;
            rd_minor_base = minor_base;
            #1;

            if (rd_data_0 !== exp0) begin
                $display("ERR %0s d0 got %0d exp %0d", case_name, rd_data_0, exp0);
                error_count = error_count + 1;
            end
            if (rd_data_1 !== exp1) begin
                $display("ERR %0s d1 got %0d exp %0d", case_name, rd_data_1, exp1);
                error_count = error_count + 1;
            end
            if (rd_data_2 !== exp2) begin
                $display("ERR %0s d2 got %0d exp %0d", case_name, rd_data_2, exp2);
                error_count = error_count + 1;
            end
            if (rd_data_3 !== exp3) begin
                $display("ERR %0s d3 got %0d exp %0d", case_name, rd_data_3, exp3);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        rst_n        = 1'b0;
        clear        = 1'b0;
        n_rows       = 7'd4;
        n_cols       = 7'd8;
        wr_valid     = 1'b0;
        wr_row_idx   = 7'd0;
        wr_col_base  = 7'd0;
        wr_data_0    = '0;
        wr_data_1    = '0;
        wr_data_2    = '0;
        wr_data_3    = '0;
        rd_transpose = 1'b0;
        rd_major_idx = 7'd0;
        rd_minor_base = 7'd0;
        error_count  = 0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        clear <= 1'b1;
        @(posedge clk);
        clear <= 1'b0;

        write_group(7'd0, 7'd0, 16'sd0, 16'sd1, 16'sd2, 16'sd3);
        write_group(7'd0, 7'd4, 16'sd4, 16'sd5, 16'sd6, 16'sd7);
        write_group(7'd1, 7'd0, 16'sd10, 16'sd11, 16'sd12, 16'sd13);
        write_group(7'd1, 7'd4, 16'sd14, 16'sd15, 16'sd16, 16'sd17);
        write_group(7'd2, 7'd0, 16'sd20, 16'sd21, 16'sd22, 16'sd23);
        write_group(7'd2, 7'd4, 16'sd24, 16'sd25, 16'sd26, 16'sd27);
        write_group(7'd3, 7'd0, 16'sd30, 16'sd31, 16'sd32, 16'sd33);
        write_group(7'd3, 7'd4, 16'sd34, 16'sd35, 16'sd36, 16'sd37);

        check_read(1'b0, 7'd1, 7'd0, 16'sd10, 16'sd11, 16'sd12, 16'sd13, "row_read_1");
        check_read(1'b0, 7'd2, 7'd4, 16'sd24, 16'sd25, 16'sd26, 16'sd27, "row_read_2");
        check_read(1'b1, 7'd0, 7'd0, 16'sd0, 16'sd10, 16'sd20, 16'sd30, "transpose_col0");
        check_read(1'b1, 7'd3, 7'd0, 16'sd3, 16'sd13, 16'sd23, 16'sd33, "transpose_col3");
        check_read(1'b1, 7'd7, 7'd0, 16'sd7, 16'sd17, 16'sd27, 16'sd37, "transpose_col7");
        check_read(1'b1, 7'd7, 7'd4, 16'sd0, 16'sd0, 16'sd0, 16'sd0, "transpose_oob_minor");
        check_read(1'b0, 7'd3, 7'd8, 16'sd0, 16'sd0, 16'sd0, 16'sd0, "row_oob_minor");

        clear <= 1'b1;
        @(posedge clk);
        clear <= 1'b0;
        check_read(1'b0, 7'd1, 7'd0, 16'sd0, 16'sd0, 16'sd0, 16'sd0, "clear_row_read");

        if (error_count != 0) begin
            $display("FAIL tb_its_transpose_buffer errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_its_transpose_buffer");
        $finish;
    end

endmodule
