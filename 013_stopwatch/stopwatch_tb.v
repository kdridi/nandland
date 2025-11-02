// Testbench pour stopwatch
// Test du chronomètre 00-99 avec Start/Stop et Reset

`timescale 1ns/1ps

module stopwatch_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    reg r_Switch_1 = 0;  // Start/Stop
    reg r_Switch_2 = 0;  // Reset
    wire [6:0] w_Segments1;  // Dizaines
    wire [6:0] w_Segments2;  // Unités

    // Valeurs de test
    localparam TEST_DEBOUNCE_TIME = 50;
    localparam TEST_CENTISECOND = 100;  // 100 cycles au lieu de 250_000

    // Instantiation du module à tester
    stopwatch #(
        .DEBOUNCE_TIME(TEST_DEBOUNCE_TIME),
        .CENTISECOND(TEST_CENTISECOND)
    ) UUT (
        .i_Clk(r_Clk),
        .i_Switch_1(r_Switch_1),
        .i_Switch_2(r_Switch_2),
        .o_Segments1(w_Segments1),
        .o_Segments2(w_Segments2)
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
    integer tens, units;

    // Tâche pour appuyer sur un bouton avec anti-rebond
    task press_button;
        input button_num;  // 1 = start/stop, 2 = reset
        integer j;
        begin
            // Simuler rebonds
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
            repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);

            // Relâcher avec rebonds
            for (j = 0; j < 4; j = j + 1) begin
                if (button_num == 1)
                    r_Switch_1 = ~r_Switch_1;
                else
                    r_Switch_2 = ~r_Switch_2;
                repeat(3) @(posedge r_Clk);
            end

            if (button_num == 1)
                r_Switch_1 = 0;
            else
                r_Switch_2 = 0;
            repeat(TEST_DEBOUNCE_TIME + 20) @(posedge r_Clk);
        end
    endtask

    // Tâche pour lire la valeur affichée
    task read_display;
        output integer value;
        integer t, u;
        begin
            // Trouver les dizaines
            for (t = 0; t <= 9; t = t + 1) begin
                if (w_Segments1 == expected_segments[t])
                    tens = t;
            end

            // Trouver les unités
            for (u = 0; u <= 9; u = u + 1) begin
                if (w_Segments2 == expected_segments[u])
                    units = u;
            end

            value = tens * 10 + units;
        end
    endtask

    // Test principal
    initial begin
        $dumpfile("stopwatch_tb.vcd");
        $dumpvars(0, stopwatch_tb);

        $display("=== Test Stopwatch ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Temps anti-rebond: %0d cycles", TEST_DEBOUNCE_TIME);
        $display("Centiseconde: %0d cycles", TEST_CENTISECOND);

        // État initial
        repeat(10) @(posedge r_Clk);

        // Test 1: État initial IDLE à 00
        $display("\n[Test 1] État initial...");
        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: État initial devrait être 00");
            $finish;
        end
        $display("  PASS: État initial = 00");

        // Test 2: Start démarre le comptage
        $display("\n[Test 2] Start démarre le comptage...");
        press_button(1);  // Start

        // Attendre quelques incréments
        repeat((TEST_CENTISECOND + 10) * 5) @(posedge r_Clk);

        read_display(i);
        if (i < 4) begin
            $display("  FAIL: Chrono devrait avoir compté (valeur=%0d)", i);
            $finish;
        end
        $display("  Valeur après start: %02d", i);
        $display("  PASS: Chrono a démarré");

        // Test 3: Stop met en pause
        $display("\n[Test 3] Stop met en pause...");
        press_button(1);  // Stop

        read_display(i);
        $display("  Valeur à la pause: %02d", i);

        // Attendre plusieurs périodes
        repeat((TEST_CENTISECOND + 10) * 5) @(posedge r_Clk);

        read_display(tens);
        if (tens != i) begin
            $display("  FAIL: Chrono devrait être en pause (était %02d, maintenant %02d)", i, tens);
            $finish;
        end
        $display("  PASS: Chrono en pause à %02d", i);

        // Test 4: Resume continue
        $display("\n[Test 4] Resume continue depuis la pause...");
        press_button(1);  // Resume

        // Attendre quelques incréments
        repeat((TEST_CENTISECOND + 10) * 3) @(posedge r_Clk);

        read_display(tens);
        if (tens <= i) begin
            $display("  FAIL: Chrono devrait avoir continué (était %02d, maintenant %02d)", i, tens);
            $finish;
        end
        $display("  Valeur après resume: %02d", tens);
        $display("  PASS: Chrono a repris");

        // Test 5: Reset remet à 00
        $display("\n[Test 5] Reset remet à 00...");
        press_button(2);  // Reset

        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Reset devrait remettre à 00");
            $finish;
        end
        $display("  PASS: Reset correct à 00");

        // Test 6: Après reset, le chrono ne compte pas
        $display("\n[Test 6] Après reset, chrono arrêté...");
        repeat((TEST_CENTISECOND + 10) * 3) @(posedge r_Clk);

        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Chrono ne devrait pas compter après reset");
            $finish;
        end
        $display("  PASS: Chrono arrêté après reset");

        // Test 7: Wrap 99→00
        $display("\n[Test 7] Wrap 99→00...");
        press_button(1);  // Start

        // Attendre d'atteindre au moins 98
        read_display(i);
        while (i < 98) begin
            @(posedge r_Clk);
            read_display(i);
        end
        $display("  Atteint %02d", i);

        // Attendre le wrap
        read_display(i);
        while (i != 0) begin
            @(posedge r_Clk);
            read_display(i);
            if (i > 99) begin
                $display("  FAIL: Dépassement de 99");
                $finish;
            end
        end
        $display("  PASS: Wrap 99→00 correct");

        // Arrêter le chrono après test 7
        press_button(1);  // Stop

        // Test 8: Séquence complète
        $display("\n[Test 8] Séquence Start→Stop→Resume→Reset...");

        // Reset
        press_button(2);
        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Reset initial");
            $finish;
        end

        // Start
        press_button(1);
        repeat((TEST_CENTISECOND + 10) * 3) @(posedge r_Clk);
        read_display(i);
        if (i < 2) begin
            $display("  FAIL: Start");
            $finish;
        end

        // Stop
        read_display(tens);  // Lire avant d'appuyer
        press_button(1);     // Appuyer sur Stop

        // Attendre quelques cycles après le press pour que le stop soit effectif
        repeat(20) @(posedge r_Clk);
        read_display(units);  // Lire la valeur juste après le stop

        // Attendre et vérifier que ça ne bouge plus
        repeat((TEST_CENTISECOND + 10) * 3) @(posedge r_Clk);
        read_display(i);
        if (i != units) begin
            $display("  FAIL: Stop (avant=%02d, juste après=%02d, maintenant=%02d)", tens, units, i);
            $finish;
        end

        // Resume
        i = units;  // Sauvegarder la valeur arrêtée
        press_button(1);
        repeat((TEST_CENTISECOND + 10) * 3) @(posedge r_Clk);
        read_display(tens);
        if (tens <= i) begin
            $display("  FAIL: Resume (était %02d, maintenant %02d)", i, tens);
            $finish;
        end

        // Reset
        press_button(2);
        if (w_Segments1 !== expected_segments[0] || w_Segments2 !== expected_segments[0]) begin
            $display("  FAIL: Reset final");
            $finish;
        end

        $display("  PASS: Séquence complète correcte");

        $display("\n=== Tous les tests PASS ===");
        $display("Chronomètre validé");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(100000 * 40);  // 100000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
