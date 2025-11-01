// Testbench pour blink_led
// Test du clignotement à 1 Hz (toggle toutes les 0.5s = 12 500 000 cycles)

`timescale 1ns/1ps

module blink_led_tb;

    // Signaux du testbench
    reg r_Clk = 0;
    wire w_LED_1;

    // Valeur de test (50 cycles au lieu de 12.5M pour simulation rapide)
    localparam TEST_HALF_SECOND = 50;

    // Instantiation du module à tester
    blink_led #(
        .HALF_SECOND(TEST_HALF_SECOND)
    ) UUT (
        .i_Clk(r_Clk),
        .o_LED_1(w_LED_1)
    );

    // Génération de l'horloge 25 MHz (période 40 ns)
    always #20 r_Clk = ~r_Clk;

    // Variables pour les tests
    integer cycle_count;
    reg prev_led_state;

    // Test principal
    initial begin
        $dumpfile("blink_led_tb.vcd");
        $dumpvars(0, blink_led_tb);

        $display("=== Test Blink LED ===");
        $display("Horloge: 25 MHz (période 40 ns)");
        $display("Valeur test: LED toggle toutes les %0d cycles", TEST_HALF_SECOND);

        // Test : Vérifier 2 toggles consécutifs
        $display("\n[Test] Vérification période...");

        // Attendre quelques cycles
        repeat(5) @(posedge r_Clk);
        prev_led_state = w_LED_1;
        cycle_count = 0;

        // Premier toggle
        while (w_LED_1 == prev_led_state && cycle_count < (TEST_HALF_SECOND + 10)) begin
            @(posedge r_Clk);
            cycle_count = cycle_count + 1;
        end

        if (cycle_count >= (TEST_HALF_SECOND - 5) && cycle_count <= (TEST_HALF_SECOND + 5)) begin
            $display("  PASS: Premier toggle après %0d cycles (attendu: ~%0d)", cycle_count, TEST_HALF_SECOND);
        end else begin
            $display("  FAIL: Premier toggle après %0d cycles (attendu: ~%0d)", cycle_count, TEST_HALF_SECOND);
            $finish;
        end

        // Deuxième toggle
        prev_led_state = w_LED_1;
        cycle_count = 0;

        while (w_LED_1 == prev_led_state && cycle_count < (TEST_HALF_SECOND + 10)) begin
            @(posedge r_Clk);
            cycle_count = cycle_count + 1;
        end

        if (cycle_count >= (TEST_HALF_SECOND - 5) && cycle_count <= (TEST_HALF_SECOND + 5)) begin
            $display("  PASS: Deuxième toggle après %0d cycles (attendu: ~%0d)", cycle_count, TEST_HALF_SECOND);
        end else begin
            $display("  FAIL: Deuxième toggle après %0d cycles (attendu: ~%0d)", cycle_count, TEST_HALF_SECOND);
            $finish;
        end

        $display("\n=== Tous les tests PASS ===");
        $display("Logique validée (sur FPGA: 1 Hz avec HALF_SECOND=12_500_000)");
        $finish;
    end

    // Timeout de sécurité
    initial begin
        #(1000 * 40);  // 1000 cycles × 40 ns
        $display("\nERROR: Timeout!");
        $finish;
    end

endmodule
