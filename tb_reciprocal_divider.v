`timescale 1ns / 1ps
module tb_reciprocal_divider;

    reg clk;
    reg rst;
    reg [15:0] u;
    reg [15:0] v;
    wire [15:0] q;

    reciprocal_divider uut (
        .clk(clk),
        .rst(rst),
        .u(u),
        .v(v),
        .q(q)
    );

    // Clock: 100 MHz
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        u = 0;
        v = 0;

        #10;
        rst = 0;
        #10;

        test_divide(16'd101, 16'd25);
        test_divide(16'd32767, 16'd127);
        test_divide(16'd12345, 16'd13);
        test_divide(16'd65535, 16'd255);
        test_divide(16'd5000,  16'd100);
        test_divide(16'd1,     16'd1);
        test_divide(16'd0,     16'd5);

        #50;
        $finish;
    end

    task test_divide;
        input [15:0] a, b;
        begin
            u = a;
            v = b;
            #50;
            $display("u = %0d, v = %0d => q = %0d", u, v, q);
        end
    endtask

endmodule