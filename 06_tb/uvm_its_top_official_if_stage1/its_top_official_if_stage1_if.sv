interface its_top_official_if_stage1_if #(
    parameter integer DATA_W = 16
) (
    input logic clk
);

    logic rst_n;
    logic [21:0]        it_info;
    logic               it_info_vld;
    logic signed [15:0] it_data_in;
    logic [11:0]        it_data_addr;
    logic               it_data_in_vld;
    logic               it_data_end;
    logic               it_data_in_req;
    logic [39:0]        it_data_out;
    logic               it_data_out_vld;
    logic               it_data_out_req;
    logic               it_done;

    property p_no_vld_when_req_low;
        @(posedge clk) disable iff (!rst_n)
            (!it_data_out_req) |-> (!it_data_out_vld);
    endproperty

    a_no_vld_when_req_low: assert property (p_no_vld_when_req_low)
        else $error("its_top_official_if_stage1_if: top-level out_vld asserted while out_req=0");

endinterface
