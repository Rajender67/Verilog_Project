module tb;
  
  reg clk,rst,load;
  reg [3:0] u_in_h,u_in_m,u_in_s;
  wire [3:0] hours,minutes,seconds;
  wire [3:0] ref_h,ref_m,ref_s;
  reg [3:0] ref_h_d,ref_m_d,ref_s_d;
  
  integer errors = 0;
  
  clock dut1 (clk,rst,load,u_in_h,u_in_m,u_in_s,hours,minutes,seconds);
  
  ref_clock dut2 (clk,rst,load,u_in_h,u_in_m,u_in_s,ref_h,ref_m,ref_s);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  always @(posedge clk) begin
    ref_h_d <= ref_h;
    ref_m_d <= ref_m;
    ref_s_d <= ref_s;
  end

  initial begin

    $monitor("Time=%0t | Load=%d | input=%0d:%0d:%0d | Clock(DUT)=%0d:%0d:%0d |Clock(REF)=%0d:%0d:%0d",$time,load,u_in_h,u_in_m,u_in_s,hours,minutes,seconds,ref_h_d,ref_m_d,ref_s_d);
    
    rst = 1; load = 0;
    #20;
    rst = 0;
    #200;
    
    @(posedge clk);
    load = 1;
    u_in_h = 7;
    u_in_m = 5;
    u_in_s = 12;

    @(posedge clk);
    load = 0;
    
    @(posedge clk);

    if (hours != ref_h_d || minutes != ref_m_d || seconds != ref_s_d) begin
      $display("ERROR: Load mismatch");
      errors = errors + 1;
    end

    @(posedge clk);
    
    if (hours != ref_h_d || minutes != ref_m_d || seconds != ref_s_d) begin
      $display("ERROR: Increment mismatch");
      errors = errors + 1;
    end

    #150;

    if (hours != ref_h_d || minutes != ref_m_d || seconds != ref_s_d) begin
      $display("ERROR: Final mismatch");
      errors = errors + 1;
    end

    if (errors == 0)
      $display("TEST PASSED");
    else
      $display("TEST FAILED with %0d errors", errors);
    
    $finish;
    
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
  
endmodule