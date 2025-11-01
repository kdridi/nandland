// Testbench pour multiplexer
// Test Driven Development (TDD)

`timescale 1ns/1ps

module multiplexer_tb;

    // Signaux de test
    reg tb_switch_1;  // sel[0]
    reg tb_switch_2;  // sel[1]

    wire tb_led_1;    // Sortie du mux
    wire tb_led_2;    // Écho sel[0]
    wire tb_led_3;    // Écho sel[1]
    wire tb_led_4;    // Inverse sortie

    // Instanciation du module à tester
    multiplexer uut (
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
        input [1:0] sel;
        input expected_out;
        input [80*8:1] test_name;
        begin
            if (tb_led_1 === expected_out &&
                tb_led_2 === sel[0] &&
                tb_led_3 === sel[1] &&
                tb_led_4 === ~expected_out) begin
                $display("✓ PASS: %0s", test_name);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ FAIL: %0s", test_name);
                $display("  Sélecteur: sel[1:0]=%b%b", tb_switch_2, tb_switch_1);
                $display("  Sortie mux: attendu=%b, obtenu=%b", expected_out, tb_led_1);
                $display("  LED_2 (sel[0]): attendu=%b, obtenu=%b", sel[0], tb_led_2);
                $display("  LED_3 (sel[1]): attendu=%b, obtenu=%b", sel[1], tb_led_3);
                $display("  LED_4 (NOT): attendu=%b, obtenu=%b", ~expected_out, tb_led_4);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    // Séquence de test
    initial begin
        $display("=== Début des tests pour multiplexer 4→1 ===");
        $display("");
        $display("Données câblées : data[3:0] = 4'b1010");
        $display("  data[0] = 0");
        $display("  data[1] = 1");
        $display("  data[2] = 0");
        $display("  data[3] = 1");
        $display("");
        $display("Table de vérité du multiplexeur :");
        $display("sel[1] sel[0] | LED_1 (sortie)");
        $display("--------------|---------------");

        // Test 1 : sel=00 → data[0]=0
        tb_switch_1 = 0; tb_switch_2 = 0;
        #10;
        $display("   0      0    |       %b", tb_led_1);
        check_output(2'b00, 1'b0, "sel=00 → data[0]=0");

        // Test 2 : sel=01 → data[1]=1
        tb_switch_1 = 1; tb_switch_2 = 0;
        #10;
        $display("   0      1    |       %b", tb_led_1);
        check_output(2'b01, 1'b1, "sel=01 → data[1]=1");

        // Test 3 : sel=10 → data[2]=0
        tb_switch_1 = 0; tb_switch_2 = 1;
        #10;
        $display("   1      0    |       %b", tb_led_1);
        check_output(2'b10, 1'b0, "sel=10 → data[2]=0");

        // Test 4 : sel=11 → data[3]=1
        tb_switch_1 = 1; tb_switch_2 = 1;
        #10;
        $display("   1      1    |       %b", tb_led_1);
        check_output(2'b11, 1'b1, "sel=11 → data[3]=1");

        // Tests supplémentaires de vérification
        $display("");
        $display("Tests de vérification des échos :");

        // Vérifier que LED_2 et LED_3 suivent bien les switches
        tb_switch_1 = 1; tb_switch_2 = 0; #10;
        if (tb_led_2 == 1 && tb_led_3 == 0) begin
            $display("✓ PASS: Échos des switches (LED_2=1, LED_3=0)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: Échos des switches");
            tests_failed = tests_failed + 1;
        end

        // Vérifier que LED_4 est bien l'inverse de LED_1
        tb_switch_1 = 1; tb_switch_2 = 0; #10;  // sel=01 → data[1]=1
        if (tb_led_1 == 1 && tb_led_4 == 0) begin
            $display("✓ PASS: LED_4 inverse de LED_1 (1→0)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: LED_4 pas l'inverse de LED_1");
            tests_failed = tests_failed + 1;
        end

        tb_switch_1 = 0; tb_switch_2 = 0; #10;  // sel=00 → data[0]=0
        if (tb_led_1 == 0 && tb_led_4 == 1) begin
            $display("✓ PASS: LED_4 inverse de LED_1 (0→1)");
            tests_passed = tests_passed + 1;
        end else begin
            $display("✗ FAIL: LED_4 pas l'inverse de LED_1");
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
        $dumpfile("multiplexer.vcd");
        $dumpvars(0, multiplexer_tb);
    end

endmodule
