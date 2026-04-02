module dff1bit (input clk,rst,din,output reg dout);
  
  always @(posedge clk or posedge rst) begin
    if(rst)
      dout <= 0;
    else
      dout <= din;
  end
  
endmodule

module dff4bit (input clk,rst,input [3:0] din,output [3:0] dout);
  
  dff1bit u1 (clk,rst,din[0],dout[0]);
  dff1bit u2 (clk,rst,din[1],dout[1]);
  dff1bit u3 (clk,rst,din[2],dout[2]);
  dff1bit u4 (clk,rst,din[3],dout[3]);
  
endmodule

module mux1bit(input a,b,sel,output out);
  
  assign out = sel ? b : a;
  
endmodule

module mux3bit (input [2:0] a,b,input sel,output [2:0] out);

  mux1bit u2 (a[2],b[2],sel,out[2]);
  mux1bit u3 (a[1],b[1],sel,out[1]);
  mux1bit u4 (a[0],b[0],sel,out[0]);
  
endmodule

module mux4bit (input [3:0] a,b,input sel,output [3:0] out);
  
  mux1bit u1 (a[3],b[3],sel,out[3]);
  mux1bit u2 (a[2],b[2],sel,out[2]);
  mux1bit u3 (a[1],b[1],sel,out[1]);
  mux1bit u4 (a[0],b[0],sel,out[0]);
  
endmodule

module com1bit (input a,b,output eq,lt,gt);
  
  assign eq = (a == b);
  assign lt = (a < b);
  assign gt = (a > b);
  
endmodule

module com4bit (input [3:0] a,b, output eq,lt,gt);
  
  wire [3:0] eqi,lti,gti;
  wire [2:0] mux1,mux2,mux3;
  
  com1bit c1 (a[3],b[3],eqi[3],lti[3],gti[3]);  
  
  mux3bit m1 ({eqi[3],lti[3],gti[3]},mux2,eqi[3],mux1);
  
  com1bit c2 (a[2],b[2],eqi[2],lti[2],gti[2]); 
  
  mux3bit m2 ({eqi[2],lti[2],gti[2]},mux3,eqi[2],mux2);
  
  com1bit c3 (a[1],b[1],eqi[1],lti[1],gti[1]); 
  
  mux3bit m3 ({eqi[1],lti[1],gti[1]},{eqi[0],lti[0],gti[0]},eqi[1],mux3);
  
  com1bit c4 (a[0],b[0],eqi[0],lti[0],gti[0]); 
  
  assign eq = mux1[2];
  assign lt = mux1[1];
  assign gt = mux1[0]; 
    
endmodule

module full_adder(input a,b,cin,output sum,cout);
  
  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (b & cin) | (a & cin);
  
endmodule

module inc4(input [3:0] a,output [3:0] sum);
  
  wire c1,c2,c3;
  
  full_adder f1(a[0],1'b1,1'b0,sum[0],c1);
  full_adder f2(a[1],1'b0,c1,sum[1],c2);
  full_adder f3(a[2],1'b0,c2,sum[2],c3);
  full_adder f4(a[3],1'b0,c3,sum[3]);
  
endmodule

module and1(input a,b,output out);
  
  assign out = (a & b);
  
endmodule



module seconds_counter (input clk,rst,load,input [3:0] u_in_s,output [3:0] seconds,output carry_s);

  wire [3:0] cnt, next_cnt, inc_out, roll_out, mux_out;
  wire eq, lt, gt;

  inc4 r1 (cnt,next_cnt);

  assign inc_out = next_cnt;

  com4bit r2 (cnt,4'd15,eq,lt,gt);

  mux4bit r3 (inc_out,4'd1,eq,roll_out);

  mux4bit r4 (roll_out,u_in_s,load,mux_out);

  dff4bit r5 (clk,rst,mux_out,cnt);

  assign seconds = cnt;
  assign carry_s = eq;

endmodule

module minutes_counter (input clk,rst,load,en,input [3:0] u_in_m,output [3:0] minutes,output carry_m);

  wire [3:0] cnt, next_cnt, inc_out, roll_out, mux_out;
  wire eq, lt, gt;

  inc4 r1 (cnt, next_cnt);

  mux4bit r2 (cnt,next_cnt,en,inc_out);

  com4bit r3 (cnt,4'd10,eq,lt,gt);

  mux4bit r4 (inc_out,4'd1,eq,roll_out);

  mux4bit r5 (roll_out,u_in_m,load,mux_out);

  dff4bit r6 (clk,rst,mux_out,cnt);

  assign minutes = cnt;
  
  and1 r7 (eq,en,carry_m);

endmodule

module hours_counter (input clk,rst,load,en,input [3:0] u_in_h,output [3:0] hours);

  wire [3:0] cnt, next_cnt, inc_out, roll_out, mux_out;
  wire eq, lt, gt;

  inc4 r1 (cnt,next_cnt);

  mux4bit r2 (cnt,next_cnt,en,inc_out);

  com4bit r3 (cnt,4'd12,eq,lt,gt);

  mux4bit r4 (inc_out,4'd1,eq,roll_out);

  mux4bit r5 (roll_out,u_in_h,load,mux_out);

  dff4bit r6 (clk,rst,mux_out,cnt);

  assign hours = cnt;

endmodule

module clock (input clk,rst,load,input [3:0] u_in_h,u_in_m,u_in_s,output [3:0] hours,minutes,seconds);

  wire carry_s,carry_m;

  seconds_counter S (clk,rst,load,u_in_s,seconds,carry_s);

  minutes_counter M (clk,rst,load,carry_s,u_in_m,minutes,carry_m);

  hours_counter H (clk,rst,load,carry_m,u_in_h,hours);

endmodule



module ref_clock (
  input clk, rst, load,
  input [3:0] u_in_h, u_in_m, u_in_s,
  output reg [3:0] hours, minutes, seconds
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    hours <= 0;
    minutes <= 0;
    seconds <= 0;
  end
  else if (load) begin
    hours <= u_in_h;
    minutes <= u_in_m;
    seconds <= u_in_s;
  end
  else begin
    if (seconds == 15) begin
      seconds <= 1;

      if (minutes == 10) begin
        minutes <= 1;

        if (hours == 12)
          hours <= 1;
        else
          hours <= hours + 1;

      end else begin
        minutes <= minutes + 1;
      end

    end else begin
      seconds <= seconds + 1;
    end
  end
end

endmodule