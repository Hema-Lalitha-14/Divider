module non_restoring_divider #(parameter N = 32) (
    input      [N-1:0] M,        // Divisor
    input      [N-1:0] Q_in,     // Dividend
    input      [N-1:0] count,    // Number of iterations (bit width)
    output reg [N-1:0] Quotient,
    output reg [N-1:0] Remainder
);
    reg [N-1:0] A, Q;
    reg [N-1:0] M_reg;
    integer i;

    always @(*) begin
        A = 0;
        Q = Q_in;
        M_reg = M;

        for (i = 0; i < count; i = i + 1) begin
            // 1. Left shift AQ as a combined register
            {A, Q} = {A, Q} << 1;

            // 2. If A is positive, subtract M; else add M
            if (A[N-1] == 0)
                A = A - M_reg;
            else
                A = A + M_reg;

            // 3. Set Q0 based on A's MSB
            if (A[N-1] == 0)
                Q[0] = 1;
            else
                Q[0] = 0;
        end

        // Final correction step
        if (A[N-1] == 1)
            A = A + M_reg;

        Quotient = Q;
        Remainder = A;
    end
endmodule