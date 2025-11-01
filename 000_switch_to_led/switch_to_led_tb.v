// Testbench pour switch_to_led
// Test Driven Development (TDD)

`timescale 1ns/1ps

module switch_to_led_tb;

    // Signaux de test
    reg tb_switch_1;
    reg tb_switch_2;
    reg tb_switch_3;
    reg tb_switch_4;

    wire tb_led_1;
    wire tb_led_2;
    wire tb_led_3;
    wire tb_led_4;

    // Instanciation du module à tester
    switch_to_led uut (
        .i_Switch_1(tb_switch_1),
        .i_Switch_2(tb_switch_2),
        .i_Switch_3(tb_switch_3),
        .i_Switch_4(tb_switch_4),
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
        input [3:0] expected_leds;
        input [3:0] actual_leds;
        input [80*8:1] test_name;
        begin
            if (expected_leds === actual_leds) begin
                $display("✓ PASS: %0s", test_name);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ FAIL: %0s", test_name);
                $display("  Attendu: %b, Obtenu: %b", expected_leds, actual_leds);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    // Séquence de test
    initial begin
        $display("=== Début des tests pour switch_to_led ===");
        $display("");

        // Test 1 : Tous les switches à 0
        tb_switch_1 = 0; tb_switch_2 = 0; tb_switch_3 = 0; tb_switch_4 = 0;
        #10;
        check_output(4'b0000, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Tous les switches OFF");

        // Test 2 : Tous les switches à 1
        tb_switch_1 = 1; tb_switch_2 = 1; tb_switch_3 = 1; tb_switch_4 = 1;
        #10;
        check_output(4'b1111, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Tous les switches ON");

        // Test 3 : Switch 1 uniquement
        tb_switch_1 = 1; tb_switch_2 = 0; tb_switch_3 = 0; tb_switch_4 = 0;
        #10;
        check_output(4'b1000, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Switch 1 ON seulement");

        // Test 4 : Switch 2 uniquement
        tb_switch_1 = 0; tb_switch_2 = 1; tb_switch_3 = 0; tb_switch_4 = 0;
        #10;
        check_output(4'b0100, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Switch 2 ON seulement");

        // Test 5 : Switch 3 uniquement
        tb_switch_1 = 0; tb_switch_2 = 0; tb_switch_3 = 1; tb_switch_4 = 0;
        #10;
        check_output(4'b0010, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Switch 3 ON seulement");

        // Test 6 : Switch 4 uniquement
        tb_switch_1 = 0; tb_switch_2 = 0; tb_switch_3 = 0; tb_switch_4 = 1;
        #10;
        check_output(4'b0001, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Switch 4 ON seulement");

        // Test 7 : Pattern alterné 1010
        tb_switch_1 = 1; tb_switch_2 = 0; tb_switch_3 = 1; tb_switch_4 = 0;
        #10;
        check_output(4'b1010, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Pattern 1010");

        // Test 8 : Pattern alterné 0101
        tb_switch_1 = 0; tb_switch_2 = 1; tb_switch_3 = 0; tb_switch_4 = 1;
        #10;
        check_output(4'b0101, {tb_led_1, tb_led_2, tb_led_3, tb_led_4}, "Pattern 0101");

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
        $dumpfile("switch_to_led.vcd");
        $dumpvars(0, switch_to_led_tb);
    end

endmodule
