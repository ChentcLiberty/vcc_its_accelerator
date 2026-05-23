module tb_its_2d_large_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;

    localparam string MEM_32_DCT2 =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d32_dct2_full_expected.memh";
    localparam string MEM_64_DCT2 =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d64_dct2_full_expected.memh";

    reg clk;
    reg rst_n;

    reg start32;
    wire in_ready32;
    reg [6:0] non_zero_cols32;
    reg [6:0] non_zero_rows32;
    reg signed [DATA_W-1:0] x32_in [0:4095];
    reg out_req32;
    wire out_valid32;
    wire out_last32;
    wire [11:0] out_index_base32;
    wire signed [OUT_W-1:0] out_data32_0;
    wire signed [OUT_W-1:0] out_data32_1;
    wire signed [OUT_W-1:0] out_data32_2;
    wire signed [OUT_W-1:0] out_data32_3;
    wire done32;

    reg start64;
    wire in_ready64;
    reg [6:0] non_zero_cols64;
    reg [6:0] non_zero_rows64;
    reg signed [DATA_W-1:0] x64_in [0:4095];
    reg out_req64;
    wire out_valid64;
    wire out_last64;
    wire [11:0] out_index_base64;
    wire signed [OUT_W-1:0] out_data64_0;
    wire signed [OUT_W-1:0] out_data64_1;
    wire signed [OUT_W-1:0] out_data64_2;
    wire signed [OUT_W-1:0] out_data64_3;
    wire done64;

    reg signed [OUT_W-1:0] expected32 [0:1023];
    reg signed [OUT_W-1:0] expected64 [0:4095];

    integer idx;
    integer error_count;

    its_2d_large_core #(
        .N_TBS(32),
        .ROW_TR_TYPE(0),
        .COL_TR_TYPE(0),
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) dut32 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start32),
        .in_ready(in_ready32),
        .non_zero_cols(non_zero_cols32),
        .non_zero_rows(non_zero_rows32),
        .x_in(x32_in),
        .out_req(out_req32),
        .out_valid(out_valid32),
        .out_last(out_last32),
        .out_index_base(out_index_base32),
        .out_data_0(out_data32_0),
        .out_data_1(out_data32_1),
        .out_data_2(out_data32_2),
        .out_data_3(out_data32_3),
        .done(done32),
        .busy()
    );

    its_2d_large_core #(
        .N_TBS(64),
        .ROW_TR_TYPE(0),
        .COL_TR_TYPE(0),
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) dut64 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start64),
        .in_ready(in_ready64),
        .non_zero_cols(non_zero_cols64),
        .non_zero_rows(non_zero_rows64),
        .x_in(x64_in),
        .out_req(out_req64),
        .out_valid(out_valid64),
        .out_last(out_last64),
        .out_index_base(out_index_base64),
        .out_data_0(out_data64_0),
        .out_data_1(out_data64_1),
        .out_data_2(out_data64_2),
        .out_data_3(out_data64_3),
        .done(done64),
        .busy()
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic clear_inputs;
        begin
            start32 = 1'b0;
            start64 = 1'b0;
            out_req32 = 1'b1;
            out_req64 = 1'b1;
            non_zero_cols32 = 7'd32;
            non_zero_rows32 = 7'd32;
            non_zero_cols64 = 7'd64;
            non_zero_rows64 = 7'd64;
        end
    endtask

    task automatic load_demo_inputs;
        begin
            for (idx = 0; idx < 4096; idx = idx + 1) begin
                x32_in[idx] = '0;
                x64_in[idx] = idx + 1;
            end
            for (idx = 0; idx < 1024; idx = idx + 1) begin
                x32_in[idx] = idx + 1;
            end
        end
    endtask

    task automatic compare_group32(input int group_idx);
        int base_idx;
        begin
            base_idx = group_idx * 4;
            if (out_index_base32 !== base_idx[11:0]) begin
                $display("ERR 32x32 out_index_base group=%0d got=%0d exp=%0d",
                         group_idx, out_index_base32, base_idx);
                error_count = error_count + 1;
            end
            if (out_data32_0 !== expected32[base_idx + 0]) begin
                $display("ERR 32x32 idx=%0d got=%0d exp=%0d",
                         base_idx + 0, out_data32_0, expected32[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data32_1 !== expected32[base_idx + 1]) begin
                $display("ERR 32x32 idx=%0d got=%0d exp=%0d",
                         base_idx + 1, out_data32_1, expected32[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data32_2 !== expected32[base_idx + 2]) begin
                $display("ERR 32x32 idx=%0d got=%0d exp=%0d",
                         base_idx + 2, out_data32_2, expected32[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data32_3 !== expected32[base_idx + 3]) begin
                $display("ERR 32x32 idx=%0d got=%0d exp=%0d",
                         base_idx + 3, out_data32_3, expected32[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic compare_group64(input int group_idx);
        int base_idx;
        begin
            base_idx = group_idx * 4;
            if (out_index_base64 !== base_idx[11:0]) begin
                $display("ERR 64x64 out_index_base group=%0d got=%0d exp=%0d",
                         group_idx, out_index_base64, base_idx);
                error_count = error_count + 1;
            end
            if (out_data64_0 !== expected64[base_idx + 0]) begin
                $display("ERR 64x64 idx=%0d got=%0d exp=%0d",
                         base_idx + 0, out_data64_0, expected64[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data64_1 !== expected64[base_idx + 1]) begin
                $display("ERR 64x64 idx=%0d got=%0d exp=%0d",
                         base_idx + 1, out_data64_1, expected64[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data64_2 !== expected64[base_idx + 2]) begin
                $display("ERR 64x64 idx=%0d got=%0d exp=%0d",
                         base_idx + 2, out_data64_2, expected64[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data64_3 !== expected64[base_idx + 3]) begin
                $display("ERR 64x64 idx=%0d got=%0d exp=%0d",
                         base_idx + 3, out_data64_3, expected64[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case_32x32_dct2;
        int accepted_groups;
        reg [11:0] hold_index;
        reg signed [OUT_W-1:0] hold0;
        reg signed [OUT_W-1:0] hold1;
        reg signed [OUT_W-1:0] hold2;
        reg signed [OUT_W-1:0] hold3;
        begin
            while (in_ready32 !== 1'b1) @(posedge clk);
            @(posedge clk);
            start32 <= 1'b1;
            @(posedge clk);
            start32 <= 1'b0;

            accepted_groups = 0;
            while (accepted_groups < 256) begin
                @(posedge clk);
                if (out_valid32 && out_req32) begin
                    compare_group32(accepted_groups);
                    if (accepted_groups == 31) begin
                        out_req32 <= 1'b0;
                        @(posedge clk);
                        if (out_valid32 !== 1'b1) begin
                            $display("ERR 32x32 out_valid deasserted during stall");
                            error_count = error_count + 1;
                        end
                        hold_index = out_index_base32;
                        hold0 = out_data32_0;
                        hold1 = out_data32_1;
                        hold2 = out_data32_2;
                        hold3 = out_data32_3;
                        @(posedge clk);
                        if (out_valid32 !== 1'b1) begin
                            $display("ERR 32x32 out_valid deasserted during second stall cycle");
                            error_count = error_count + 1;
                        end
                        if ((out_index_base32 !== hold_index) ||
                            (out_data32_0 !== hold0) ||
                            (out_data32_1 !== hold1) ||
                            (out_data32_2 !== hold2) ||
                            (out_data32_3 !== hold3)) begin
                            $display("ERR 32x32 output changed while stalled");
                            error_count = error_count + 1;
                        end
                        out_req32 <= 1'b1;
                    end
                    accepted_groups = accepted_groups + 1;
                end
            end

            wait (done32 === 1'b1);
            @(posedge clk);
        end
    endtask

    task automatic run_case_64x64_dct2;
        int accepted_groups;
        reg [11:0] hold_index;
        reg signed [OUT_W-1:0] hold0;
        reg signed [OUT_W-1:0] hold1;
        reg signed [OUT_W-1:0] hold2;
        reg signed [OUT_W-1:0] hold3;
        begin
            while (in_ready64 !== 1'b1) @(posedge clk);
            @(posedge clk);
            start64 <= 1'b1;
            @(posedge clk);
            start64 <= 1'b0;

            accepted_groups = 0;
            while (accepted_groups < 1024) begin
                @(posedge clk);
                if (out_valid64 && out_req64) begin
                    compare_group64(accepted_groups);
                    if ((accepted_groups == 63) || (accepted_groups == 511)) begin
                        out_req64 <= 1'b0;
                        @(posedge clk);
                        if (out_valid64 !== 1'b1) begin
                            $display("ERR 64x64 out_valid deasserted during stall");
                            error_count = error_count + 1;
                        end
                        hold_index = out_index_base64;
                        hold0 = out_data64_0;
                        hold1 = out_data64_1;
                        hold2 = out_data64_2;
                        hold3 = out_data64_3;
                        @(posedge clk);
                        if (out_valid64 !== 1'b1) begin
                            $display("ERR 64x64 out_valid deasserted during second stall cycle");
                            error_count = error_count + 1;
                        end
                        if ((out_index_base64 !== hold_index) ||
                            (out_data64_0 !== hold0) ||
                            (out_data64_1 !== hold1) ||
                            (out_data64_2 !== hold2) ||
                            (out_data64_3 !== hold3)) begin
                            $display("ERR 64x64 output changed while stalled");
                            error_count = error_count + 1;
                        end
                        out_req64 <= 1'b1;
                    end
                    accepted_groups = accepted_groups + 1;
                end
            end

            wait (done64 === 1'b1);
            @(posedge clk);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        error_count = 0;
        clear_inputs();
        load_demo_inputs();
        $readmemh(MEM_32_DCT2, expected32);
        $readmemh(MEM_64_DCT2, expected64);

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case_32x32_dct2();
        run_case_64x64_dct2();

        if (error_count != 0) begin
            $display("FAIL tb_its_2d_large_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_its_2d_large_core");
        $finish;
    end

endmodule
