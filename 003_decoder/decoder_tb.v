// Testbench pour decoder
// Test Driven Development (TDD)

`timescale 1ns/1ps

module decoder_tb;

    // Signaux de test
    reg tb_switch_1;  // code[0]
    reg tb_switch_2;  // code[1]

    wire tb_led_1;    // Sortie 0 (code=00)
    wire tb_led_2;    // Sortie 1 (code=01)
    wire tb_led_3;    // Sortie 2 (code=10)
    wire tb_led_4;    // Sortie 3 (code=11)

    // Instanciation du module à tester
    decoder uut (
        .i_Switch_1(tb_switch_1),
        .i_Switch_2(tb_switch_2),
        .o_LED_1(tb_led_1),
        .o_LED_2(tb_led_2),
        .o_LED_3(tb_led_3),
        .o_LED_4(tb_led_4)
    );

    // Compteur de tests réussis/échoués
    integer tests_passed = 0;
    integer tests_failed = 0;

    // Tâche pour vérifier un résultat
    task check_output;
        input [1:0] code;
        input [3:0] expected_leds;
        input [80*8:1] test_name;
        begin
            if ({tb_led_4, tb_led_3, tb_led_2, tb_led_1} === expected_leds) begin
                $display("✓ PASS: %0s", test_name);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ FAIL: %0s", test_name);
                $display("  Code: code[1:0]=%b%b", tb_switch_2, tb_switch_1);
                $display("  LEDs attendues: %b", expected_leds);
                $display("  LEDs obtenues:  %b", {tb_led_4, tb_led_3, tb_led_2, tb_led_1});
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    // Séquence de test
    initial begin
        $display("=== Début des tests pour decoder 2→4 ===");
        $display("");
        $display("Le décodeur active une seule sortie selon le code binaire");
        $display("");
        $display("Table de vérité du décodeur :");
        $display("code[1] code[0] | LED_4 LED_3 LED_2 LED_1");
        $display("----------------|------------------------");

        // Test 1 : code=00 → LED_1 active
        tb_switch_1 = 0; tb_switch_2 = 0;
        #10;
        $display("   0       0    |   %b     %b     %b     %b", tb_led_4, tb_led_3, tb_led_2, tb_led_1);
        check_output(2'b00, 4'b0001, "code=00 → LED_1 active (0001)");

        // Test 2 : code=01 → LED_2 active
        tb_switch_1 = 1; tb_switch_2 = 0;
        #10;
        $display("   0       1    |   %b     %b     %b     %b", tb_led_4, tb_led_3, tb_led_2, tb_led_1);
        check_output(2'b01, 4'b0010, "code=01 → LED_2 active (0010)");

        // Test 3 : code=10 → LED_3 active
        tb_switch_1 = 0; tb_switch_2 = 1;
        #10;
        $display("   1       0    |   %b     %b     %b     %b", tb_led_4, tb_led_3, tb_led_2, tb_led_1);
        check_output(2'b10, 4'b0100, "code=10 → LED_3 active (0100)");

        // Test 4 : code=11 → LED_4 active
        tb_switch_1 = 1; tb_switch_2 = 1;
        #10;
        $display("   1       1    |   %b     %b     %b     %b", tb_led_4, tb_led_3, tb_led_2, tb_led_1);
        check_output(2'b11, 4'b1000, "code=11 → LED_4 active (1000)");

        // Tests supplémentaires de validation
        $display("");
        $display("Tests de validation (une seule LED active) :");

        // Vérifier qu'une seule LED est active pour code=00
        tb_switch_1 = 0; tb_switch_2 = 0; #10;
        if ((tb_led_1 == 1) && (tb_led_2 == 0) && (tb_led_3 == 0) && (tb_led_4 == 0)) begin
            $display("✓ PASS: Code 00 - Une seule LED active (LED_1)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: Code 00 - Plusieurs LEDs actives ou mauvaise LED");
            tests_failed = tests_failed + 1;
        end

        // Vérifier qu'une seule LED est active pour code=01
        tb_switch_1 = 1; tb_switch_2 = 0; #10;
        if ((tb_led_1 == 0) && (tb_led_2 == 1) && (tb_led_3 == 0) && (tb_led_4 == 0)) begin
            $display("✓ PASS: Code 01 - Une seule LED active (LED_2)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: Code 01 - Plusieurs LEDs actives ou mauvaise LED");
            tests_failed = tests_failed + 1;
        end

        // Vérifier qu'une seule LED est active pour code=10
        tb_switch_1 = 0; tb_switch_2 = 1; #10;
        if ((tb_led_1 == 0) && (tb_led_2 == 0) && (tb_led_3 == 1) && (tb_led_4 == 0)) begin
            $display("✓ PASS: Code 10 - Une seule LED active (LED_3)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: Code 10 - Plusieurs LEDs actives ou mauvaise LED");
            tests_failed = tests_failed + 1;
        end

        // Vérifier qu'une seule LED est active pour code=11
        tb_switch_1 = 1; tb_switch_2 = 1; #10;
        if ((tb_led_1 == 0) && (tb_led_2 == 0) && (tb_led_3 == 0) && (tb_led_4 == 1)) begin
            $display("✓ PASS: Code 11 - Une seule LED active (LED_4)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: Code 11 - Plusieurs LEDs actives ou mauvaise LED");
            tests_failed = tests_failed + 1;
        end

        // Test de parcours complet
        $display("");
        $display("Test de parcours complet (00→01→10→11) :");
        tb_switch_1 = 0; tb_switch_2 = 0; #10;
        if (tb_led_1 == 1 && tb_led_2 == 0 && tb_led_3 == 0 && tb_led_4 == 0) begin
            tb_switch_1 = 1; tb_switch_2 = 0; #10;
            if (tb_led_1 == 0 && tb_led_2 == 1 && tb_led_3 == 0 && tb_led_4 == 0) begin
                tb_switch_1 = 0; tb_switch_2 = 1; #10;
                if (tb_led_1 == 0 && tb_led_2 == 0 && tb_led_3 == 1 && tb_led_4 == 0) begin
                    tb_switch_1 = 1; tb_switch_2 = 1; #10;
                    if (tb_led_1 == 0 && tb_led_2 == 0 && tb_led_3 == 0 && tb_led_4 == 1) begin
                        $display("✓ PASS: Parcours complet réussi (LED se déplace 1→2→3→4)");
                        tests_passed = tests_passed + 1;
                    end else begin
                        $display("✗ FAIL: Parcours échoué à l'étape 11");
                        tests_failed = tests_failed + 1;
                    end
                end else begin
                    $display("✗ FAIL: Parcours échoué à l'étape 10");
                    tests_failed = tests_failed + 1;
                end
            end else begin
                $display("✗ FAIL: Parcours échoué à l'étape 01");
                tests_failed = tests_failed + 1;
            end
        end else begin
            $display("✗ FAIL: Parcours échoué à l'étape 00");
            tests_failed = tests_failed + 1;
        end

        // Résumé des tests
        $display("");
        $display("=== Résumé des tests ===");
        $display("Tests réussis : %0d", tests_passed);
        $display("Tests échoués : %0d", tests_failed);

        if (tests_failed == 0) begin
            $display("");
            $display("✓ Tous les tests sont passés !");
            $display("Vous pouvez maintenant lancer 'make build' puis 'make flash'");
        end else begin
            $display("");
            $display("✗ Certains tests ont échoué. Corrigez le code avant de flasher.");
        end

        $finish;
    end

    // Génération du fichier VCD pour visualisation (optionnel)
    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_tb);
    end

endmodule
