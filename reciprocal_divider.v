module reciprocal_divider (
    input  clk,
    input  rst,
    input  [15:0] u,
    input  [15:0] v,
    output reg [15:0] q
);

    // Reciprocal Lookup Table (Q8 format)
    reg [7:0] recip_lut [0:7];
    initial begin
        recip_lut[0] = 8'hFF;
        recip_lut[1] = 8'hE3;
        recip_lut[2] = 8'hCC;
        recip_lut[3] = 8'hBA;
        recip_lut[4] = 8'hAA;
        recip_lut[5] = 8'h9D;
        recip_lut[6] = 8'h92;
        recip_lut[7] = 8'h88;
    end

    reg [15:0] q_reg, u_reg, v_reg, r, v_shifted, temp;
    reg [4:0] n;
    reg [15:0] i, mul1, mul2, correction;

    // Leading zero counter
    function [4:0] clz16;
        input [15:0] x;
        integer j;
        reg found;
        begin
            clz16 = 16;
            found = 0;
            for (j = 15; j >= 0; j = j - 1) begin
                if (!found && x[j]) begin
                    clz16 = 15 - j;
                    found = 1;
                end
            end
            if (!found)
                clz16 = 16;  // input is zero
        end
    endfunction


    // High 16-bits of multiplication
    function [15:0] MulHi_U16_U16;
        input [15:0] a, b;
        reg [31:0] product;
        begin
            product = a * b;
            MulHi_U16_U16 = product[31:16];
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            u_reg <= u;
            v_reg <= v;

            // Step 1: Leading zeros in v
            n = clz16(v);
            v_shifted = v << n;

            // Step 2: LUT index
            i = (v << n) >> 12;  // top 3 bits
            r = {recip_lut[i - 8], 8'b00000000};  // Q16

            // Step 3: Newton-Raphson iterations
            mul1 = MulHi_U16_U16(r, v_shifted);
            mul2 = MulHi_U16_U16(~mul1 + 1, r);
            r = mul2 << 1;

            mul1 = MulHi_U16_U16(r, v_shifted);
            mul2 = MulHi_U16_U16(~mul1 + 1, r);
            r = mul2 << 1;

            // Step 4: Quotient estimation
            q_reg = MulHi_U16_U16(u, r);
            q_reg = q_reg >> (15 - n);

            if (q_reg > 0)
                q_reg = q_reg - 1;

            // Step 5: Remainder and correction
            temp = u - q_reg * v;
            correction = 0;
            if (temp >= v) begin
                correction = correction + 1;
                temp = temp - v;
                if (temp >= v) begin
                    correction = correction + 1;
                    temp = temp - v;
                    if (temp >= v) begin
                        correction = correction + 1;
                    end
                end
            end

            q <= q_reg + correction;
        end
    end

endmodule