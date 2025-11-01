// Testbench pour binary_counter
// Test du compteur 4-bit avec incrément toutes les 0.5s

`timescale 1ns/1ps

module binary_counter_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    wire [3:0] w_LED;

    // Valeur de test (50 cycles au lieu de 12.5M pour simulation rapide)
    localparam TEST_HALF_SECOND = 50;

    // Instantiation du module à tester
    binary_counter #(
        .HALF_SECOND(TEST_HALF_SECOND)
    ) UUT (
        .i_Clk(r_Clk),
        .o_LED_1(w_LED[3]),  // MSB
        .o_LED_2(w_LED[2]),
        .o_LED_3(w_LED[1]),
        .o_LED_4(w_LED[0])   // LSB
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Variables pour les tests
    integer i;
    reg [3:0] expected_value;
    integer cycle_count;

    // Test principal
    initial begin
        $dumpfile("binary_counter_tb.vcd");
        $dumpvars(0, binary_counter_tb);

        $display("=== Test Binary Counter ==.");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Valeur test: Incrément toutes les %0d cycles", TEST_HALF_SECOND);

        // Attendre la stabilisation et le premier incrément
        repeat(5) @(posedge r_Clk);

        // Attendre le premier incrément (sans vérifier le timing strict)
        while (w_LED == 4'b0000) begin
            @(posedge r_Clk);
        end

        $display("\nPremier incrément détecté, compteur = %0d", w_LED);

        // Test 1: Vérifier la séquence complète 1-15 puis 0
        $display("\n[Test 1] Séquence complète 1-15 puis wrap...");

        for (i = 1; i < 17; i = i + 1) begin
            expected_value = (i == 16) ? 0 : i;

            // Vérifier la valeur actuelle
            if (w_LED !== expected_value) begin
                $display("  FAIL: Attendu %0d (0b%04b), reçu %0d (0b%04b)",
                         expected_value, expected_value, w_LED, w_LED);
                $finish;
            end

            // Attendre le prochain incrément (environ HALF_SECOND cycles)
            cycle_count = 0;
            while (w_LED == expected_value && cycle_count < (TEST_HALF_SECOND + 10)) begin
                @(posedge r_Clk);
                cycle_count = cycle_count + 1;
            end

            // Vérifier le timing (avec tolérance)
            if (cycle_count < (TEST_HALF_SECOND - 5) || cycle_count > (TEST_HALF_SECOND + 5)) begin
                $display("  FAIL: Incrément %0d→%0d après %0d cycles (attendu: ~%0d)",
                         expected_value, w_LED, cycle_count, TEST_HALF_SECOND);
                $finish;
            end
        end

        $display("  PASS: Séquence complète et wrap-around corrects");

        // Test 2: Vérifier quelques incréments supplémentaires
        $display("\n[Test 2] Continuité après wrap...");

        // On teste 2 incréments supplémentaires
        for (i = 0; i < 2; i = i + 1) begin
            // Enregistrer la valeur actuelle
            expected_value = w_LED;
            $display("  Attente incrément depuis %0d...", expected_value);

            // Attendre le prochain incrément
            cycle_count = 0;
            while (w_LED == expected_value && cycle_count < (TEST_HALF_SECOND + 10)) begin
                @(posedge r_Clk);
                cycle_count = cycle_count + 1;
            end

            // Vérifier que la valeur a bien changé
            if (w_LED == expected_value) begin
                $display("  FAIL: Pas d'incrément détecté");
                $finish;
            end

            // Vérifier le timing
            if (cycle_count < (TEST_HALF_SECOND - 5) || cycle_count > (TEST_HALF_SECOND + 5)) begin
                $display("  FAIL: Incrément %0d→%0d après %0d cycles (attendu: ~%0d)",
                         expected_value, w_LED, cycle_count, TEST_HALF_SECOND);
                $finish;
            end

            $display("  Incrément %0d→%0d en %0d cycles - OK", expected_value, w_LED, cycle_count);
        end

        $display("  PASS: Continuité après wrap correcte");

        $display("\n=== Tous les tests PASS ===");
        $display("Logique validée (sur FPGA: incrément 0.5s avec HALF_SECOND=12_500_000)");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(2000 * 40);  // 2000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
