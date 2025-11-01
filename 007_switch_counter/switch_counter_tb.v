// Testbench pour switch_counter
// Test du compteur contrôlable par switches

`timescale 1ns/1ps

module switch_counter_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    reg r_Switch_1 = 0;
    reg r_Switch_2 = 0;
    wire [3:0] w_LED;

    // Valeur de test (50 cycles au lieu de 12.5M pour simulation rapide)
    localparam TEST_HALF_SECOND = 50;

    // Instantiation du module à tester
    switch_counter #(
        .HALF_SECOND(TEST_HALF_SECOND)
    ) UUT (
        .i_Clk(r_Clk),
        .i_Switch_1(r_Switch_1),
        .i_Switch_2(r_Switch_2),
        .o_LED_1(w_LED[3]),  // MSB
        .o_LED_2(w_LED[2]),
        .o_LED_3(w_LED[1]),
        .o_LED_4(w_LED[0])   // LSB
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Variables pour les tests
    integer i;

    // Test principal
    initial begin
        $dumpfile("switch_counter_tb.vcd");
        $dumpvars(0, switch_counter_tb);

        $display("=== Test Switch Counter ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Valeur test: Incrément toutes les %0d cycles", TEST_HALF_SECOND);

        // Test 1: Reset force le compteur à 0
        $display("\n[Test 1] Reset force à 0...");
        r_Switch_1 = 0;
        r_Switch_2 = 1;  // Reset actif
        repeat(10) @(posedge r_Clk);

        if (w_LED !== 4'b0000) begin
            $display("  FAIL: Compteur devrait être à 0, valeur = %0d", w_LED);
            $finish;
        end
        $display("  PASS: Reset force bien à 0");

        // Test 2: Compteur incrémente avec Switch_1=1 et Switch_2=0
        $display("\n[Test 2] Comptage avec Switch_1=1...");
        r_Switch_2 = 0;  // Désactiver reset
        r_Switch_1 = 1;  // Activer comptage
        repeat(5) @(posedge r_Clk);

        // Attendre 3 incréments
        for (i = 0; i < 3; i = i + 1) begin
            // Attendre le prochain incrément
            repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
        end

        if (w_LED < 2 || w_LED > 4) begin
            $display("  FAIL: Compteur devrait être ~3, valeur = %0d", w_LED);
            $finish;
        end
        $display("  PASS: Compteur incrémente correctement (valeur=%0d)", w_LED);

        // Test 3: Pause avec Switch_1=0
        $display("\n[Test 3] Pause avec Switch_1=0...");
        r_Switch_1 = 0;  // Pause
        repeat(5) @(posedge r_Clk);

        i = w_LED;  // Sauvegarder la valeur
        $display("  Valeur avant pause: %0d", i);

        // Attendre plusieurs périodes
        repeat(TEST_HALF_SECOND * 3) @(posedge r_Clk);

        if (w_LED !== i) begin
            $display("  FAIL: Compteur devrait rester à %0d, valeur = %0d", i, w_LED);
            $finish;
        end
        $display("  PASS: Compteur en pause correctement");

        // Test 4: Reprise du comptage
        $display("\n[Test 4] Reprise après pause...");
        r_Switch_1 = 1;  // Reprendre
        repeat(5) @(posedge r_Clk);

        // Attendre 2 incréments
        repeat((TEST_HALF_SECOND + 5) * 2) @(posedge r_Clk);

        if (w_LED <= i) begin
            $display("  FAIL: Compteur devrait avoir repris, valeur = %0d (avant pause: %0d)", w_LED, i);
            $finish;
        end
        $display("  PASS: Compteur a repris (valeur=%0d)", w_LED);

        // Test 5: Reset a priorité sur enable
        $display("\n[Test 5] Reset prioritaire sur enable...");
        r_Switch_1 = 1;  // Enable
        r_Switch_2 = 1;  // Reset (prioritaire)
        repeat(10) @(posedge r_Clk);

        if (w_LED !== 4'b0000) begin
            $display("  FAIL: Reset devrait avoir priorité, valeur = %0d", w_LED);
            $finish;
        end
        $display("  PASS: Reset a bien priorité sur enable");

        // Test 6: Vérifier wrap-around
        $display("\n[Test 6] Wrap-around 15→0...");
        r_Switch_2 = 0;
        r_Switch_1 = 1;
        repeat(5) @(posedge r_Clk);

        // Attendre que le compteur arrive à 15 puis wrap à 0
        for (i = 0; i < 20; i = i + 1) begin
            if (w_LED == 4'b1111) begin
                $display("  Compteur à 15, attente du wrap...");
                repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
                if (w_LED !== 4'b0000) begin
                    $display("  FAIL: Wrap devrait donner 0, valeur = %0d", w_LED);
                    $finish;
                end
                $display("  PASS: Wrap 15→0 correct");
                i = 20;  // Sortir de la boucle
            end else begin
                repeat(TEST_HALF_SECOND + 5) @(posedge r_Clk);
            end
        end

        $display("\n=== Tous les tests PASS ===");
        $display("Logique validée (sur FPGA: incrément 0.5s avec HALF_SECOND=12_500_000)");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(3000 * 40);  // 3000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
