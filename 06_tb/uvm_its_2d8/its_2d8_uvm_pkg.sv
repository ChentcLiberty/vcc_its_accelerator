package its_2d8_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class its_2d8_case extends uvm_sequence_item;
        string case_name;
        int unsigned non_zero_cols;
        int unsigned non_zero_rows;
        int signed x_in[];
        int signed expected[];
        int stall_after_group;

        `uvm_object_utils_begin(its_2d8_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(non_zero_cols, UVM_DEFAULT)
            `uvm_field_int(non_zero_rows, UVM_DEFAULT)
            `uvm_field_array_int(x_in, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(stall_after_group, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_2d8_case");
            super.new(name);
            x_in = new[64];
            expected = new[64];
            stall_after_group = -1;
        endfunction

        function int unsigned group_count();
            return 16;
        endfunction
    endclass

    class its_2d8_output_sample extends uvm_sequence_item;
        int unsigned base_idx;
        bit          out_last;
        int signed   data[];

        `uvm_object_utils_begin(its_2d8_output_sample)
            `uvm_field_int(base_idx, UVM_DEFAULT)
            `uvm_field_int(out_last, UVM_DEFAULT)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_2d8_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class its_2d8_sequencer extends uvm_sequencer #(its_2d8_case);
        `uvm_component_utils(its_2d8_sequencer)
        function new(string name = "its_2d8_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    class its_2d8_driver extends uvm_driver #(its_2d8_case);
        `uvm_component_utils(its_2d8_driver)

        virtual its_2d8_if vif;
        uvm_analysis_port #(its_2d8_case) exp_ap;

        function new(string name = "its_2d8_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_2d8_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_2d8_driver failed to get virtual interface")
            end
        endfunction

        task init_signals();
            vif.start <= 1'b0;
            vif.non_zero_cols <= '0;
            vif.non_zero_rows <= '0;
            vif.out_req <= 1'b1;
            foreach (vif.x_in[i]) begin
                vif.x_in[i] <= '0;
            end
        endtask

        task run_phase(uvm_phase phase);
            its_2d8_case req;
            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(its_2d8_case req);
            its_2d8_case exp_case;
            int unsigned consumed_groups;
            bit stalled_once;
            bit done_seen;

            wait (vif.in_ready === 1'b1);
            @(posedge vif.clk);
            vif.non_zero_cols <= req.non_zero_cols[6:0];
            vif.non_zero_rows <= req.non_zero_rows[6:0];
            foreach (vif.x_in[i]) begin
                vif.x_in[i] <= req.x_in[i];
            end
            vif.out_req <= 1'b1;
            vif.start <= 1'b1;

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
            repeat (10) begin
                @(posedge vif.clk);
                if (vif.done) begin
                    done_seen = 1'b1;
                    break;
                end
            end
            if (!done_seen) begin
                `uvm_error("ITS_2D8_DRV", $sformatf("case %s did not raise done in time", req.case_name))
            end
        endtask
    endclass

    class its_2d8_monitor extends uvm_component;
        `uvm_component_utils(its_2d8_monitor)

        virtual its_2d8_if vif;
        uvm_analysis_port #(its_2d8_output_sample) ap;

        function new(string name = "its_2d8_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_2d8_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_2d8_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            its_2d8_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    sample = its_2d8_output_sample::type_id::create("sample");
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

    class its_2d8_scoreboard extends uvm_component;
        `uvm_component_utils(its_2d8_scoreboard)

        uvm_tlm_analysis_fifo #(its_2d8_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(its_2d8_output_sample) act_fifo;

        function new(string name = "its_2d8_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_2d8_case exp_case;
            its_2d8_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned expected_base;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("ITS_2D8_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    expected_base = group_idx * 4;

                    if (act_sample.base_idx != expected_base) begin
                        `uvm_error(
                            "ITS_2D8_SB",
                            $sformatf("case %s base_idx got %0d exp %0d",
                                      exp_case.case_name, act_sample.base_idx, expected_base)
                        )
                    end

                    if (act_sample.out_last != (group_idx == (exp_case.group_count() - 1))) begin
                        `uvm_error(
                            "ITS_2D8_SB",
                            $sformatf("case %s out_last mismatch at group %0d",
                                      exp_case.case_name, group_idx)
                        )
                    end

                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[expected_base + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "ITS_2D8_SB",
                                $sformatf(
                                    "case %s idx %0d got %0d exp %0d",
                                    exp_case.case_name,
                                    expected_base + lane_idx,
                                    act_sample.data[lane_idx],
                                    expected_value
                                )
                            )
                        end
                    end
                end
            end
        endtask
    endclass

    class its_2d8_agent extends uvm_component;
        `uvm_component_utils(its_2d8_agent)

        its_2d8_sequencer seqr;
        its_2d8_driver    drv;
        its_2d8_monitor   mon;

        function new(string name = "its_2d8_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = its_2d8_sequencer::type_id::create("seqr", this);
            drv  = its_2d8_driver::type_id::create("drv", this);
            mon  = its_2d8_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class its_2d8_env extends uvm_component;
        `uvm_component_utils(its_2d8_env)

        its_2d8_agent      agent;
        its_2d8_scoreboard sb;

        function new(string name = "its_2d8_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = its_2d8_agent::type_id::create("agent", this);
            sb    = its_2d8_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class its_2d8_smoke_seq extends uvm_sequence #(its_2d8_case);
        `uvm_object_utils(its_2d8_smoke_seq)

        function new(string name = "its_2d8_smoke_seq");
            super.new(name);
        endfunction

        function its_2d8_case build_case(
            string       case_name,
            int unsigned non_zero_cols,
            int unsigned non_zero_rows,
            int          stall_after_group,
            int signed   exp_vals[]
        );
            its_2d8_case item;

            item = its_2d8_case::type_id::create(case_name);
            item.case_name = case_name;
            item.non_zero_cols = non_zero_cols;
            item.non_zero_rows = non_zero_rows;
            item.stall_after_group = stall_after_group;
            foreach (item.x_in[i]) begin
                item.x_in[i] = i + 1;
                item.expected[i] = exp_vals[i];
            end
            return item;
        endfunction

        task send_case(its_2d8_case item);
            start_item(item);
            finish_item(item);
        endtask

        task body();
            int signed exp_full[64] = '{
                5505250, -2278955, 1237755, -834385, 513285, -341240, 286330, -105260,
                -5981010, 2069455, -1204031, 772957, -492737, 313344, -278074, 95812,
                2519210, -902163, 517699, -335593, 212413, -136288, 119602, -41748,
                -2050670, 715361, -414833, 266931, -169871, 108256, -95814, 33116,
                1104470, -392301, 225853, -146071, 92611, -59296, 52174, -18156,
                -863930, 300247, -174375, 112085, -71385, 45448, -40274, 13900,
                586910, -209957, 120533, -78111, 49451, -31720, 27846, -9716,
                -274170, 94951, -55223, 35461, -22601, 14376, -12754, 4396
            };
            int signed exp_sparse[64] = '{
                1409920, 513120, -317072, -334528, 105712, 256064, -42384, -220816,
                95500, 14560, -52744, -40446, 11624, 26468, -6778, -25572,
                -963634, -381968, 168300, 201101, -65340, -160886, 22919, 134486,
                -702336, -273392, 130408, 150976, -48728, -119520, 17672, 100648,
                198014, 76528, -37620, -43051, 13860, 33946, -5089, -28666,
                444728, 170976, -85888, -97484, 31328, 76648, -11604, -64856,
                -123178, -48736, 21652, 25785, -8372, -20606, 2947, 17238,
                -440322, -170864, 82588, 95125, -30668, -75174, 11183, 63382
            };

            send_case(build_case("full8_case", 8, 8, 4, exp_full));
            send_case(build_case("sparse4_case", 4, 4, -1, exp_sparse));
        endtask
    endclass

    class its_2d8_uvm_test extends uvm_test;
        `uvm_component_utils(its_2d8_uvm_test)

        its_2d8_env env;

        function new(string name = "its_2d8_uvm_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = its_2d8_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_2d8_smoke_seq seq;
            phase.raise_objection(this);
            seq = its_2d8_smoke_seq::type_id::create("seq");
            seq.start(env.agent.seqr);
            repeat (24) @(posedge env.agent.drv.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass

endpackage
