module risc_v_tb(rst,clk,pc,data_mem,inst_mem,reg_mem);
input logic rst;
input logic clk;
output logic [31:0]pc;
output logic [31:0]data_mem[0:16];
output logic [7:0]inst_mem[0:52];
output logic [31:0]reg_mem[0:31];
always #100 clk=~clk; //200 ps clk period
risc_v dut(
.rst(rst),
.clk(clk),
.pc(pc),
.data_mem(data_mem),
.inst_mem(inst_mem),
.reg_mem(reg_mem)
);
initial begin
clk=1'b0;
rst=1;
repeat(2)begin
@(posedge clk);
end
rst=0;
repeat(21)begin
@(posedge clk);
end
@(posedge clk);
$display("data_mem %p",data_mem);
$display("reg_mem %p",reg_mem);
$finish;
end
endmodule
