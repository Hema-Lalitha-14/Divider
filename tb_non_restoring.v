module tb_non_restoring;

    // 🔧 Change only this parameter to adjust bit-width
    localparam N =32;

    reg  [N-1:0] M, Q_in;
    reg  [N-1:0] count;
    wire [N-1:0] Quotient, Remainder;

    // Instantiate the Unit Under Test (UUT)
    non_restoring_divider #(.N(N)) uut (
        .M(M),
        .Q_in(Q_in),
        .count(count),
        .Quotient(Quotient),
        .Remainder(Remainder)
    );

    initial begin
        // ✅ Just assign integers directly - safe with [N-1:0]
        M     = 5;     // Divisor
        Q_in  = 304;    // Dividend
        count = N;     // Number of iterations

        #10; // Wait for simulation result

        $display("Dividend = %d, Divisor = %d", Q_in, M);
        $display("Quotient = %d, Remainder = %d", Quotient, Remainder);
    end
endmodule