module risc_v(rst,clk,pc,data_mem,inst_mem,reg_mem);
input logic rst;
output logic [31:0]pc;
logic [31:0]pc_branch,pc_nxt,id_inst;
output logic signed [31:0]data_mem[0:16];
output logic [7:0]inst_mem[0:52];
output logic signed [31:0]reg_mem[0:31];
typedef enum logic [6:0]{R=7'b0110011,I=7'b0010011,L=7'b0000011,S=7'b0100011,B=7'b1100011,NOP=7'b0000000}inst_type;
logic [31:0]inst_bus;
logic [2:0]fun3;
logic [6:0]fun7;
logic [4:0]rs1,rs2,rd;
logic [6:0]opcode;
logic [31:0]imd,Rs1_val,Rs2_val,Rs2_alu;
logic [31:0]alu_res,wb_wr_data,mem_wb_wr_data1;
logic zero_f;
logic RegWrite,ALUSrc,MemRead,MemWrite,MemtoReg,Branch;
logic [1:0]ALUOp;
input logic clk;
logic psel;
logic [4:0]ex_rd,mem_rd,wb_rd,de_ex_rd,ex_mem_rd,mem_wb_rd;
typedef enum logic [1:0]{add,sub,andd,orr}alu;
logic [1:0]rs1_sel,rs2_sel;
logic id_ex_inst_bus_30,ex_MemtoReg,ex_mem_MemtoReg,ex_MemRead,ex_mem_MemWrite,ex_MemWrite,mem_RegWrite,ex_mem_RegWrite,ex_mem_MemRead,ex_Branch,ex_RegWrite;
logic [1:0]id_ex_ALUOp,ALUop1;
logic mem_MemtoReg,mem_MemRead;
logic mem_wb_RegWrite;
logic [31:0]wr_data1;
logic [2:0]id_ex_inst_bus_1412,inst_bus_1;
logic inst_bus_3;
logic wb_RegWrite,mem_Memwrite;
logic [31:0]ex_pc,ex_mem_alu_res,mem_alu_res,imd1,imd2;
alu alu_sel;

logic [31:0] if_id_pc,if_id_inst;
logic [31:0] id_ex_pc,id_ex_rs1,id_ex_rs2,ex_Rs1_val;
logic id_ex_RegWrite,id_ex_MemRead,id_ex_MemWrite,id_ex_MemtoReg,id_ex_Branch;
logic [31:0] id_ex_Rs2_val,ex_Rs2_val,ex_mem_Rs2_val,wr_mem_alu_res,mem_Rs2_val;
logic wb1_RegWrite;   
logic [31:0] wb1_rd ,wb1_wr_data,ex_Rs2_val1;

logic RegWrite1,MemRead1,MemWrite1,MemtoReg1,Branch1;
logic [1:0] ALUOp1;
logic stall,id_if_write;


always_comb begin
if(rst)
pc_nxt=32'b0;

else begin
    if (psel)
        pc_nxt = pc_branch;
    else
        pc_nxt = pc + 4;
end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 0;
else if (stall)
pc<=pc;
    else
        pc <= pc_nxt;
end
always_ff@(posedge clk)begin//inst_mem

// add x3,x1,x2
inst_mem[0] = 8'hB3;
inst_mem[1] = 8'h81;
inst_mem[2] = 8'h20;
inst_mem[3] = 8'h00;

// sub x4,x3,x1
inst_mem[4] = 8'h33;
inst_mem[5] = 8'h82;
inst_mem[6] = 8'h11;
inst_mem[7] = 8'h40;

// add x5,x4,x3
inst_mem[8]  = 8'hB3;
inst_mem[9]  = 8'h02;
inst_mem[10] = 8'h32;
inst_mem[11] = 8'h00;

// lw x6,0(x1)
inst_mem[12] = 8'h03;
inst_mem[13] = 8'hA3;
inst_mem[14] = 8'h00;
inst_mem[15] = 8'h00;

// add x7,x6,x5
inst_mem[16] = 8'hB3;
inst_mem[17] = 8'h03;
inst_mem[18] = 8'h53;
inst_mem[19] = 8'h00;

// sw x7,4(x1)
inst_mem[20] = 8'h23;
inst_mem[21] = 8'hA2;
inst_mem[22] = 8'h70;
inst_mem[23] = 8'h00;

// lw x8,4(x1)
inst_mem[24] = 8'h03;
inst_mem[25] = 8'hA4;
inst_mem[26] = 8'h40;
inst_mem[27] = 8'h00;

// add x0,x1,x2
inst_mem[28] = 8'h33;
inst_mem[29] = 8'h80;
inst_mem[30] = 8'h20;
inst_mem[31] = 8'h00;

// add x9,x0,x1
inst_mem[32] = 8'hB3;
inst_mem[33] = 8'h04;
inst_mem[34] = 8'h10;
inst_mem[35] = 8'h00;

// beq x1,x2,+8
inst_mem[36] = 8'h63;
inst_mem[37] = 8'h84;
inst_mem[38] = 8'h20;
inst_mem[39] = 8'h00;

// beq x1,x1,+8
inst_mem[40] = 8'h63;
inst_mem[41] = 8'h84;
inst_mem[42] = 8'h10;
inst_mem[43] = 8'h00;

// add x10,x10,x10
inst_mem[44] = 8'h33;
inst_mem[45] = 8'h05;
inst_mem[46] = 8'hA5;
inst_mem[47] = 8'h00;

// add x11,x7,x8
inst_mem[48] = 8'hB3;
inst_mem[49] = 8'h85;
inst_mem[50] = 8'h83;
inst_mem[51] = 8'h00;


end

always_comb begin
case(psel)
1'b0:id_inst=({inst_mem[pc+3],inst_mem[pc+2],inst_mem[pc+1],inst_mem[pc]});
1'b1:id_inst=32'b0;
endcase
end

always_ff@(posedge clk)begin//if_id decode
if(id_if_write==1'b1)begin
if_id_pc<=pc;
if_id_inst<=id_inst;
end
else begin
if_id_pc<=if_id_pc;
if_id_inst<=if_id_inst;
end
end

always_comb begin//decode

inst_bus=if_id_inst;
rd=inst_bus[11:7];
rs1=inst_bus[19:15];
rs2=inst_bus[24:20];
fun3=inst_bus[14:12];
fun7=inst_bus[31:25];
opcode=inst_bus[6:0];
case(opcode)

R:begin
imd=32'b0;
end

I:begin
imd={{20{inst_bus[31]}}, inst_bus[31:20]};
end

L:begin
imd={{20{inst_bus[31]}}, inst_bus[31:20]};
end

S:begin
imd={{20{inst_bus[31]}}, inst_bus[31:25], inst_bus[11:7]};
end

B:begin
imd = {{19{inst_bus[31]}},inst_bus[31],inst_bus[7],inst_bus[30:25],inst_bus[11:8],1'b0};
end

endcase



    RegWrite = 0;
    ALUSrc   = 0;
    MemRead  = 0;
    MemWrite = 0;
    MemtoReg = 0;
    Branch   = 0;
    ALUOp    = 2'b00;

    case(opcode)

        // R-Type
        R: begin
            RegWrite = 1;
            ALUSrc   = 0;
            MemRead  = 0;
            MemWrite = 0;
            MemtoReg = 0;
            Branch   = 0;
            ALUOp    = 2'b10;
        end

        // I-Type (ADDI)
        I: begin
            RegWrite = 1;
            ALUSrc   = 1;
            MemRead  = 0;
            MemWrite = 0;
            MemtoReg = 0;
            Branch   = 0;
            ALUOp    = 2'b11;
        end

        // LW
        L: begin
            RegWrite = 1;
            ALUSrc   = 1;
            MemRead  = 1;
            MemWrite = 0;
            MemtoReg = 1;
            Branch   = 0;
            ALUOp    = 2'b00;
        end

        // SW
        S: begin
            RegWrite = 0;
            ALUSrc   = 1;
            MemRead  = 0;
            MemWrite = 1;
            MemtoReg = 0;   
            Branch   = 0;
            ALUOp    = 2'b00;
        end

        // BEQ
        B: begin
            RegWrite = 0;
            ALUSrc   = 0;
            MemRead  = 0;
            MemWrite = 0;
            MemtoReg = 0;   // Don't care
            Branch   = 1;
            ALUOp    = 2'b01;
        end
		
		NOP: begin
            RegWrite = 0;
            ALUSrc   = 0;
            MemRead  = 0;
            MemWrite = 0;
            MemtoReg = 0;   // Don't care
            Branch   = 0;
            ALUOp    = 2'b00;
        end

    endcase
//end

//forward_sel
//comparator
//ex_rd,mem_rd,wb_rd
if((rs1==ex_rd)&& (ex_rd!=5'b0))rs1_sel=2'b01;
else if((rs1==mem_rd)&& (mem_rd!=5'b0))rs1_sel=2'b10;
else if((rs1==wb_rd)&& (wb_rd!=5'b0))rs1_sel=2'b11;
else rs1_sel=2'b00;

if((rs2==ex_rd)&& (ex_rd!=5'b0))rs2_sel=2'b01;
else if((rs2==mem_rd)&& (mem_rd!=5'b0))rs2_sel=2'b10;
else if((rs2==wb_rd)&& (wb_rd!=5'b0))rs2_sel=2'b11;
else rs2_sel=2'b00;

case(rs1_sel)
2'b00:Rs1_val=reg_mem[rs1];
2'b01:Rs1_val=alu_res;
2'b10:Rs1_val=wr_data1;
2'b11:Rs1_val=wb_wr_data;
endcase

case(rs2_sel)
2'b00:Rs2_val=reg_mem[rs2];
2'b01:Rs2_val=alu_res;
2'b10:Rs2_val=wr_data1;
2'b11:Rs2_val=wb_wr_data;
endcase

case(ALUSrc)
1'b0:Rs2_alu=Rs2_val;
1'b1:Rs2_alu=imd;
endcase

case(psel|stall)
1'b0:begin
            RegWrite1 = RegWrite;
            MemRead1  = MemRead;
            MemWrite1 = MemWrite;
            MemtoReg1 = MemtoReg;  
            Branch1   = Branch;
            ALUOp1    = ALUOp;
end
1'b1:begin
            RegWrite1 = 1'b0;
            MemRead1  = 1'b0;
            MemWrite1 = 1'b0;
            MemtoReg1 = 1'b0;   
            Branch1   = 1'b0;
            ALUOp1    = 2'b00;
end
endcase


end

always_ff@(posedge clk)begin//id_ex decode
id_ex_Rs2_val <= Rs2_val;
id_ex_pc<=if_id_pc;
id_ex_rs1<=Rs1_val;
id_ex_rs2<=Rs2_alu;
id_ex_RegWrite <= RegWrite1;
id_ex_MemRead  <= MemRead1;
id_ex_MemWrite <= MemWrite1;
id_ex_MemtoReg <= MemtoReg1;
id_ex_Branch   <= Branch1;
id_ex_ALUOp    <= ALUOp1;
id_ex_inst_bus_30<=inst_bus[30];
id_ex_inst_bus_1412<=inst_bus[14:12];
de_ex_rd<=rd;
imd1<=imd;
end

always_comb begin//ex
imd2=imd1;
ex_Rs2_val1=id_ex_Rs2_val;
ex_MemWrite=id_ex_MemWrite;
ex_MemRead=id_ex_MemRead;
ex_RegWrite=id_ex_RegWrite;
inst_bus_3=id_ex_inst_bus_30;
inst_bus_1=id_ex_inst_bus_1412;
ALUop1=id_ex_ALUOp;
ex_Branch=id_ex_Branch;
ex_MemtoReg=id_ex_MemtoReg;
ex_pc =id_ex_pc;
ex_rd = de_ex_rd;
ex_Rs1_val=id_ex_rs1;
ex_Rs2_val=id_ex_rs2;
stall=1'b0;
id_if_write=1'b1;
case(ALUop1)
2'b00:alu_sel=add;
2'b01:alu_sel=sub;
2'b10:begin
case({inst_bus_3,inst_bus_1})
4'b0000:alu_sel=add;
4'b1000:alu_sel=sub;
4'b0001:alu_sel=andd;
4'b0010:alu_sel=orr;
endcase
end
2'b11:begin
case(inst_bus_1)
3'b000:alu_sel=add;
3'b001:alu_sel=andd;
3'b010:alu_sel=orr;
endcase
end
endcase
case(alu_sel)
add:alu_res=ex_Rs1_val+ex_Rs2_val;
sub:alu_res=ex_Rs1_val-ex_Rs2_val;
andd:alu_res=ex_Rs1_val & ex_Rs2_val;
orr:alu_res=ex_Rs1_val| ex_Rs2_val;
endcase

if(alu_res==32'b0)zero_f=1'b1;
else zero_f=1'b0;

pc_branch=ex_pc+imd2;


psel=zero_f & ex_Branch;


if((ex_MemRead==1'b1) && ((rs1==ex_rd) || (rs2==ex_rd)))begin
stall=1'b1;
id_if_write=1'b0;
end
else begin
stall=1'b0;
id_if_write=1'b1;
end


end

always_ff@(posedge clk)begin//ex-mem
ex_mem_MemtoReg<=ex_MemtoReg;
ex_mem_RegWrite <= ex_RegWrite;
ex_mem_MemRead  <= ex_MemRead;
ex_mem_MemWrite <= ex_MemWrite;
ex_mem_alu_res <= alu_res;
ex_mem_rd<=ex_rd;
ex_mem_Rs2_val<=ex_Rs2_val1;
end

always_comb begin//mem_blk;
mem_RegWrite=ex_mem_RegWrite;
mem_MemtoReg=ex_mem_MemtoReg;
mem_MemRead=ex_mem_MemRead;
mem_alu_res=ex_mem_alu_res;
mem_rd=ex_mem_rd;

if(mem_MemRead)begin
wr_data1=data_mem[mem_alu_res];
end
else begin
 wr_data1=mem_alu_res;
end
end



always_ff@(posedge clk)begin//data_memory
if(rst)begin
data_mem[0]<=32'd0;
data_mem[1]<=32'd1;
data_mem[2]<=32'd2;
data_mem[3]<=32'd3;
data_mem[4]<=32'd4;
data_mem[5]<=32'd5;
data_mem[6]<=32'd6;
data_mem[7]<=32'd7;
data_mem[8]<=32'd8;
data_mem[9]<=32'd8;
data_mem[10]<=32'd50;
data_mem[11]<=32'd11;
data_mem[12]<=32'd12;
data_mem[13]<=32'd13;
data_mem[14]<=32'd100;
data_mem[15]<=32'd15;
data_mem[16]<=32'd16;
end
else begin
mem_Memwrite<=ex_mem_MemWrite;
mem_Rs2_val<=ex_mem_Rs2_val;
wr_mem_alu_res<=ex_mem_alu_res;
if (mem_Memwrite) begin 
data_mem[wr_mem_alu_res]<=mem_Rs2_val;

end
else begin
data_mem[0]<=data_mem[0];
data_mem[1]<=data_mem[1];
data_mem[2]<=data_mem[2];
data_mem[3]<=data_mem[3];
data_mem[4]<=data_mem[4];
data_mem[5]<=data_mem[5];
data_mem[6]<=data_mem[6];
data_mem[7]<=data_mem[7];
data_mem[8]<=data_mem[8];
data_mem[10]<=data_mem[10];
data_mem[11]<=data_mem[11];
data_mem[12]<=data_mem[12];
data_mem[13]<=data_mem[13];
data_mem[14]<=data_mem[14];
data_mem[15]<=data_mem[15];
data_mem[16]<=data_mem[16];

end
end

end

always_ff@(posedge clk)begin//mem_wb
mem_wb_rd<=mem_rd;
mem_wb_RegWrite<=mem_RegWrite;
mem_wb_wr_data1<=wr_data1;

end

always_comb begin //wb
wb_RegWrite=mem_wb_RegWrite;
 wb_wr_data =mem_wb_wr_data1;
wb_rd=mem_wb_rd;

end

always_ff@(posedge clk)begin//register_memory
if(rst)begin
reg_mem[0]<=32'd0;
reg_mem[1]<=32'd10;
reg_mem[2]<=32'd20;
reg_mem[3]<=32'd3;
reg_mem[4]<=32'd4;
reg_mem[5]<=32'd5;
reg_mem[6]<=32'd6;
reg_mem[7]<=32'd7;
reg_mem[8]<=32'd8;
reg_mem[9]<=32'd9;
reg_mem[10]<=32'd10;
reg_mem[11] <= 32'd11;
reg_mem[12] <= 32'd12;
reg_mem[13] <= 32'd13;
reg_mem[14] <= 32'd14;
reg_mem[15] <= 32'd15;
reg_mem[16] <= 32'd16;
reg_mem[17] <= 32'd17;
reg_mem[18] <= 32'd18;
reg_mem[19] <= 32'd19;
reg_mem[20] <= 32'd20;
reg_mem[21] <= 32'd21;
reg_mem[22] <= 32'd22;
reg_mem[23] <= 32'd23;
reg_mem[24] <= 32'd24;
reg_mem[25] <= 32'd25;
reg_mem[26] <= 32'd26;
reg_mem[27] <= 32'd27;
reg_mem[28] <= 32'd28;
reg_mem[29] <= 32'd29;
reg_mem[30] <= 32'd30;
reg_mem[31] <= 32'd31;

end
else begin
wb1_RegWrite   <= wb_RegWrite;
wb1_rd   <=wb_rd;
wb1_wr_data	<= wb_wr_data;
if((wb1_RegWrite==1'b1) && (wb1_rd!=5'b0))begin
reg_mem[wb1_rd] <= wb1_wr_data;

end
else begin
reg_mem[0]<=reg_mem[0];
reg_mem[1]<=reg_mem[1];
reg_mem[2]<=reg_mem[2];
reg_mem[3]<=reg_mem[3];
reg_mem[4]<=reg_mem[4];
reg_mem[5]<=reg_mem[5];
reg_mem[6]<=reg_mem[6];
reg_mem[7]<=reg_mem[7];
reg_mem[8]<=reg_mem[8];
reg_mem[9]<= reg_mem[9];
reg_mem[10]<= reg_mem[10];
reg_mem[11] <= reg_mem[11];
reg_mem[12] <= reg_mem[12];
reg_mem[13] <= reg_mem[13];
reg_mem[14] <= reg_mem[14];
reg_mem[15] <= reg_mem[15];
reg_mem[16] <= reg_mem[16];
reg_mem[17] <= reg_mem[17];
reg_mem[18] <= reg_mem[18];
reg_mem[19] <= reg_mem[19];
reg_mem[20] <= reg_mem[20];
reg_mem[21] <= reg_mem[21];
reg_mem[22] <= reg_mem[22];
reg_mem[23] <= reg_mem[23];
reg_mem[24] <= reg_mem[24];
reg_mem[25] <= reg_mem[25];
reg_mem[26] <= reg_mem[26];
reg_mem[27] <= reg_mem[27];
reg_mem[28] <= reg_mem[28];
reg_mem[29] <= reg_mem[29];
reg_mem[30] <= reg_mem[30];
reg_mem[31] <= reg_mem[31];

end
end



end


endmodule
