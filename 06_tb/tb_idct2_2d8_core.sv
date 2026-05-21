module tb_idct2_2d8_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;

    reg clk;
    reg rst_n;
    reg start;
    reg [6:0] non_zero_cols;
    reg [6:0] non_zero_rows;
    reg out_req;
    reg signed [DATA_W-1:0] x_in [0:63];

    wire in_ready;
    wire out_valid;
    wire out_last;
    wire [6:0] out_index_base;
    wire signed [OUT_W-1:0] out_data_0;
    wire signed [OUT_W-1:0] out_data_1;
    wire signed [OUT_W-1:0] out_data_2;
    wire signed [OUT_W-1:0] out_data_3;
    wire done;
    wire busy;

    reg signed [OUT_W-1:0] expected [0:63];

    reg signed [OUT_W-1:0] hold_0;
    reg signed [OUT_W-1:0] hold_1;
    reg signed [OUT_W-1:0] hold_2;
    reg signed [OUT_W-1:0] hold_3;

    integer idx;
    integer group_idx;
    integer error_count;

    idct2_2d8_core #(
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_ready(in_ready),
        .non_zero_cols(non_zero_cols),
        .non_zero_rows(non_zero_rows),
        .x_in(x_in),
        .out_req(out_req),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_index_base(out_index_base),
        .out_data_0(out_data_0),
        .out_data_1(out_data_1),
        .out_data_2(out_data_2),
        .out_data_3(out_data_3),
        .done(done),
        .busy(busy)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic load_demo_matrix;
        begin
            for (idx = 0; idx < 64; idx = idx + 1) begin
                x_in[idx] = idx + 1;
            end
        end
    endtask

    task automatic init_expected_flat;
        begin
            expected[0]  = 64'sd8519680;
            expected[1]  = -64'sd596992;
            expected[2]  = 64'sd0;
            expected[3]  = -64'sd60416;
            expected[4]  = 64'sd0;
            expected[5]  = -64'sd17408;
            expected[6]  = 64'sd0;
            expected[7]  = -64'sd6144;
            expected[8]  = -64'sd4775936;
            expected[9]  = 64'sd0;
            expected[10] = 64'sd0;
            expected[11] = 64'sd0;
            expected[12] = 64'sd0;
            expected[13] = 64'sd0;
            expected[14] = 64'sd0;
            expected[15] = 64'sd0;
            expected[16] = 64'sd0;
            expected[17] = 64'sd0;
            expected[18] = 64'sd0;
            expected[19] = 64'sd0;
            expected[20] = 64'sd0;
            expected[21] = 64'sd0;
            expected[22] = 64'sd0;
            expected[23] = 64'sd0;
            expected[24] = -64'sd483328;
            expected[25] = 64'sd0;
            expected[26] = 64'sd0;
            expected[27] = 64'sd0;
            expected[28] = 64'sd0;
            expected[29] = 64'sd0;
            expected[30] = 64'sd0;
            expected[31] = 64'sd0;
            expected[32] = 64'sd0;
            expected[33] = 64'sd0;
            expected[34] = 64'sd0;
            expected[35] = 64'sd0;
            expected[36] = 64'sd0;
            expected[37] = 64'sd0;
            expected[38] = 64'sd0;
            expected[39] = 64'sd0;
            expected[40] = -64'sd139264;
            expected[41] = 64'sd0;
            expected[42] = 64'sd0;
            expected[43] = 64'sd0;
            expected[44] = 64'sd0;
            expected[45] = 64'sd0;
            expected[46] = 64'sd0;
            expected[47] = 64'sd0;
            expected[48] = 64'sd0;
            expected[49] = 64'sd0;
            expected[50] = 64'sd0;
            expected[51] = 64'sd0;
            expected[52] = 64'sd0;
            expected[53] = 64'sd0;
            expected[54] = 64'sd0;
            expected[55] = 64'sd0;
            expected[56] = -64'sd49152;
            expected[57] = 64'sd0;
            expected[58] = 64'sd0;
            expected[59] = 64'sd0;
            expected[60] = 64'sd0;
            expected[61] = 64'sd0;
            expected[62] = 64'sd0;
            expected[63] = 64'sd0;
        end
    endtask

    task automatic check_group(input integer base_idx);
        begin
            if (out_data_0 !== expected[base_idx + 0]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data_1 !== expected[base_idx + 1]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data_2 !== expected[base_idx + 2]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data_3 !== expected[base_idx + 3]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case;
        begin
            @(posedge clk);
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < 16; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end

                if (out_index_base !== (group_idx * 4)) begin
                    $display("ERR base got %0d exp %0d", out_index_base, group_idx * 4);
                    error_count = error_count + 1;
                end

                if (out_last !== (group_idx == 15)) begin
                    $display("ERR out_last at group %0d", group_idx);
                    error_count = error_count + 1;
                end

                check_group(group_idx * 4);

                if (group_idx == 3) begin
                    hold_0 = out_data_0;
                    hold_1 = out_data_1;
                    hold_2 = out_data_2;
                    hold_3 = out_data_3;
                    out_req <= 1'b0;
                    @(posedge clk);
                    if (out_valid !== 1'b1 ||
                        out_data_0 !== hold_0 ||
                        out_data_1 !== hold_1 ||
                        out_data_2 !== hold_2 ||
                        out_data_3 !== hold_3) begin
                        $display("ERR out hold mismatch during stall");
                        error_count = error_count + 1;
                    end
                    out_req <= 1'b1;
                end
            end

            wait(done === 1'b1);
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        non_zero_cols = 7'd8;
        non_zero_rows = 7'd8;
        out_req = 1'b1;
        error_count = 0;

        load_demo_matrix();
        init_expected_flat();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case();

        if (error_count != 0) begin
            $display("FAIL tb_idct2_2d8_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_idct2_2d8_core");
        $finish;
    end

endmodule
