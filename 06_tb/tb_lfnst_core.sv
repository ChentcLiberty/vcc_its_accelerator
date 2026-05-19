`timescale 1ns/1ps

module tb_lfnst_core;

    localparam int DATA_W = 16;

    reg clk;
    reg rst_n;
    reg start;
    reg [6:0] tu_width;
    reg [6:0] tu_height;
    reg [1:0] lfnst_tr_set_idx;
    reg [1:0] lfnst_idx;
    reg out_req;

    reg signed [DATA_W-1:0] x_bar [0:15];

    wire in_ready;
    wire out_valid;
    wire out_last;
    wire [5:0] out_row_base;
    wire signed [DATA_W-1:0] out_data_0;
    wire signed [DATA_W-1:0] out_data_1;
    wire signed [DATA_W-1:0] out_data_2;
    wire signed [DATA_W-1:0] out_data_3;
    wire done;
    wire busy;

    integer sample_idx;
    integer group_idx;
    integer error_count;

    reg signed [DATA_W-1:0] expected16 [0:15];
    reg signed [DATA_W-1:0] expected48 [0:47];

    lfnst_core #(
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/lfnst_tables.memh")
    ) dut (
        .clk              (clk),
        .rst_n            (rst_n),
        .start            (start),
        .in_ready         (in_ready),
        .tu_width         (tu_width),
        .tu_height        (tu_height),
        .lfnst_tr_set_idx (lfnst_tr_set_idx),
        .lfnst_idx        (lfnst_idx),
        .x_bar_0          (x_bar[0]),
        .x_bar_1          (x_bar[1]),
        .x_bar_2          (x_bar[2]),
        .x_bar_3          (x_bar[3]),
        .x_bar_4          (x_bar[4]),
        .x_bar_5          (x_bar[5]),
        .x_bar_6          (x_bar[6]),
        .x_bar_7          (x_bar[7]),
        .x_bar_8          (x_bar[8]),
        .x_bar_9          (x_bar[9]),
        .x_bar_10         (x_bar[10]),
        .x_bar_11         (x_bar[11]),
        .x_bar_12         (x_bar[12]),
        .x_bar_13         (x_bar[13]),
        .x_bar_14         (x_bar[14]),
        .x_bar_15         (x_bar[15]),
        .out_req          (out_req),
        .out_valid        (out_valid),
        .out_last         (out_last),
        .out_row_base     (out_row_base),
        .out_data_0       (out_data_0),
        .out_data_1       (out_data_1),
        .out_data_2       (out_data_2),
        .out_data_3       (out_data_3),
        .done             (done),
        .busy             (busy)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic load_demo_xbar;
        begin
            x_bar[0]  = 16'sd1;
            x_bar[1]  = 16'sd5;
            x_bar[2]  = 16'sd2;
            x_bar[3]  = 16'sd9;
            x_bar[4]  = 16'sd6;
            x_bar[5]  = 16'sd3;
            x_bar[6]  = 16'sd13;
            x_bar[7]  = 16'sd10;
            x_bar[8]  = 16'sd7;
            x_bar[9]  = 16'sd4;
            x_bar[10] = 16'sd14;
            x_bar[11] = 16'sd11;
            x_bar[12] = 16'sd8;
            x_bar[13] = 16'sd15;
            x_bar[14] = 16'sd12;
            x_bar[15] = 16'sd16;
        end
    endtask

    task automatic init_expected_vectors;
        begin
            expected16[0]  = -16'sd2;
            expected16[1]  = -16'sd4;
            expected16[2]  =  16'sd1;
            expected16[3]  =  16'sd3;
            expected16[4]  =  16'sd2;
            expected16[5]  = -16'sd1;
            expected16[6]  =  16'sd10;
            expected16[7]  = -16'sd1;
            expected16[8]  = -16'sd5;
            expected16[9]  = -16'sd4;
            expected16[10] = -16'sd8;
            expected16[11] = -16'sd11;
            expected16[12] = -16'sd2;
            expected16[13] =  16'sd6;
            expected16[14] =  16'sd1;
            expected16[15] = -16'sd4;

            expected48[0]  =  16'sd2;
            expected48[1]  = -16'sd5;
            expected48[2]  =  16'sd0;
            expected48[3]  =  16'sd0;
            expected48[4]  =  16'sd1;
            expected48[5]  =  16'sd0;
            expected48[6]  =  16'sd2;
            expected48[7]  = -16'sd8;
            expected48[8]  = -16'sd10;
            expected48[9]  = -16'sd3;
            expected48[10] =  16'sd2;
            expected48[11] = -16'sd12;
            expected48[12] = -16'sd4;
            expected48[13] =  16'sd0;
            expected48[14] =  16'sd8;
            expected48[15] = -16'sd3;
            expected48[16] =  16'sd0;
            expected48[17] =  16'sd0;
            expected48[18] = -16'sd1;
            expected48[19] =  16'sd0;
            expected48[20] = -16'sd1;
            expected48[21] =  16'sd1;
            expected48[22] = -16'sd3;
            expected48[23] = -16'sd1;
            expected48[24] =  16'sd1;
            expected48[25] =  16'sd4;
            expected48[26] =  16'sd0;
            expected48[27] =  16'sd5;
            expected48[28] =  16'sd0;
            expected48[29] =  16'sd2;
            expected48[30] = -16'sd2;
            expected48[31] = -16'sd1;
            expected48[32] =  16'sd0;
            expected48[33] =  16'sd0;
            expected48[34] =  16'sd0;
            expected48[35] =  16'sd0;
            expected48[36] =  16'sd0;
            expected48[37] =  16'sd0;
            expected48[38] =  16'sd0;
            expected48[39] =  16'sd1;
            expected48[40] =  16'sd1;
            expected48[41] =  16'sd1;
            expected48[42] =  16'sd0;
            expected48[43] =  16'sd1;
            expected48[44] =  16'sd1;
            expected48[45] =  16'sd1;
            expected48[46] =  16'sd0;
            expected48[47] = -16'sd1;
        end
    endtask

    task automatic check_group_against_expected16(input integer base_idx);
        begin
            if (out_data_0 !== expected16[base_idx + 0]) begin
                $display("ERR16 row %0d got %0d exp %0d", base_idx + 0, out_data_0, expected16[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data_1 !== expected16[base_idx + 1]) begin
                $display("ERR16 row %0d got %0d exp %0d", base_idx + 1, out_data_1, expected16[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data_2 !== expected16[base_idx + 2]) begin
                $display("ERR16 row %0d got %0d exp %0d", base_idx + 2, out_data_2, expected16[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data_3 !== expected16[base_idx + 3]) begin
                $display("ERR16 row %0d got %0d exp %0d", base_idx + 3, out_data_3, expected16[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic check_group_against_expected48(input integer base_idx);
        begin
            if (out_data_0 !== expected48[base_idx + 0]) begin
                $display("ERR48 row %0d got %0d exp %0d", base_idx + 0, out_data_0, expected48[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data_1 !== expected48[base_idx + 1]) begin
                $display("ERR48 row %0d got %0d exp %0d", base_idx + 1, out_data_1, expected48[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data_2 !== expected48[base_idx + 2]) begin
                $display("ERR48 row %0d got %0d exp %0d", base_idx + 2, out_data_2, expected48[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data_3 !== expected48[base_idx + 3]) begin
                $display("ERR48 row %0d got %0d exp %0d", base_idx + 3, out_data_3, expected48[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case_16;
        begin
            @(posedge clk);
            tu_width         <= 7'd4;
            tu_height        <= 7'd4;
            lfnst_tr_set_idx <= 2'd0;
            lfnst_idx        <= 2'd1;
            start            <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < 4; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end
                if (out_row_base !== (group_idx * 4)) begin
                    $display("ERR16 row_base got %0d exp %0d", out_row_base, group_idx * 4);
                    error_count = error_count + 1;
                end
                check_group_against_expected16(group_idx * 4);
            end

            wait(done === 1'b1);
            @(posedge clk);
        end
    endtask

    task automatic run_case_48;
        begin
            @(posedge clk);
            tu_width         <= 7'd8;
            tu_height        <= 7'd16;
            lfnst_tr_set_idx <= 2'd0;
            lfnst_idx        <= 2'd1;
            start            <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < 12; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end
                if (out_row_base !== (group_idx * 4)) begin
                    $display("ERR48 row_base got %0d exp %0d", out_row_base, group_idx * 4);
                    error_count = error_count + 1;
                end
                check_group_against_expected48(group_idx * 4);
            end

            wait(done === 1'b1);
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n            = 1'b0;
        start            = 1'b0;
        tu_width         = 7'd0;
        tu_height        = 7'd0;
        lfnst_tr_set_idx = 2'd0;
        lfnst_idx        = 2'd0;
        out_req          = 1'b1;
        error_count      = 0;

        for (sample_idx = 0; sample_idx < 16; sample_idx = sample_idx + 1) begin
            x_bar[sample_idx] = '0;
        end

        init_expected_vectors();
        load_demo_xbar();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case_16();
        run_case_48();

        if (error_count == 0) begin
            $display("PASS tb_lfnst_core");
        end else begin
            $display("FAIL tb_lfnst_core errors=%0d", error_count);
        end
        $finish;
    end

endmodule
