`timescale 1ns / 1ps

module tb_Reg_TOP;

    reg clk;
    reg reset;

    reg [31:0] instr_in;
    reg [31:0] data_in;
    reg [31:0] alu_out;
    reg [21:0] ctrl_in;

    wire [31:0] rs_data_out;
    wire [31:0] rt_data_out;
    wire [25:0] jta_out;
    wire [31:0] imm_out;
    wire [5:0]  op_out;
    wire [5:0]  fn_out;

    // Instantiate the DUT
    Reg_TOP uut (
        .clk(clk),
        .reset(reset),
        .instr_in(instr_in),
        .data_in(data_in),
        .alu_out(alu_out),
        .ctrl_in(ctrl_in),
        .rs_data_out(rs_data_out),
        .rt_data_out(rt_data_out),
        .jta_out(jta_out),
        .imm_out(imm_out),
        .op_out(op_out),
        .fn_out(fn_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns period

    initial begin
        // Simulation dump
        $dumpfile("tb_Reg_TOP.vcd");
        $dumpvars(0, tb_Reg_TOP);

        // Initial reset
        reset = 1;
        instr_in = 32'd0;
        data_in = 32'd0;
        alu_out = 32'd0;
        ctrl_in = 22'd0;

        #20;
        reset = 0;

        // Test 1: Load instruction (opcode 35 = 100011)
        instr_in = 32'h8C010000;  // lw $1, 0($0)
        ctrl_in = 22'b0000000000100000; // IRWrite=1, 나머지 0 (예시)
        #10;  // 1 clock

        ctrl_in[14] = 0;  // IRWrite 끄고 다음 instruction 준비
        instr_in = 32'h8C020004;  // lw $2, 4($0)
        #10;

        instr_in = 32'h00242825;  // add $5, $1, $4
        ctrl_in[14] = 1;  // IRWrite 다시 켬
        #10;

        instr_in = 32'h20060007;  // addi $6, $0, 7
        #10;

        // 끝까지 시뮬레이션
        #100;
        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        $display("Time=%0t | instr=%h | op=%b | fn=%b | rs_data=%d | rt_data=%d | imm=%d | jta=%h",
                 $time, instr_in, op_out, fn_out, rs_data_out, rt_data_out, imm_out, jta_out);
    end

endmodule
