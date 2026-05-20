module tb_lfnst_idct2_2d4_uvm_top;

    import uvm_pkg::*;
    import lfnst_idct2_2d4_uvm_pkg::*;

    logic clk;

    lfnst_idct2_2d4_if tb_if(.clk(clk));

    lfnst_idct2_2d4_core #(
        .LFNST_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/lfnst_tables.memh"),
        .IDCT_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) dut (
        .clk(clk),
        .rst_n(tb_if.rst_n),
        .start(tb_if.start),
        .in_ready(tb_if.in_ready),
        .lfnst_tr_set_idx(tb_if.lfnst_tr_set_idx),
        .lfnst_idx(tb_if.lfnst_idx),
        .x_bar_0(tb_if.x_bar[0]),
        .x_bar_1(tb_if.x_bar[1]),
        .x_bar_2(tb_if.x_bar[2]),
        .x_bar_3(tb_if.x_bar[3]),
        .x_bar_4(tb_if.x_bar[4]),
        .x_bar_5(tb_if.x_bar[5]),
        .x_bar_6(tb_if.x_bar[6]),
        .x_bar_7(tb_if.x_bar[7]),
        .x_bar_8(tb_if.x_bar[8]),
        .x_bar_9(tb_if.x_bar[9]),
        .x_bar_10(tb_if.x_bar[10]),
        .x_bar_11(tb_if.x_bar[11]),
        .x_bar_12(tb_if.x_bar[12]),
        .x_bar_13(tb_if.x_bar[13]),
        .x_bar_14(tb_if.x_bar[14]),
        .x_bar_15(tb_if.x_bar[15]),
        .out_req(tb_if.out_req),
        .out_valid(tb_if.out_valid),
        .out_last(tb_if.out_last),
        .out_row_base(tb_if.out_row_base),
        .out_data_0(tb_if.out_data_0),
        .out_data_1(tb_if.out_data_1),
        .out_data_2(tb_if.out_data_2),
        .out_data_3(tb_if.out_data_3),
        .done(tb_if.done),
        .busy(tb_if.busy)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        tb_if.rst_n = 1'b0;
        tb_if.start = 1'b0;
        tb_if.lfnst_tr_set_idx = '0;
        tb_if.lfnst_idx = '0;
        tb_if.out_req = 1'b1;
        foreach (tb_if.x_bar[i]) begin
            tb_if.x_bar[i] = '0;
        end

        repeat (5) @(posedge clk);
        tb_if.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual lfnst_idct2_2d4_if)::set(null, "*", "vif", tb_if);
        run_test("lfnst_idct2_2d4_uvm_test");
    end

endmodule
