// Testbench pour dual_segment_counter
// Test du compteur 2 chiffres 00-99 sur afficheurs 7 segments

`timescale 1ns/1ps

module dual_segment_counter_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    wire [6:0] w_Segments1;  // Dizaines (gauche)
    wire [6:0] w_Segments2;  // Unités (droite)

    // Valeur de test (50 cycles au lieu de 12.5M pour simulation rapide)
    localparam TEST_HALF_SECOND = 50;

    // Instantiation du module à tester
    dual_segment_counter #(
        .HALF_SECOND(TEST_HALF_SECOND)
    ) UUT (
        .i_Clk(r_Clk),
        // Segment 1 (gauche = dizaines)
        .o_Segment1_G(w_Segments1[6]),
        .o_Segment1_F(w_Segments1[5]),
        .o_Segment1_E(w_Segments1[4]),
        .o_Segment1_D(w_Segments1[3]),
        .o_Segment1_C(w_Segments1[2]),
        .o_Segment1_B(w_Segments1[1]),
        .o_Segment1_A(w_Segments1[0]),
        // Segment 2 (droite = unités)
        .o_Segment2_G(w_Segments2[6]),
        .o_Segment2_F(w_Segments2[5]),
        .o_Segment2_E(w_Segments2[4]),
        .o_Segment2_D(w_Segments2[3]),
        .o_Segment2_C(w_Segments2[2]),
        .o_Segment2_B(w_Segments2[1]),
        .o_Segment2_A(w_Segments2[0])
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Encodages 7 segments attendus (actif bas)
    reg [6:0] expected_segments [0:9];
    initial begin
        expected_segments[0] = ~7'b0111111;  // 0
        expected_segments[1] = ~7'b0000110;  // 1
        expected_segments[2] = ~7'b1011011;  // 2
        expected_segments[3] = ~7'b1001111;  // 3
        expected_segments[4] = ~7'b1100110;  // 4
        expected_segments[5] = ~7'b1101101;  // 5
        expected_segments[6] = ~7'b1111101;  // 6
        expected_segments[7] = ~7'b0000111;  // 7
        expected_segments[8] = ~7'b1111111;  // 8
        expected_segments[9] = ~7'b1101111;  // 9
    end

    // Variables pour les tests
    integer i;
    integer cycle_count;
    integer tens, units;
    reg [6:0] current_seg1, current_seg2;

    // Test principal
    initial begin
        $dumpfile("dual_segment_counter_tb.vcd");
        $dumpvars(0, dual_segment_counter_tb);

        $display("=== Test Dual Segment Counter ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Valeur test: Incrément toutes les %0d cycles", TEST_HALF_SECOND);

        // Attendre la stabilisation
        repeat(5) @(posedge r_Clk);

        // Test 1: Vérifier la séquence 00-20
        $display("\n[Test 1] Séquence 00-20...");

        for (i = 0; i <= 20; i = i + 1) begin
            tens = i / 10;
            units = i % 10;

            // Vérifier les segments
            current_seg1 = w_Segments1;  // Dizaines (gauche)
            current_seg2 = w_Segments2;  // Unités (droite)

            if (current_seg1 !== expected_segments[tens]) begin
                $display("  FAIL: Valeur %0d, dizaines attendues=%07b, reçues=%07b",
                         i, expected_segments[tens], current_seg1);
                $finish;
            end

            if (current_seg2 !== expected_segments[units]) begin
                $display("  FAIL: Valeur %0d, unités attendues=%07b, reçues=%07b",
                         i, expected_segments[units], current_seg2);
                $finish;
            end

            if (i % 5 == 0) begin
                $display("  Valeur %02d: dizaines=%0d, unités=%0d - OK", i, tens, units);
            end

            // Attendre le prochain incrément (sauf pour le dernier)
            if (i < 20) begin
                cycle_count = 0;
                while ((w_Segments1 == current_seg1 && w_Segments2 == current_seg2) &&
                       cycle_count < (TEST_HALF_SECOND + 10)) begin
                    @(posedge r_Clk);
                    cycle_count = cycle_count + 1;
                end
            end
        end

        $display("  PASS: Séquence 00-20 correcte");

        // Test 2: Sauter à des valeurs clés (simulation rapide)
        $display("\n[Test 2] Transitions clés (89→90, 98→99→00)...");

        // Attendre jusqu'à 89 (dizaines=8, unités=9)
        while (!(w_Segments1 == expected_segments[8] && w_Segments2 == expected_segments[9])) begin
            @(posedge r_Clk);
        end
        $display("  Atteint 89");

        // Vérifier 89→90 (dizaines=9, unités=0)
        repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
        if (w_Segments1 !== expected_segments[9] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Transition 89→90 incorrecte");
            $finish;
        end
        $display("  Transition 89→90 - OK");

        // Attendre jusqu'à 98 (dizaines=9, unités=8)
        while (!(w_Segments1 == expected_segments[9] && w_Segments2 == expected_segments[8])) begin
            @(posedge r_Clk);
        end
        $display("  Atteint 98");

        // Vérifier 98→99 (dizaines=9, unités=9)
        repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
        if (w_Segments1 !== expected_segments[9] || w_Segments2 !== expected_segments[9]) begin
            $display("  FAIL: Transition 98→99 incorrecte");
            $finish;
        end
        $display("  Transition 98→99 - OK");

        // Vérifier 99→00 (wrap : dizaines=0, unités=0)
        repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Wrap 99→00 incorrect");
            $finish;
        end
        $display("  Wrap 99→00 - OK");

        $display("  PASS: Transitions clés correctes");

        // Test 3: Continuité après wrap (00→01→02)
        $display("\n[Test 3] Continuité après wrap...");

        for (i = 0; i < 3; i = i + 1) begin
            tens = i / 10;
            units = i % 10;

            if (w_Segments1 !== expected_segments[tens] ||
                w_Segments2 !== expected_segments[units]) begin
                $display("  FAIL: Valeur %02d incorrecte après wrap", i);
                $finish;
            end

            // Attendre le prochain incrément
            if (i < 2) begin
                repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
            end
        end

        $display("  PASS: Continuité après wrap correcte");

        $display("\n=== Tous les tests PASS ===");
        $display("Logique validée (sur FPGA: compteur 0.5s avec HALF_SECOND=12_500_000)");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(10000 * 40);  // 10000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
