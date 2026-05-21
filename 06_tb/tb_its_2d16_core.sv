module tb_its_2d16_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;
    localparam int TR_DCT8 = 2;
    localparam string FULL_MEM = "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d16_dct8_full_expected.memh";
    localparam string SPARSE_MEM = "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d16_dct8_sparse_expected.memh";

    reg clk;
    reg rst_n;
    reg start;
    reg [6:0] non_zero_cols;
    reg [6:0] non_zero_rows;
    reg out_req;
    reg signed [DATA_W-1:0] x_in [0:255];

    wire in_ready;
    wire out_valid;
    wire out_last;
    wire [7:0] out_index_base;
    wire signed [OUT_W-1:0] out_data_0;
    wire signed [OUT_W-1:0] out_data_1;
    wire signed [OUT_W-1:0] out_data_2;
    wire signed [OUT_W-1:0] out_data_3;
    wire done;
    wire busy;

    reg signed [OUT_W-1:0] expected_full [0:255];
    reg signed [OUT_W-1:0] expected_sparse [0:255];
    reg signed [OUT_W-1:0] hold_0;
    reg signed [OUT_W-1:0] hold_1;
    reg signed [OUT_W-1:0] hold_2;
    reg signed [OUT_W-1:0] hold_3;

    integer idx;
    integer group_idx;
    integer error_count;

    its_2d16_core #(
        .ROW_TR_TYPE(TR_DCT8),
        .COL_TR_TYPE(TR_DCT8),
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
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
            for (idx = 0; idx < 256; idx = idx + 1) begin
                x_in[idx] = idx + 1;
            end
        end
    endtask

    task automatic load_expected_mem;
        begin
            $readmemh(FULL_MEM, expected_full);
            $readmemh(SPARSE_MEM, expected_sparse);
        end
    endtask

    task automatic check_group(
        input string case_name,
        input integer base_idx,
        input reg signed [OUT_W-1:0] expected [0:255]
    );
        begin
            if (out_data_0 !== expected[base_idx + 0]) begin
                $display("ERR %s idx %0d got %0d exp %0d", case_name, base_idx + 0, out_data_0, expected[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data_1 !== expected[base_idx + 1]) begin
                $display("ERR %s idx %0d got %0d exp %0d", case_name, base_idx + 1, out_data_1, expected[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data_2 !== expected[base_idx + 2]) begin
                $display("ERR %s idx %0d got %0d exp %0d", case_name, base_idx + 2, out_data_2, expected[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data_3 !== expected[base_idx + 3]) begin
                $display("ERR %s idx %0d got %0d exp %0d", case_name, base_idx + 3, out_data_3, expected[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case(
        input string case_name,
        input [6:0] case_non_zero_cols,
        input [6:0] case_non_zero_rows,
        input reg signed [OUT_W-1:0] expected [0:255],
        input integer stall_group
    );
        begin
            wait (in_ready === 1'b1);
            @(posedge clk);
            non_zero_cols = case_non_zero_cols;
            non_zero_rows = case_non_zero_rows;
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            for (group_idx = 0; group_idx < 64; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end

                if (out_index_base !== (group_idx * 4)) begin
                    $display("ERR %s base got %0d exp %0d", case_name, out_index_base, group_idx * 4);
                    error_count = error_count + 1;
                end

                if (out_last !== (group_idx == 63)) begin
                    $display("ERR %s out_last at group %0d", case_name, group_idx);
                    error_count = error_count + 1;
                end

                check_group(case_name, group_idx * 4, expected);

                if (group_idx == stall_group) begin
                    hold_0 = out_data_0;
                    hold_1 = out_data_1;
                    hold_2 = out_data_2;
                    hold_3 = out_data_3;
                    out_req = 1'b0;
                    @(posedge clk);
                    #1;
                    if (out_valid !== 1'b1 ||
                        out_data_0 !== hold_0 ||
                        out_data_1 !== hold_1 ||
                        out_data_2 !== hold_2 ||
                        out_data_3 !== hold_3) begin
                        $display(
                            "ERR %s out hold mismatch during stall base=%0d d0=%0d/%0d d1=%0d/%0d d2=%0d/%0d d3=%0d/%0d",
                            case_name,
                            out_index_base,
                            out_data_0, hold_0,
                            out_data_1, hold_1,
                            out_data_2, hold_2,
                            out_data_3, hold_3
                        );
                        error_count = error_count + 1;
                    end
                    out_req = 1'b1;
                end
            end

            wait (done === 1'b1);
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        non_zero_cols = 7'd16;
        non_zero_rows = 7'd16;
        out_req = 1'b1;
        error_count = 0;

        load_demo_matrix();
        load_expected_mem();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case("full16_case", 7'd16, 7'd16, expected_full, -1);
        run_case("sparse8_case", 7'd8, 7'd8, expected_sparse, -1);

        if (error_count != 0) begin
            $display("FAIL tb_its_2d16_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_its_2d16_core");
        $finish;
    end

endmodule
