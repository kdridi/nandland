// Testbench pour logic_gates
// Test Driven Development (TDD)

`timescale 1ns/1ps

module logic_gates_tb;

    // Signaux de test
    reg tb_switch_1;  // A
    reg tb_switch_2;  // B

    wire tb_led_1;    // AND
    wire tb_led_2;    // OR
    wire tb_led_3;    // XOR
    wire tb_led_4;    // NOT

    // Instanciation du module à tester
    logic_gates uut (
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
        input expected_and;
        input expected_or;
        input expected_xor;
        input expected_not;
        input [80*8:1] test_name;
        begin
            if (tb_led_1 === expected_and &&
                tb_led_2 === expected_or &&
                tb_led_3 === expected_xor &&
                tb_led_4 === expected_not) begin
                $display("✓ PASS: %0s", test_name);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ FAIL: %0s", test_name);
                $display("  Entrées: A=%b B=%b", tb_switch_1, tb_switch_2);
                $display("  AND: attendu=%b, obtenu=%b", expected_and, tb_led_1);
                $display("  OR:  attendu=%b, obtenu=%b", expected_or, tb_led_2);
                $display("  XOR: attendu=%b, obtenu=%b", expected_xor, tb_led_3);
                $display("  NOT: attendu=%b, obtenu=%b", expected_not, tb_led_4);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    // Séquence de test
    initial begin
        $display("=== Début des tests pour logic_gates ===");
        $display("");
        $display("Table de vérité :");
        $display("A B | AND OR XOR NOT");
        $display("----+---------------");

        // Test 1 : A=0, B=0
        tb_switch_1 = 0; tb_switch_2 = 0;
        #10;
        $display("0 0 |  %b   %b   %b   %b", tb_led_1, tb_led_2, tb_led_3, tb_led_4);
        check_output(0, 0, 0, 1, "A=0, B=0");

        // Test 2 : A=0, B=1
        tb_switch_1 = 0; tb_switch_2 = 1;
        #10;
        $display("0 1 |  %b   %b   %b   %b", tb_led_1, tb_led_2, tb_led_3, tb_led_4);
        check_output(0, 1, 1, 1, "A=0, B=1");

        // Test 3 : A=1, B=0
        tb_switch_1 = 1; tb_switch_2 = 0;
        #10;
        $display("1 0 |  %b   %b   %b   %b", tb_led_1, tb_led_2, tb_led_3, tb_led_4);
        check_output(0, 1, 1, 0, "A=1, B=0");

        // Test 4 : A=1, B=1
        tb_switch_1 = 1; tb_switch_2 = 1;
        #10;
        $display("1 1 |  %b   %b   %b   %b", tb_led_1, tb_led_2, tb_led_3, tb_led_4);
        check_output(1, 1, 0, 0, "A=1, B=1");

        // Tests individuels des portes
        $display("");
        $display("Tests individuels des portes :");

        // Tests spécifiques pour AND
        tb_switch_1 = 1; tb_switch_2 = 1; #10;
        if (tb_led_1 == 1)
            $display("✓ PASS: AND gate avec 1 AND 1 = 1");
        else begin
            $display("✗ FAIL: AND gate");
            tests_failed = tests_failed + 1;
        end
        tests_passed = tests_passed + 1;

        // Tests spécifiques pour OR
        tb_switch_1 = 0; tb_switch_2 = 1; #10;
        if (tb_led_2 == 1) begin
            $display("✓ PASS: OR gate avec 0 OR 1 = 1");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: OR gate");
            tests_failed = tests_failed + 1;
        end

        // Tests spécifiques pour XOR
        tb_switch_1 = 1; tb_switch_2 = 0; #10;
        if (tb_led_3 == 1) begin
            $display("✓ PASS: XOR gate avec 1 XOR 0 = 1");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: XOR gate");
            tests_failed = tests_failed + 1;
        end

        tb_switch_1 = 1; tb_switch_2 = 1; #10;
        if (tb_led_3 == 0) begin
            $display("✓ PASS: XOR gate avec 1 XOR 1 = 0");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: XOR gate (identiques)");
            tests_failed = tests_failed + 1;
        end

        // Tests spécifiques pour NOT
        tb_switch_1 = 0; #10;
        if (tb_led_4 == 1) begin
            $display("✓ PASS: NOT gate avec NOT 0 = 1");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: NOT gate");
            tests_failed = tests_failed + 1;
        end

        tb_switch_1 = 1; #10;
        if (tb_led_4 == 0) begin
            $display("✓ PASS: NOT gate avec NOT 1 = 0");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: NOT gate (inversion)");
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
        $dumpfile("logic_gates.vcd");
        $dumpvars(0, logic_gates_tb);
    end

endmodule
