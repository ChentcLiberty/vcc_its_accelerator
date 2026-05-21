package its_1d_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int unsigned TR_DCT2 = 0;
    localparam int unsigned TR_DST7 = 1;
    localparam int unsigned TR_DCT8 = 2;

    class its_1d_case extends uvm_sequence_item;
        string case_name;
        int unsigned tr_type;
        int unsigned n_tbs;
        int unsigned non_zero_size;
        int signed x_vec[];
        int signed expected[];
        int stall_after_group;

        `uvm_object_utils_begin(its_1d_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(tr_type, UVM_DEFAULT)
            `uvm_field_int(n_tbs, UVM_DEFAULT)
            `uvm_field_int(non_zero_size, UVM_DEFAULT)
            `uvm_field_array_int(x_vec, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(stall_after_group, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_1d_case");
            super.new(name);
            x_vec = new[64];
            expected = new[0];
            stall_after_group = -1;
        endfunction

        function int unsigned group_count();
            return (n_tbs >> 2);
        endfunction
    endclass

    class its_1d_output_sample extends uvm_sequence_item;
        int unsigned base_idx;
        bit          out_last;
        int signed   data[];

        `uvm_object_utils_begin(its_1d_output_sample)
            `uvm_field_int(base_idx, UVM_DEFAULT)
            `uvm_field_int(out_last, UVM_DEFAULT)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_1d_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class its_1d_sequencer extends uvm_sequencer #(its_1d_case);
        `uvm_component_utils(its_1d_sequencer)
        function new(string name = "its_1d_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    class its_1d_driver extends uvm_driver #(its_1d_case);
        `uvm_component_utils(its_1d_driver)

        virtual its_1d_if vif;
        uvm_analysis_port #(its_1d_case) exp_ap;

        function new(string name = "its_1d_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_1d_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_1d_driver failed to get virtual interface")
            end
        endfunction

        task init_signals();
            vif.start         <= 1'b0;
            vif.tr_type       <= '0;
            vif.n_tbs         <= '0;
            vif.non_zero_size <= '0;
            vif.out_req       <= 1'b1;
            foreach (vif.x_vec[i]) begin
                vif.x_vec[i] <= '0;
            end
        endtask

        task run_phase(uvm_phase phase);
            its_1d_case req;
            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(its_1d_case req);
            its_1d_case exp_case;
            int unsigned consumed_groups;
            bit stalled_once;
            bit done_seen;

            wait (vif.in_ready === 1'b1);
            @(posedge vif.clk);
            vif.tr_type       <= req.tr_type[1:0];
            vif.n_tbs         <= req.n_tbs[6:0];
            vif.non_zero_size <= req.non_zero_size[6:0];
            foreach (vif.x_vec[i]) begin
                vif.x_vec[i] <= req.x_vec[i];
            end
            vif.out_req <= 1'b1;
            vif.start   <= 1'b1;

            $cast(exp_case, req.clone());
            exp_ap.write(exp_case);

            @(posedge vif.clk);
            vif.start <= 1'b0;

            consumed_groups = 0;
            stalled_once = 1'b0;
            while (consumed_groups < req.group_count()) begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    consumed_groups++;
                    if (!stalled_once && (req.stall_after_group >= 0) &&
                        (consumed_groups == req.stall_after_group)) begin
                        vif.out_req <= 1'b0;
                        @(posedge vif.clk);
                        vif.out_req <= 1'b1;
                        stalled_once = 1'b1;
                    end
                end
            end

            done_seen = 1'b0;
            repeat (8) begin
                @(posedge vif.clk);
                if (vif.done) begin
                    done_seen = 1'b1;
                    break;
                end
            end
            if (!done_seen) begin
                `uvm_error("ITS1D_DRV", $sformatf("case %s did not raise done in time", req.case_name))
            end
        endtask
    endclass

    class its_1d_monitor extends uvm_component;
        `uvm_component_utils(its_1d_monitor)

        virtual its_1d_if vif;
        uvm_analysis_port #(its_1d_output_sample) ap;

        function new(string name = "its_1d_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_1d_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_1d_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            its_1d_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    sample = its_1d_output_sample::type_id::create("sample");
                    sample.base_idx = vif.out_index_base;
                    sample.out_last = vif.out_last;
                    sample.data[0] = vif.out_data_0;
                    sample.data[1] = vif.out_data_1;
                    sample.data[2] = vif.out_data_2;
                    sample.data[3] = vif.out_data_3;
                    ap.write(sample);
                end
            end
        endtask
    endclass

    class its_1d_scoreboard extends uvm_component;
        `uvm_component_utils(its_1d_scoreboard)

        uvm_tlm_analysis_fifo #(its_1d_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(its_1d_output_sample) act_fifo;

        function new(string name = "its_1d_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_1d_case exp_case;
            its_1d_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned expected_base;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("ITS1D_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    expected_base = group_idx * 4;

                    if (act_sample.base_idx != expected_base) begin
                        `uvm_error(
                            "ITS1D_SB",
                            $sformatf("case %s base_idx got %0d exp %0d",
                                      exp_case.case_name, act_sample.base_idx, expected_base)
                        )
                    end

                    if (act_sample.out_last != (group_idx == (exp_case.group_count() - 1))) begin
                        `uvm_error(
                            "ITS1D_SB",
                            $sformatf("case %s out_last mismatch at group %0d",
                                      exp_case.case_name, group_idx)
                        )
                    end

                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[expected_base + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "ITS1D_SB",
                                $sformatf("case %s idx %0d got %0d exp %0d",
                                          exp_case.case_name,
                                          expected_base + lane_idx,
                                          act_sample.data[lane_idx],
                                          expected_value)
                            )
                        end
                    end
                end
            end
        endtask
    endclass

    class its_1d_agent extends uvm_component;
        `uvm_component_utils(its_1d_agent)

        its_1d_sequencer seqr;
        its_1d_driver    drv;
        its_1d_monitor   mon;

        function new(string name = "its_1d_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = its_1d_sequencer::type_id::create("seqr", this);
            drv  = its_1d_driver::type_id::create("drv", this);
            mon  = its_1d_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class its_1d_env extends uvm_component;
        `uvm_component_utils(its_1d_env)

        its_1d_agent      agent;
        its_1d_scoreboard sb;

        function new(string name = "its_1d_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = its_1d_agent::type_id::create("agent", this);
            sb    = its_1d_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class its_1d_smoke_seq extends uvm_sequence #(its_1d_case);
        `uvm_object_utils(its_1d_smoke_seq)

        function new(string name = "its_1d_smoke_seq");
            super.new(name);
        endfunction

        function its_1d_case build_case(
            string       case_name,
            int unsigned tr_type,
            int unsigned n_tbs,
            int unsigned non_zero_size,
            int          stall_after_group,
            int signed   exp_vals[]
        );
            its_1d_case item;
            item = its_1d_case::type_id::create(case_name);
            item.case_name = case_name;
            item.tr_type = tr_type;
            item.n_tbs = n_tbs;
            item.non_zero_size = non_zero_size;
            item.stall_after_group = stall_after_group;
            foreach (item.x_vec[i]) begin
                item.x_vec[i] = i + 1;
            end
            item.expected = new[n_tbs];
            foreach (item.expected[i]) begin
                item.expected[i] = exp_vals[i];
            end
            return item;
        endfunction

        task send_case(its_1d_case item);
            start_item(item);
            finish_item(item);
        endtask

        task body();
            int signed exp_dct2_8_sparse4[] = '{
                640, 461, -285, -428, 0, 226, -25, -213
            };
            int signed exp_dct8_8_full[] = '{
                1710, -1657, 713, -571, 311, -240, 166, -76
            };
            int signed exp_dst7_8_full[] = '{
                2565, -298, 106, -58, 22, -33, 23, -13
            };
            int signed exp_dct8_32_full[] = '{
                22898, -24679, 10675, -9456, 6173, -5804, 4331, -4064,
                3311, -3077, 2565, -2488, 2117, -1934, 1795, -1712,
                1393, -1347, 1238, -1077, 957, -885, 776, -697,
                606, -531, 469, -397, 317, -268, 143, -94
            };
            int signed exp_dst7_32_full[] = '{
                38416, -4285, 1535, -744, 427, -260, 223, -170,
                121, -41, 9, -46, 61, -86, 53, 4,
                -7, -27, 82, -21, -33, -27, 16, -37,
                54, -3, -7, -1, 79, -4, 55, 38
            };

            send_case(build_case("dct2_8_sparse4", TR_DCT2, 8, 4, -1, exp_dct2_8_sparse4));
            send_case(build_case("dct8_8_full", TR_DCT8, 8, 8, -1, exp_dct8_8_full));
            send_case(build_case("dst7_8_full", TR_DST7, 8, 8, 1, exp_dst7_8_full));
            send_case(build_case("dct8_32_full", TR_DCT8, 32, 32, -1, exp_dct8_32_full));
            send_case(build_case("dst7_32_full", TR_DST7, 32, 32, -1, exp_dst7_32_full));
        endtask
    endclass

    class its_1d_uvm_test extends uvm_test;
        `uvm_component_utils(its_1d_uvm_test)

        its_1d_env env;

        function new(string name = "its_1d_uvm_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = its_1d_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_1d_smoke_seq seq;
            phase.raise_objection(this);
            seq = its_1d_smoke_seq::type_id::create("seq");
            seq.start(env.agent.seqr);
            repeat (24) @(posedge env.agent.drv.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass

endpackage
