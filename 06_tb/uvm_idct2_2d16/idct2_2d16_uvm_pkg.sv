package idct2_2d16_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class idct2_2d16_case extends uvm_sequence_item;
        string case_name;
        int unsigned non_zero_cols;
        int unsigned non_zero_rows;
        int signed x_in[];
        int signed expected[];
        int stall_after_group;

        `uvm_object_utils_begin(idct2_2d16_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(non_zero_cols, UVM_DEFAULT)
            `uvm_field_int(non_zero_rows, UVM_DEFAULT)
            `uvm_field_array_int(x_in, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(stall_after_group, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "idct2_2d16_case");
            super.new(name);
            x_in = new[256];
            expected = new[256];
            stall_after_group = -1;
        endfunction

        function int unsigned group_count();
            return 64;
        endfunction
    endclass

    class idct2_2d16_output_sample extends uvm_sequence_item;
        int unsigned base_idx;
        bit          out_last;
        int signed   data[];

        `uvm_object_utils_begin(idct2_2d16_output_sample)
            `uvm_field_int(base_idx, UVM_DEFAULT)
            `uvm_field_int(out_last, UVM_DEFAULT)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "idct2_2d16_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class idct2_2d16_sequencer extends uvm_sequencer #(idct2_2d16_case);
        `uvm_component_utils(idct2_2d16_sequencer)
        function new(string name = "idct2_2d16_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    class idct2_2d16_driver extends uvm_driver #(idct2_2d16_case);
        `uvm_component_utils(idct2_2d16_driver)

        virtual idct2_2d16_if vif;
        uvm_analysis_port #(idct2_2d16_case) exp_ap;

        function new(string name = "idct2_2d16_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual idct2_2d16_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "idct2_2d16_driver failed to get virtual interface")
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
            idct2_2d16_case req;
            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(idct2_2d16_case req);
            idct2_2d16_case exp_case;
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
            repeat (16) begin
                @(posedge vif.clk);
                if (vif.done) begin
                    done_seen = 1'b1;
                    break;
                end
            end
            if (!done_seen) begin
                `uvm_error("IDCT2_2D16_DRV", $sformatf("case %s did not raise done in time", req.case_name))
            end
        endtask
    endclass

    class idct2_2d16_monitor extends uvm_component;
        `uvm_component_utils(idct2_2d16_monitor)

        virtual idct2_2d16_if vif;
        uvm_analysis_port #(idct2_2d16_output_sample) ap;

        function new(string name = "idct2_2d16_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual idct2_2d16_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "idct2_2d16_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            idct2_2d16_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    sample = idct2_2d16_output_sample::type_id::create("sample");
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

    class idct2_2d16_scoreboard extends uvm_component;
        `uvm_component_utils(idct2_2d16_scoreboard)

        uvm_tlm_analysis_fifo #(idct2_2d16_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(idct2_2d16_output_sample) act_fifo;

        function new(string name = "idct2_2d16_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            idct2_2d16_case exp_case;
            idct2_2d16_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned expected_base;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("IDCT2_2D16_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    expected_base = group_idx * 4;

                    if (act_sample.base_idx != expected_base) begin
                        `uvm_error(
                            "IDCT2_2D16_SB",
                            $sformatf("case %s base_idx got %0d exp %0d",
                                      exp_case.case_name, act_sample.base_idx, expected_base)
                        )
                    end

                    if (act_sample.out_last != (group_idx == (exp_case.group_count() - 1))) begin
                        `uvm_error(
                            "IDCT2_2D16_SB",
                            $sformatf("case %s out_last mismatch at group %0d",
                                      exp_case.case_name, group_idx)
                        )
                    end

                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[expected_base + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "IDCT2_2D16_SB",
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

    class idct2_2d16_agent extends uvm_component;
        `uvm_component_utils(idct2_2d16_agent)

        idct2_2d16_sequencer seqr;
        idct2_2d16_driver    drv;
        idct2_2d16_monitor   mon;

        function new(string name = "idct2_2d16_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = idct2_2d16_sequencer::type_id::create("seqr", this);
            drv  = idct2_2d16_driver::type_id::create("drv", this);
            mon  = idct2_2d16_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class idct2_2d16_env extends uvm_component;
        `uvm_component_utils(idct2_2d16_env)

        idct2_2d16_agent      agent;
        idct2_2d16_scoreboard sb;

        function new(string name = "idct2_2d16_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = idct2_2d16_agent::type_id::create("agent", this);
            sb    = idct2_2d16_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class idct2_2d16_smoke_seq extends uvm_sequence #(idct2_2d16_case);
        `uvm_object_utils(idct2_2d16_smoke_seq)

        function new(string name = "idct2_2d16_smoke_seq");
            super.new(name);
        endfunction

        function idct2_2d16_case build_case(
            string       case_name,
            int unsigned non_zero_cols,
            int unsigned non_zero_rows,
            int          stall_after_group,
            int signed   exp_vals[]
        );
            idct2_2d16_case item;

            item = idct2_2d16_case::type_id::create(case_name);
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

        task send_case(idct2_2d16_case item);
            start_item(item);
            finish_item(item);
        endtask

        task body();
            int signed exp_full[256] = '{
                134742016, -4801536, 0, -525312, 0, -191488, 0, -74752, 0, -52224, 0, -15360, 0, 3072, 0, -31744,
                -76824576, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                -8404992, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                -3063808, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                -1196032, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                -835584, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                -245760, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                49152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                -507904, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            };
            int signed exp_sparse[256] = '{
                15859712, 14023680, -596992, -5250048, 0, 3155456, -60416, -2429440, 0, 1935360, -17408, -1754112, 0, 1552896, -6144, -1427968,
                10179840, 8935102, -537526, -3485854, 0, 2064367, -54398, -1602861, 0, 1270108, -15674, -1154962, 0, 1021837, -5532, -941385,
                -9551872, -8600416, 0, 2891680, 0, -1809632, 0, 1361888, 0, -1100704, 0, 988768, 0, -876832, 0, 802208,
                -11981568, -10710514, 180730, 3763090, 0, -2315593, 18290, 1759227, 0, -1413316, 5270, 1274302, 0, -1129243, 1860, 1035327,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                5417216, 4829062, -113102, -1724998, 0, 1054875, -11446, -804241, 0, 644668, -3298, -582058, 0, 515665, -1164, -473149,
                -966656, -870368, 0, 292640, 0, -183136, 0, 137824, 0, -111392, 0, 100064, 0, -88736, 0, 81184,
                -4952320, -4422486, 85118, 1563222, 0, -959731, 8614, 730073, 0, -586044, 2482, 528666, 0, -468441, 876, 429605,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                3552000, 3168658, -68794, -1127026, 0, 690313, -6962, -525819, 0, 421732, -2006, -380638, 0, 337243, -708, -309375,
                -278528, -250784, 0, 84320, 0, -52768, 0, 39712, 0, -32096, 0, 28832, 0, -25568, 0, 23392,
                -3439872, -3070702, 61798, 1087822, 0, -667303, 6254, 507861, 0, -407548, 1802, 367714, 0, -325813, 636, 298833,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                3008256, 2685082, -54802, -951898, 0, 583765, -5546, -444351, 0, 356548, -1598, -321718, 0, 285055, -564, -261459,
                -98304, -88512, 0, 29760, 0, -18624, 0, 14016, 0, -11328, 0, 10176, 0, -9024, 0, 8256,
                -2867968, -2560770, 50138, 905922, 0, -556009, 5074, 423035, 0, -339540, 1462, 306318, 0, -271419, 516, 248927
            };

            send_case(build_case("full16_case", 16, 16, 8, exp_full));
            send_case(build_case("sparse8_case", 8, 8, -1, exp_sparse));
        endtask
    endclass

    class idct2_2d16_uvm_test extends uvm_test;
        `uvm_component_utils(idct2_2d16_uvm_test)

        idct2_2d16_env env;

        function new(string name = "idct2_2d16_uvm_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = idct2_2d16_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            idct2_2d16_smoke_seq seq;
            phase.raise_objection(this);
            seq = idct2_2d16_smoke_seq::type_id::create("seq");
            seq.start(env.agent.seqr);
            repeat (32) @(posedge env.agent.drv.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass

endpackage
