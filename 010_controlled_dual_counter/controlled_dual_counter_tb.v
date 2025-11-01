// Testbench pour controlled_dual_counter
// Test du compteur 00-99 contrôlable sur afficheurs 7 segments

`timescale 1ns/1ps

module controlled_dual_counter_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    reg r_Switch_1 = 0;
    reg r_Switch_2 = 0;
    wire [6:0] w_Segments1;  // Dizaines (gauche)
    wire [6:0] w_Segments2;  // Unités (droite)

    // Valeur de test (50 cycles au lieu de 12.5M pour simulation rapide)
    localparam TEST_HALF_SECOND = 50;

    // Instantiation du module à tester
    controlled_dual_counter #(
        .HALF_SECOND(TEST_HALF_SECOND)
    ) UUT (
        .i_Clk(r_Clk),
        .i_Switch_1(r_Switch_1),
        .i_Switch_2(r_Switch_2),
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

    // Test principal
    initial begin
        $dumpfile("controlled_dual_counter_tb.vcd");
        $dumpvars(0, controlled_dual_counter_tb);

        $display("=== Test Controlled Dual Counter ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Valeur test: Incrément toutes les %0d cycles", TEST_HALF_SECOND);

        // Test 1: Reset force à 00
        $display("\n[Test 1] Reset force à 00...");
        r_Switch_1 = 0;
        r_Switch_2 = 1;  // Reset actif
        repeat(10) @(posedge r_Clk);

        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Reset devrait donner 00");
            $finish;
        end
        $display("  PASS: Reset force bien à 00");

        // Test 2: Comptage avec Switch_1=1
        $display("\n[Test 2] Comptage avec Switch_1=1...");
        r_Switch_2 = 0;  // Désactiver reset
        r_Switch_1 = 1;  // Activer comptage
        repeat(5) @(posedge r_Clk);

        // Attendre 5 incréments
        for (i = 0; i < 5; i = i + 1) begin
            repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
        end

        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[5]) begin
            $display("  FAIL: Compteur devrait être à 05");
            $finish;
        end
        $display("  PASS: Compteur à 05 correct");

        // Test 3: Pause avec Switch_1=0
        $display("\n[Test 3] Pause avec Switch_1=0...");
        r_Switch_1 = 0;  // Pause
        repeat(5) @(posedge r_Clk);

        // Attendre plusieurs périodes
        repeat(TEST_HALF_SECOND * 3) @(posedge r_Clk);

        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[5]) begin
            $display("  FAIL: Compteur devrait rester à 05");
            $finish;
        end
        $display("  PASS: Compteur en pause correctement");

        // Test 4: Reprise après pause
        $display("\n[Test 4] Reprise après pause...");
        r_Switch_1 = 1;  // Reprendre
        repeat(5) @(posedge r_Clk);

        // Attendre 3 incréments (pour tolérance de timing)
        repeat((TEST_HALF_SECOND + 10) * 3) @(posedge r_Clk);

        // Afficher la valeur actuelle pour debug
        for (i = 0; i <= 9; i = i + 1) begin
            if (w_Segments2 == expected_segments[i]) begin
                $display("  Valeur actuelle unités: %0d", i);
            end
        end

        // Le compteur devrait avoir augmenté d'au moins 2
        if (w_Segments1 !== expected_segments[0]) begin
            $display("  FAIL: Dizaines devrait être 0");
            $finish;
        end
        // Vérifier que le compteur a repris (valeur >= 6)
        if (w_Segments2 == expected_segments[5] || w_Segments2 == expected_segments[4] ||
            w_Segments2 == expected_segments[3] || w_Segments2 == expected_segments[2] ||
            w_Segments2 == expected_segments[1] || w_Segments2 == expected_segments[0]) begin
            $display("  FAIL: Compteur n'a pas repris, valeur trop basse");
            $finish;
        end
        $display("  PASS: Compteur a repris correctement");

        // Test 5: Reset prioritaire sur enable
        $display("\n[Test 5] Reset prioritaire sur enable...");
        r_Switch_1 = 1;  // Enable
        r_Switch_2 = 1;  // Reset (prioritaire)
        repeat(10) @(posedge r_Clk);

        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Reset devrait avoir priorité");
            $finish;
        end
        $display("  PASS: Reset a bien priorité sur enable");

        // Test 6: Wrap 99→00
        $display("\n[Test 6] Wrap 99→00...");
        r_Switch_2 = 0;
        r_Switch_1 = 1;
        repeat(5) @(posedge r_Clk);

        // Attendre d'atteindre 99
        while (!(w_Segments1 == expected_segments[9] && w_Segments2 == expected_segments[9])) begin
            @(posedge r_Clk);
        end
        $display("  Atteint 99");

        // Vérifier wrap 99→00
        repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Wrap 99→00 incorrect");
            $finish;
        end
        $display("  PASS: Wrap 99→00 correct");

        // Test 7: Continuité après wrap
        $display("\n[Test 7] Continuité après wrap...");

        // Vérifier 00→01→02
        for (i = 0; i < 3; i = i + 1) begin
            if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[i]) begin
                $display("  FAIL: Valeur %02d incorrecte après wrap", i);
                $finish;
            end

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
