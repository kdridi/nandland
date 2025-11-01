// Testbench pour segment_counter
// Test du compteur décimal avec affichage 7 segments

`timescale 1ns/1ps

module segment_counter_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    wire [6:0] w_Segments;

    // Valeur de test (50 cycles au lieu de 12.5M pour simulation rapide)
    localparam TEST_HALF_SECOND = 50;

    // Instantiation du module à tester
    segment_counter #(
        .HALF_SECOND(TEST_HALF_SECOND)
    ) UUT (
        .i_Clk(r_Clk),
        .o_Segment1_G(w_Segments[6]),
        .o_Segment1_F(w_Segments[5]),
        .o_Segment1_E(w_Segments[4]),
        .o_Segment1_D(w_Segments[3]),
        .o_Segment1_C(w_Segments[2]),
        .o_Segment1_B(w_Segments[1]),
        .o_Segment1_A(w_Segments[0])
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Encodages 7 segments attendus (actif bas, donc inversés)
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
    reg [6:0] current_segments;

    // Test principal
    initial begin
        $dumpfile("segment_counter_tb.vcd");
        $dumpvars(0, segment_counter_tb);

        $display("=== Test Segment Counter ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Valeur test: Incrément toutes les %0d cycles", TEST_HALF_SECOND);

        // Attendre la stabilisation
        repeat(5) @(posedge r_Clk);

        // Test 1: Vérifier la séquence 0-9
        $display("\n[Test 1] Séquence 0-9 avec segments corrects...");

        for (i = 0; i < 10; i = i + 1) begin
            // Vérifier les segments actuels
            current_segments = w_Segments;

            if (current_segments !== expected_segments[i]) begin
                $display("  FAIL: Chiffre %0d, segments attendus=%07b, reçus=%07b",
                         i, expected_segments[i], current_segments);
                $finish;
            end

            $display("  Chiffre %0d: segments=%07b - OK", i, current_segments);

            // Attendre le prochain incrément
            cycle_count = 0;
            while (w_Segments == current_segments && cycle_count < (TEST_HALF_SECOND + 10)) begin
                @(posedge r_Clk);
                cycle_count = cycle_count + 1;
            end

            // Vérifier le timing (sauf pour le dernier qui wrap)
            if (i < 9) begin
                if (cycle_count < (TEST_HALF_SECOND - 5) || cycle_count > (TEST_HALF_SECOND + 5)) begin
                    $display("  FAIL: Incrément %0d après %0d cycles (attendu: ~%0d)",
                             i, cycle_count, TEST_HALF_SECOND);
                    $finish;
                end
            end
        end

        $display("  PASS: Séquence 0-9 correcte avec segments valides");

        // Test 2: Vérifier le wrap 9→0
        $display("\n[Test 2] Wrap-around 9→0...");

        if (w_Segments !== expected_segments[0]) begin
            $display("  FAIL: Wrap devrait donner 0, segments=%07b (attendu=%07b)",
                     w_Segments, expected_segments[0]);
            $finish;
        end

        $display("  PASS: Wrap 9→0 correct");

        // Test 3: Vérifier continuité après wrap
        $display("\n[Test 3] Continuité après wrap (0→1→2)...");

        for (i = 0; i < 3; i = i + 1) begin
            current_segments = w_Segments;

            if (current_segments !== expected_segments[i]) begin
                $display("  FAIL: Après wrap, attendu chiffre %0d, segments=%07b (attendu=%07b)",
                         i, current_segments, expected_segments[i]);
                $finish;
            end

            // Attendre le prochain incrément
            cycle_count = 0;
            while (w_Segments == current_segments && cycle_count < (TEST_HALF_SECOND + 10)) begin
                @(posedge r_Clk);
                cycle_count = cycle_count + 1;
            end

            // Vérifier le timing
            if (cycle_count < (TEST_HALF_SECOND - 5) || cycle_count > (TEST_HALF_SECOND + 5)) begin
                $display("  FAIL: Incrément %0d après %0d cycles (attendu: ~%0d)",
                         i, cycle_count, TEST_HALF_SECOND);
                $finish;
            end
        end

        $display("  PASS: Continuité après wrap correcte");

        $display("\n=== Tous les tests PASS ===");
        $display("Logique validée (sur FPGA: compteur 0.5s avec HALF_SECOND=12_500_000)");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(1500 * 40);  // 1500 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
