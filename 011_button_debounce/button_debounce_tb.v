// Testbench pour button_debounce
// Test de l'anti-rebond pour filtrer les rebonds mécaniques

`timescale 1ns/1ps

module button_debounce_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    reg r_Switch_1 = 0;
    wire w_LED_1;

    // Valeur de test (50 cycles pour simulation rapide)
    localparam TEST_DEBOUNCE_TIME = 50;

    // Instantiation du module à tester
    button_debounce #(
        .DEBOUNCE_TIME(TEST_DEBOUNCE_TIME)
    ) UUT (
        .i_Clk(r_Clk),
        .i_Switch_1(r_Switch_1),
        .o_LED_1(w_LED_1)
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Variables pour les tests
    integer i;

    // Tâche pour simuler des rebonds
    task simulate_bounces;
        input integer num_bounces;
        integer j;
        begin
            for (j = 0; j < num_bounces; j = j + 1) begin
                r_Switch_1 = ~r_Switch_1;
                repeat(5) @(posedge r_Clk);  // Rebonds courts (~200 ns)
            end
        end
    endtask

    // Tâche pour attendre un nombre de cycles
    task wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge r_Clk);
        end
    endtask

    // Test principal
    initial begin
        $dumpfile("button_debounce_tb.vcd");
        $dumpvars(0, button_debounce_tb);

        $display("=== Test Button Debounce ===" );
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Temps anti-rebond: %0d cycles", TEST_DEBOUNCE_TIME);

        // Test 1: État initial
        $display("\n[Test 1] État initial...");
        repeat(10) @(posedge r_Clk);

        if (w_LED_1 !== 0) begin
            $display("  FAIL: État initial devrait être 0");
            $finish;
        end
        $display("  PASS: État initial = 0");

        // Test 2: Rebonds courts (doivent être filtrés)
        $display("\n[Test 2] Rebonds courts (< %0d cycles)...", TEST_DEBOUNCE_TIME);
        r_Switch_1 = 0;
        wait_cycles(10);

        // Simuler des rebonds rapides
        simulate_bounces(6);  // 6 rebonds de ~5 cycles chacun

        // Attendre un peu
        wait_cycles(10);

        // Le signal filtré devrait toujours être à 0
        if (w_LED_1 !== 0) begin
            $display("  FAIL: Rebonds courts devraient être filtrés");
            $finish;
        end
        $display("  PASS: Rebonds courts filtrés correctement");

        // Test 3: Transition stable (0→1)
        $display("\n[Test 3] Transition stable 0→1...");
        r_Switch_1 = 0;
        wait_cycles(10);

        // Appui avec rebonds initiaux
        simulate_bounces(4);

        // Maintenir le signal stable
        r_Switch_1 = 1;
        wait_cycles(TEST_DEBOUNCE_TIME + 10);

        if (w_LED_1 !== 1) begin
            $display("  FAIL: Signal devrait être à 1 après transition stable");
            $finish;
        end
        $display("  PASS: Transition 0→1 correcte");

        // Test 4: Signal reste stable
        $display("\n[Test 4] Maintien de l'état stable...");
        wait_cycles(TEST_DEBOUNCE_TIME * 2);

        if (w_LED_1 !== 1) begin
            $display("  FAIL: Signal devrait rester à 1");
            $finish;
        end
        $display("  PASS: État stable maintenu");

        // Test 5: Transition stable (1→0)
        $display("\n[Test 5] Transition stable 1→0...");

        // Relâchement avec rebonds
        simulate_bounces(4);

        // Maintenir le signal stable
        r_Switch_1 = 0;
        wait_cycles(TEST_DEBOUNCE_TIME + 10);

        if (w_LED_1 !== 0) begin
            $display("  FAIL: Signal devrait être à 0 après transition stable");
            $finish;
        end
        $display("  PASS: Transition 1→0 correcte");

        // Test 6: Appuis multiples avec rebonds
        $display("\n[Test 6] Appuis multiples avec rebonds...");

        for (i = 0; i < 3; i = i + 1) begin
            // Appui avec rebonds
            simulate_bounces(4);
            r_Switch_1 = 1;
            wait_cycles(TEST_DEBOUNCE_TIME + 10);

            if (w_LED_1 !== 1) begin
                $display("  FAIL: Appui %0d non détecté", i + 1);
                $finish;
            end

            // Relâchement avec rebonds
            simulate_bounces(4);
            r_Switch_1 = 0;
            wait_cycles(TEST_DEBOUNCE_TIME + 10);

            if (w_LED_1 !== 0) begin
                $display("  FAIL: Relâchement %0d non détecté", i + 1);
                $finish;
            end

            $display("  Appui %0d: OK", i + 1);
        end
        $display("  PASS: Appuis multiples corrects");

        // Test 7: Changement très rapide (doit être ignoré)
        $display("\n[Test 7] Glitch très court (doit être ignoré)...");
        r_Switch_1 = 0;
        wait_cycles(TEST_DEBOUNCE_TIME + 10);

        // Pulse très court
        r_Switch_1 = 1;
        wait_cycles(3);
        r_Switch_1 = 0;
        wait_cycles(TEST_DEBOUNCE_TIME + 10);

        if (w_LED_1 !== 0) begin
            $display("  FAIL: Glitch court devrait être ignoré");
            $finish;
        end
        $display("  PASS: Glitch court ignoré");

        // Test 8: Transition interrompue
        $display("\n[Test 8] Transition interrompue...");
        r_Switch_1 = 0;
        wait_cycles(10);

        // Commencer une transition
        r_Switch_1 = 1;
        wait_cycles(TEST_DEBOUNCE_TIME / 2);  // Attendre seulement la moitié

        // Interrompre avant la fin du temps de debounce
        r_Switch_1 = 0;
        wait_cycles(TEST_DEBOUNCE_TIME + 10);

        if (w_LED_1 !== 0) begin
            $display("  FAIL: Transition interrompue devrait être annulée");
            $finish;
        end
        $display("  PASS: Transition interrompue correctement gérée");

        $display("\n=== Tous les tests PASS ===");
        $display("Anti-rebond validé (sur FPGA: 10ms avec DEBOUNCE_TIME=250_000)");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(20000 * 40);  // 20000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
