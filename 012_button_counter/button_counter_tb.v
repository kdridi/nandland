// Testbench pour button_counter
// Test du compteur 0-9 contrôlé par boutons avec anti-rebond

`timescale 1ns/1ps

module button_counter_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    reg r_Switch_1 = 0;  // Increment
    reg r_Switch_2 = 0;  // Decrement
    wire [6:0] w_Segments;

    // Valeur de test (50 cycles pour anti-rebond rapide)
    localparam TEST_DEBOUNCE_TIME = 50;

    // Instantiation du module à tester
    button_counter #(
        .DEBOUNCE_TIME(TEST_DEBOUNCE_TIME)
    ) UUT (
        .i_Clk(r_Clk),
        .i_Switch_1(r_Switch_1),
        .i_Switch_2(r_Switch_2),
        .o_Segments(w_Segments)
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Encodages 7 segments attendus (actif bas)
    reg [6:0] expected_segments [0:9];
    initial begin
        expected_segments[0] = ~7'b0111111;
        expected_segments[1] = ~7'b0000110;
        expected_segments[2] = ~7'b1011011;
        expected_segments[3] = ~7'b1001111;
        expected_segments[4] = ~7'b1100110;
        expected_segments[5] = ~7'b1101101;
        expected_segments[6] = ~7'b1111101;
        expected_segments[7] = ~7'b0000111;
        expected_segments[8] = ~7'b1111111;
        expected_segments[9] = ~7'b1101111;
    end

    // Variables
    integer i;

    // Tâche pour simuler un appui avec rebonds
    task press_button_with_bounces;
        input button_num;  // 1 = inc, 2 = dec
        integer j;
        begin
            // Simuler rebonds à l'appui
            for (j = 0; j < 4; j = j + 1) begin
                if (button_num == 1)
                    r_Switch_1 = ~r_Switch_1;
                else
                    r_Switch_2 = ~r_Switch_2;
                repeat(3) @(posedge r_Clk);
            end

            // Maintenir appuyé
            if (button_num == 1)
                r_Switch_1 = 1;
            else
                r_Switch_2 = 1;

            // Attendre que l'anti-rebond se stabilise + marge
            repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);

            // Simuler rebonds au relâchement
            for (j = 0; j < 4; j = j + 1) begin
                if (button_num == 1)
                    r_Switch_1 = ~r_Switch_1;
                else
                    r_Switch_2 = ~r_Switch_2;
                repeat(3) @(posedge r_Clk);
            end

            // Relâcher
            if (button_num == 1)
                r_Switch_1 = 0;
            else
                r_Switch_2 = 0;

            // Attendre stabilisation
            repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);
        end
    endtask

    // Test principal
    initial begin
        $dumpfile("button_counter_tb.vcd");
        $dumpvars(0, button_counter_tb);

        $display("=== Test Button Counter ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Temps anti-rebond: %0d cycles", TEST_DEBOUNCE_TIME);

        // État initial
        repeat(10) @(posedge r_Clk);

        // Test 1: État initial à 0
        $display("\n[Test 1] État initial...");
        if (w_Segments !== expected_segments[0]) begin
            $display("  FAIL: État initial devrait être 0");
            $finish;
        end
        $display("  PASS: État initial = 0");

        // Test 2: Increment 0→1→2→3
        $display("\n[Test 2] Increments avec rebonds (0→1→2→3)...");
        for (i = 0; i < 3; i = i + 1) begin
            press_button_with_bounces(1);  // Inc

            if (w_Segments !== expected_segments[i + 1]) begin
                $display("  FAIL: Valeur devrait être %0d", i + 1);
                $finish;
            end
            $display("  Increment %0d→%0d : OK", i, i + 1);
        end
        $display("  PASS: Increments corrects");

        // Test 3: Decrement 3→2→1→0
        $display("\n[Test 3] Decrements avec rebonds (3→2→1→0)...");
        for (i = 3; i > 0; i = i - 1) begin
            press_button_with_bounces(2);  // Dec

            if (w_Segments !== expected_segments[i - 1]) begin
                $display("  FAIL: Valeur devrait être %0d", i - 1);
                $finish;
            end
            $display("  Decrement %0d→%0d : OK", i, i - 1);
        end
        $display("  PASS: Decrements corrects");

        // Test 4: Wrap increment 9→0
        $display("\n[Test 4] Wrap increment (9→0)...");

        // Aller à 9
        for (i = 0; i < 9; i = i + 1) begin
            press_button_with_bounces(1);
        end

        if (w_Segments !== expected_segments[9]) begin
            $display("  FAIL: Devrait être à 9");
            $finish;
        end
        $display("  Atteint 9");

        // Incrementer pour wrap
        press_button_with_bounces(1);

        if (w_Segments !== expected_segments[0]) begin
            $display("  FAIL: Wrap 9→0 incorrect");
            $finish;
        end
        $display("  PASS: Wrap 9→0 correct");

        // Test 5: Wrap decrement 0→9
        $display("\n[Test 5] Wrap decrement (0→9)...");

        press_button_with_bounces(2);

        if (w_Segments !== expected_segments[9]) begin
            $display("  FAIL: Wrap 0→9 incorrect");
            $finish;
        end
        $display("  PASS: Wrap 0→9 correct");

        // Test 6: Appui maintenu ne doit incrémenter qu'une fois
        $display("\n[Test 6] Appui maintenu (une seule fois)...");

        // Revenir à 0
        press_button_with_bounces(1);  // 9→0

        // Appuyer et maintenir longtemps
        r_Switch_1 = 1;
        repeat(TEST_DEBOUNCE_TIME * 5) @(posedge r_Clk);  // Maintenir 5× le temps de debounce

        if (w_Segments !== expected_segments[1]) begin
            $display("  FAIL: Appui maintenu devrait incrémenter une seule fois");
            $finish;
        end

        r_Switch_1 = 0;
        repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);

        $display("  PASS: Appui maintenu = un seul incrément");

        // Test 7: Appuis simultanés (priorité increment)
        $display("\n[Test 7] Appuis simultanés (priorité Inc)...");

        // Valeur actuelle = 1
        // Appuyer sur les deux en même temps
        r_Switch_1 = 1;
        r_Switch_2 = 1;
        repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);

        // Devrait incrémenter (priorité inc)
        if (w_Segments !== expected_segments[2]) begin
            $display("  FAIL: Priorité increment, devrait être à 2");
            $finish;
        end

        r_Switch_1 = 0;
        r_Switch_2 = 0;
        repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);

        $display("  PASS: Priorité increment correcte");

        // Test 8: Séquence complexe
        $display("\n[Test 8] Séquence complexe...");

        // 2 → +1 → 3
        press_button_with_bounces(1);
        if (w_Segments !== expected_segments[3]) begin
            $display("  FAIL: Devrait être 3");
            $finish;
        end

        // 3 → -1 → 2
        press_button_with_bounces(2);
        if (w_Segments !== expected_segments[2]) begin
            $display("  FAIL: Devrait être 2");
            $finish;
        end

        // 2 → +1 → 3 → +1 → 4
        press_button_with_bounces(1);
        press_button_with_bounces(1);
        if (w_Segments !== expected_segments[4]) begin
            $display("  FAIL: Devrait être 4");
            $finish;
        end

        $display("  PASS: Séquence complexe correcte");

        $display("\n=== Tous les tests PASS ===");
        $display("Compteur avec boutons validé");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(50000 * 40);  // 50000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
