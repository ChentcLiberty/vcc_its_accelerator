module tb_idct2_2d16_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;

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

    idct2_2d16_core #(
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
            for (idx = 0; idx < 256; idx = idx + 1) begin
                x_in[idx] = idx + 1;
            end
        end
    endtask

    task automatic init_expected_full;
        begin
            expected_full = '{
                64'sd134742016, -64'sd4801536, 64'sd0, -64'sd525312, 64'sd0, -64'sd191488, 64'sd0, -64'sd74752, 64'sd0, -64'sd52224, 64'sd0, -64'sd15360, 64'sd0, 64'sd3072, 64'sd0, -64'sd31744,
                -64'sd76824576, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                -64'sd8404992, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                -64'sd3063808, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                -64'sd1196032, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                -64'sd835584, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                -64'sd245760, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd49152, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                -64'sd507904, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0
            };
        end
    endtask

    task automatic init_expected_sparse;
        begin
            expected_sparse = '{
                64'sd15859712, 64'sd14023680, -64'sd596992, -64'sd5250048, 64'sd0, 64'sd3155456, -64'sd60416, -64'sd2429440, 64'sd0, 64'sd1935360, -64'sd17408, -64'sd1754112, 64'sd0, 64'sd1552896, -64'sd6144, -64'sd1427968,
                64'sd10179840, 64'sd8935102, -64'sd537526, -64'sd3485854, 64'sd0, 64'sd2064367, -64'sd54398, -64'sd1602861, 64'sd0, 64'sd1270108, -64'sd15674, -64'sd1154962, 64'sd0, 64'sd1021837, -64'sd5532, -64'sd941385,
                -64'sd9551872, -64'sd8600416, 64'sd0, 64'sd2891680, 64'sd0, -64'sd1809632, 64'sd0, 64'sd1361888, 64'sd0, -64'sd1100704, 64'sd0, 64'sd988768, 64'sd0, -64'sd876832, 64'sd0, 64'sd802208,
                -64'sd11981568, -64'sd10710514, 64'sd180730, 64'sd3763090, 64'sd0, -64'sd2315593, 64'sd18290, 64'sd1759227, 64'sd0, -64'sd1413316, 64'sd5270, 64'sd1274302, 64'sd0, -64'sd1129243, 64'sd1860, 64'sd1035327,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd5417216, 64'sd4829062, -64'sd113102, -64'sd1724998, 64'sd0, 64'sd1054875, -64'sd11446, -64'sd804241, 64'sd0, 64'sd644668, -64'sd3298, -64'sd582058, 64'sd0, 64'sd515665, -64'sd1164, -64'sd473149,
                -64'sd966656, -64'sd870368, 64'sd0, 64'sd292640, 64'sd0, -64'sd183136, 64'sd0, 64'sd137824, 64'sd0, -64'sd111392, 64'sd0, 64'sd100064, 64'sd0, -64'sd88736, 64'sd0, 64'sd81184,
                -64'sd4952320, -64'sd4422486, 64'sd85118, 64'sd1563222, 64'sd0, -64'sd959731, 64'sd8614, 64'sd730073, 64'sd0, -64'sd586044, 64'sd2482, 64'sd528666, 64'sd0, -64'sd468441, 64'sd876, 64'sd429605,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd3552000, 64'sd3168658, -64'sd68794, -64'sd1127026, 64'sd0, 64'sd690313, -64'sd6962, -64'sd525819, 64'sd0, 64'sd421732, -64'sd2006, -64'sd380638, 64'sd0, 64'sd337243, -64'sd708, -64'sd309375,
                -64'sd278528, -64'sd250784, 64'sd0, 64'sd84320, 64'sd0, -64'sd52768, 64'sd0, 64'sd39712, 64'sd0, -64'sd32096, 64'sd0, 64'sd28832, 64'sd0, -64'sd25568, 64'sd0, 64'sd23392,
                -64'sd3439872, -64'sd3070702, 64'sd61798, 64'sd1087822, 64'sd0, -64'sd667303, 64'sd6254, 64'sd507861, 64'sd0, -64'sd407548, 64'sd1802, 64'sd367714, 64'sd0, -64'sd325813, 64'sd636, 64'sd298833,
                64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0, 64'sd0,
                64'sd3008256, 64'sd2685082, -64'sd54802, -64'sd951898, 64'sd0, 64'sd583765, -64'sd5546, -64'sd444351, 64'sd0, 64'sd356548, -64'sd1598, -64'sd321718, 64'sd0, 64'sd285055, -64'sd564, -64'sd261459,
                -64'sd98304, -64'sd88512, 64'sd0, 64'sd29760, 64'sd0, -64'sd18624, 64'sd0, 64'sd14016, 64'sd0, -64'sd11328, 64'sd0, 64'sd10176, 64'sd0, -64'sd9024, 64'sd0, 64'sd8256,
                -64'sd2867968, -64'sd2560770, 64'sd50138, 64'sd905922, 64'sd0, -64'sd556009, 64'sd5074, 64'sd423035, 64'sd0, -64'sd339540, 64'sd1462, 64'sd306318, 64'sd0, -64'sd271419, 64'sd516, 64'sd248927
            };
        end
    endtask

    task automatic check_group(
        input integer base_idx,
        input reg signed [OUT_W-1:0] expected [0:255]
    );
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

    task automatic run_case(
        input [6:0] case_non_zero_cols,
        input [6:0] case_non_zero_rows,
        input reg signed [OUT_W-1:0] expected [0:255],
        input integer stall_group
    );
        begin
            @(posedge clk);
            non_zero_cols <= case_non_zero_cols;
            non_zero_rows <= case_non_zero_rows;
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < 64; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end

                if (out_index_base !== (group_idx * 4)) begin
                    $display("ERR base got %0d exp %0d", out_index_base, group_idx * 4);
                    error_count = error_count + 1;
                end

                if (out_last !== (group_idx == 63)) begin
                    $display("ERR out_last at group %0d", group_idx);
                    error_count = error_count + 1;
                end

                check_group(group_idx * 4, expected);

                if (group_idx == stall_group) begin
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
        non_zero_cols = 7'd16;
        non_zero_rows = 7'd16;
        out_req = 1'b1;
        error_count = 0;

        load_demo_matrix();
        init_expected_full();
        init_expected_sparse();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case(7'd16, 7'd16, expected_full, 7);
        run_case(7'd8, 7'd8, expected_sparse, -1);

        if (error_count != 0) begin
            $display("FAIL tb_idct2_2d16_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_idct2_2d16_core");
        $finish;
    end

endmodule
