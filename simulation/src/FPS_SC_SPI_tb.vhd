library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;
use work.FPS_SlowControl.all;

-- ENTITY ----------------------------------------------------

entity FPS_SC_SPI_tb is
end FPS_SC_SPI_tb;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_SPI_tb is
-- Constants -------------------------------------------------
-- Types -----------------------------------------------------		
-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------

	signal x_nreset  : std_logic;
	signal x_clk     : std_logic;
	signal x_start   : std_logic;
	signal x_reg 	 : std_logic_vector(19 downto 0);
	signal x_clk_SPI : std_logic;
   	signal x_CS 	 : std_logic;
   	signal x_mosi 	 : std_logic;
   	signal x_ack 	 : std_logic;

  ----------------------------------------------
  -- Procedure
  -- Components ------------------------------------------------

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	FPS_SC_SPI_DUT : FPS_SC_SPI
	generic map (x_reset_active => '0')
	port map(
			x_nreset 	=> x_nreset,
   			x_clk   	=> x_clk,
   			x_start 	=> x_start,
   			x_reg 		=> x_reg,
   			x_clk_SPI 	=> x_clk_SPI,
   			x_CS 		=> x_CS,
   			x_mosi 		=> x_mosi,
   			x_ack 		=> x_ack
		);

	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	p_clk : process  --50MHz
	begin
		x_clk <= '1';
		wait for 10 ns;
		x_clk <= '0';
		wait for 10 ns;
	end process;

	p_testbench : PROCESS
	begin
		x_nreset <= '0';
		x_reg <= "11001100011110001110";
		x_start <= '0';

		wait for 50 ns;
		report "starting test x_ reg = 11001100011110001110 ... " & time'image(now);
		x_nreset <= '1';
		x_start <= '1';

		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(19)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(19)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(18)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(18)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(17)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(17)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(16)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(16)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(15)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(15)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(14)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(14)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(13)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(13)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(12)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(12)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(11)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(11)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(10)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(10)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(9)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(9)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(8)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(8)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(7)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(7)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(6)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(6)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(5)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(5)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(4)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(4)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(3)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(3)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(2)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(2)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(1)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(1)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(0)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(0)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;

		wait until x_ack = '1';
		wait until x_ack = '0';
		x_start <= '0';

		wait until x_clk = '1';
		report "change x_ reg to 11111111111100000101 ... " & time'image(now);
		x_reg <= "11111111111100000101";
		x_start <= '1';

		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(19)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(19)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(18)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(18)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(17)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(17)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(16)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(16)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(15)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(15)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(14)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(14)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(13)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(13)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(12)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(12)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(11)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(11)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(10)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(10)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(9)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(9)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(8)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(8)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(7)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(7)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(6)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(6)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(5)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(5)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(4)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(4)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(3)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(3)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(2)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(2)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(1)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(1)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;
		wait until x_clk_SPI = '1';
		assert (x_mosi = x_reg(0)) report "Error checking x_mosi (expect 0b" & to_string(x_reg(0)) & "; read 0b" & to_string(x_mosi) & ")" severity failure;

		wait until x_ack = '1';
		wait until x_ack = '0';
		x_start <= '0';
		----------------------------------------------------
		report "TEST SUCCESSFULL ... " & time'image(now);
		---------------------------------------------------
		wait; -- will wait forever
	end process;

end rtl;