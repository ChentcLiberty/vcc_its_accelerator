module tb_idct2_2d16_uvm_top;

    import uvm_pkg::*;
    import idct2_2d16_uvm_pkg::*;

    logic clk;

    idct2_2d16_if tb_if(.clk(clk));

    idct2_2d16_core #(
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) dut (
        .clk(clk),
        .rst_n(tb_if.rst_n),
        .start(tb_if.start),
        .in_ready(tb_if.in_ready),
        .non_zero_cols(tb_if.non_zero_cols),
        .non_zero_rows(tb_if.non_zero_rows),
        .x_in(tb_if.x_in),
        .out_req(tb_if.out_req),
        .out_valid(tb_if.out_valid),
        .out_last(tb_if.out_last),
        .out_index_base(tb_if.out_index_base),
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
        tb_if.non_zero_cols = '0;
        tb_if.non_zero_rows = '0;
        tb_if.out_req = 1'b1;
        foreach (tb_if.x_in[i]) begin
            tb_if.x_in[i] = '0;
        end

        repeat (5) @(posedge clk);
        tb_if.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual idct2_2d16_if)::set(null, "*", "vif", tb_if);
        run_test("idct2_2d16_uvm_test");
    end

endmodule
