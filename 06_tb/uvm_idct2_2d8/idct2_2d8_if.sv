interface idct2_2d8_if #(
    parameter integer DATA_W = 16,
    parameter integer OUT_W  = 64
) (
    input logic clk
);

    logic rst_n;
    logic start;
    logic in_ready;
    logic [6:0] non_zero_cols;
    logic [6:0] non_zero_rows;
    logic signed [DATA_W-1:0] x_in [0:63];
    logic out_req;
    logic out_valid;
    logic out_last;
    logic [6:0] out_index_base;
    logic signed [OUT_W-1:0] out_data_0;
    logic signed [OUT_W-1:0] out_data_1;
    logic signed [OUT_W-1:0] out_data_2;
    logic signed [OUT_W-1:0] out_data_3;
    logic done;
    logic busy;

    property p_hold_when_blocked;
        @(posedge clk) disable iff (!rst_n)
            (out_valid && !out_req) |=> (
                out_valid &&
                $stable(out_index_base) &&
                $stable(out_last) &&
                $stable(out_data_0) &&
                $stable(out_data_1) &&
                $stable(out_data_2) &&
                $stable(out_data_3)
            );
    endproperty

    a_hold_when_blocked: assert property (p_hold_when_blocked)
        else $error("idct2_2d8_if: output changed while blocked by out_req=0");

endinterface
